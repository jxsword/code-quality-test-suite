#!/usr/bin/env bash
# cases/bad-lint.sh —— 反面用例：ShellCheck 规则违规
#   SC2086：变量未加引号（词拆分/通配符风险）
#   SC2164 ：cd 后未判断返回值（本脚本未开 set -e，目录不存在时会在错误目录继续执行）
deploy() {
    local src="$1"
    local dest="$2"
    cd "$dest"
    cp -r $src ./backup
}

deploy "data" "backup_dir"
