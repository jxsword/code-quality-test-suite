#!/usr/bin/env bash
# shellcheck disable=SC1091,SC2034  # source 的 common.sh 单独受检；LANG_NAME/TOOLCHAIN 由 common.sh 消费
# dotnet/run-tests.sh —— dotnet format（格式）+ Roslyn/StyleCop（命名 + Lint）正/反用例实测
# 离线/降级：SDK 不在 PATH 时尝试 ~/.dotnet；仍缺则尝试 dotnet-install.sh 装到 ~/.dotnet；
#           仍失败则降级 warn 不阻断（CI 用 actions/setup-dotnet 覆盖回填）。
set -euo pipefail
cd "$(dirname "$0")"

LANG_NAME="C#/.NET"
TOOLCHAIN="dotnet format + NetAnalyzers + StyleCop.Analyzers（.editorconfig dotnet_naming_rule 系列）"
source ../scripts/common.sh

# 1. 定位 / 安装 .NET SDK（装进 Home，不写系统目录）
export DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
export PATH="$DOTNET_ROOT:$PATH"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOTNET_NOLOGO=1

if ! command -v dotnet > /dev/null 2>&1; then
    if [ -x "$DOTNET_ROOT/dotnet" ]; then
        export PATH="$DOTNET_ROOT:$PATH"
    else
        echo "[..] 未找到 .NET SDK，尝试 dotnet-install.sh 安装 8.0 到 $DOTNET_ROOT ..."
        curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh &&
            chmod +x /tmp/dotnet-install.sh &&
            /tmp/dotnet-install.sh --channel 8.0 --install-dir "$DOTNET_ROOT" || true
    fi
fi
if ! tool_require ".NET SDK" "dotnet"; then
    summary_finalize
    exit 0
fi
TOOLCHAIN="dotnet SDK $(dotnet --version)（dotnet format + NetAnalyzers + StyleCop.Analyzers 1.3.151-beta）"

# 准备用例工作区：每个反面用例一个独立小工程（拷贝 csproj + editorconfig + Case.cs）
WORK="results/.casework"
rm -rf "$WORK"
mkdir -p "$WORK"

setup_case() { # <case名> <源文件>
    local d="$WORK/$1"
    mkdir -p "$d"
    cp DotnetSample.csproj .editorconfig "$d/"
    cp "$2" "$d/Case.cs"
}

# 2. 正面用例（预期 PASS）
run_ok "case-ok-1" "DotnetSample 通过 dotnet build（含 Roslyn 分析器 + EnforceCodeStyleInBuild 命名规则）" dotnet build -nologo
run_ok "case-ok-2" "DotnetSample 通过 dotnet format whitespace --verify-no-changes" dotnet format whitespace --verify-no-changes

# 3. 反面用例 1：格式违规（dotnet format whitespace --verify-no-changes 失败 → 自动重排 → 通过）
setup_case bad-format cases/bad-format.cs
run_fail "case-bad-1" "格式违规：花括号与类同行/2 空格缩进，dotnet format whitespace 判定需重排" "格式" bash -c "cd $WORK/bad-format && dotnet format whitespace --verify-no-changes"
run_fix "case-bad-1" "dotnet format whitespace 自动重排（花括号换行/4 空格）后通过" bash -c "cd $WORK/bad-format && dotnet format whitespace && dotnet format whitespace --verify-no-changes"

# 4. 反面用例 2：命名违规（接口缺 I 前缀，dotnet_naming_rule + EnforceCodeStyleInBuild，不可自动修复）
setup_case bad-naming cases/bad-naming.cs
run_fail "case-bad-2" "命名违规：接口 GreeterOptions 缺少 I 前缀（dotnet_naming_rule.interfaces_i_prefix）" "命名" bash -c "cd $WORK/bad-naming && dotnet build -nologo"
run_fix "case-bad-2" "手工重命名为 IGreeterOptions（命名规则不可自动修复）" bash -c "cp cases/bad-naming.fixed.cs $WORK/bad-naming/Case.cs && cd $WORK/bad-naming && dotnet build -nologo"

# 5. 反面用例 3：Lint 违规（SA1101 实例成员未加 this. 前缀，需手工补 this.）
setup_case bad-lint cases/bad-lint.cs
run_fail "case-bad-3" "Lint 违规：实例方法 BuildGreeting 未加 this. 前缀（StyleCop SA1101）" "Lint" bash -c "cd $WORK/bad-lint && dotnet build -nologo"
run_fix "case-bad-3" "实例成员前补 this. 后通过" bash -c "cp cases/bad-lint.fixed.cs $WORK/bad-lint/Case.cs && cd $WORK/bad-lint && dotnet build -nologo"

# 6. 汇总
summary_finalize
