# cpp/CMakeLists.txt —— C++ 正面用例构建配置
# CI 跑 clang-tidy 前必须先 configure 一次以产出 compile_commands.json：
#   cmake -S cpp -B cpp/build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
# clang-format 不需要编译；clang-tidy 需要编译数据库（或逐文件手动传 -- 编译参数）。
cmake_minimum_required(VERSION 3.16)
project(cpp_lint_suite CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 产出 compile_commands.json（clang-tidy 输入），禁止缓存覆盖
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE BOOL "Export compile_commands.json for clang-tidy")

add_library(greeter src/greeter.cpp)
target_include_directories(greeter PUBLIC src)
