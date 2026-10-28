# Rust 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:25 +08:00）　工具链：**rustc 1.99.0**（rustfmt 1.10.0 / clippy 0.1.99；CI 锁 1.99.1，仅 patch 差）
> 正面用例 2/2 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。
> CI（GitHub Actions）运行后如错误输出有差异，本页将同步回填更新。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/lib.rs 通过 cargo fmt --check（rustfmt.toml 配置） | PASS |
| case-ok-2 | src/lib.rs 通过 cargo clippy -- -D warnings（含 [lints] 命名/全部 clippy 组） | PASS |

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（rustfmt --check，exit=1）

```text
Diff in results/.casework/bad-format.rs:1:
 // 格式违规反面用例：冒号/箭头缺空格、花括号紧贴（rustfmt --check 将报错）。
-pub fn add(a: i32,b: i32)->i32{a+b}
+pub fn add(a: i32, b: i32) -> i32 {
+    a + b
+}
```

**修复**：`rustfmt bad-format.rs` 自动重排为多行表达式 → 复查通过（`fix-case-bad-1.log`）。

### case-bad-2　命名违规（rustc 内置 lint，exit=1）

```text
error: type `user_data` should have an upper camel case name
 --> results/.casework/bad-naming.rs:3:12
  |
3 | pub struct user_data {}
  |            ^^^^^^^^^ help: convert the identifier to upper camel case: `UserData`
  |
  = note: requested on the command line with `-D non-camel-case-types`

error: function `ComputeValue` should have a snake case name
 --> results/.casework/bad-naming.rs:4:8
  |
4 | pub fn ComputeValue() -> i32 { 1 }
  |        ^^^^^^^^^^^^ help: convert the identifier to snake case: `compute_value`
  |
  = note: requested on the command line with `-D non-snake-case`

error: constant `maxSize` should have an upper case name
 --> results/.casework/bad-naming.rs:5:7
  |
5 | const maxSize: i32 = 10;
  |       ^^^^^^^ help: convert the identifier to upper case: `MAX_SIZE`
  |
  = note: requested on the command line with `-D non-upper-case-globals`

error: aborting due to 3 previous errors; 1 warning emitted
```

（另有一条 `maxSize is never used` 的 dead_code 警告，不影响退出码。）

**修复**：手工重命名为 `UserData` / `compute_value` / `MAX_SIZE`（命名规则不可自动修复，提供 `cases/bad-naming.fixed.rs` 等价验证）→ rustc 复查通过（`fix-case-bad-2.log`）。

### case-bad-3　Lint 违规（clippy needless_return，exit=1）

```text
error: unneeded `return` statement
 --> results/.casework/bad-lint-needless-return.rs:3:5
  |
3 |     return a + b;
  |     ^^^^^^^^^^^^
  |
  = help: for further information visit https://rust-lang.github.io/rust-clippy/rust-1.99.0/index.html#needless_return
  = note: `-D clippy::needless-return` implied by `-D warnings`
  = help: to override `-D warnings` add `#[allow(clippy::needless_return)]`
help: remove `return`
  |
3 -     return a + b;
3 +     a + b
  |

error: aborting due to 1 previous error
```

**修复**：去掉裸 `return`、直接表达式返回 `a + b`（clippy 可自动修复，本仓库以 `cases/bad-lint-needless-return.fixed.rs` 等价验证）→ clippy-driver 复查通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | rustfmt 自动重排 | PASS |
| case-bad-2 | 命名（non_camel_case_types / non_snake_case / non_upper_case_globals） | results/fail-case-bad-2.log | 重命名 UserData / compute_value / MAX_SIZE | PASS |
| case-bad-3 | Lint（clippy::needless_return） | results/fail-case-bad-3.log | 删 return 直接返回 | PASS |
