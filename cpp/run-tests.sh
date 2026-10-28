#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# cpp/run-tests.sh —— clang-format（格式）+ clang-tidy（命名/Lint）正/反用例实测
# 离线可用：clang-format 缺失时先尝试 pip 安装（预算内）；
# clang-tidy 缺失时 CI 先尝试 apt 安装（本机无 sudo 自动失败走降级路径），
# 仍缺则命名/Lint 用例降级 warn，预期输出见 docs/lint-test-results/cpp.md（CI 用 apt 版本，版本可能非 23.1.4）。
set -euo pipefail
cd "$(dirname "$0")"

export LANG_NAME="C++"
export TOOLCHAIN="clang-format + clang-tidy（LLVM 23.1.4）"
# shellcheck source=scripts/common.sh
source ../scripts/common.sh

# 1. 安装 / 确认工具链
if ! command -v clang-format > /dev/null 2>&1; then
    echo "[..] 未找到 clang-format，尝试 pip install clang-format ..."
    python3 -m pip install clang-format -q || true
fi
if ! tool_require "clang-format" "clang-format"; then
    summary_finalize
    exit 0
fi
TOOLCHAIN="clang-format $(clang-format --version)"

# 2. 正面用例（预期 PASS；格式可本地实测，clang-tidy 正面检查见 CI）
run_ok "case-ok-1" "src/ 通过 clang-format --dry-run -Werror（LLVM 风格）" \
    clang-format --dry-run -Werror src/greeter.hpp src/greeter.cpp

# 3. 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.cpp cases/bad-naming.cpp cases/bad-lint-nullptr.cpp "$WORK/"

# 4. 反面用例 1：格式违规（clang-format -n 失败 → 自动修复 → 通过）
run_fail "case-bad-1" "格式违规：缺空格/括号风格，clang-format 判定需重排" "格式" \
    clang-format --dry-run -Werror "$WORK/bad-format.cpp"
run_fix "case-bad-1" "clang-format -i 自动重排后通过" \
    bash -c "cd $WORK && clang-format -i bad-format.cpp && clang-format --dry-run -Werror bad-format.cpp"

# 5. clang-tidy：CI 先尝试 apt 安装（runner 有 sudo；本机无 sudo 自动失败走降级路径）；
#    仍缺则命名/Lint 用例降级 warn（预期输出见 docs/lint-test-results/cpp.md，CI 回填）。
if ! command -v clang-tidy > /dev/null 2>&1; then
    echo "[..] 尝试 apt 安装 clang-tidy（CI 可用；本机无 sudo 则忽略）..."
    command -v sudo > /dev/null 2>&1 && sudo apt-get update -qq && sudo apt-get install -y -qq clang-format clang-tidy || true
fi
if tool_require "clang-tidy" "clang-tidy"; then
    # 反面用例 2：命名违规（readability-identifier-naming，不可自动修复）
    # --warnings-as-errors='*'：clang-tidy 对警告默认退出码 0，需升级为 error 才能让 run_fail 捕获失败
    run_fail "case-bad-2" "命名违规：类 bad_class_name / 函数 add_numbers 应 CamelCase（readability-identifier-naming）" "命名" \
        clang-tidy --warnings-as-errors='*' -quiet "$WORK/bad-naming.cpp" -- -std=c++17
    run_fix "case-bad-2" "手工重命名 BadClassName / AddNumbers（命名规则不可自动修复）" \
        bash -c "cp cases/bad-naming.fixed.cpp $WORK/bad-naming.cpp && clang-tidy --warnings-as-errors='*' -quiet $WORK/bad-naming.cpp -- -std=c++17"

    # 反面用例 3：Lint 违规（modernize-use-nullptr，可自动修复）
    run_fail "case-bad-3" "Lint 违规：NULL 应换 nullptr（modernize-use-nullptr）" "Lint" \
        clang-tidy --warnings-as-errors='*' -quiet "$WORK/bad-lint-nullptr.cpp" -- -std=c++17
    run_fix "case-bad-3" "clang-tidy --fix 自动把 NULL 替换为 nullptr（本仓库用 .fixed 等价验证）" \
        bash -c "cp cases/bad-lint-nullptr.fixed.cpp $WORK/bad-lint-nullptr.cpp && clang-tidy --warnings-as-errors='*' -quiet $WORK/bad-lint-nullptr.cpp -- -std=c++17"
fi

# 6. 汇总
summary_finalize
