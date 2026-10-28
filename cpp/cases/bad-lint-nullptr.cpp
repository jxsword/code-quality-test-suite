// Lint 违规反面用例：使用 NULL 而非 nullptr（.clang-tidy modernize-use-nullptr 将报错）。
#include <cstddef>

int *FindValue(int *array, std::size_t n) {
  for (std::size_t i = 0; i < n; ++i) {
    if (array[i] == 0) {
      return NULL;
    }
  }
  return NULL;
}
