<?php

declare(strict_types=1);

namespace CodeQuality;

// 命名违规反面用例：手工重命名为 PascalCase / camelCase 后通过。
final class BadClassName
{
    public function doWork(): string
    {
        return 'x';
    }
}
