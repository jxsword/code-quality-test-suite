-- src/active_users.sql —— SQL 正面用例（预期通过 sqlfluff lint）
-- 规范：关键字全大写（CP01/L010）；表/列名 snake_case 小写（CP02/L014）；函数名全大写（CP03/L030）。
WITH recent_orders AS (
    SELECT
        user_id,
        COUNT(*) AS order_count,
        MAX(created_at) AS last_order_at
    FROM orders
    WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY user_id
)

SELECT
    u.user_id,
    u.username,
    r.order_count,
    r.last_order_at
FROM users AS u
INNER JOIN recent_orders AS r
    ON u.user_id = r.user_id
WHERE r.order_count >= 3
ORDER BY r.last_order_at DESC;
