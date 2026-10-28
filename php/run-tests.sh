#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# php/run-tests.sh —— PHP-CS-Fixer + PHPStan + phpcs 正/反用例实测（格式 / 命名 / Lint）
# 本地沙箱无 php/composer 时降级 warn 不阻断；CI（shivammathur/setup-php 或 apt 装 php+composer）覆盖回填。
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="PHP"
TOOLCHAIN="php-cs-fixer 3.95.27 + phpstan 2.3.3 + php_codesniffer 4.0.4"
source ../scripts/common.sh

# 1. 检测工具链；缺失时先尝试 CI 可用的安装路径（沙箱无 sudo/网络则自动失败，仍走降级）
if ! command -v php > /dev/null 2>&1; then
  echo "[..] 尝试 apt 安装 PHP（CI 可用；本机无 sudo 则忽略）..."
  command -v sudo > /dev/null 2>&1 && sudo apt-get update -qq && sudo apt-get install -y -qq php-cli php-mbstring php-xml unzip || true
fi
if command -v php > /dev/null 2>&1 && ! command -v composer > /dev/null 2>&1; then
  echo "[..] 尝试下载 composer 到 \$HOME/bin ..."
  mkdir -p "$HOME/bin"
  curl -fsSL https://getcomposer.org/installer -o /tmp/composer-setup.php \
    && php /tmp/composer-setup.php --install-dir="$HOME/bin" --filename=composer --quiet || true
  export PATH="$HOME/bin:$PATH"
fi

# 安装尝试后仍缺失 → 降级 warn（不阻断），CI 首次真实运行后回填
if ! command -v php > /dev/null 2>&1; then
  echo "[WARN] 未找到 php，本机沙箱跳过真实执行，降级记录（CI 将装 php+composer 并覆盖回填）"
  summary_finalize
  exit 0
fi
if ! command -v composer > /dev/null 2>&1; then
  echo "[WARN] 未找到 composer，本机沙箱跳过真实执行，降级记录（CI 将装 php+composer 并覆盖回填）"
  summary_finalize
  exit 0
fi

# 2. 安装依赖：composer.lock 缺失时先 composer update 生成（CI 缓存 key 依赖 composer.lock）
#    注意：`composer update --lock` 需已有 lock 文件，首次生成用普通 `composer update`。
if [ ! -f composer.lock ]; then
  composer update --no-interaction --no-progress || true
fi
composer install --no-interaction --no-progress || true

# 依赖安装后仍缺 vendor/ 工具 → 降级 warn（CI 网络可用时不会走到这里）
if [ ! -x vendor/bin/phpcs ] || [ ! -x vendor/bin/php-cs-fixer ] || [ ! -x vendor/bin/phpstan ]; then
  echo "[WARN] vendor/ 中缺少 php 工具链（phpcs/php-cs-fixer/phpstan），降级记录（CI 将覆盖回填）"
  summary_finalize
  exit 0
fi

# 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-naming.php cases/bad-lint.php "$WORK/"

# 3. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/Greeter.php 通过 phpcs（PSR-12 + Squiz.NamingConventions）" vendor/bin/phpcs --standard=phpcs.xml.dist
run_ok "case-ok-2" "src/Greeter.php 通过 php-cs-fixer --dry-run（@PSR12）" vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.php --dry-run
run_ok "case-ok-3" "src/Greeter.php 通过 phpstan analyse（level 5）" vendor/bin/phpstan analyse -c phpstan.neon --no-progress

# 4. 反面用例 1：格式违规（php-cs-fixer finder 限定 src/，临时把夹具放进 src/；
#    注意文件名不能以 . 开头——finder ignoreDotFiles(true) 会忽略 dotfile）
TMPF="src/case-format.tmp.php"
trap 'rm -f "$TMPF"' EXIT
cp cases/bad-format.php "$TMPF"
run_fail "case-bad-1" "格式违规：花括号同行/双引号/多行数组缺尾逗号（php-cs-fixer @PSR12）" "格式" vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.php --dry-run
run_fix "case-bad-1" "php-cs-fixer 自动重排（花括号换行/单引号/尾逗号）后通过，并清理临时文件" bash -c "vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.php $TMPF >/dev/null && vendor/bin/php-cs-fixer fix --config=.php-cs-fixer.php --dry-run && rm -f $TMPF"

# 5. 反面用例 2：命名违规（phpcs Squiz.NamingConventions：类名/方法名 snake_case，不可自动修复）
run_fail "case-bad-2" "命名违规：类名 bad_class_name 应 PascalCase、方法 do_work 应 camelCase" "命名" vendor/bin/phpcs --standard=phpcs.xml.dist "$WORK/bad-naming.php"
run_fix "case-bad-2" "手工重命名 BadClassName / doWork（phpcs 命名 sniff 不可自动修复）" bash -c "cp cases/bad-naming.fixed.php $WORK/bad-naming.php && vendor/bin/phpcs --standard=phpcs.xml.dist $WORK/bad-naming.php"

# 6. 反面用例 3：Lint 违规（phpstan level 5：未定义变量）
run_fail "case-bad-3" "Lint 违规：引用未定义变量 \$undefinedVariable（phpstan level 5）" "Lint" vendor/bin/phpstan analyse -c phpstan.neon --no-progress "$WORK/bad-lint.php"
run_fix "case-bad-3" "改用 \$b（phpstan 类型错误需手工修复）" bash -c "cp cases/bad-lint.fixed.php $WORK/bad-lint.php && vendor/bin/phpstan analyse -c phpstan.neon --no-progress $WORK/bad-lint.php"

# 7. 汇总
summary_finalize
