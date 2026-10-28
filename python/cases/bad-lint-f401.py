"""Lint 违规反面用例：未使用的导入（ruff F401 将报错）。"""

import os


def get_message() -> str:
    return "hello"
