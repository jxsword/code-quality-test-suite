#!/usr/bin/env bash
# setup-hooks.sh —— 一键注入 git hook
# 流程：pip 安装 pre-commit → pre-commit install →（可选）commit-msg
# 用法：bash scripts/setup-hooks.sh [--with-commit-msg|-c]   （非交互环境请用参数跳过提示）
set -euo pipefail
cd "$(dirname "$0")/.."

if command -v pre-commit > /dev/null 2>&1; then
    echo "[ok] pre-commit 已安装: $(pre-commit --version)"
else
    echo "[..] 安装 pre-commit ..."
    python3 -m pip install pre-commit
fi

echo "[..] pre-commit install ..."
pre-commit install

ans="N"
if [ "${1:-}" = "--with-commit-msg" ] || [ "${1:-}" = "-c" ]; then
    ans="y"
elif [ -t 0 ]; then
    read -r -p "是否同时启用 commit-msg 规范检查（Conventional Commits）? [y/N] " ans || true
    ans="${ans:-N}"
fi
if [[ $ans =~ ^[Yy]$ ]]; then
    pre-commit install --hook-type commit-msg
    echo "[ok] commit-msg hook 已启用（scripts/commit-msg-check.sh）"
fi

echo "[ok] hook 注入完成：pre-commit $(pre-commit --version)"
echo "    提示：首次运行 pre-commit run --all-files 会下载各语言 hook 环境（需对应工具链）"
