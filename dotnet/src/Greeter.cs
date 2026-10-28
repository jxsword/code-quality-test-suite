namespace DotnetSample;

/// <summary>问候服务（正面用例，预期通过 dotnet build + dotnet format whitespace --verify-no-changes）。</summary>
public class Greeter
{
    private readonly string _punctuation;

    /// <summary>默认问候语常量（常量规则 UPPER_SNAKE_CASE）。</summary>
    public const string DEFAULT_GREETING = "Hello";

    public Greeter(string punctuation = "!")
    {
        this._punctuation = punctuation;
    }

    public string Greet(string name)
    {
        return $"{DEFAULT_GREETING}, {name}{this._punctuation}";
    }
}
