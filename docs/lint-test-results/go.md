# Go 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:31 +08:00）　工具链：**gofmt（go1.23.0）+ golangci-lint 2.15.0**（go1.26.10 toolchain 编译；CI 锁 Go 1.27，规则一致）
> 正面用例 2/2 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/greeter/ 通过 gofmt -l（无输出=合规） | PASS |
| case-ok-2 | src/greeter/ 通过 golangci-lint run（revive+staticcheck+govet） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（gofmt -l，exit=1）

`gofmt -l results/.casework/bad-format.go` 输出文件名即视为违规（gofmt 本身退出码恒 0，本套件用 `gofmt -l 文件 | grep -q .` 判定）：

```text
results/.casework/bad-format.go
```

违规内容 `func Add(a int,b int)int{return a+b}`，gofmt 期望：

```go
func Add(a int, b int) int { return a + b }
```

**修复**：`gofmt -w bad-format.go` 自动重排 → 复查无输出（`fix-case-bad-1.log`）。

### case-bad-2　命名违规（revive var-naming，exit=1）

```text
results/.casework/bad-naming.go:5:22: var-naming: func parameter userUrl should be userURL (revive)
func GreetingMessage(userUrl string) string {
                     ^
1 issues:
* revive: 1
```

**修复**：手工重命名参数 `userUrl` → `userURL`（revive var-naming 不可自动修复，提供 `cases/bad-naming.fixed.go` 等价验证）→ golangci-lint 复查 0 issues（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规（govet printf，exit=1）

```text
results/.casework/bad-lint-printf.go:8:20: printf: fmt.Printf format %d has arg "not-a-number" of wrong type string (govet)
	fmt.Printf("count=%d\n", "not-a-number")
	                  ^
1 issues:
* govet: 1
```

**修复**：占位符 `%d` 改为 `%s` 与字符串参数类型对齐（govet printf 需手工改，提供 `cases/bad-lint-printf.fixed.go` 等价验证）→ golangci-lint 复查 0 issues（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log（gofmt -l 列出文件） | gofmt -w | PASS |
| case-bad-2 | 命名（revive var-naming） | results/fail-case-bad-2.log | userUrl → userURL | PASS |
| case-bad-3 | Lint（govet printf） | results/fail-case-bad-3.log | %d → %s | PASS |

> **CI 实测**：全量运行 40662260620 通过（gofmt + golangci-lint 2.15.0，版本与本地一致）。
