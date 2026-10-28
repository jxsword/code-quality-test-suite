# 文档总览（docs/README.md）

本仓库是 **11 语言格式化 / Lint 工具实测套件**（monorepo）：每种语言一个示例项目，含 1 个正面用例（预期全绿）与多个反面用例（覆盖格式违规、命名违规、Lint 违规），逐一捕获反面用例的错误输出原文与修复方案，供团队落地质量门禁时对照。

> **数据口径说明**：
> - 工具与版本号以 **2026-10-28《多语言代码质量工具链与 Git Hook 落地指南》调研**为准（与根 README.md、AGENTS.md 口径一致）。
> - 「**本地实测**」= 沙箱真实运行捕获的错误输出原文（见各 `lint-test-results` 中的 fail/fix 日志）。
> - 「**降级待 CI 回填**」= 本地工具不可用（沙箱无 sudo/apt、内存/预算受限），运行脚本降级 warn 不阻断，文档中所列输出为基于工具文档的预期形态，精确行/列与措辞以 GitHub Actions 真实日志回填为准。

## 1. 11 语言汇总总览

| 语言 | 格式化工具 | Lint / 静态分析 | 命名约束落地 | 正面用例 | 反面用例数 | 本地实测状态 |
|---|---|---|---|---|---|---|
| C++ | clang-format（CI 锁 LLVM 23.1.4；本地 pip 23.1.3） | clang-tidy（本地 apt 14.0.0） | `.clang-tidy` readability-identifier-naming（类/函数 CamelCase、变量 lower_case、常量 UPPER_CASE、私有成员 `m_`） | 1 | 3 | **全量本地实测**（clang-format 23.1.3 + apt clang-tidy 14.0.0，规则全部生效）；注意本地 clang-tidy 14.0.0 **低于锁定 23.1.4**，CI 若用 23.1.4 输出可能有差异 |
| Rust | rustfmt（CI 锁 1.99.1；本地 1.99.0） | cargo clippy 0.1.99 | `[lints.rust]`：non_snake_case / non_camel_case_types / non_upper_case_globals = deny | 2 | 3 | **全量本地实测**（本地 1.99.0 与 CI 1.99.1 仅 patch 差，规则一致） |
| Go | gofmt（本地 go1.23.0；CI 锁 Go 1.27） | golangci-lint v2.15.0（revive + staticcheck + govet） | revive var-naming（initialism 全大写，如 userURL） | 2 | 3 | **全量本地实测**（golangci-lint 经 GOTOOLCHAIN=auto 拉 go1.26.10 toolchain 编译） |
| Python | ruff format 0.17.3 | ruff 0.17.3 | ruff N 规则族（N801–N818 pep8-naming） | 2 | 4 | **全量本地实测**（format + check 合一） |
| Java | google-java-format 1.37.0（经 Spotless 接入） | Checkstyle 14.3.0 | checkstyle.xml 命名模块组（ConstantName 等）+ UnusedImports | 3 | 3 | **本地实测**（独立 jar 全部正反用例 + `mvn checkstyle:check` 均通过；需 JDK21）；**例外**：`mvn spotless:check` 因插件反射不兼容 **降级待 CI 回填** |
| Kotlin | ktlint 1.8.0 | detekt 1.23.8 | `.editorconfig` + detekt naming（ClassNaming 等） | 2 | 3 | **全量本地实测**（Temurin JDK21，独立 jar 串行运行） |
| JS/TS | Prettier 3.9.10 | ESLint 10.13.0 + typescript-eslint 8.72.1（flat config） | @typescript-eslint/naming-convention | 2 | 3 | **全量本地实测**（npm 实装，npx 捕获真实输出） |
| C#/.NET | dotnet format（随 .NET SDK 8.0.427） | NetAnalyzers + StyleCop.Analyzers 1.3.151-beta | `.editorconfig` dotnet_naming_rule_*（SA1302 接口 I 前缀、SA1101 this. 前缀） | 2 | 3 | **全量本地实测**（dotnet-install.sh 装 8.0 到 ~/.dotnet，dotnet build 含 Roslyn 分析器） |
| PHP | PHP-CS-Fixer 3.95.27（@PSR12） | PHPStan 2.3.3（level 5）+ PHP_CodeSniffer 4.0.4 | PSR12 + Squiz.Classes.ValidClassName（phpcs 4.x 命名 sniff） | 3 | 3 | **全量本地实测**（apt 装 PHP 8.1.2 + Composer 2.10.3 后真实运行：php-cs-fixer 3.95.27 + PHPStan 2.3.3 + phpcs 4.0.4） |
| Shell | shfmt v3.14.1 | ShellCheck v0.11.0 | 自定义正则 `scripts/shell-naming-check.sh`（函数/local 小写 snake_case、export UPPER_SNAKE_CASE） | 3 | 3 | **全量本地实测**（shfmt 单二进制 + shellcheck-py） |
| SQL（PostgreSQL） | SQLFluff 4.4.0（lint + fix 合一） | SQLFluff 4.4.0 | `.sqlfluff` CP01/CP02/CP03（关键字大写、标识符小写 snake_case、函数大写） | 1 | 3 | **全量本地实测**（dialect=postgres） |

