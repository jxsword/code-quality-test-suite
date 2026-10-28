# C#/.NET 用例设计（正/反用例）

> 语言：C#　工具链：**dotnet format**（随 .NET SDK 8.0.427 分发，格式化）+ **NetAnalyzers** + **StyleCop.Analyzers 1.3.151-beta**（命名 + 风格 Lint）
> 配置：`dotnet/DotnetSample.csproj`（`EnforceCodeStyleInBuild=true` 让 IDE 命名规则参与 build）+ `dotnet/.editorconfig`（`dotnet_naming_rule_*` 系列 severity=error，叠加 `dotnet_diagnostic.SAxxxx.severity`）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/Greeter.cs` | 问候服务（class PascalCase + 私有 `_camelCase` 字段 + `this.` 前缀 + 常量 UPPER_SNAKE_CASE） | `dotnet build`（含 Roslyn 分析器）与 `dotnet format whitespace --verify-no-changes` 均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.cs` | 格式 | dotnet format whitespace（花括号与类同行 / 2 空格缩进） | `dotnet format whitespace` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.cs` | 命名 | **SA1302** 接口名必须 I 前缀（`dotnet_naming_rule.interfaces_i_prefix` 双保险） | 手工重命名 `IGreeterOptions` | ❌ |
| case-bad-3 | `cases/bad-lint.cs` | Lint | **SA1101** 实例成员须 `this.` 前缀 | 手工补 `this.` | ❌ |

## 运行方式

```bash
cd dotnet && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# 本机：dotnet-install.sh 装 8.0 到 ~/.dotnet（预算 ≤10 分钟）；CI 用 actions/setup-dotnet@v4。
# SDK 缺失时降级 warn 不阻断（CI 覆盖回填）。
```
