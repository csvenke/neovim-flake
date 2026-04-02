pub struct Greeter {
    pub message: &'static str,
}

pub fn create_greeter() -> Greeter {
    Greeter {
        message: "Hello from Rust LSP",
    }
}