## 2. 每语言用例与结果索引

> 链接相对本目录（`docs/`）展开。

| 语言 | 用例设计（cases） | 实测结果（lint-test-results） | 反面用例清单 |
|---|---|---|---|
| C++ | [cases/cpp.md](cases/cpp.md) | [lint-test-results/cpp.md](lint-test-results/cpp.md) | case-bad-1 格式（clang-format）；case-bad-2 命名（readability-identifier-naming）；case-bad-3 Lint（modernize-use-nullptr） |
| Rust | [cases/rust.md](cases/rust.md) | [lint-test-results/rust.md](lint-test-results/rust.md) | case-bad-1 格式（rustfmt）；case-bad-2 命名（rustc 内置 lint）；case-bad-3 Lint（clippy::needless_return） |
| Go | [cases/go.md](cases/go.md) | [lint-test-results/go.md](lint-test-results/go.md) | case-bad-1 格式（gofmt）；case-bad-2 命名（revive var-naming）；case-bad-3 Lint（govet printf） |
| Python | [cases/python.md](cases/python.md) | [lint-test-results/python.md](lint-test-results/python.md) | case-bad-1 格式（ruff format）；case-bad-2 命名（N801）；case-bad-3 Lint（F401）；case-bad-4 Lint（B006，unsafe fix） |
| Java | [cases/java.md](cases/java.md) | [lint-test-results/java.md](lint-test-results/java.md) | case-bad-1 格式（google-java-format）；case-bad-2 命名（ConstantName）；case-bad-3 Lint（UnusedImports） |
| Kotlin | [cases/kotlin.md](cases/kotlin.md) | [lint-test-results/kotlin.md](lint-test-results/kotlin.md) | case-bad-1 格式（ktlint indent）；case-bad-2 命名（detekt ClassNaming）；case-bad-3 Lint（UnusedPrivateMember） |
| JS/TS | [cases/js-ts.md](cases/js-ts.md) | [lint-test-results/js-ts.md](lint-test-results/js-ts.md) | case-bad-1 格式（prettier）；case-bad-2 命名（naming-convention I 前缀）；case-bad-3 Lint（no-explicit-any） |
| C#/.NET | [cases/dotnet.md](cases/dotnet.md) | [lint-test-results/dotnet.md](lint-test-results/dotnet.md) | case-bad-1 格式（dotnet format whitespace）；case-bad-2 命名（SA1302）；case-bad-3 Lint（SA1101） |
| PHP | [cases/php.md](cases/php.md) | [lint-test-results/php.md](lint-test-results/php.md) | case-bad-1 格式（php-cs-fixer @PSR12）；case-bad-2 命名（phpcs 4.x Squiz.Classes.ValidClassName 等）；case-bad-3 Lint（phpstan UndefinedVariable） |
| Shell | [cases/shell.md](cases/shell.md) | [lint-test-results/shell.md](lint-test-results/shell.md) | case-bad-1 格式（shfmt）；case-bad-2 Lint（SC2086/SC2164）；case-bad-3 命名（自定义正则） |
| SQL | [cases/sql.md](cases/sql.md) | [lint-test-results/sql.md](lint-test-results/sql.md) | case-bad-1 格式（CP01 关键字大写）；case-bad-2 命名（CP02 标识符小写）；case-bad-3 Lint（CP03 函数大写） |

