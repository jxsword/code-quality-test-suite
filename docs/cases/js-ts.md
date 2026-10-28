# JS/TS 用例设计（正/反用例）

> 语言：JavaScript / TypeScript　工具链：**Prettier 3.9.10**（格式化）+ **ESLint 10.13.0** + **typescript-eslint 8.72.1**（flat config）
> 配置：`js-ts/eslint.config.js`（flat config，`@typescript-eslint/naming-convention` 承担命名强制）+ `js-ts/.prettierrc`（singleQuote / semi / printWidth=100）。
> 目录：`src/` 正面用例；`cases/` 反面用例夹具（被 `.pre-commit-config.yaml` 顶层 exclude，hook 不检查）；`run-tests.sh` 实测脚本；`results/` 运行产物（gitignored）。

## 正面用例

| 用例文件 | 内容 | 验证点 |
|---|---|---|
| `src/greeter.ts` | 问候服务（enum + interface I 前缀 + type alias + class + 私有 `_camelCase` 字段 + 常量 UPPER_CASE） | `npx eslint src/`（含 naming-convention / no-unused-vars / no-explicit-any）与 `npx prettier --check src/` 均 PASS |

## 反面用例（3 个，覆盖格式 / 命名 / Lint）

| 用例 ID | 夹具文件 | 违规类型 | 触发规则 | 修复方式 | 可自动修复 |
|---|---|---|---|---|---|
| case-bad-1 | `cases/bad-format.ts` | 格式 | prettier --check（双引号 / 缺分号 / 4 空格缩进） | `prettier --write` 自动重排 | ✅ |
| case-bad-2 | `cases/bad-naming.ts` | 命名 | **@typescript-eslint/naming-convention**：接口 `User` 缺 I 前缀（应匹配 `^I[A-Z]`） | 手工重命名 `IUser` | ❌ |
| case-bad-3 | `cases/bad-lint.ts` | Lint | **@typescript-eslint/no-explicit-any**（显式 any） | 改用泛型 `<T>` 消除 any | ❌ |

## 运行方式

```bash
cd js-ts && bash run-tests.sh
# 产物：results/pass.log、results/fail-<id>.log（错误原文）、results/fix-<id>.log（修复验证）、results/summary.md
# 首次运行自动 npm ci（有 package-lock.json）/ npm install；npx 捕获真实输出。
```

> 说明：`package-lock.json` 随仓库提交，CI 缓存 key 依赖它（`npm-${{ hashFiles('js-ts/package-lock.json') }}`）。
