// 格式违规反面用例：冒号/箭头缺空格、花括号紧贴（rustfmt --check 将报错）。
pub fn add(a: i32,b: i32)->i32{a+b}
