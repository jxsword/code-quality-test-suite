#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# python/run-tests.sh —— ruff 正/反用例实测（格式 / 命名 / Lint）
# 离线可用：ruff 缺失时先尝试 pip 安装，仍缺则降级 warn 不阻断（CI 覆盖回填）
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="Python"
TOOLCHAIN="ruff 0.17.3（format + check，select 含 N 命名规则族）"
source ../scripts/common.sh

# 1. 安装 / 确认工具链
if ! command -v ruff > /dev/null 2>&1; then
    echo "[..] 未找到 ruff，尝试 pip install ruff ..."
    python3 -m pip install ruff -q || true
fi
if ! tool_require "ruff" "ruff"; then
    summary_finalize
    exit 0
fi
TOOLCHAIN="ruff $(ruff --version)"

# 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.py cases/bad-naming.py cases/bad-lint-f401.py cases/bad-lint-b006.py "$WORK/"

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/greeter.py 通过 ruff check（含 N 命名规则）" ruff check src/
run_ok "case-ok-2" "src/greeter.py 通过 ruff format --check" ruff format --check src/

# 3. 反面用例 1：格式违规（ruff format --check 失败 → 自动修复 → 通过）
run_fail "case-bad-1" "格式违规：运算符/注解缺空格，ruff format 判定需重排" "格式" ruff format --check "$WORK/bad-format.py"
run_fix "case-bad-1" "ruff format 自动重排后通过" bash -c "cd $WORK && ruff format bad-format.py && ruff format --check bad-format.py"

# 4. 反面用例 2：命名违规（N801 类名 snake_case，不可自动修复）
run_fail "case-bad-2" "命名违规：类名 bad_class_name 应为 CapWords（N801）" "命名" ruff check "$WORK/bad-naming.py"
run_fix "case-bad-2" "重命名为 BadClassName（N801 需手工修改）" bash -c "cp cases/bad-naming.fixed.py $WORK/bad-naming.py && ruff check $WORK/bad-naming.py"

# 5. 反面用例 3：Lint 违规（F401 未使用导入，可自动修复）
run_fail "case-bad-3" "Lint 违规：import os 未使用（F401）" "Lint" ruff check "$WORK/bad-lint-f401.py"
run_fix "case-bad-3" "ruff check --fix 自动移除未使用导入" bash -c "cd $WORK && ruff check --fix bad-lint-f401.py && ruff check bad-lint-f401.py"

# 6. 反面用例 4：Lint 违规（B006 可变默认参数，需手工重构）
run_fail "case-bad-4" "Lint 违规：可变默认参数 items=[]（B006）" "Lint" ruff check "$WORK/bad-lint-b006.py"
run_fix "case-bad-4" "改用 None + 函数体内初始化（B006 需手工重构）" bash -c "cp cases/bad-lint-b006.fixed.py $WORK/bad-lint-b006.py && ruff check $WORK/bad-lint-b006.py"

# 7. 汇总
summary_finalize
