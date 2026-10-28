// Package greeter 命名违规反面用例：参数 userUrl 的 initialism 应为全大写 URL（revive var-naming 将报错）。
package greeter

// GreetingMessage 返回问候消息。
func GreetingMessage(userUrl string) string {
	return "hello from " + userUrl
}
