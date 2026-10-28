// 正面用例：问候服务（预期同时通过 ESLint 与 Prettier --check）。

/** 问候种类枚举：成员使用 PascalCase。 */
export enum GreetingKind {
  Hello = 'Hello',
  Hi = 'Hi',
}

/** 问候请求：接口必须 I 前缀（naming-convention custom regex ^I[A-Z]）。 */
export interface IGreeting {
  name: string;
  kind: GreetingKind;
}

/** 问候结果：类型别名 PascalCase。 */
export type GreetingResult = string;

/** 问候器：class PascalCase；私有只读字段 _camelCase；方法 camelCase。 */
export class Greeter {
  private readonly _punctuation: string;

  constructor(punctuation: string = '!') {
    this._punctuation = punctuation;
  }

  greet(greeting: IGreeting): GreetingResult {
    return `${greeting.kind}, ${greeting.name}${this._punctuation}`;
  }
}

/** 常量：UPPER_CASE（variable 规则允许）。 */
export const DEFAULT_GREETING = GreetingKind.Hello;

/** 工厂函数：camelCase。 */
export function createGreeter(): Greeter {
  return new Greeter();
}
