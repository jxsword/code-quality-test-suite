-- cases/bad-format.sql —— 反面用例：关键字小写（CP01/L010 要求全大写）
SELECT
    user_id,
    username
FROM users
WHERE user_id >= 1
ORDER BY username DESC;
