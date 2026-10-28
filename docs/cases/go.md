# Go 用例设计（正/反用例）

> 语言：Go　工具链：gofmt + golangci-lint **v2.15.0**（2026-10-16 已查证）　配置：`go/.golangci.yml`（v2 格式）、`go/go.mod`
> 命名约束：golangci-lint 内置 **revive** 的 `var-naming`（initialism 必须全大写，如 URL/ID/API）；Lint 静态分析：**staticcheck + govet**（含 printf 检查）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/greeter/greeter.go` | 问候服务（Package 注释 + 导出类型/函数/方法） | `gofmt -l src/` 无输出；`golangci-lint run src/...` 0 issues |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.go` | 格式 | gofmt（参数间缺空格、括号紧贴） | `gofmt -w` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.go` | 命名 | **revive var-naming**：参数 `userUrl` 应为 `userURL` | 手工重命名 `userURL` | ❌ |
| case-bad-3 | `cases/bad-lint-printf.go` | Lint | **govet printf**：`%d` 却传字符串 | 占位符 `%d` 改为 `%s` | ❌（需手工对齐类型） |

## 运行方式

```bash
cd go && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# golangci-lint 缺失时自动 GOTOOLCHAIN=auto go install（预算 8 分钟；本机 go1.23.0 会自动拉 go1.26.10 toolchain）；
# 仍缺失则降级 warn 不阻断（CI 覆盖回填）
```

## 备注：本地 vs CI 版本

- CI 锁 Go 1.27 + golangci-lint v2.15.0；本机实测 go1.23.0（gofmt）+ v2.15.0（go1.26.10 toolchain 编译），规则一致。
- gofmt 无配置文件（Go 官方强制风格）；命名/Lint 规则集中在 `.golangci.yml` 的 `linters.settings.revive.rules`。
