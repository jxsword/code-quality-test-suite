-- cases/bad-format.sql —— 反面用例：关键字小写（CP01/L010 要求全大写）
select
    user_id,
    username
from users
where user_id >= 1
order by username desc;
