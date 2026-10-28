namespace DotnetSample;

// 命名违规反面用例：手工重命名为 IGreeterOptions 后通过。
public interface IGreeterOptions
{
    string Name { get; }
}
