# PHP 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:56 +08:00），沙箱具备 sudo，run-tests.sh 自动 `apt-get install php-cli php-mbstring php-xml` + 下载 composer 到 `$HOME/bin` 后实测。
> 工具链（实测）：**PHP 8.1.2** + Composer 2.10.3 + **php-cs-fixer 3.95.27** + **phpstan 2.3.3** + **php_codesniffer 4.0.4**。
> 正面用例 3/3 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI 运行后以真实日志回填本文档（CI 用 shivammathur/setup-php 或 apt 装 php+composer，流程与本脚本一致）。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/Greeter.php 通过 phpcs（PSR-12 + Squiz.Classes.ValidClassName 等命名 sniff） | PASS |
| case-ok-2 | src/Greeter.php 通过 php-cs-fixer --dry-run（@PSR12） | PASS |
| case-ok-3 | src/Greeter.php 通过 phpstan analyse（level 5） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（php-cs-fixer --dry-run，exit=8）

```text
PHP CS Fixer 3.95.27 Adalbertus ...
Loaded config default from ".php-cs-fixer.php".
  1) src/case-format.tmp.php

Found 1 of 2 files that can be fixed in 0.110 seconds, 18.00 MB memory used
```

**修复**：`php-cs-fixer fix` 自动重排（花括号换行、双引号→单引号、多行数组补尾逗号）→ `--dry-run` 通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规（phpcs，exit=2）

```text
FILE: results/.casework/bad-naming.php
--------------------------------------------------------------------------------
FOUND 4 ERRORS AFFECTING 2 LINES
--------------------------------------------------------------------------------
  8 | ERROR | Class name "bad_class_name" is not in PascalCase format
 10 | ERROR | Method name "bad_class_name::do_work" is not in camel caps format
 10 | ERROR | Public method name "bad_class_name::do_work" is not in camel caps format
 10 | ERROR | Public method name "bad_class_name::do_work" is not in camel caps format
```

**修复**：手工重命名 `bad_class_name` → `BadClassName`、`do_work` → `doWork`（命名 sniff 不可自动修复）→ `phpcs` 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规（phpstan level 5，exit=1）

```text
 ------ ----------------------------------------
  Line   bad-lint.php
 ------ ----------------------------------------
  10     Undefined variable: $undefinedVariable
         🪪  variable.undefined
 ------ ----------------------------------------

 [ERROR] Found 1 error
```

**修复**：改用 `$b`（phpstan 类型错误需手工修复）→ `phpstan analyse` 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | php-cs-fixer fix 自动重排 | PASS |
| case-bad-2 | 命名 | results/fail-case-bad-2.log | 重命名 BadClassName / doWork | PASS |
| case-bad-3 | Lint phpstan | results/fail-case-bad-3.log | 改用 $b | PASS |

> 备注：php_codesniffer 4.x 已将类名校验从 `Squiz.NamingConventions.ValidClassName` 移到 `Squiz.Classes.ValidClassName`；常量校验在 `Generic.NamingConventions.UpperCaseConstantName`。phpstan 2.3.3 不再接受 `phpstan.neon` 里字符串形式的 `cache:` 目录参数（会触发 Nette DI "Missing parameter" 错误），故未在 neon 中配置缓存目录。
