# Shell 实测结果（lint-test-results）

> 实测环境：本地沙箱（2026-10-28 14:23 +08:00）　工具链：**shfmt v3.14.1 + shellcheck 0.11.0**
> 正面用例 3/3 PASS；反面用例 3/3 均按预期 FAIL，修复后全部 PASS。

## 正面用例

| 用例 | 说明 | 结果 |
|---|---|---|
| case-ok-1 | src/greeter.sh 通过 shfmt -d（格式检查） | PASS |
| case-ok-2 | src/greeter.sh 通过 shellcheck（含 .shellcheckrc） | PASS |
| case-ok-3 | src/greeter.sh 通过 shell-naming-check.sh 命名检查 | PASS |

> 说明：shfmt -d / shellcheck / 命名检查在“无问题”时均不输出（exit=0），故 `case-ok-*.log` 为空文件，这是三者的真实成功行为。

## 反面用例：错误输出原文 + 修复方案

### case-bad-1　格式违规（shfmt -d，exit=1）

```text
diff results/.casework/bad-format.sh.orig results/.casework/bad-format.sh
--- results/.casework/bad-format.sh.orig
+++ results/.casework/bad-format.sh
@@ -3,11 +3,11 @@
 set -euo pipefail

 greet() {
-  local name="$1"
-  if [ -n "$name" ];then
-    printf 'Hi, %s\n' "$name"
-  fi
-  echo "done" >/dev/null
+    local name="$1"
+    if [ -n "$name" ]; then
+        printf 'Hi, %s\n' "$name"
+    fi
+    echo "done" > /dev/null
 }

 greet "World"
```

**修复**：`shfmt -w -i 4 -ci -sr -s bad-format.sh` 自动重排（缩进 4 空格、`if` 后补空格、重定向两侧留空格）→ `shfmt -d` 通过（`fix-case-bad-1.log`，无输出=PASS）。

### case-bad-2　Lint 违规（shellcheck，exit=1）

```text
In results/.casework/bad-lint.sh line 8:
    cd "$dest"
    ^--------^ SC2164 (warning): Use 'cd ... || exit' or 'cd ... || return' in case cd fails.

Did you mean:
    cd "$dest" || exit


In results/.casework/bad-lint.sh line 9:
    cp -r $src ./backup
          ^--^ SC2086 (info): Double quote to prevent globbing and word splitting.

Did you mean:
    cp -r "$src" ./backup
```

**修复**：`$src` 改为 `"$src"` 加双引号；`cd "$dest" || { ...; return 1; }` 判断返回值（ShellCheck 无 `--fix`，手工修复）→ `shellcheck` 通过（`fix-case-bad-2.log`）。
> 注：本夹具刻意未开 `set -e`，否则 ShellCheck 会因 `set -e` 自动退出而抑制 SC2164，正好演示该规则的触发条件。

### case-bad-3　命名违规（shell-naming-check.sh，exit=1）

```text
10:DeployArtifact() {
::error file=results/.casework/bad-naming.sh::函数名必须为小写 snake_case
11:    local Target="$1"
::error file=results/.casework/bad-naming.sh::local 局部变量必须小写 snake_case
8:export app_home=/tmp/app
::error file=results/.casework/bad-naming.sh::export 变量必须 UPPER_SNAKE_CASE
```

**修复**：函数 `DeployArtifact` → `deploy_artifact`、`local Target` → `local target`、`export app_home` → `export APP_HOME`（正则命名检查不可自动修复，手工重命名）→ 命名检查通过（`fix-case-bad-3.log`）。

## 小结

| 用例 | 违规类型 | 错误信息原文 | 修复方案 | 修复后验证 |
|---|---|---|---|---|
| case-bad-1 | 格式 | results/fail-case-bad-1.log | shfmt -w 自动重排 | PASS |
| case-bad-2 | Lint SC2086/SC2164 | results/fail-case-bad-2.log | 加引号 + cd 判断返回值 | PASS |
| case-bad-3 | 命名（正则） | results/fail-case-bad-3.log | snake_case 函数/local、大写 export | PASS |

> **CI 实测**：全量运行 40662260620 通过（shfmt v3.14.1 / shellcheck 0.11.0，版本与本地一致）。
