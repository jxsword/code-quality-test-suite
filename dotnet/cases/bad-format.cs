namespace DotnetSample;

// 格式违规反面用例：花括号与类同行、2 空格缩进（dotnet format whitespace --verify-no-changes 将判定需重排）。
public class Greeter {
  private readonly string _punctuation;

  public Greeter() {
  _punctuation = "!";
  }
}
