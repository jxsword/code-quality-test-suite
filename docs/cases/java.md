# Java 用例设计（正/反用例）

> 语言：Java　工具链：**google-java-format 1.37.0**（格式化，经 Spotless 接入）+ **Checkstyle 14.3.0**（风格/命名/Lint）
> 配置：`java/pom.xml`（Spotless + maven-checkstyle-plugin）、`java/checkstyle.xml`（TreeWalker 命名模块组 + UnusedImports）
> 本地实测用独立 jar：`google-java-format-1.37.0-all-deps.jar`、`checkstyle-14.3.0-all.jar`；二者均需 **JDK21**（锁定版 class 版本 65，仍可编译/校验 release 17 代码）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 `exclude: '(^|/)cases/'` 排除）；`run-tests.sh` 实测；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/main/java/com/example/qcts/Greeter.java` | 问候服务（UPPER_SNAKE 常量 + 2 空格缩进 + 标准 import） | `google-java-format --dry-run --set-exit-if-changed` 与 `checkstyle -c checkstyle.xml` 均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.java` | 格式 | google-java-format（4 空格缩进，应为 2 空格） | `google-java-format --replace` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.java` | 命名 | **ConstantName** 常量应 UPPER_SNAKE_CASE | 手工重命名 `MAX_RETRIES` | ❌ |
| case-bad-3 | `cases/bad-lint.java` | Lint | **UnusedImports** 未使用 import | 删除未使用 import | ⚠️（checkstyle 无 --fix，手工/Spotless removeUnusedImports） |

## Maven 集成（CI / pre-commit）

- `mvn spotless:check`（只检查不改）、`mvn checkstyle:check`；CI 绑定 `verify`。
- checkstyle 14.3.0 覆盖方式：maven-checkstyle-plugin 不提供 `checkstyle.version` 属性，按官方文档在插件 `<dependencies>` 内声明 `com.puppycrawl.tools:checkstyle:14.3.0`（见 `pom.xml`）。
- 已知问题：Spotless 插件内部仍以反射调用 `JavaFormatterOptions.Style.valueOf(String)`，而 google-java-format 1.37.0 已将 `Style` 重构为 record（无该方法），`mvn spotless:check` 本地暂未跑通；格式化行为由独立 jar 完整验证，CI 侧待 Spotless 适配 gjf 1.37.0 后回填。`mvn checkstyle:check` 已本地通过。

## 运行方式

```bash
cd java && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# 工具 jar 缺失时降级 warn 不阻断（CI 覆盖回填）
```
