public sealed class Greeter
{
    public string Message()
    {
        return "Hello from Roslyn";
    }

    public static Greeter Create()
    {
        return new Greeter();
    }
}
