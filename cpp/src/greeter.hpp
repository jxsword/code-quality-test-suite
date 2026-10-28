#ifndef GREETER_GREETER_HPP
#define GREETER_GREETER_HPP

#include <string>

namespace greeter {

// 问候器：统一输出格式。
// 命名约束（.clang-tidy readability-identifier-naming）：
//   类/方法 CamelCase，私有成员 m_ 前缀，命名空间 lower_case。
class Greeter {
public:
  Greeter();
  explicit Greeter(std::string greeting);

  std::string Greet(const std::string &name) const;

private:
  std::string m_greeting;
  char m_punctuation;
};

} // namespace greeter

#endif // GREETER_GREETER_HPP
