#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# js-ts/run-tests.sh —— Prettier + ESLint(typescript-eslint) 正/反用例实测（格式 / 命名 / Lint）
# 离线可用：node_modules 缺失时 npm ci（有 lock）/ npm install；npx 捕获真实输出。
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="JS/TS"
TOOLCHAIN="prettier 3.9.10 + eslint + typescript-eslint（naming-convention / no-unused-vars / no-explicit-any）"
source ../scripts/common.sh

# 1. 安装 / 确认工具链
if ! command -v npm > /dev/null 2>&1; then
    echo "[WARN] 未找到 npm，本机跳过真实执行，降级记录（CI 将覆盖并回填）"
    summary_finalize
    exit 0
fi
if [ ! -d node_modules ]; then
    echo "[..] 未发现 node_modules，尝试 npm ci（或 npm install）..."
    if [ -f package-lock.json ]; then
        npm ci --no-audit --no-fund || npm install --no-audit --no-fund || true
    else
        npm install --no-audit --no-fund || true
    fi
fi
if [ ! -x node_modules/.bin/prettier ] || [ ! -x node_modules/.bin/eslint ]; then
    echo "[WARN] node_modules 中缺少 prettier/eslint，依赖安装未完成，降级记录（CI 将覆盖并回填）"
    summary_finalize
    exit 0
fi
TOOLCHAIN="prettier $(npx prettier --version) / eslint $(npx eslint --version) / typescript-eslint $(node -p "require('typescript-eslint/package.json').version")"

# 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.ts cases/bad-naming.ts cases/bad-lint.ts "$WORK/"

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/greeter.ts 通过 ESLint（含 naming-convention / no-unused-vars / no-explicit-any）" npx eslint src/
run_ok "case-ok-2" "src/greeter.ts 通过 prettier --check（singleQuote / semi / printWidth=100）" npx prettier --check src/

# 3. 反面用例 1：格式违规（prettier --check 失败 → prettier --write 自动修复 → 通过）
run_fail "case-bad-1" "格式违规：双引号/缺分号/4 空格缩进，prettier --check 判定需重排" "格式" npx prettier --check "$WORK/bad-format.ts"
run_fix "case-bad-1" "prettier --write 自动重排（单引号/分号/2 空格）后通过" bash -c "npx prettier --write $WORK/bad-format.ts >/dev/null && npx prettier --check $WORK/bad-format.ts"

# 4. 反面用例 2：命名违规（interface 缺 I 前缀，naming-convention 不可自动修复）
run_fail "case-bad-2" "命名违规：interface User 缺少 I 前缀（应 ^I[A-Z]）" "命名" npx eslint "$WORK/bad-naming.ts"
run_fix "case-bad-2" "手工重命名为 IUser（naming-convention 不可自动修复）" bash -c "cp cases/bad-naming.fixed.ts $WORK/bad-naming.ts && npx eslint $WORK/bad-naming.ts"

# 5. 反面用例 3：Lint 违规（no-explicit-any，需手工重构为泛型）
run_fail "case-bad-3" "Lint 违规：显式 any（@typescript-eslint/no-explicit-any）" "Lint" npx eslint "$WORK/bad-lint.ts"
run_fix "case-bad-3" "改用泛型 <T> 消除显式 any" bash -c "cp cases/bad-lint.fixed.ts $WORK/bad-lint.ts && npx eslint $WORK/bad-lint.ts"

# 6. 汇总
summary_finalize
