package greet

type Greeter struct {
	Message string
}

func New() Greeter {
	return Greeter{Message: "Hello from Go LSP"}
}
