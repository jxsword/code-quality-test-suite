# Python 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:13 +08:00）　工具链：**ruff 0.17.3**
> 正面用例 2/2 PASS；反面用例 4/4 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions）运行后如错误输出有差异，本页将同步回填更新。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/greeter.py 通过 ruff check（含 N 命名规则） | PASS |
| case-ok-2 | src/greeter.py 通过 ruff format --check | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（ruff format --check，exit=1）

```text
unformatted: File would be reformatted
 --> results/.casework/bad-format.py:3:1
  |
2 |
  - def add(a:int,b:int)->int:
  -     return a+b
3 +
4 + def add(a: int, b: int) -> int:
5 +     return a + b
  |

1 file would be reformatted
```

**修复**：`ruff format bad-format.py` 自动重排 → `ruff format --check` 通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规 N801（ruff check，exit=1）

```text
N801 Class name `bad_class_name` should use CapWords convention
 --> results/.casework/bad-naming.py:4:7
  |
4 | class bad_class_name:
  |       ^^^^^^^^^^^^^^
5 |     """反例类。"""
  |

Found 1 error.
```

**修复**：手工重命名为 `BadClassName`（N801 不可自动修复）→ `ruff check` 通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规 F401（ruff check，exit=1）

```text
F401 [*] `os` imported but unused
 --> results/.casework/bad-lint-f401.py:3:8
  |
1 | """Lint 违规反面用例：未使用的导入（ruff F401 将报错）。"""
2 |
3 | import os
  |        ^^
help: Remove unused import: `os`
  |
2 |
  - import os
3 |
  |

Found 1 error.
[*] 1 fixable with `--fix`.
```

**修复**：`ruff check --fix` 自动移除 `import os` → 复查 `ruff check` 通过（`fix-case-bad-3.log`）。

### case-bad-4　Lint 违规 B006（ruff check，exit=1）

```text
B006 Do not use mutable data structures for argument defaults
 --> results/.casework/bad-lint-b006.py:4:47
  |
4 | def append_item(item: str, items: list[str] = []) -> list[str]:
  |                                               ^^
5 |     items.append(item)
6 |     return items
  |
help: Replace with `None`; initialize within function
  |
3 |
  - def append_item(item: str, items: list[str] = []) -> list[str]:
4 + def append_item(item: str, items: list[str] = None) -> list[str]:
5 +     if items is None:
6 +         items = []
7 |     items.append(item)
  |
note: This is an unsafe fix and may change runtime behavior

Found 1 error.
1 unsafe fix available with `--fix --unsafe-fixes`.
```

**修复**：改用 `items: list[str] | None = None` + 函数体内初始化（ruff 将其标为 unsafe fix，建议手工重构）→ `ruff check` 通过（`fix-case-bad-4.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | ruff format 自动重排 | PASS |
| case-bad-2 | 命名 N801 | results/fail-case-bad-2.log | 重命名 BadClassName | PASS |
| case-bad-3 | Lint F401 | results/fail-case-bad-3.log | ruff check --fix | PASS |
| case-bad-4 | Lint B006 | results/fail-case-bad-4.log | None + 体内初始化 | PASS |
