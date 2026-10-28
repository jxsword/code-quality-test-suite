#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# java/run-tests.sh —— google-java-format(Spotless) + Checkstyle 正/反用例实测
# 离线可用：JDK17 / 工具 jar 缺失时降级 warn 不阻断（CI 覆盖回填）
# 风格由 google-java-format 1.37.0 承担；命名 + Lint 由 Checkstyle 14.3.0（checkstyle.xml）承担。
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="Java"
TOOLCHAIN="google-java-format 1.37.0 + checkstyle 14.3.0（JDK21，编译 release 17）"
source ../scripts/common.sh

# ---- 探测 JDK21（优先 21；google-java-format 1.37.0 / checkstyle 14.3.0 需 JDK21，class 版本 65）----
# 说明：任务基线写 JDK17，但锁定版 gjf 1.37.0 / checkstyle 14.3.0 实际编译目标为 JDK21，
# 因此要求 Temurin 21（仍可编译/校验 release 17 代码）。
pick_jdk21() {
    local candidates=("$HOME/jdk21" "$HOME/jdk17")
    local c v
    for c in "${candidates[@]}"; do
        if [ -x "$c/bin/java" ]; then
            v="$("$c/bin/java" -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/')"
            if [ "${v:-0}" -ge 21 ] 2> /dev/null; then
                export JAVA_HOME="$c"
                export PATH="$JAVA_HOME/bin:$PATH"
                return 0
            fi
        fi
    done
    if command -v java > /dev/null 2>&1; then
        v="$(java -version 2>&1 | head -1 | sed -E 's/.*"([0-9]+).*/\1/')"
        if [ "${v:-0}" -ge 21 ] 2> /dev/null; then
            return 0
        fi
    fi
    return 1
}

# 没有 >=21 的 JDK 时下载 Temurin 21（CI 与沙箱通用；沙箱已装则 pick_jdk21 直接命中不重复下载）
ensure_jdk21() {
    if pick_jdk21; then
        return 0
    fi
    echo "[..] 未找到 JDK21，尝试下载 Temurin 21 到 $HOME/jdk21 ..."
    mkdir -p "$HOME/jdk21"
    curl -fsSL 'https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jdk/hotspot/normal/eclipse' \
        -o /tmp/jdk21.tgz \
        && tar -xzf /tmp/jdk21.tgz --strip-components=1 -C "$HOME/jdk21" || true
    pick_jdk21
}

GJF_JAR="$HOME/tools/google-java-format-1.37.0-all-deps.jar"
CS_JAR="$HOME/tools/checkstyle-14.3.0-all.jar"

if ! ensure_jdk21; then
    echo "[WARN] 未找到 JDK21 且下载失败（google-java-format 1.37.0 / checkstyle 14.3.0 需 JDK21）。降级记录，CI 回填。"
    TOOLCHAIN="JDK21 缺失，本机降级（CI 回填）"
    summary_finalize
    exit 0
fi
echo "[ok] java -> $(command -v java)（$(java -version 2>&1 | head -1)）"

# 工具 jar 缺失时先下载到 $HOME/tools（与原路径一致），下载失败才降级
mkdir -p "$HOME/tools"
if [ ! -f "$GJF_JAR" ]; then
    echo "[..] 下载 google-java-format 1.37.0 ..."
    curl -fsSL 'https://github.com/google/google-java-format/releases/download/v1.37.0/google-java-format-1.37.0-all-deps.jar' \
        -o "$GJF_JAR" || true
fi
if [ ! -f "$CS_JAR" ]; then
    echo "[..] 下载 checkstyle 14.3.0 ..."
    curl -fsSL 'https://github.com/checkstyle/checkstyle/releases/download/checkstyle-14.3.0/checkstyle-14.3.0-all.jar' \
        -o "$CS_JAR" || true
fi
if [ ! -f "$GJF_JAR" ] || [ ! -f "$CS_JAR" ]; then
    echo "[WARN] 缺少工具 jar（$GJF_JAR 或 $CS_JAR）且下载失败，降级记录，CI 回填。"
    summary_finalize
    exit 0
fi

# ---- 用例工作区（cases/ 夹具永不被修改）----
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.java cases/bad-naming.java cases/bad-lint.java "$WORK/"

