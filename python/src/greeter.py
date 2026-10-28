"""示例：问候服务（正面用例，预期通过 ruff check + ruff format --check）。"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass
class Greeter:
    """问候器：统一输出格式。"""

    greeting: str = "Hello"
    _punctuation: str = "!"

    def greet(self, name: str) -> str:
        """向指定名字发出问候。"""
        return f"{self.greeting}, {name}{self._punctuation}"
