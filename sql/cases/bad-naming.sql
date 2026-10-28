-- cases/bad-naming.sql —— 反面用例：标识符 CamelCase（CP02/L014 要求小写 snake_case）
SELECT
    UserID,
    UserName,
    OrderCount
FROM UserOrders
WHERE OrderCount >= 3
ORDER BY UserName DESC;