## 3. 运行方式

```bash
# 1. 注入本地 git hook（pip 装 pre-commit → pre-commit install → 可选 commit-msg）
bash scripts/setup-hooks.sh

# 2. 单语言实测（离线可用；工具缺失自动降级 warn，不阻断）
cd <lang> && bash run-tests.sh && cat results/summary.md
```

- **产物约定**（每语言 `results/`，gitignored）：`pass.log`（正面用例日志）、`fail-<id>.log`（反面用例错误输出原文）、`fix-<id>.log`（修复后验证）、`summary.md`（结构化汇总）。
- 反面用例夹具位于各语言 `cases/`，被 `.pre-commit-config.yaml` 顶层 `exclude` 排除，hook 不检查；多数语言另配同名 `.fixed` 修复版夹具供修复验证对照。

## 4. CI 说明（`.github/workflows/lint-test.yml`，设计 v1 要点）

- **路径过滤 + 动态矩阵**：dorny/paths-filter 判定改动语言目录，只跑被改动的语言 job；push/PR 改动 `docs/**`、`**.md` 全部跳过；`workflow_dispatch` 支持 `full` 全量与 `langs` 指定语言。
- **缓存策略**：只缓存包管理器依赖目录（`~/.gradle`、`~/.m2`、`~/.cargo`、`~/.nuget`、`~/.npm`、`~/.cache/composer`、`~/go/pkg/mod`、`~/.cache/pip`），总量约 2 GB（GitHub 缓存配额 10 GB、7 天刷新）；工具链二进制（LLVM / .NET SDK / rustup 等）走 setup action / CDN，不占用缓存配额。JS 侧缓存 key 依赖随仓库提交的 `js-ts/package-lock.json`。
- **产物与回填**：每语言 `results/` 上传为 artifact（`results-<lang>`），供 `docs/lint-test-results/` 回填真实错误信息；本文档中所有「降级待 CI 回填」项即由此流程补全。

## 5. 已知问题与偏差清单

> 以下逐条从各 `lint-test-results` / `cases` 文档提取，括号内标注来源文档；未在文档中出现的结论不予收录。

