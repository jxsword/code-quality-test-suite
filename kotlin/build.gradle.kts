// kotlin/build.gradle.kts —— 供 CI 用 Gradle 跑 ktlint / detekt。
// 本地实测优先用独立 jar（run-tests.sh 直接 java -jar），无需拉起 Gradle 守护进程。
plugins {
    kotlin("jvm") version "1.9.24"
    id("org.jlleitschuh.gradle.ktlint") version "12.1.1"
    id("io.gitlab.arturbosch.detekt") version "1.23.8"
}

repositories {
    mavenCentral()
}

ktlint {
    version.set("1.8.0")
}

detekt {
    config.setFrom(rootProject.files("detekt-config.yml"))
    buildUponDefaultConfig = false
}
