#!/usr/bin/env bash
# cases/bad-lint.fixed.sh —— 修复后版本：加引号 + cd 判断返回值（通过 shellcheck）
set -euo pipefail

deploy() {
    local src="$1"
    local dest="$2"
    cd "$dest" || {
        printf '无法进入目录: %s\n' "$dest" >&2
        return 1
    }
    cp -r "$src" ./backup
}

deploy "data" "backup_dir"
