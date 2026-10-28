#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# shell/run-tests.sh —— shfmt（格式）+ ShellCheck（Lint）+ 自定义命名正则 正/反用例实测
# 离线可用：工具缺失时先尝试安装（shfmt 下载单二进制、shellcheck 走 pip），仍缺则降级 warn 不阻断
set -euo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091  # common.sh 为仓库内可信共享库，按设计不在本脚本内展开 lint
source ../scripts/common.sh

# shellcheck disable=SC2034  # LANG_NAME / TOOLCHAIN 由 source 的 common.sh 读取并写入 summary
LANG_NAME="Shell"
TOOLCHAIN="shfmt v3.14.1（格式）+ ShellCheck v0.11.0（Lint）+ scripts/shell-naming-check.sh（命名）"

# 确保 ~/.local/bin 在 PATH（pip --user / 手动下载的单二进制都装这里）
export PATH="$HOME/.local/bin:$PATH"

# 1. 安装 / 确认工具链
if ! command -v shfmt > /dev/null 2>&1; then
    echo "[..] 未找到 shfmt，下载 v3.14.1 单二进制到 ~/.local/bin ..."
    mkdir -p "$HOME/.local/bin"
    curl -sSL -o "$HOME/.local/bin/shfmt" \
        "https://github.com/mvdan/sh/releases/download/v3.14.1/shfmt_v3.14.1_linux_amd64"
    chmod +x "$HOME/.local/bin/shfmt"
fi
if ! tool_require "shfmt" "shfmt"; then
    summary_finalize
    exit 0
fi

if ! command -v shellcheck > /dev/null 2>&1; then
    echo "[..] 未找到 shellcheck，尝试 pip3 install shellcheck-py ..."
    python3 -m pip install shellcheck-py -q || true
fi
if ! tool_require "shellcheck" "shellcheck"; then
    summary_finalize
    exit 0
fi

# shellcheck disable=SC2034  # 版本字符串供 summary 引用
TOOLCHAIN="shfmt $(shfmt --version) + shellcheck $(shellcheck --version | sed -n 's/version: //p' | head -1)"
NAMING_CHECK="../scripts/shell-naming-check.sh"

# 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.sh cases/bad-lint.sh cases/bad-naming.sh "$WORK/"

SHFMT_FLAGS=(-i 4 -ci -sr -s)

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/greeter.sh 通过 shfmt -d（格式检查）" shfmt -d "${SHFMT_FLAGS[@]}" src/
run_ok "case-ok-2" "src/greeter.sh 通过 shellcheck（含 .shellcheckrc）" shellcheck src/greeter.sh
run_ok "case-ok-3" "src/greeter.sh 通过 shell-naming-check.sh 命名检查" bash "$NAMING_CHECK" src/greeter.sh

# 3. 反面用例 1：格式违规（shfmt -d 失败 → shfmt -w 自动重排 → 通过）
run_fail "case-bad-1" "格式违规：缩进 2 空格 / if 缺空格 / 重定向无空格，shfmt 判定需重排" "格式" \
    shfmt -d "${SHFMT_FLAGS[@]}" "$WORK/bad-format.sh"
shfmt -w "${SHFMT_FLAGS[@]}" "$WORK/bad-format.sh"
run_fix "case-bad-1" "shfmt -w 自动重排（缩进4空格/补空格/重定向两侧空格）后通过" \
    shfmt -d "${SHFMT_FLAGS[@]}" "$WORK/bad-format.sh"

# 4. 反面用例 2：Lint 违规（SC2086 变量未引号 + SC2164 cd 未检查，需手工修复）
run_fail "case-bad-2" "Lint 违规：位置变量未加引号（SC2086）+ cd 未判断返回值（SC2164）" "Lint" \
    shellcheck "$WORK/bad-lint.sh"
cp cases/bad-lint.fixed.sh "$WORK/bad-lint.sh"
run_fix "case-bad-2" "变量加双引号、cd 后 || return 判断（shellcheck 无 --fix，手工修复）" \
    shellcheck "$WORK/bad-lint.sh"

# 5. 反面用例 3：命名违规（PascalCase 函数 / 大写 local / 小写 export，需手工重命名）
run_fail "case-bad-3" "命名违规：函数 DeployArtifact（PascalCase）/ local Target / export app_home 小写" "命名" \
    bash "$NAMING_CHECK" "$WORK/bad-naming.sh"
cp cases/bad-naming.fixed.sh "$WORK/bad-naming.sh"
run_fix "case-bad-3" "函数改 deploy_artifact / local target / export APP_HOME（正则命名不可自动修复）" \
    bash "$NAMING_CHECK" "$WORK/bad-naming.sh"

# 6. 汇总
summary_finalize
