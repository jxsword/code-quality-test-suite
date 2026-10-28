package com.example.qcts;

/** 格式违规反面用例：使用 4 空格缩进（google-java-format 要求 2 空格）。 */
public class BadFormat {
  public String hello(String name) {
    return "hi " + name;
  }
}
