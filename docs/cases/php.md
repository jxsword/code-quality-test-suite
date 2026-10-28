# PHP 用例设计（正/反用例）

> 语言：PHP　工具链：**PHP-CS-Fixer 3.95.27**（格式化，@PSR12）+ **PHPStan 2.3.3**（类型静态分析，level 5）+ **PHP_CodeSniffer 4.0.4**（PSR-12 + 命名 sniff）
> 配置：`php/composer.json`（require-dev）、`php/.php-cs-fixer.php`（@PSR12 rule set）、`php/phpstan.neon`（level 5）、`php/phpcs.xml.dist`（PSR-12 + 命名 sniff）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/Greeter.php` | 问候服务（final class PascalCase + 方法 camelCase + 属性 camelCase + 常量 UPPER_SNAKE_CASE） | `phpcs`（PSR-12 + 命名）、`php-cs-fixer --dry-run`、`phpstan analyse`（level 5）均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.php` | 格式 | php-cs-fixer @PSR12（花括号同行 / 双引号 / 多行数组缺尾逗号） | `php-cs-fixer fix` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.php` | 命名 | phpcs 命名 sniff：类名 `bad_class_name` 应 PascalCase（Squiz.Classes.ValidClassName）、方法 `do_work` 应 camelCase（Squiz.NamingConventions.ValidFunctionName） | 手工重命名 | ❌ |
| case-bad-3 | `cases/bad-lint.php` | Lint | **phpstan level 5**：引用未定义变量 `$undefinedVariable` | 手工改用 `$b` | ❌ |

## 运行方式

```bash
cd php && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# 本地沙箱无 php/composer 时降级 warn 不阻断；CI 用 shivammathur/setup-php 或 apt 装 php+composer 后 composer install 再跑。
```
