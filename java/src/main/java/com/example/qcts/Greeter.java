package com.example.qcts;

/** 问候服务（正面用例，预期通过 google-java-format 与 checkstyle）。 */
public class Greeter {

  /** 默认问候语（常量：UPPER_SNAKE_CASE）。 */
  public static final String DEFAULT_GREETING = "Hello";

  private final String greeting;

  public Greeter() {
    this(DEFAULT_GREETING);
  }

  public Greeter(String greeting) {
    this.greeting = greeting;
  }

  /** 向指定名字发出问候。 */
  public String greet(String name) {
    return greeting + ", " + name + "!";
  }
}
