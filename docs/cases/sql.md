# SQL 用例设计（正/反用例）

> 语言：SQL（PostgreSQL 方言）　工具链：**SQLFluff 4.4.0**（linter + auto-formatter，格式/Lint/命名一体）
> 配置：`sql/.sqlfluff`（`dialect = postgres`，`templater = raw`）。
> 命名约束：SQLFluff 内置大小写规则把命名写成机器可执行规则。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 4.4.0 规则码映射（重要）

SQLFluff 4.x 已把大小写规则从旧编号 L010/L014/L030 重组为命名空间规则，**配置段与配置键名同步变化**：

| 旧编号 | 4.4.0 规则 | 规则全名 | 配置段 | 配置键 | 本套件取值 |
|---|---|---|---|---|---|
| L010 | **CP01** | `capitalisation.keywords` | `[sqlfluff:rules:capitalisation.keywords]` | `capitalisation_policy` | `upper`（关键字全大写） |
| L014 | **CP02** | `capitalisation.identifiers` | `[sqlfluff:rules:capitalisation.identifiers]` | `extended_capitalisation_policy` | `lower`（表/列名小写 = snake_case） |
| L030 | **CP03** | `capitalisation.functions` | `[sqlfluff:rules:capitalisation.functions]` | `extended_capitalisation_policy` | `upper`（函数名全大写） |

> 注：旧文档/旧版的 `keywords = upper` / `identifiers = lower` 键名在 4.4.0 已失效（会被静默忽略，回落到默认 consistent 策略），必须改用上表键名。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/active_users.sql` | 活跃用户查询（CTE + JOIN + 聚合，关键字大写、标识符 snake_case、函数大写） | `sqlfluff lint src/` PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.sql` | 格式 | **CP01**（L010）关键字小写 | `sqlfluff fix` 自动大写关键字 | ✅ |
| case-bad-2 | `cases/bad-naming.sql` | 命名 | **CP02**（L014）标识符 CamelCase | 手工重命名为 snake_case | ⚠️（fix 只会小写化，需手工拆分单词） |
| case-bad-3 | `cases/bad-lint.sql` | Lint | **CP03**（L030）函数名小写 | `sqlfluff fix` 自动大写函数名 | ✅ |

> 每个反面用例均配同名 `.fixed.sql` 修复版夹具；case-bad-1 / case-bad-3 直接演示 `sqlfluff fix` 自动修复，case-bad-2 用 `.fixed.sql` 手工重命名版。

## 运行方式

```bash
cd sql && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# sqlfluff 缺失时自动 pip3 install sqlfluff==4.4.0；仍缺失则降级 warn 不阻断（CI 覆盖回填）
```
