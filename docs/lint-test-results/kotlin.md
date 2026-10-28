# Kotlin 实测结果（lint-test-results）

> **本地与 CI 均已实测**（CI 全量运行 40662260620 全绿，JDK25 + ktlint 1.8.0 + detekt 1.23.8）。
> 实测环境：本地沙箱（2026-10-28 14:37 +08:00）　工具链：**ktlint 1.8.0 + detekt 1.23.8**（Temurin JDK21）
> 正面用例 2/2 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src 通过 ktlint（格式 + 命名规则） | PASS |
| case-ok-2 | src 通过 detekt（命名 + MagicNumber + UnusedPrivateMember） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（ktlint，exit=1）

```text
.../results/.casework/bad-format.kt:4:1: Unexpected indentation (0) (should be 4) (standard:indent)
.../results/.casework/bad-format.kt:4:30: Function body should be replaced with body expression (standard:function-expression-body)
.../results/.casework/bad-format.kt:5:1: Unexpected indentation (0) (should be 8) (standard:indent)
.../results/.casework/bad-format.kt:6:1: Unexpected indentation (0) (should be 4) (standard:indent)

Summary error count (descending) by rule:
  standard:indent: 3
  standard:function-expression-body: 1
```

**修复**：`ktlint -F bad-format.kt` 自动补齐 4 空格缩进并将函数体转为表达式体 → 复查通过（`fix-case-bad-1.log`）。修复后内容：

```kotlin
class BadFormat {
    fun hi(name: String): String = "hi $name"
}
```

### case-bad-2　命名违规 ClassNaming（detekt，exit=2）

```text
.../results/.casework/bad-naming.kt:4:7: Class and Object names should match the pattern: [A-Z][A-Za-z0-9]* [ClassNaming]

Analysis failed with 1 weighted issues.
```

**修复**：手工重命名 `badNaming` → `BadNaming`（ClassNaming 不可自动修复）→ detekt 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规 UnusedPrivateMember（detekt，exit=2）

```text
.../results/.casework/bad-lint.kt:5:17: Private function `unusedHelper` is unused. [UnusedPrivateMember]

Analysis failed with 1 weighted issues.
```

**修复**：删除未使用的私有方法 `unusedHelper` → detekt 通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | ktlint -F 自动修复 | PASS |
| case-bad-2 | 命名 ClassNaming | results/fail-case-bad-2.log | 重命名 BadNaming | PASS |
| case-bad-3 | Lint UnusedPrivateMember | results/fail-case-bad-3.log | 删除未使用私有成员 | PASS |
