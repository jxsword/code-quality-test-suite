# Rust 用例设计（正/反用例）

> 语言：Rust　工具链：rustfmt + cargo clippy（**Rust 1.99.1**，2026-10-16 已查证）　配置：`rust/Cargo.toml`（[lints] 表）、`rust/rustfmt.toml`
> 命名约束：rustc 内置 lint（`[lints.rust]`：non_snake_case / non_camel_case_types / non_upper_case_globals = deny），无需额外工具。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/lib.rs` | 问候服务（pub struct + 常量 + impl 方法） | `cargo fmt --check` 与 `cargo clippy -- -D warnings` 均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.rs` | 格式 | rustfmt（冒号/箭头缺空格、花括号紧贴） | `rustfmt` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.rs` | 命名 | **non_camel_case_types / non_snake_case / non_upper_case_globals** | 手工重命名 `UserData` / `compute_value` / `MAX_SIZE` | ❌ |
| case-bad-3 | `cases/bad-lint-needless-return.rs` | Lint | **clippy::needless_return**（函数体裸 return） | 删 `return`，直接表达式返回（clippy 可自动修复） | ✅ |

## 运行方式

```bash
cd rust && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# cargo 缺失时自动 rustup 安装（--profile minimal，预算 8 分钟）；仍缺失则降级 warn 不阻断（CI 覆盖回填）
```

## 备注：本地 vs CI 版本

- CI 锁 Rust 1.99.1；本地实测 1.99.0（rustc 1.99.0 / rustfmt 1.10.0 / clippy 0.1.99），仅 patch 差，规则一致。
- 命名用例用 `rustc -D non_snake_case -D non_camel_case_types -D non_upper_case_globals` 对单文件跑；Lint 用例用 `clippy-driver -D warnings` 对单文件跑——无需完整 crate，夹具可直接验证。
