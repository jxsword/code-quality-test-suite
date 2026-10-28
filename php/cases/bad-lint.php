<?php

declare(strict_types=1);

namespace CodeQuality;

// Lint 违规反面用例：引用未定义变量 $undefinedVariable（PHPStan level 5 报错）。
function add(int $a, int $b): int
{
    return $a + $undefinedVariable;
}
