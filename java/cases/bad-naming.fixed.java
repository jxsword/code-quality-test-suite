package com.example.qcts;

/** 命名违规反面用例：常量使用小驼峰（checkstyle ConstantName 要求 UPPER_SNAKE_CASE）。 */
public class BadNaming {
  public static final int MAX_RETRIES = 3;

  public int getMaxRetries() {
    return MAX_RETRIES;
  }
}
