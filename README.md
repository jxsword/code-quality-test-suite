# code-quality-test-suite

11 语言格式化 / Lint 工具**实测套件**（monorepo）：每种语言一个示例项目，包含 1 个正面用例（预期全绿）与多个反面用例（覆盖**格式违规、命名违规、Lint 违规**），逐一捕获反面用例的**错误输出原文**与**修复方案**，供团队落地质量门禁时对照。

- 调研依据：2026-10-28《多语言代码质量工具链与 Git Hook 落地指南》（工具与版本号当日查证）
- 工具选型：每语言 = 格式化工具 + Lint/静态分析工具 + 命名约束落地方式（详见各语言目录与 `docs/`）

## 覆盖语言与工具

| 语言 | 格式化 | Lint / 静态分析 | 命名约束 |
|---|---|---|---|
| cpp | clang-format (LLVM 23.1.4) | clang-tidy | `.clang-tidy` readability-identifier-naming |
| rust | rustfmt (随 1.99.1) | cargo clippy | `[lints.rust]`（non_snake_case 等） |
| go | gofmt | golangci-lint v2.15.0 | revive var-naming / exported |
| python | ruff format | ruff 0.17.3 | ruff N 规则族（N801–N818） |
| java | google-java-format 1.37.0 (Spotless) | Checkstyle 14.3.0 | checkstyle.xml 命名模块组 |
| kotlin | ktlint 1.8.0 | detekt v1.23.8 | .editorconfig + detekt naming |
| js-ts | Prettier 3.9.10 | ESLint 10.13.0 + typescript-eslint 8.72.1 | naming-convention |
| dotnet | dotnet format (随 SDK) | NetAnalyzers + StyleCop | .editorconfig dotnet_naming_rule_* |
| php | PHP-CS-Fixer v3.95.27 | PHPStan 2.3.3 + phpcs 4.0.4 | PSR12 + Squiz.NamingConventions |
| shell | shfmt v3.14.1 | shellcheck v0.11.0 | 自定义正则 scripts/shell-naming-check.sh |
| sql | SQLFluff 4.4.0（合一） | SQLFluff 4.4.0 | .sqlfluff L010/L014/L030 |

## 快速上手

```bash
# 1. 注入本地 git hook（pip 装 pre-commit → pre-commit install → 可选 commit-msg）
bash scripts/setup-hooks.sh

# 2. 单语言实测（离线可用；工具缺失自动降级 warn，不阻断）
cd python && bash run-tests.sh && cat results/summary.md

# 3. 全量实测（手动触发 CI 或本地逐个目录跑）
```

## CI 说明

`.github/workflows/lint-test.yml`：

- **路径过滤 + 动态矩阵**：dorny/paths-filter 判定改动语言目录，只跑被改动的语言 job；push/PR 改 `docs/**`、`**.md` 全部跳过；`workflow_dispatch` 支持 `full` 全量与 `langs` 指定
- **缓存策略**：只缓存包管理器依赖目录（~/.gradle、~/.m2、~/.cargo、~/.nuget、~/.npm、~/.cache/composer、~/go/pkg/mod、~/.cache/pip），总量约 2 GB（GitHub 缓存配额 10 GB、7 天刷新）；工具链二进制（LLVM/.NET SDK/rustup 等）走 setup action/CDN，不占用缓存配额
- **产物**：每语言 `results/` 上传为 artifact（`results-<lang>`），供 `docs/lint-test-results/` 回填真实错误信息

## 文档

- `docs/cases/<lang>.md` —— 每语言正/反用例设计
- `docs/lint-test-results/<lang>.md` —— 实测错误输出原文 + 修复方案（CI 后回填）
- 汇总见 `docs/README.md`
