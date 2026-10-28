// Lint 违规反面用例：修复版——NULL 全部替换为 nullptr。
#include <cstddef>

int *FindValue(int *array, std::size_t n) {
  for (std::size_t i = 0; i < n; ++i) {
    if (array[i] == 0) {
      return nullptr;
    }
  }
  return nullptr;
}
