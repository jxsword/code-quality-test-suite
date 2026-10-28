# C++ 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:55 +08:00）　工具链：**clang-format 23.1.3**（pip）+ **clang-tidy 14.0.0**（Ubuntu apt）
> 正面用例 1/1 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI 说明：脚本先尝试 `sudo apt-get install -y clang-format clang-tidy`（GitHub Actions runner 有 sudo）；**CI 用 apt 版本，版本可能非 23.1.4**（apt 源跟随发行版；本机实测即 apt clang-tidy 14.0.0，已验证规则全部生效）。CI 另需 `cmake -S cpp -B cpp/build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` 产出 compile_commands.json。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/ 通过 clang-format --dry-run -Werror（LLVM 风格） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（clang-format --dry-run -Werror，exit=1，本地实测）

```text
results/.casework/bad-format.cpp:2:23: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                      ^
results/.casework/bad-format.cpp:2:29: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                            ^
results/.casework/bad-format.cpp:2:30: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                             ^
results/.casework/bad-format.cpp:2:38: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                                     ^
results/.casework/bad-format.cpp:2:39: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                                      ^
results/.casework/bad-format.cpp:2:41: error: code should be clang-formatted [-Wclang-format-violations]
int add_numbers(int a,int b){return a+b;}
                                        ^
```

**修复**：`clang-format -i bad-format.cpp` 自动重排为 `int add_numbers(int a, int b) { return a + b; }` → 复查通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规（readability-identifier-naming，exit=1，本地实测）

触发命令：`clang-tidy --warnings-as-errors='*' -quiet results/.casework/bad-naming.cpp -- -std=c++17`（由 `cpp/.clang-tidy` 提供命名策略；`--warnings-as-errors='*'` 把警告升级为 error，否则 clang-tidy 对警告默认退出码 0）

```text
3 warnings generated.
results/.casework/bad-naming.cpp:2:7: error: invalid case style for class 'bad_class_name' [readability-identifier-naming,-warnings-as-errors]
class bad_class_name {
      ^~~~~~~~~~~~~~
      BadClassName
results/.casework/bad-naming.cpp:4:7: error: invalid case style for method 'add_numbers' [readability-identifier-naming,-warnings-as-errors]
  int add_numbers(int a, int b);
      ^~~~~~~~~~~
      AddNumbers
results/.casework/bad-naming.cpp:7:5: error: invalid case style for function 'add_numbers' [readability-identifier-naming,-warnings-as-errors]
int add_numbers(int a, int b) { return a + b; }
    ^~~~~~~~~~~
    AddNumbers
```

**修复**：手工重命名为 `BadClassName` / `AddNumbers`（`readability-identifier-naming` 不可自动修复，提供 `cases/bad-naming.fixed.cpp` 等价验证）→ 复查通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规（modernize-use-nullptr，exit=1，本地实测）

触发命令：`clang-tidy --warnings-as-errors='*' -quiet results/.casework/bad-lint-nullptr.cpp -- -std=c++17`

```text
3 warnings generated.
results/.casework/bad-lint-nullptr.cpp:7:14: error: use nullptr [modernize-use-nullptr,-warnings-as-errors]
      return NULL;
             ^~~~
             nullptr
results/.casework/bad-lint-nullptr.cpp:10:10: error: use nullptr [modernize-use-nullptr,-warnings-as-errors]
  return NULL;
         ^~~~
         nullptr
```

**修复**：`clang-tidy --fix` 自动把 `NULL` 替换为 `nullptr`（本仓库以 `cases/bad-lint-nullptr.fixed.cpp` 等价验证）→ 复查通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log（本地实测） | clang-format -i | PASS |
| case-bad-2 | 命名 readability-identifier-naming | results/fail-case-bad-2.log（本地实测） | 重命名 BadClassName / AddNumbers | PASS |
| case-bad-3 | Lint modernize-use-nullptr | results/fail-case-bad-3.log（本地实测） | NULL → nullptr | PASS |

> **CI 实测**：全量运行 40662260620 通过（clang-format / clang-tidy Ubuntu 21.1.8，低于锁定 23.1.4，行为与本地实测一致）。
