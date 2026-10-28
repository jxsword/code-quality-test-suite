#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# go/run-tests.sh —— gofmt（格式）+ golangci-lint（命名 revive / Lint govet+staticcheck）正/反用例实测
# 离线可用：gofmt 随 Go 工具链；golangci-lint 缺失时尝试 go install（GOTOOLCHAIN=auto 自动拉新版 toolchain，
# 预算 8 分钟）；仍缺则命名/Lint 用例降级 warn 不阻断，预期输出见 docs/lint-test-results/go.md，CI 回填。
# 版本锁：Go 1.27（CI）/ golangci-lint v2.15.0（2026-10-16 已查证）；本机实测 go1.23.0 + go1.26.10 toolchain 编译的 v2.15.0。
set -euo pipefail
cd "$(dirname "$0")"

export LANG_NAME="Go"
export TOOLCHAIN="gofmt + golangci-lint v2.15.0"
# shellcheck source=scripts/common.sh
source ../scripts/common.sh

# 1. 安装 / 确认工具链
if ! tool_require "go/gofmt" "gofmt"; then
    summary_finalize
    exit 0
fi
GOPATH_BIN="$(go env GOPATH)/bin"
if ! command -v golangci-lint > /dev/null 2>&1 && [ -x "$GOPATH_BIN/golangci-lint" ]; then
    export PATH="$GOPATH_BIN:$PATH"
fi
if ! command -v golangci-lint > /dev/null 2>&1; then
    echo "[..] 未找到 golangci-lint，尝试 go install（预算 8 分钟）..."
    GOTOOLCHAIN=auto timeout 480 go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.15.0 || true
    export PATH="$GOPATH_BIN:$PATH"
fi

# 2. 正面用例：gofmt 检查（预期 PASS；gofmt -l 有输出=违规，无输出=合规）
run_ok "case-ok-1" "src/greeter/ 通过 gofmt -l（无输出=合规）" \
    bash -c "gofmt -l src/ | grep -q . && exit 1 || exit 0"

# 3. 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.go cases/bad-naming.go cases/bad-lint-printf.go "$WORK/"

# 4. 反面用例 1：格式违规（gofmt -l 列出文件 → gofmt -w 修复 → 复查无输出）
run_fail "case-bad-1" "格式违规：参数间缺空格、括号紧贴，gofmt -l 列出本文件" "格式" \
    bash -c "gofmt -l \"$WORK/bad-format.go\" | grep -q . && exit 1 || exit 0"
run_fix "case-bad-1" "gofmt -w 自动重排后通过" \
    bash -c "cd $WORK && gofmt -w bad-format.go && gofmt -l bad-format.go | grep -q . && exit 1 || exit 0"

# 5. golangci-lint：命名 / Lint 用例（缺失则降级 warn，CI 回填）
if tool_require "golangci-lint" "golangci-lint"; then
    TOOLCHAIN="gofmt + golangci-lint $(golangci-lint --version | awk '{print $4}')"

    # 正面用例：golangci-lint 全规则
    run_ok "case-ok-2" "src/greeter/ 通过 golangci-lint run（revive+staticcheck+govet）" \
        golangci-lint run src/...

    # 反面用例 2：命名违规（revive var-naming，不可自动修复）
    run_fail "case-bad-2" "命名违规：参数 userUrl 的 initialism 应为 userURL（revive var-naming）" "命名" \
        golangci-lint run "$WORK/bad-naming.go"
    run_fix "case-bad-2" "手工重命名 userURL（命名规则不可自动修复）" \
        bash -c "cp cases/bad-naming.fixed.go $WORK/bad-naming.go && golangci-lint run $WORK/bad-naming.go"

    # 反面用例 3：Lint 违规（govet printf 占位符/参数类型不匹配）
    run_fail "case-bad-3" "Lint 违规：fmt.Printf 用 %d 却传字符串（govet printf）" "Lint" \
        golangci-lint run "$WORK/bad-lint-printf.go"
    run_fix "case-bad-3" "占位符 %d 改为 %s（govet printf 需手工对齐类型）" \
        bash -c "cp cases/bad-lint-printf.fixed.go $WORK/bad-lint-printf.go && golangci-lint run $WORK/bad-lint-printf.go"
fi

# 6. 汇总
summary_finalize
