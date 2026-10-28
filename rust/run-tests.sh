#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# rust/run-tests.sh —— rustfmt（格式）+ rustc/clippy（命名/Lint）正/反用例实测
# 离线可用：cargo 缺失时先尝试 rustup 安装（预算 8 分钟）；仍缺则降级 warn 不阻断（CI 覆盖回填）。
# 版本锁：Rust 1.99.1（CI）；本机实测 1.99.0（仅 patch 差，规则一致）。
set -euo pipefail
cd "$(dirname "$0")"

export LANG_NAME="Rust"
export TOOLCHAIN="rustfmt + cargo clippy（Rust 1.99.1）"
# shellcheck source=scripts/common.sh
source ../scripts/common.sh

# 1. 安装 / 确认工具链
if ! command -v cargo > /dev/null 2>&1 && [ -f "$HOME/.cargo/env" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.cargo/env"
fi
if ! command -v cargo > /dev/null 2>&1; then
    echo "[..] 未找到 cargo，尝试 rustup 安装（--profile minimal，预算 8 分钟）..."
    timeout 480 bash -c 'curl -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal' || true
    export PATH="$HOME/.cargo/bin:$PATH"
fi
if ! tool_require "cargo/rustfmt/clippy" "cargo"; then
    summary_finalize
    exit 0
fi
rustup component add rustfmt clippy || true
TOOLCHAIN="$(rustc --version)"

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "src/lib.rs 通过 cargo fmt --check（rustfmt.toml 配置）" cargo fmt -- --check
run_ok "case-ok-2" "src/lib.rs 通过 cargo clippy -- -D warnings（含 [lints] 命名/全部 clippy 组）" \
    cargo clippy -- -D warnings

# 3. 准备用例工作区（保证可重复运行：cases/ 夹具永不被修改）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.rs cases/bad-naming.rs cases/bad-lint-needless-return.rs "$WORK/"

# 4. 反面用例 1：格式违规（rustfmt --check 失败 → 自动重排 → 通过）
run_fail "case-bad-1" "格式违规：冒号/箭头缺空格、花括号紧贴，rustfmt 判定需重排" "格式" \
    rustfmt --check "$WORK/bad-format.rs"
run_fix "case-bad-1" "rustfmt 自动重排为多行表达式后通过" \
    bash -c "cd $WORK && rustfmt bad-format.rs && rustfmt --check bad-format.rs"

# 5. 反面用例 2：命名违规（rustc 内置 lint，不可自动修复）
run_fail "case-bad-2" \
    "命名违规：user_data 类型非 CamelCase / ComputeValue 函数非 snake_case / maxSize 常量非 UPPER_SNAKE_CASE" \
    "命名" \
    rustc --edition 2024 --crate-type lib \
    -D non_snake_case -D non_camel_case_types -D non_upper_case_globals \
    "$WORK/bad-naming.rs" -o "$WORK/bad-naming.rlib"
run_fix "case-bad-2" "手工重命名 UserData / compute_value / MAX_SIZE（命名规则不可自动修复）" \
    bash -c "cp cases/bad-naming.fixed.rs $WORK/bad-naming.rs && rustc --edition 2024 --crate-type lib -D non_snake_case -D non_camel_case_types -D non_upper_case_globals $WORK/bad-naming.rs -o $WORK/bad-naming.rlib"

# 6. 反面用例 3：Lint 违规（clippy needless_return，clippy 建议删 return）
run_fail "case-bad-3" "Lint 违规：函数体裸 return（clippy needless_return）" "Lint" \
    clippy-driver --edition 2024 --crate-type lib -D warnings \
    "$WORK/bad-lint-needless-return.rs" -o "$WORK/bad-lint.rlib"
run_fix "case-bad-3" "去掉裸 return、直接表达式返回（clippy 可自动修复，本仓库用 .fixed 等价验证）" \
    bash -c "cp cases/bad-lint-needless-return.fixed.rs $WORK/bad-lint-needless-return.rs && clippy-driver --edition 2024 --crate-type lib -D warnings $WORK/bad-lint-needless-return.rs -o $WORK/bad-lint.rlib"

# 7. 汇总
summary_finalize
