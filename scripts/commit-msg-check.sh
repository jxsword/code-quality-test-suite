#!/usr/bin/env bash
# commit-msg-check.sh —— Conventional Commits 提交信息校验（commit-msg hook）
# 格式：<type>(<scope>): <subject>，type ∈ feat|fix|docs|chore|ci|refactor|test|perf|build|style|revert
set -u
MSG_FILE="${1:-.git/COMMIT_EDITMSG}"
[ -f "$MSG_FILE" ] || exit 0
first_line="$(head -1 "$MSG_FILE")"

case "$first_line" in
    Merge* | Revert* | "") exit 0 ;;
esac

if ! printf '%s' "$first_line" | grep -qE '^(feat|fix|docs|chore|ci|refactor|test|perf|build|style|revert)(\([a-z0-9-]+\))?!?: .+'; then
    echo "✗ commit-msg 不符合 Conventional Commits 规范" >&2
    echo "  期望格式: <type>(<scope>): <subject>" >&2
    echo "  示例: feat(python): 新增命名违规反面用例" >&2
    exit 1
fi
exit 0
