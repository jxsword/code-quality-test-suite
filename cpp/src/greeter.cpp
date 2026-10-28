#include "greeter.hpp"

namespace greeter {

Greeter::Greeter() : m_greeting("Hello"), m_punctuation('!') {}

Greeter::Greeter(std::string greeting) : m_greeting(std::move(greeting)), m_punctuation('!') {}

std::string Greeter::Greet(const std::string &name) const { return m_greeting + ", " + name + m_punctuation; }

} // namespace greeter
