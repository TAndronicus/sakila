-- Generated column
select *
from PAYMENT;
set integrity for payment off;
alter table PAYMENT
    add column TOTAL_COST DECIMAL(10, 2) generated ALWAYS AS (RENTAL_ID * AMOUNT);
set integrity for payment IMMEDIATE CHECKED FORCE GENERATED;

-- User-defined function
create or replace function select_films_by_category(cat_id integer)
    returns table
            (
                film_id smallint
            )
    language sql
    reads sql data
    no external action
    deterministic
    return select film_id
           from film_category
           where category_id = cat_id;
select *
from FILM
where FILM_ID in (select * from table(select_films_by_category(2)));

-- Performance comparison `inner join`, `exists`, `in`
select r.*
from rental r
         inner join payment p on r.rental_id = p.rental_id;
-- (execution: 11 ms, fetching: 43 ms)
-- cost=510.99..1116.68
select *
from rental r
where exists(
              select null
              from payment p
              where p.rental_id = r.rental_id
          );
-- (execution: 9 ms, fetching: 45 ms)
-- cost=844.75..1516.18
select r.*
from rental r
where r.rental_id in (
    select r.rental_id
    from payment p
    where p.rental_id = r.rental_id
);
-- (execution: 10 ms, fetching: 35 ms)
-- cost=0.75..3869882.58

-- Limit count
select *
from ACTOR
order by LAST_NAME
limit 5;
select *
from ACTOR
order by LAST_NAME
    fetch first 5 rows only;
select ACTOR_ID, FIRST_NAME, LAST_NAME, LAST_UPDATE
from (
         select *, row_number() over (order by LAST_NAME) rownum
         from ACTOR
     )
where rownum <= 5;

-- Window functions
select customer_id,
       amount,
       sum(amount) over (partition by customer_id order by payment_date),
       sum(amount) over (order by customer_id, payment_date)
from payment
order by customer_id, payment_date;

select payment_id, amount, rank() over (partition by customer_id order by amount), row_number() over (order by customer_id, amount)
from payment
order by customer_id, amount;

select customer_id, amount,
       sum(amount) over (partition by customer_id order by amount range between unbounded preceding and current row),
    avg(amount) over (partition by customer_id order by amount rows between 1 preceding and 1 following)
from payment
order by customer_id, amount;

-- Explain plan table
call SYSPROC.SYSINSTALLOBJECTS('EXPLAIN', 'C', cast(null as varchar(128)), cast(null as varchar(128)));
