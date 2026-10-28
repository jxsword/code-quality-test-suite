<?php

declare(strict_types=1);

namespace CodeQuality;

/**
 * 问候服务（正面用例，预期通过 phpcs + php-cs-fixer + phpstan）。
 */
final class Greeter
{
    private string $punctuation;

    public const DEFAULT_GREETING = 'Hello';

    public function __construct(string $punctuation = '!')
    {
        $this->punctuation = $punctuation;
    }

    public function greet(string $name): string
    {
        return self::DEFAULT_GREETING . ', ' . $name . $this->punctuation;
    }
}
