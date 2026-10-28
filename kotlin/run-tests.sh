#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# kotlin/run-tests.sh —— ktlint 1.8.0（格式）+ detekt 1.23.8（命名/Lint）正/反用例实测
# 本地优先用独立 jar：ktlint 可执行资产 + detekt-cli-all.jar；均需 JDK17+。
# 工具缺失时降级 warn 不阻断（CI 覆盖回填）。JVM 工具严格串行，避免 OOM。
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="Kotlin"
TOOLCHAIN="ktlint 1.8.0 + detekt 1.23.8（JDK17+）"
source ../scripts/common.sh

# ---- 探测 JDK21（优先 21；ktlint 1.8.0 / detekt 1.23.8 在其上稳定运行）----
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

# 没有 >=21 的 JDK 时下载 Temurin 21（CI 与沙箱通用；沙箱已装则直接命中不重复下载）
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

KTLINT_BIN="$HOME/tools/ktlint"
DETEKT_JAR="$HOME/tools/detekt-cli-1.23.8-all.jar"

if ! ensure_jdk21; then
    echo "[WARN] 未找到 JDK21 且下载失败（ktlint 1.8.0 / detekt 1.23.8 需要）。降级记录，CI 回填。"
    TOOLCHAIN="JDK21 缺失，本机降级（CI 回填）"
    summary_finalize
    exit 0
fi
echo "[ok] java -> $(command -v java)（$(java -version 2>&1 | head -1)）"

# 工具缺失时先下载到 $HOME/tools（与原路径一致），下载失败才降级
mkdir -p "$HOME/tools"
if [ ! -x "$KTLINT_BIN" ]; then
    echo "[..] 下载 ktlint 1.8.0 ..."
    curl -fsSL 'https://github.com/pinterest/ktlint/releases/download/1.8.0/ktlint' \
        -o "$KTLINT_BIN" || true
    chmod +x "$KTLINT_BIN" 2> /dev/null || true
fi
if [ ! -f "$DETEKT_JAR" ]; then
    echo "[..] 下载 detekt-cli 1.23.8 ..."
    curl -fsSL 'https://github.com/detekt/detekt/releases/download/v1.23.8/detekt-cli-1.23.8-all.jar' \
        -o "$DETEKT_JAR" || true
fi
if [ ! -x "$KTLINT_BIN" ] || [ ! -f "$DETEKT_JAR" ]; then
    echo "[WARN] 缺少 ktlint / detekt 独立 jar（$KTLINT_BIN 或 $DETEKT_JAR）且下载失败，降级记录，CI 回填。"
    summary_finalize
    exit 0
fi

# ---- 用例工作区（cases/ 夹具永不被修改）----
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"
cp cases/bad-format.kt cases/bad-naming.kt cases/bad-lint.kt "$WORK/"

# ---- 正面用例（预期 PASS）----
run_ok "case-ok-1" "src 通过 ktlint（格式 + 命名规则）" \
    "$KTLINT_BIN" "src/main"

run_ok "case-ok-2" "src 通过 detekt（命名 + MagicNumber + UnusedPrivateMember）" \
    java -jar "$DETEKT_JAR" --config detekt-config.yml --input src/main/kotlin

# ---- 反面用例 1：格式违规（缩进不对齐 → ktlint -F 自动修复）----
run_fail "case-bad-1" "格式违规：方法体未按 4 空格缩进（ktlint indent 规则）" "格式" \
    "$KTLINT_BIN" "$WORK/bad-format.kt"
run_fix "case-bad-1" "ktlint -F 自动补齐 4 空格缩进" \
    bash -c "'$KTLINT_BIN' -F '$WORK/bad-format.kt' && '$KTLINT_BIN' '$WORK/bad-format.kt'"

# ---- 反面用例 2：命名违规（类名小写 → ClassNaming，需手工重命名）----
run_fail "case-bad-2" "命名违规：类名 badNaming 应为 PascalCase（detekt ClassNaming）" "命名" \
    java -jar "$DETEKT_JAR" --config detekt-config.yml --input "$WORK/bad-naming.kt"
run_fix "case-bad-2" "手工重命名为 BadNaming（ClassNaming 不可自动修复）" \
    bash -c "cp cases/bad-naming.fixed.kt '$WORK/bad-naming.kt' && java -jar '$DETEKT_JAR' --config detekt-config.yml --input '$WORK/bad-naming.kt'"

# ---- 反面用例 3：Lint 违规（未使用私有方法 → UnusedPrivateMember，删除即可）----
run_fail "case-bad-3" "Lint 违规：私有方法 unusedHelper 未被使用（UnusedPrivateMember）" "Lint" \
    java -jar "$DETEKT_JAR" --config detekt-config.yml --input "$WORK/bad-lint.kt"
run_fix "case-bad-3" "删除未使用的私有成员" \
    bash -c "cp cases/bad-lint.fixed.kt '$WORK/bad-lint.kt' && java -jar '$DETEKT_JAR' --config detekt-config.yml --input '$WORK/bad-lint.kt'"

summary_finalize
