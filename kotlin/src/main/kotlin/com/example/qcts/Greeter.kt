package com.example.qcts

/** 问候服务（正面用例，预期通过 ktlint 与 detekt）。 */
class Greeter {
    /** 向指定名字发出问候。 */
    fun greet(name: String): String = "Hello, $name!"
}
