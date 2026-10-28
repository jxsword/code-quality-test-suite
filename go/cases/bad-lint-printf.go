// Package greeter Lint 违规反面用例：printf 用 %d 却传字符串（govet printf 将报错）。
package greeter

import "fmt"

// PrintGreeting 打印问候（故意制造 printf 参数类型不匹配）。
func PrintGreeting() {
	fmt.Printf("count=%d\n", "not-a-number")
}
