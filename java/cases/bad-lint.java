package com.example.qcts;

import java.util.ArrayList;
import java.util.List;

/** Lint 违规反面用例：未使用的 import（checkstyle UnusedImports 将报错）。 */
public class BadLint {
  public String greet(String name) {
    return "hi " + name;
  }
}
