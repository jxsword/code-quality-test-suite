// 命名违规反面用例：手工重命名为 IUser 后通过。

export interface IUser {
  name: string;
}

export function greetUser(user: IUser): string {
  return user.name;
}
