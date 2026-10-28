// Package greeter Lint 违规反面用例：修复版——占位符与参数类型一致（%s 配字符串）。
package greeter

import "fmt"

// PrintGreeting 打印问候。
func PrintGreeting() {
	fmt.Printf("count=%s\n", "not-a-number")
}
