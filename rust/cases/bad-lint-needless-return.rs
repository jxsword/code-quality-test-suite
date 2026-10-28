// Lint 违规反面用例：函数体裸 return（clippy needless_return 将报错）。
pub fn add(a: i32, b: i32) -> i32 {
    return a + b;
}
