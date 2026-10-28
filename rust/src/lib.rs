//! 示例：问候服务（正面用例，预期通过 cargo fmt --check / cargo clippy -- -D warnings）。

/// 问候器：统一输出格式。
pub struct Greeter {
    greeting: String,
}

const DEFAULT_GREETING: &str = "Hello";

impl Greeter {
    /// 创建默认问候器。
    #[must_use]
    pub fn new() -> Self {
        Self {
            greeting: DEFAULT_GREETING.to_string(),
        }
    }

    /// 向指定名字发出问候。
    #[must_use]
    pub fn greet(&self, name: &str) -> String {
        format!("{}, {}!", self.greeting, name)
    }
}

impl Default for Greeter {
    fn default() -> Self {
        Self::new()
    }
}
