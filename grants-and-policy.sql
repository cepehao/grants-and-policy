create or replace view workers_id_view as
select w.id, w.name || '_' || w.surname as name_surname
from sale as s join worker as w
on w.id =s.worker_id;

select * from workers_id_view

CREATE ROLE base_user NOINHERIT;

CREATE ROLE director INHERIT;
CREATE ROLE manager INHERIT;
CREATE ROLE saler INHERIT;

GRANT base_user TO director, manager, saler;

GRANT SELECT ON work_time TO base_user;

GRANT SELECT, INSERT, UPDATE, DELETE 
ON ALL TABLES IN SCHEMA public TO director;

set role director;
insert into post values(default, 'saler', 20000), (default, 'oldest_saler', 30000);
insert into worker values(default, 1, 'Aleksandr', 'Ivanov'), (default, 2, 'Maksim', 'Petrov');
insert into sale values(default, 1, 'notebook', 1), (default, 1, 'mousepad', 3),
				 		(default, 2, 'iphone 12', 5), (default, 2, 'apple airpods 2', 7);

set role base_user;
insert into post values(default, 'noinsert', 88888);

--привилегии для менеджера
GRANT SELECT, INSERT, UPDATE, DELETE ON sale, worker TO manager;

--подготовка политики для продавца (выдаем роли продавца доступ к таблице продаж и представлению)
grant SELECT, INSERT, UPDATE, DELETE on sale to saler;
grant select on workers_id_view to saler

create role Aleksandr_Ivanov LOGIN;
grant saler to Aleksandr_Ivanov;

alter table sale enable row level security;

CREATE POLICY saler_policy ON sale FOR ALL TO saler
USING (worker_id in (SELECT id FROM workers_id_view WHERE LOWER(name_surname) = current_user))
WITH CHECK (worker_id in (SELECT id FROM workers_id_view WHERE LOWER(name_surname) = current_user));

set role Aleksandr_Ivanov;
select * from sale;

update sale set amount = amount + 1;

select * from work_time

drop policy saler_policy on sale 
alter table sale disable row level security;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM Aleksandr_ivanov;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM saler;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM manager;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM director;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM base_user;

drop role Aleksandr_Ivanov;
drop role saler;
drop role manager;
drop role director;
drop role base_user;

set role postgres;
select current_user