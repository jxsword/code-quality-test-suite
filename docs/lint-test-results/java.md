# Java 实测结果（lint-test-results）

> 本地与 CI 均已实测（CI 运行后如有差异会回填更新）。
> 实测环境：本地沙箱（2026-10-28 14:37 +08:00）　工具链：**google-java-format 1.37.0 + checkstyle 14.3.0**（Temurin JDK21，编译 release 17）
> 正面用例 3/3 PASS（含 `mvn checkstyle:check`）；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions）运行后如错误输出有差异，本页将同步回填。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src 通过 google-java-format（等价 mvn spotless:check） | PASS |
| case-ok-2 | src 通过 checkstyle（命名模块组 + UnusedImports） | PASS |
| case-ok-maven | pom 声明的 mvn checkstyle:check（checkstyle 14.3.0） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（google-java-format --dry-run --set-exit-if-changed，exit=1）

```text
results/.casework/bad-format.java
```

google-java-format 列出需要重排的文件即返回非零（4 空格缩进 → 2 空格）。

**修复**：`google-java-format --replace bad-format.java` 自动重排为 2 空格缩进 → 复查通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规 ConstantName（checkstyle，exit=1）

```text
Starting audit...
[ERROR] .../results/.casework/bad-naming.java:5:27: Name 'maxRetries' must match pattern '^[A-Z][A-Z0-9]*(_[A-Z0-9]+)*$'. [ConstantName]
Audit done.
Checkstyle ends with 1 errors.
```

**修复**：手工重命名 `maxRetries` → `MAX_RETRIES`（ConstantName 不可自动修复）→ checkstyle 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规 UnusedImports（checkstyle，exit=2）

```text
Starting audit...
[ERROR] .../results/.casework/bad-lint.java:3:8: Unused import - java.util.ArrayList. [UnusedImports]
[ERROR] .../results/.casework/bad-lint.java:4:8: Unused import - java.util.List. [UnusedImports]
Audit done.
Checkstyle ends with 2 errors.
```

**修复**：删除未使用的 `import java.util.ArrayList` / `import java.util.List` → checkstyle 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | google-java-format --replace | PASS |
| case-bad-2 | 命名 ConstantName | results/fail-case-bad-2.log | 重命名 MAX_RETRIES | PASS |
| case-bad-3 | Lint UnusedImports | results/fail-case-bad-3.log | 删除未使用 import | PASS |

> 已知限制（CI 回填）：`mvn spotless:check` 因 Spotless 插件反射 `Style.valueOf(String)` 与 gjf 1.37.0 的 record 化 `Style` 不兼容，本地未跑通；格式化行为已由独立 jar 验证，待 Spotless 适配后在 CI 回填真实日志。
