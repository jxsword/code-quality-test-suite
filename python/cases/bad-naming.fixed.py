"""命名违规反面用例：类名使用 snake_case（ruff N801 将报错）。"""


class BadClassName:
    """反例类。"""

    def method(self) -> int:
        return 42
