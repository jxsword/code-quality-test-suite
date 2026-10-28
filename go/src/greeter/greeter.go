// Package greeter 提供问候服务（正面用例，预期通过 gofmt -l / golangci-lint run）。
package greeter

// Greeter 问候器：统一输出格式。
type Greeter struct {
	greeting string
}

// New 创建默认问候器。
func New() *Greeter {
	return &Greeter{greeting: "Hello"}
}

// Greet 向指定名字发出问候。
func (g *Greeter) Greet(name string) string {
	return g.greeting + ", " + name + "!"
}