1. **C++ 本地版本与锁定版本存在差距**：本地 clang-format 为 pip 23.1.3（CI 锁 LLVM 23.1.4，仅差 patch）；本地 clang-tidy 为 Ubuntu apt **14.0.0，显著低于锁定 23.1.4**——实测规则已全部生效（命名/modernize-use-nullptr 均捕获），但 CI 若使用 23.1.4，错误输出行/列与措辞可能与本地日志有差异，以 CI 为准。（来源：[lint-test-results/cpp.md](lint-test-results/cpp.md)）
2. **C++ clang-tidy 触发方式**：clang-tidy 对警告默认退出码 0，套件用 `--warnings-as-errors='*'` 把命名/现代化警告升级为 error 才能拦截；CI 另需 `cmake -S cpp -B cpp/build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` 产出 compile_commands.json 后再跑。（来源：[lint-test-results/cpp.md](lint-test-results/cpp.md)、[cases/cpp.md](cases/cpp.md)）
3. **Rust 本地 1.99.0 vs CI 1.99.1**：仅 patch 差，规则一致；case-bad-2 另带一条 `maxSize is never used` 的 dead_code 警告，不影响退出码。（来源：[lint-test-results/rust.md](lint-test-results/rust.md)、[cases/rust.md](cases/rust.md)）
4. **Go 工具链版本差异与 gofmt 判定方式**：本机 go1.23.0（gofmt）+ golangci-lint v2.15.0（go1.26.10 toolchain 编译），CI 锁 Go 1.27；gofmt 退出码恒 0，套件用 `gofmt -l 文件 | grep -q .` 判定违规。（来源：[lint-test-results/go.md](lint-test-results/go.md)、[cases/go.md](cases/go.md)）
5. **Java JDK21 要求**：google-java-format 1.37.0 与 checkstyle 14.3.0 锁定版 class 版本 65，需 JDK21（仍可编译/校验 release 17 代码）。（来源：[cases/java.md](cases/java.md)）
6. **Java Spotless 与 google-java-format 1.37.0 反射不兼容（CI 回填）**：Spotless 插件内部反射调用 `JavaFormatterOptions.Style.valueOf(String)`，而 gjf 1.37.0 已将 `Style` 重构为 record（无该方法），`mvn spotless:check` 本地未跑通；格式化行为已由独立 jar 完整验证，待 Spotless 适配后在 CI 回填真实日志。`mvn checkstyle:check` 已本地通过。（来源：[lint-test-results/java.md](lint-test-results/java.md)、[cases/java.md](cases/java.md)）
7. **Java checkstyle 插件依赖声明方式**：maven-checkstyle-plugin 不提供 `checkstyle.version` 属性，需在插件 `<dependencies>` 内声明 `com.puppycrawl.tools:checkstyle:14.3.0`。（来源：[cases/java.md](cases/java.md)）
8. **Kotlin detekt 规则集归属与配置细节**：detekt 1.23.8 中 `UnusedPrivateMember` 位于 **style** 规则集（非 potential-bugs），`ignoreNumbers` 需为 YAML 数组；`.editorconfig` 显式 `ktlint_standard_filename = disabled`（cases 按 `bad-*.kt` 命名、类名 `Bad*`，不强制一文件一类）；JVM 工具严格串行。（来源：[cases/kotlin.md](cases/kotlin.md)）
9. **PHP phpcs 4.x sniff 更名与 PHPStan 缓存参数变更**：php_codesniffer 4.x 已将类名校验从 `Squiz.NamingConventions.ValidClassName` 移到 **`Squiz.Classes.ValidClassName`**，常量校验在 **`Generic.NamingConventions.UpperCaseConstantName`**；PHPStan 2.3.3 不再接受 `phpstan.neon` 里字符串形式的 `cache:` 目录参数（会触发 Nette DI "Missing parameter" 错误），故未在 neon 中配置缓存目录。（来源：[lint-test-results/php.md](lint-test-results/php.md)）
10. **Shell 正面日志为空属正常行为**：shfmt -d / shellcheck / 命名检查在无问题时均不输出（exit=0），`case-ok-*.log` 为空文件即真实成功；bad-lint.sh 刻意未开 `set -e`，否则 ShellCheck 会因 `set -e` 自动退出而抑制 SC2164。（来源：[lint-test-results/shell.md](lint-test-results/shell.md)）
11. **SQLFluff 4.4.0 规则更名与旧配置失效**：旧编号 L010/L014/L030 重组为命名空间规则——**CP01** `capitalisation.keywords`（关键字大写）、**CP02** `capitalisation.identifiers`（标识符小写）、**CP03** `capitalisation.functions`（函数大写）；旧文档/旧版的 `keywords = upper` / `identifiers = lower` 键名在 4.4.0 已失效（会被静默忽略，回落默认 consistent 策略），必须改用新配置段与键名。（来源：[cases/sql.md](cases/sql.md)、[lint-test-results/sql.md](lint-test-results/sql.md)）
12. **SQL CP02 自动修复局限**：`sqlfluff fix` 对驼峰标识符只会整体小写化（如 UserID → userid），单词拆分（user_id）需人工，故 case-bad-2 用 `.fixed.sql` 手工重命名版验证。（来源：[lint-test-results/sql.md](lint-test-results/sql.md)、[cases/sql.md](cases/sql.md)）

## 6. 附录：docs 目录文件清单

```
docs/
├── README.md                        # 本文件（汇总索引）
├── cases/                           # 每语言正/反用例设计（11 份）
│   ├── cpp.md
│   ├── rust.md
│   ├── go.md
│   ├── python.md
│   ├── java.md
│   ├── kotlin.md
│   ├── js-ts.md
│   ├── dotnet.md
│   ├── php.md
│   ├── shell.md
│   └── sql.md
└── lint-test-results/               # 实测错误输出原文 + 修复方案（11 份）
    ├── cpp.md
    ├── rust.md
    ├── go.md
    ├── python.md
    ├── java.md
    ├── kotlin.md
    ├── js-ts.md
    ├── dotnet.md
    ├── php.md
    ├── shell.md
    └── sql.md
```
