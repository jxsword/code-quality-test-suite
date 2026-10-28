// 命名违规反面用例：类型 snake_case / 函数 CamelCase / 常量 camelCase
// （rustc non_camel_case_types / non_snake_case / non_upper_case_globals 将报错）。
pub struct user_data {}
pub fn ComputeValue() -> i32 { 1 }
const maxSize: i32 = 10;
