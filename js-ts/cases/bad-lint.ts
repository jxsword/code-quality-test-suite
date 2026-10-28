// Lint 违规反面用例：显式 any（@typescript-eslint/no-explicit-any 报错）。

export function identity(value: any): any {
  return value;
}
