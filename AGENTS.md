# AGENTS.md —— code-quality-test-suite 项目约定

本仓库是「11 语言格式化 / Lint 工具实测套件」monorepo。任何 agent / 开发者操作前先读本文件。

## 快速命令

- 本地 hook 一键注入：`bash scripts/setup-hooks.sh`（pip 装 pre-commit → `pre-commit install` → 可选 commit-msg）
- 单语言实测：`cd <lang> && bash run-tests.sh`（离线可用；工具缺失时降级 warn，不阻断）
- CI：`.github/workflows/lint-test.yml`（dorny/paths-filter 路径过滤 + 动态矩阵，只跑改动语言；缓存仅包管理器依赖目录）

## 目录与约定（硬约束）

- 每语言目录统一：`src/`（正面用例）+ `cases/`（故意违规的反面用例）+ `run-tests.sh` + `results/`（运行产物，gitignored）
- `results/` 输出约定：`pass.log`、`fail-<id>.log`（错误输出原文）、`fix-<id>.log`（修复后验证）、`summary.md`（结构化汇总）
- `cases/` 下的违规夹具被 `.pre-commit-config.yaml` 顶层 `exclude` 排除，**不得**被 hook 检查；也不得把正面代码放进 `cases/`
- `docs/cases/<lang>.md` = 正/反用例设计文档；`docs/lint-test-results/<lang>.md` = 实测错误信息 + 修复方案（CI 运行后可用真实日志回填）
- 工具版本锁：与 2026-10-28 调研报告一致（clang-format/clang-tidy LLVM 23.1.4、ruff 0.17.3、golangci-lint v2.15.0、ktlint 1.8.0、detekt v1.23.8、Prettier 3.9.10、ESLint 10.13.0、sqlfluff 4.4.0、php-cs-fixer v3.95.27、phpstan 2.3.3、phpcs 4.0.4、shfmt v3.14.1、shellcheck v0.11.0、google-java-format 1.37.0、checkstyle 14.3.0）；升级需同步改 CI 与 .pre-commit-config.yaml
- 新增 shell 脚本必须通过 shellcheck 与 shfmt（pre-commit 会检查）

## Git 规范（Git Flow + Conventional Commits）

- 分支：`main`（仅发布 / 合并）、`develop`（集成）；新功能走 `feature/<name>` 分支并入 develop
- 提交信息：Conventional Commits（`feat` / `fix` / `docs` / `chore` / `ci` / `refactor` + 作用域，如 `feat(python): ...`）
- **禁止**未经仓库 owner 明确确认执行 `git push` / `gh repo create`

## 环境约束

- 沙箱无 sudo/apt：工具一律装进 Home（pip / npm / go install / 官方 tarball），禁止写系统目录
- 内存 3.9 GB / 2 核：重工具链（Gradle / Maven / .NET / LLVM）必须串行运行，禁止并行安装
