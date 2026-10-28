#!/usr/bin/env bash
# cases/bad-format.sh —— 反面用例：shfmt 格式违规（缩进 2 空格、if 缺空格、重定向无空格）
set -euo pipefail

greet() {
  local name="$1"
  if [ -n "$name" ];then
    printf 'Hi, %s\n' "$name"
  fi
  echo "done" >/dev/null
}

greet "World"
