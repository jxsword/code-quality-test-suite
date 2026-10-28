// 命名违规反面用例：接口 User 缺少 I 前缀（@typescript-eslint/naming-convention 要求 ^I[A-Z]）。

export interface User {
  name: string;
}

export function greetUser(user: User): string {
  return user.name;
}
