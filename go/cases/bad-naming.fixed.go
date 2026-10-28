// Package greeter 命名违规反面用例：修复版——参数 userUrl 改为 userURL。
package greeter

// GreetingMessage 返回问候消息。
func GreetingMessage(userURL string) string {
	return "hello from " + userURL
}
