package com.example.qcts;

/** Lint 违规反面用例：未使用的 import（checkstyle UnusedImports 将报错）。 */
public class BadLint {
  public String greet(String name) {
    return "hi " + name;
  }
}
