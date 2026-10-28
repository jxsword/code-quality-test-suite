namespace DotnetSample;

// 格式违规反面用例：dotnet format whitespace 自动修复后版本（花括号换行、4 空格缩进）。
public class Greeter
{
    private readonly string _punctuation;

    public Greeter()
    {
        _punctuation = "!";
    }
}
