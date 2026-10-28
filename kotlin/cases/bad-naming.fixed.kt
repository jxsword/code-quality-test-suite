package com.example.qcts

/** 命名违规反面用例：类名小写开头（detekt ClassNaming 要求 PascalCase）。 */
class BadNaming {
    fun greet(): String = "hi"
}
