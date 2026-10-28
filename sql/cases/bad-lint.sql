-- cases/bad-lint.sql —— 反面用例：函数名小写（CP03/L030 要求全大写）
SELECT
    user_id,
    count(*) AS order_count,
    now() AS snapshot_at
FROM orders
GROUP BY user_id;
