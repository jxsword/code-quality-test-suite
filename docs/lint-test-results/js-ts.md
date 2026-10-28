# JS/TS 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:22 +08:00）　工具链：**prettier 3.9.10 / eslint v10.13.0 / typescript-eslint 8.72.1**（npm 实装）
> 正面用例 2/2 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions，`actions/setup-node` + `npm ci`）运行后如错误输出有差异，本页将同步回填更新。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/greeter.ts 通过 ESLint（含 naming-convention / no-unused-vars / no-explicit-any） | PASS |
| case-ok-2 | src/greeter.ts 通过 prettier --check（singleQuote / semi / printWidth=100） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（prettier --check，exit=1）

```text
Checking formatting...
[warn] results/.casework/bad-format.ts
[warn] Code style issues found in the above file. Run Prettier with --write to fix.
```

**修复**：`prettier --write bad-format.ts` 自动重排（双引号→单引号、补分号、4 空格→2 空格）→ `prettier --check` 通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规 naming-convention（eslint，exit=1）

```text
/home/user/.../js-ts/results/.casework/bad-naming.ts
  3:18  error  Interface name `User` must match the RegExp: /^I[A-Z][a-zA-Z0-9]*$/u  @typescript-eslint/naming-convention

✖ 1 problem (1 error, 0 warnings)
```

**修复**：手工重命名 `User` → `IUser`（naming-convention 不可自动修复）→ `eslint` 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规 no-explicit-any（eslint，exit=1）

```text
/home/user/.../js-ts/results/.casework/bad-lint.ts
  3:33  error  Unexpected any. Specify a different type  @typescript-eslint/no-explicit-any
  3:39  error  Unexpected any. Specify a different type  @typescript-eslint/no-explicit-any

✖ 2 problems (2 errors, 0 warnings)
```

**修复**：改用泛型 `identity<T>(value: T): T` 消除显式 any → `eslint` 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | prettier --write 自动重排 | PASS |
| case-bad-2 | 命名 naming-convention | results/fail-case-bad-2.log | 重命名 IUser | PASS |
| case-bad-3 | Lint no-explicit-any | results/fail-case-bad-3.log | 泛型 `<T>` 消除 any | PASS |
