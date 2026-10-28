<?php

declare(strict_types=1);

namespace CodeQuality;

// Lint 违规反面用例：改用 $b 后通过。
function add(int $a, int $b): int
{
    return $a + $b;
}
