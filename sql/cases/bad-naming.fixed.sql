-- cases/bad-naming.fixed.sql —— 修复后版本：表/列名改为 snake_case 小写（通过 CP02/L014）
SELECT
    user_id,
    user_name,
    order_count
FROM user_orders
WHERE order_count >= 3
ORDER BY user_name DESC;
