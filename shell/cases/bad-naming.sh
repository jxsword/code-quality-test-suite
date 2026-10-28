#!/usr/bin/env bash
# cases/bad-naming.sh —— 反面用例：shell-naming-check.sh 自定义命名规则违规
#   规则1：函数名应为小写 snake_case（此处用了 PascalCase 的 DeployArtifact）
#   规则2：local 局部变量应为小写 snake_case（此处 Target 大写开头）
#   规则3：export 变量应为 UPPER_SNAKE_CASE（此处 app_home 小写开头）
set -euo pipefail

export app_home=/tmp/app

DeployArtifact() {
    local Target="$1"
    printf 'deploying to %s\n' "$Target"
}

DeployArtifact "prod"
