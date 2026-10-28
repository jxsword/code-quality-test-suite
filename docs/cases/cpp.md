# C++ 用例设计（正/反用例）

> 语言：C++　工具链：clang-format + clang-tidy（**LLVM 23.1.4**，2026-10-20 已查证）　配置：`cpp/.clang-format`、`cpp/.clang-tidy`、`cpp/CMakeLists.txt`
> 命名约束：clang-tidy `readability-identifier-naming`——类/函数/方法 CamelCase，变量/命名空间 lower_case，常量/宏 UPPER_CASE，私有成员 `m_` 前缀。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/greeter.hpp` + `src/greeter.cpp` | 问候服务（类 + 命名空间 + m_ 私有成员） | 本地 `clang-format --dry-run -Werror` PASS；CI 追加 `clang-tidy` 全规则 PASS（需先 `cmake -S cpp -B cpp/build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`） |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.cpp` | 格式 | clang-format（参数缺空格 / K&R 单括号） | `clang-format -i` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.cpp` | 命名 | **readability-identifier-naming**：类 `bad_class_name`、函数 `add_numbers` 应 CamelCase | 手工重命名 `BadClassName` / `AddNumbers` | ❌ |
| case-bad-3 | `cases/bad-lint-nullptr.cpp` | Lint | **modernize-use-nullptr**：`NULL` 应换 `nullptr` | `clang-tidy --fix` 自动替换（本仓库以 `.fixed` 文件等价验证） | ✅ |

## 运行方式

```bash
cd cpp && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# clang-format 缺失时自动 pip install（本机 pip 最高 23.1.3，与 CI 锁 23.1.4 仅差 patch）；
# clang-tidy 本机不装（LLVM 完整工具链约 2GB 超预算），命名/Lint 用例降级 warn 不阻断（CI 覆盖回填）
```

## 备注：本地 vs CI 能力边界

- 本地实测：clang-format（格式用例 case-bad-1、正面 case-ok-1）；clang-tidy（命名 case-bad-2、Lint case-bad-3）经脚本内 `sudo apt-get install` 实测（本机 apt clang-tidy 14.0.0），规则全部生效。
- CI：脚本先尝试 `sudo apt-get install -y clang-format clang-tidy`（GitHub Actions runner 有 sudo）；**CI 用 apt 版本，版本可能非 23.1.4**（apt 源跟随发行版版本）。CI 另需先 CMake 构建出 `compile_commands.json`，再跑 `clang-tidy -p build`。
- 兼容注记：`.clang-tidy` 不使用 `HeaderFileExtensions` / `ImplementationFileExtensions`（LLVM 16+ 才认；apt clang-tidy 14 解析失败会导致整份配置被忽略、所有检查静默失效）。
