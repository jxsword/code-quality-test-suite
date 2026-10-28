<?php

declare(strict_types=1);

namespace CodeQuality;

// 命名违规反面用例：类名 snake_case、方法名 snake_case（phpcs 命名 sniff 要求 PascalCase / camelCase）。
class bad_class_name
{
    public function do_work(): string
    {
        return 'x';
    }
}
