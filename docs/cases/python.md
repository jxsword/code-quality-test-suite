# Python 用例设计（正/反用例）

> 语言：Python　工具链：ruff 0.17.3（format + check 合一）　配置：`python/pyproject.toml`
> 命名约束：`select = ["E","F","I","N","UP","B","W"]`，其中 **N = pep8-naming 规则族（N801–N818）** 负责命名强制。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/greeter.py` | 问候服务（dataclass + 类型注解 + docstring） | `ruff check src/`（含 N 规则）与 `ruff format --check src/` 均 PASS |

## 反面用例（4 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.py` | 格式 | ruff format（运算符/注解缺空格） | `ruff format` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.py` | 命名 | **N801** 类名应 CapWords | 手工重命名 `BadClassName` | ❌ |
| case-bad-3 | `cases/bad-lint-f401.py` | Lint | **F401** 未使用导入 | `ruff check --fix` 自动移除 | ✅ |
| case-bad-4 | `cases/bad-lint-b006.py` | Lint | **B006** 可变默认参数 | 改 `None` + 函数体内初始化（unsafe fix，建议手工） | ⚠️（--unsafe-fixes） |

## 运行方式

```bash
cd python && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# ruff 缺失时自动 pip install；仍缺失则降级 warn 不阻断（CI 覆盖回填）
```
