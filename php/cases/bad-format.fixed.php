<?php

declare(strict_types=1);

namespace CodeQuality;

// 格式违规反面用例：php-cs-fixer 自动修复后版本（花括号换行、单引号、多行数组尾逗号）。
function buildGreeting(): array
{
    $parts = [
        'Hello',
        'world',
    ];
    return $parts;
}
