export class Greeter {
  message(): string {
    return "Hello from ts_ls";
  }
}

export function createGreeter(): Greeter {
  return new Greeter();
}
