# C#/.NET 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:29 +08:00）　工具链：**.NET SDK 8.0.427**（dotnet-install.sh 装到 ~/.dotnet）+ StyleCop.Analyzers 1.3.151-beta
> 正面用例 2/2 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions，`actions/setup-dotnet@v4` + NuGet 缓存）运行后如错误输出有差异，本页将同步回填更新。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | DotnetSample 通过 dotnet build（含 Roslyn 分析器 + EnforceCodeStyleInBuild 命名规则） | PASS |
| case-ok-2 | DotnetSample 通过 dotnet format whitespace --verify-no-changes | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（dotnet format whitespace --verify-no-changes，exit=2）

```text
results/.casework/bad-format/Case.cs(4,21): error WHITESPACE: Fix whitespace formatting. Replace 1 characters with '\n'.
results/.casework/bad-format/Case.cs(5,3): error WHITESPACE: Fix whitespace formatting. Insert '\s\s'.
results/.casework/bad-format/Case.cs(7,3): error WHITESPACE: Fix whitespace formatting. Insert '\s\s'.
results/.casework/bad-format/Case.cs(7,19): error WHITESPACE: Fix whitespace formatting. Replace 1 characters with '\n\s\s\s\s'.
results/.casework/bad-format/Case.cs(8,3): error WHITESPACE: Fix whitespace formatting. Insert '\s\s\s\s\s\s'.
results/.casework/bad-format/Case.cs(9,3): error WHITESPACE: Fix whitespace formatting. Insert '\s\s'.
```

**修复**：`dotnet format whitespace` 自动重排（花括号换行、4 空格缩进）→ `--verify-no-changes` 通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规 SA1302（dotnet build，exit=1）

```text
results/.casework/bad-naming/Case.cs(4,18): error SA1302: Interface names should begin with I

Build FAILED.
    1 Warning(s)
    1 Error(s)
```

**修复**：手工重命名 `GreeterOptions` → `IGreeterOptions`（命名规则不可自动修复）→ `dotnet build` 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规 SA1101（dotnet build，exit=1）

```text
results/.casework/bad-lint/Case.cs(10,9): error SA1101: Prefix local calls with this
results/.casework/bad-lint/Case.cs(15,16): error SA1101: Prefix local calls with this
results/.casework/bad-lint/Case.cs(20,32): error SA1101: Prefix local calls with this

Build FAILED.
    1 Warning(s)
    3 Error(s)
```

**修复**：实例成员前补 `this.`（`this.BuildGreeting(...)`、`this._punctuation`）→ `dotnet build` 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 WHITESPACE | results/fail-case-bad-1.log | dotnet format whitespace 自动重排 | PASS |
| case-bad-2 | 命名 SA1302 | results/fail-case-bad-2.log | 重命名 IGreeterOptions | PASS |
| case-bad-3 | Lint SA1101 | results/fail-case-bad-3.log | 补 this. 前缀 | PASS |
