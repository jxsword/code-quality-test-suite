package com.example.qcts

/** Lint 违规反面用例：未使用的私有成员（detekt UnusedPrivateMember 将报错）。 */
class BadLint {
    fun greet(): String {
        return "hi"
    }
}
