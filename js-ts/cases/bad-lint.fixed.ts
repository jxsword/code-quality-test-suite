// Lint 违规反面用例：改用泛型消除显式 any 后通过。

export function identity<T>(value: T): T {
  return value;
}
