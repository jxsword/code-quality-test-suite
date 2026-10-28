#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# sql/run-tests.sh —— SQLFluff 4.4.0（格式 + Lint + 命名）正/反用例实测
# 离线可用：sqlfluff 缺失时先尝试 pip 安装，仍缺则降级 warn 不阻断（CI 覆盖回填）
set -euo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091  # common.sh 为仓库内可信共享库，按设计不在本脚本内展开 lint
source ../scripts/common.sh

# shellcheck disable=SC2034  # LANG_NAME / TOOLCHAIN 由 source 的 common.sh 读取并写入 summary
LANG_NAME="SQL"
TOOLCHAIN="sqlfluff 4.4.0（dialect=postgres；CP01 关键字大写 / CP02 标识符小写 snake_case / CP03 函数大写）"

export PATH="$HOME/.local/bin:$PATH"

# 1. 安装 / 确认工具链
if ! command -v sqlfluff > /dev/null 2>&1; then
    echo "[..] 未找到 sqlfluff，尝试 pip3 install sqlfluff==4.4.0 ..."
    python3 -m pip install "sqlfluff==4.4.0" -q || true
fi
if ! tool_require "sqlfluff" "sqlfluff"; then
    summary_finalize
    exit 0
fi

# shellcheck disable=SC2034  # 版本字符串供 summary 引用
TOOLCHAIN="sqlfluff $(sqlfluff --version)"

# 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.sql cases/bad-naming.sql cases/bad-lint.sql "$WORK/"

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/ 通过 sqlfluff lint（CP01 关键字大写 / CP02 标识符小写 / CP03 函数大写）" \
    sqlfluff lint src/

# 3. 反面用例 1：格式违规（CP01 关键字小写，sqlfluff fix 可自动大写）
run_fail "case-bad-1" "格式违规：关键字小写（select/from/where/order by，CP01 要求全大写）" "格式" \
    sqlfluff lint "$WORK/bad-format.sql"
sqlfluff fix --nocolor "$WORK/bad-format.sql" > /dev/null
run_fix "case-bad-1" "sqlfluff fix 自动把关键字改为大写（CP01 可自动修复）后通过" \
    sqlfluff lint "$WORK/bad-format.sql"

# 4. 反面用例 2：命名违规（CP02 标识符 CamelCase，需手工重命名 snake_case）
run_fail "case-bad-2" "命名违规：标识符 CamelCase（UserID/UserOrders，CP02 要求小写 snake_case）" "命名" \
    sqlfluff lint "$WORK/bad-naming.sql"
cp cases/bad-naming.fixed.sql "$WORK/bad-naming.sql"
run_fix "case-bad-2" "重命名为 snake_case（user_id/user_orders，手工修改）后通过" \
    sqlfluff lint "$WORK/bad-naming.sql"

# 5. 反面用例 3：Lint 违规（CP03 函数名小写，sqlfluff fix 可自动大写）
run_fail "case-bad-3" "Lint 违规：函数名小写 count()/now()（CP03 要求全大写）" "Lint" \
    sqlfluff lint "$WORK/bad-lint.sql"
sqlfluff fix --nocolor "$WORK/bad-lint.sql" > /dev/null
run_fix "case-bad-3" "sqlfluff fix 自动把函数名改为大写（CP03 可自动修复）后通过" \
    sqlfluff lint "$WORK/bad-lint.sql"

# 6. 汇总
summary_finalize
