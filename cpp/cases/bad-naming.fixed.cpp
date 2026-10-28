// 命名违规反面用例：修复版——类名/函数名改为 CamelCase。
class BadClassName {
public:
  int AddNumbers(int a, int b);
};

int AddNumbers(int a, int b) { return a + b; }
