namespace DotnetSample;

// Lint 违规反面用例：实例方法 BuildGreeting 未加 this. 前缀（StyleCop SA1101，build 报错）。
public class Greeter
{
    private readonly string _punctuation;

    public Greeter()
    {
        _punctuation = "!";
    }

    public string Greet(string name)
    {
        return BuildGreeting(name);
    }

    private string BuildGreeting(string name)
    {
        return $"Hello, {name}{_punctuation}";
    }
}
