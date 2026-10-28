<?php

declare(strict_types=1);

namespace CodeQuality;

// 格式违规反面用例：花括号与函数同行、双引号、多行数组缺尾逗号（php-cs-fixer @PSR12 将重排）。
function buildGreeting(): array {
    $parts = ["Hello",
              "world"];
    return $parts;
}
