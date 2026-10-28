#!/usr/bin/env bash
# src/greeter.sh —— Shell 正面用例（预期通过 shfmt -d + shellcheck + shell-naming-check.sh）
# 规范：函数名小写 snake_case；local 变量小写 snake_case；export 变量 UPPER_SNAKE_CASE。
set -euo pipefail

GREETING_PREFIX="Hello"
export GREETING_PREFIX

# 拼接问候语：返回 "Hello, <name>!"
greet() {
    local name="$1"
    local punct="${2:-!}"
    printf '%s, %s%s\n' "$GREETING_PREFIX" "$name" "$punct"
}

# 在指定目录下生成一份问候记录（演示 cd 后检查返回值，规避 SC2164）
write_log() {
    local dir="$1"
    local name="$2"
    mkdir -p "$dir"
    cd "$dir" || {
        printf '无法进入目录: %s\n' "$dir" >&2
        return 1
    }
    greet "$name" > greet.txt
    cd - > /dev/null || exit 1
}

main() {
    local target="${1:-World}"
    local workdir
    workdir="$(mktemp -d)"
    write_log "$workdir" "$target"
    cat "$workdir/greet.txt"
    rm -rf "$workdir"
}

main "$@"
