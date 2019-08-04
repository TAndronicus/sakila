create or replace type id_table
as table of number not null;

create or replace function select_films_by_category(cat_id number)
return id_table
deterministic as
begin
    select FILM_ID
    from FILM_CATEGORY where cat_id = CATEGORY_ID;
end;

-- Performance comparison `inner join`, `exists`, `in`
select r.*
        from rental r
                 inner join payment p on r.rental_id = p.rental_id;
-- (execution: 6 ms, fetching: 51 ms)
-- cost=510.99..1116.68
explain select *
        from rental r
        where exists(
                      select null
                      from payment p
                      where p.rental_id = r.rental_id
                  );
-- (execution: 15 ms, fetching: 48 ms)
-- cost=844.75..1516.18
explain select r.*
        from rental r
        where r.rental_id in (
            select r.rental_id
            from payment p
            where p.rental_id = r.rental_id
        );
-- (execution: 31 ms, fetching: 133 ms)
-- cost=0.75..3869882.58

-- Fibonacci series
with fibbonaci(a, b) as (
    select 1, 1
    from DUAL
    union all
    select b, a + b
    from fibbonaci
    where b < 1000
) select *
from fibbonaci;

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
