package main

import (
	"fmt"

	"example.com/basic/greet"
)

func main() {
	greeter := greet.New()

	fmt.Println(greeter.Message)
}
