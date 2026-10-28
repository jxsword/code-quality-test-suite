namespace DotnetSample;

// Lint 违规反面用例：实例成员前补 this. 后通过（SA1101）。
public class Greeter
{
    private readonly string _punctuation;

    public Greeter()
    {
        this._punctuation = "!";
    }

    public string Greet(string name)
    {
        return this.BuildGreeting(name);
    }

    private string BuildGreeting(string name)
    {
        return $"Hello, {name}{this._punctuation}";
    }
}