# ---- 正面用例（预期 PASS）----
# google-java-format CLI 不递归目录，需显式传入 .java 文件
mapfile -t SRC_JAVA < <(find src/main/java -name '*.java')
run_ok "case-ok-1" "src 通过 google-java-format（等价 mvn spotless:check）" \
    java -jar "$GJF_JAR" --dry-run --set-exit-if-changed "${SRC_JAVA[@]}"

run_ok "case-ok-2" "src 通过 checkstyle（命名模块组 + UnusedImports）" \
    java -jar "$CS_JAR" -c checkstyle.xml src/main/java

# ---- 反面用例 1：格式违规（4 空格缩进 → gjf 自动重排）----
run_fail "case-bad-1" "格式违规：4 空格缩进（google-java-format 要求 2 空格）" "格式" \
    java -jar "$GJF_JAR" --dry-run --set-exit-if-changed "$WORK/bad-format.java"
run_fix "case-bad-1" "google-java-format --replace 自动重排为 2 空格" \
    bash -c "java -jar '$GJF_JAR' --replace '$WORK/bad-format.java' && java -jar '$GJF_JAR' --dry-run --set-exit-if-changed '$WORK/bad-format.java'"

# ---- 反面用例 2：命名违规（常量小驼峰 → ConstantName，需手工重命名）----
run_fail "case-bad-2" "命名违规：常量 maxRetries 应为 UPPER_SNAKE_CASE（ConstantName）" "命名" \
    java -jar "$CS_JAR" -c checkstyle.xml "$WORK/bad-naming.java"
run_fix "case-bad-2" "手工重命名为 MAX_RETRIES（ConstantName 不可自动修复）" \
    bash -c "cp cases/bad-naming.fixed.java '$WORK/bad-naming.java' && java -jar '$CS_JAR' -c checkstyle.xml '$WORK/bad-naming.java'"

# ---- 反面用例 3：Lint 违规（未使用 import → UnusedImports，删除即可）----
run_fail "case-bad-3" "Lint 违规：List/ArrayList 未使用导入（UnusedImports）" "Lint" \
    java -jar "$CS_JAR" -c checkstyle.xml "$WORK/bad-lint.java"
run_fix "case-bad-3" "删除未使用 import" \
    bash -c "cp cases/bad-lint.fixed.java '$WORK/bad-lint.java' && java -jar '$CS_JAR' -c checkstyle.xml '$WORK/bad-lint.java'"

# ---- 可选：Maven 集成验证（非阻断；CI 主路径 mvn verify）----
MVN_BIN=""
if command -v mvn > /dev/null 2>&1; then
    MVN_BIN="mvn"
elif [ -x "$HOME/maven/bin/mvn" ]; then
    MVN_BIN="$HOME/maven/bin/mvn"
fi
if [ -n "$MVN_BIN" ]; then
    echo "[..] 检测到 Maven，执行 mvn checkstyle:check（pom 集成：checkstyle 14.3.0 插件依赖覆盖）..."
    if "$MVN_BIN" -q -DskipTests checkstyle:check > "$RESULTS_DIR/maven-integration.log" 2>&1; then
        echo "[ok] Maven checkstyle 集成验证通过，输出见 results/maven-integration.log"
        printf 'PASS\tcase-ok-maven\tpom 声明的 mvn checkstyle:check（checkstyle 14.3.0）通过\n' >> "$PASS_LOG"
    else
        echo "[WARN] Maven checkstyle 集成验证未通过（见 results/maven-integration.log），不影响 CLI 用例；CI 回填"
    fi
    # spotless:check 已知问题：spotless-maven-plugin 内部仍以反射调用 Style.valueOf(String)，
    # 而 gjf 1.37.0 已将 Style 重构为 record（无该方法），本地无法跑通；
    # google-java-format 1.37.0 的真实格式化行为已由独立 jar 在本脚本正面用例验证。
    echo "[note] mvn spotless:check 因 spotless 插件与 gjf 1.37.0（Style 记录化）反射不兼容暂不在本机执行；CI 回填"
else
    echo "[WARN] 未找到 Maven，跳过 pom 集成验证（CLI jar 已覆盖工具行为）；CI 回填 mvn 结果"
fi

summary_finalize
