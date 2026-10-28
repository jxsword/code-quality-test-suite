#!/usr/bin/env bash
# common.sh —— 每语言 run-tests.sh 的共享辅助库（source 使用）
# 约定（设计 v1 §四）：
#   results/pass.log           正面用例记录
#   results/fail-<id>.log      反面用例错误输出原文
#   results/fix-<id>.log       修复后验证输出
#   results/summary.md         结构化汇总
# 约定变量（run-tests.sh 在 source 之前设置）：
#   LANG_NAME   语言显示名（如 "Python"）
#   TOOLCHAIN   工具链摘要（如 "ruff 0.17.3"）
set -euo pipefail

RESULTS_DIR="${RESULTS_DIR:-results}"
mkdir -p "$RESULTS_DIR"
PASS_LOG="$RESULTS_DIR/pass.log"
ROWS_TMP="$RESULTS_DIR/.rows.tmp"
FIX_TMP="$RESULTS_DIR/.fix.tmp"
SUMMARY="$RESULTS_DIR/summary.md"
: > "$PASS_LOG"
: > "$ROWS_TMP"
: > "$FIX_TMP"

# 工具存在性检查：缺失时降级 warn（不阻断），返回 1
tool_require() { # <工具名> <可执行名>
    local name="$1" bin="$2"
    if command -v "$bin" > /dev/null 2>&1; then
        echo "[ok] $name -> $(command -v "$bin")"
        return 0
    fi
    echo "[WARN] 工具 $name ($bin) 缺失，本机跳过真实执行，降级记录（CI 将覆盖并回填）"
    return 1
}

# 正面用例：预期通过；意外失败 = 套件自身问题 → 退出码 1
run_ok() { # <id> <描述> <命令...>
    local id="$1" desc="$2"
    shift 2
    if "$@" > "$RESULTS_DIR/$id.log" 2>&1; then
        printf 'PASS\t%s\t%s\n' "$id" "$desc" >> "$PASS_LOG"
    else
        echo "FAIL  $id  $desc（预期通过却失败，完整输出见 $RESULTS_DIR/$id.log）" >&2
        exit 1
    fi
}

# 反面用例：预期失败，捕获 stderr/stdout 原文到 fail-<id>.log
run_fail() { # <id> <描述> <违规类型> <命令...>
    local id="$1" desc="$2" vtype="$3"
    shift 3
    set +e
    "$@" > "$RESULTS_DIR/fail-$id.log" 2>&1
    local rc=$?
    set -e
    if [ "$rc" -eq 0 ]; then
        echo "[WARN] 用例 $id 预期失败但返回 0（规则可能未生效），仍记录"
    else
        echo "[ok] $id 按预期失败 (exit=$rc)，错误原文已存 fail-$id.log"
    fi
    printf '%s\t%s\t%s\t%s\n' "$id" "$desc" "$vtype" "fail-$id.log" >> "$ROWS_TMP"
}

# 修复后验证：预期 PASS，输出到 fix-<id>.log；同时记录修复方案说明
run_fix() { # <id> <修复方案说明> <命令...>
    local id="$1" fixdesc="$2"
    shift 2
    if "$@" > "$RESULTS_DIR/fix-$id.log" 2>&1; then
        echo "[ok] $id 修复验证通过，输出存 fix-$id.log"
        printf '%s\t%s\n' "$id" "$fixdesc" >> "$FIX_TMP"
    else
        echo "FAIL  $id 修复后验证未通过（见 $RESULTS_DIR/fix-$id.log）" >&2
        exit 1
    fi
}

# 汇总 results/summary.md（run-tests.sh 末尾必须调用一次）
summary_finalize() {
    local now id desc vtype fpath fixdesc
    now="$(date -Is 2> /dev/null || date '+%Y-%m-%dT%H:%M:%S%z')"
    {
        echo "# ${LANG_NAME:-unknown} 实测结果"
        echo
        echo "- 工具链：${TOOLCHAIN:-unknown}"
        echo "- 运行时间：$now"
        echo
        echo "## 正面用例（PASS）"
        echo
        echo '| 用例 | 说明 | 结果 |'
        echo '|---|---|---|'
        while IFS= read -r line; do
            id="$(printf '%s' "$line" | cut -f2)"
            desc="$(printf '%s' "$line" | cut -f3-)"
            echo "| $id | $desc | PASS |"
        done < "$PASS_LOG"
        echo
        echo "## 反面用例（FAIL → 修复后 PASS）"
        echo
        echo '| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |'
        echo '|---|---|---|---|---|'
        while IFS=$'\t' read -r id desc vtype fpath; do
            fixdesc="$(awk -F'\t' -v k="$id" '$1==k {print $2}' "$FIX_TMP" | head -1)"
            [ -n "${fixdesc:-}" ] || fixdesc="见 docs 对应章节"
            echo "| $id | $vtype | $fpath | $fixdesc | fix-$id.log |"
        done < "$ROWS_TMP"
        echo
        echo "> 注：错误信息原文见 results/fail-<id>.log；修复后验证见 results/fix-<id>.log；工具缺失降级为 SKIP 的用例将在 CI 运行后回填。"
    } > "$SUMMARY"
    echo "---- summary ----"
    cat "$SUMMARY"
}
