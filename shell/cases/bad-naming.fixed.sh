#!/usr/bin/env bash
# cases/bad-naming.fixed.sh —— 修复后版本：函数 snake_case / local 小写 / export 大写（通过命名检查）
set -euo pipefail

export APP_HOME=/tmp/app

deploy_artifact() {
    local target="$1"
    printf 'deploying to %s\n' "$target"
}

deploy_artifact "prod"
