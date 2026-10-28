# SQL 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:29 +08:00）　工具链：**sqlfluff 4.4.0**（dialect=postgres）
> 正面用例 1/1 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions）运行后如错误输出有差异，本页将同步回填更新。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/ 通过 sqlfluff lint（CP01 关键字大写 / CP02 标识符小写 / CP03 函数大写） | PASS |

> 说明：`sqlfluff lint` 在无问题时输出 `All Finished!`（exit=0），故 `case-ok-1.log` 内容即该行。

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（CP01 / 旧 L010，exit=1）

```text
== [results/.casework/bad-format.sql] FAIL
L:   2 | P:   1 | CP01 | Keywords must be upper case. [capitalisation.keywords]
L:   5 | P:   1 | CP01 | Keywords must be upper case. [capitalisation.keywords]
L:   6 | P:   1 | CP01 | Keywords must be upper case. [capitalisation.keywords]
L:   7 | P:   1 | CP01 | Keywords must be upper case. [capitalisation.keywords]
L:   7 | P:   7 | CP01 | Keywords must be upper case. [capitalisation.keywords]
L:   7 | P:  19 | CP01 | Keywords must be upper case. [capitalisation.keywords]
All Finished!
```

**修复**：`sqlfluff fix bad-format.sql` 自动把 `select/from/where/order by/desc` 改为大写（CP01 可自动修复）→ 复查 `sqlfluff lint` 通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规（CP02 / 旧 L014，exit=1）

```text
== [results/.casework/bad-naming.sql] FAIL
L:   3 | P:   5 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
L:   4 | P:   5 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
L:   5 | P:   5 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
L:   6 | P:   6 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
L:   7 | P:   7 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
L:   8 | P:  10 | CP02 | Unquoted identifiers must be lower case.
                       | [capitalisation.identifiers]
All Finished!
```

**修复**：手工把 `UserID/UserName/OrderCount/UserOrders` 重命名为 `user_id/user_name/order_count/user_orders`（CP02 设为 `lower`，sqlfluff fix 只会把驼峰整体小写为 `userid` 这类无法读的形式，单词拆分需人工）→ `sqlfluff lint` 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规（CP03 / 旧 L030，exit=1）

```text
== [results/.casework/bad-lint.sql] FAIL
L:   4 | P:   5 | CP03 | Function names must be upper case.
                       | [capitalisation.functions]
L:   5 | P:   5 | CP03 | Function names must be upper case.
                       | [capitalisation.functions]
All Finished!
```

**修复**：`sqlfluff fix bad-lint.sql` 自动把 `count()`/`now()` 改为 `COUNT()`/`NOW()`（CP03 可自动修复）→ 复查 `sqlfluff lint` 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 CP01 | results/fail-case-bad-1.log | sqlfluff fix 自动大写关键字 | PASS |
| case-bad-2 | 命名 CP02 | results/fail-case-bad-2.log | 手工重命名 snake_case | PASS |
| case-bad-3 | Lint CP03 | results/fail-case-bad-3.log | sqlfluff fix 自动大写函数名 | PASS |
