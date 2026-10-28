// eslint.config.js —— JS/TS flat config（ESLint 10 + typescript-eslint 8）
// 命名约束由 @typescript-eslint/naming-convention 承担；Lint 规则含 no-unused-vars / no-explicit-any。
import tseslint from 'typescript-eslint';

export default tseslint.config(
  // 忽略目录（不忽略 results/，因为 run-tests.sh 会把反面用例复制到 results/.casework 并实测）
  {
    ignores: ['node_modules/**', 'dist/**'],
  },
  // typescript-eslint 推荐规则集（含 @typescript-eslint/no-unused-vars 等）
  ...tseslint.configs.recommended,
  {
    files: ['**/*.ts'],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: 'module',
    },
    rules: {
      // Lint 规则
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/no-explicit-any': 'error',

      // 命名约束：
      '@typescript-eslint/naming-convention': [
        'error',
        // 接口：必须 I 前缀 + PascalCase（如 IGreeting）
        {
          selector: 'interface',
          format: ['PascalCase'],
          custom: { regex: '^I[A-Z][a-zA-Z0-9]*$', match: true },
        },
        // 类型别名：PascalCase（如 GreetingResult）
        { selector: 'typeAlias', format: ['PascalCase'] },
        // class：PascalCase
        { selector: 'class', format: ['PascalCase'] },
        // enum：PascalCase；枚举成员：PascalCase
        { selector: 'enum', format: ['PascalCase'] },
        { selector: 'enumMember', format: ['PascalCase'] },
        // 函数：camelCase
        { selector: 'function', format: ['camelCase'] },
        // 变量：camelCase 或 UPPER_CASE（常量）
        { selector: 'variable', format: ['camelCase', 'UPPER_CASE'] },
        // 参数：camelCase，允许 _ 前缀
        { selector: 'parameter', format: ['camelCase'], leadingUnderscore: 'allow' },
        // 类方法：camelCase
        { selector: 'classMethod', format: ['camelCase'] },
      ],
    },
  },
);
