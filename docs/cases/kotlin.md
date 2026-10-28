# Kotlin 用例设计（正/反用例）

> 语言：Kotlin　工具链：**ktlint 1.8.0**（格式 + 标准命名规则）+ **detekt 1.23.8**（命名 + Lint 规则）
> 配置：`kotlin/.editorconfig`（ktlint 规则开关）、`kotlin/detekt-config.yml`（naming + MagicNumber + UnusedPrivateMember）；`kotlin/build.gradle.kts` 供 CI 用 Gradle 跑 ktlint/detekt。
> 本地实测优先独立 jar：ktlint 可执行资产（pinterest/ktlint 1.8.0 release `ktlint`）、`detekt-cli-1.23.8-all.jar`；均需 JDK17+（本机用 Temurin 21 串行运行）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 `exclude: '(^|/)cases/'` 排除）；`run-tests.sh` 实测；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/main/kotlin/com/example/qcts/Greeter.kt` | 问候服务（4 空格缩进、表达式体、PascalCase 类） | `ktlint src/main` 与 `detekt --config detekt-config.yml --input src/main/kotlin` 均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.kt` | 格式 | ktlint **indent**（方法体未按 4 空格缩进） | `ktlint -F` 自动补齐缩进 + 转表达式体 | ✅ |
| case-bad-2 | `cases/bad-naming.kt` | 命名 | detekt **ClassNaming** 类名应 PascalCase | 手工重命名 `BadNaming` | ❌ |
| case-bad-3 | `cases/bad-lint.kt` | Lint | detekt **UnusedPrivateMember** 私有方法未使用 | 删除未使用私有成员 | ⚠️（detekt 无 --fix，手工删除） |

## 配置要点

- `.editorconfig`：`[*.{kt,kts}]` 段开启 ktlint standard 规则；显式 `ktlint_standard_filename = disabled`（cases 按 `bad-*.kt` 命名、类名为 `Bad*`，不强制「一文件一类」）。
- `detekt-config.yml`：`naming` 规则集（VariableNaming/FunctionNaming/ClassNaming/ConstructorParameterNaming）+ `style` 规则集（MagicNumber、UnusedPrivateMember）。
  - 注意：detekt 1.23.8 中 `UnusedPrivateMember` 位于 **style** 规则集（非 potential-bugs）；`ignoreNumbers` 需为 YAML 数组。

## 运行方式

```bash
cd kotlin && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# ktlint/detekt 独立 jar 缺失时降级 warn 不阻断（CI 覆盖回填）；JVM 工具严格串行
```
