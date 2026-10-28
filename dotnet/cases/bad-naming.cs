namespace DotnetSample;

// 命名违规反面用例：接口 GreeterOptions 缺少 I 前缀（dotnet_naming_rule.interfaces_i_prefix，EnforceCodeStyleInBuild 时 build 报错）。
public interface GreeterOptions
{
    string Name { get; }
}
