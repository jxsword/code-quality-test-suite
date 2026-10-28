#!/usr/bin/env bash
# =============================================================================
# Shell 命名约束自定义检查脚本（pre-commit local hook 用）
# -----------------------------------------------------------------------------
# 约束（可按团队规范自行修改正则）：
#   1. 函数名必须为小写 snake_case（Foo() / function Bar() 视为违规）
#   2. local 局部变量必须小写 snake_case（大写开头视为违规）
#   3. export 导出的环境变量必须 UPPER_SNAKE_CASE
# 说明：Shell 生态没有专用命名工具（shfmt/shellcheck 均不管命名），
#       本脚本为启发式正则检查，上线前先在存量仓库跑一遍白名单。
# 用法：shell-naming-check.sh file1.sh file2.sh ...（pre-commit 会自动传入暂存文件）
# =============================================================================
set -euo pipefail

fail=0

for f in "$@"; do
    # 跳过空文件
    [ -s "$f" ] || continue

    # 规则 1：函数定义形如 "function Foo() {" 或 "Foo () {"，首字母大写即违规
    if grep -nE '^\s*(function[[:space:]]+)?[A-Z][A-Za-z0-9_]*[[:space:]]*\(\s*\)[[:space:]]*\{' "$f"; then
        echo "::error file=$f::函数名必须为小写 snake_case"
        fail=1
    fi

    # 规则 2：local 变量声明大写开头即违规（如 "local Foo=1"）
    if grep -nE '^\s*local[[:space:]]+[A-Z][A-Za-z0-9_]*' "$f"; then
        echo "::error file=$f::local 局部变量必须小写 snake_case"
        fail=1
    fi

    # 规则 3：export 变量小写开头即违规（应为 UPPER_SNAKE_CASE）
    if grep -nE '^\s*export[[:space:]]+[a-z][a-z0-9_]*=' "$f"; then
        echo "::error file=$f::export 变量必须 UPPER_SNAKE_CASE"
        fail=1
    fi
done

exit "$fail"
