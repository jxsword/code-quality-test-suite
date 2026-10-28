// 格式违规反面用例：双引号、缺分号、4 空格缩进（Prettier --check 会要求重排为单引号/分号/2 空格）。

export function add(a: number, b: number): number {
    const message = "sum"
    return a + b
}
