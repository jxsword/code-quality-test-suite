"""Lint 违规反面用例：可变默认参数（ruff B006 将报错）。"""


def append_item(item: str, items: list[str] = []) -> list[str]:
    items.append(item)
    return items
