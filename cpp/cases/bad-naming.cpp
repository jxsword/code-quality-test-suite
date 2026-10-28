// 命名违规反面用例：类名 snake_case、函数名 snake_case（.clang-tidy readability-identifier-naming 将报错）。
class bad_class_name {
public:
  int add_numbers(int a, int b);
};

int add_numbers(int a, int b) { return a + b; }
