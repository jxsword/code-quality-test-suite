# Shell 用例设计（正/反用例）

> 语言：Shell（bash）　工具链：**shfmt v3.14.1**（格式化）+ **ShellCheck v0.11.0**（Lint）+ **scripts/shell-naming-check.sh**（自定义命名正则）
> 配置：`shell/.shellcheckrc`（ShellCheck 项目配置）；shfmt 参数 `-i 4 -ci -sr -s`（缩进 4 空格 / case 分支缩进 / 重定向两侧空格 / 自动简化）。
> 命名约束：Shell 生态无专用命名工具（shfmt、ShellCheck 均不管命名），由 `scripts/shell-naming-check.sh` 正则兜底——
> 函数名小写 snake_case、`local` 局部变量小写 snake_case、`export` 变量 UPPER_SNAKE_CASE。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/greeter.sh` | 问候工具库（`greet`/`write_log`/`main`，含 `set -euo pipefail`、引号、`cd` 判断返回值、UPPER_SNAKE export） | `shfmt -d`、`shellcheck`、`shell-naming-check.sh` 三者均 PASS |

## 反面用例（3 个，覆盖格式 / Lint / 命名）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.sh` | 格式 | shfmt（缩进 2 空格、`if` 缺空格、重定向无空格） | `shfmt -w` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-lint.sh` | Lint | **SC2086** 变量未引号 + **SC2164** `cd` 未判断返回值 | 加双引号、`cd ... \|\| return`（手工修复） | ❌ |
| case-bad-3 | `cases/bad-naming.sh` | 命名 | shell-naming-check：PascalCase 函数 / 大写 `local` / 小写 `export` | 改 snake_case / 大写 export（手工重命名） | ❌ |

> 每个反面用例均配同名 `.fixed.sh` 修复版夹具，`run-tests.sh` 修复验证阶段直接对照。

## 运行方式

```bash
cd shell && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# 工具缺失时：shfmt 自动下载 v3.14.1 单二进制到 ~/.local/bin；shellcheck 自动 pip3 install shellcheck-py；
# 仍缺失则降级 warn 不阻断（CI 覆盖回填）
```
