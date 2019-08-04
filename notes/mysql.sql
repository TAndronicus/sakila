-- Generated column
alter table payment
    add column total_payment decimal(10, 2) as (rental_id * amount);
select *
from payment;

-- User-defined function
drop procedure select_films_by_category;
create procedure select_films_by_category(cat_id tinyint)
begin
    select film_id
    from film_category
    where category_id = cat_id;
end;

-- Performance comparison `inner join`, `exists`, `in`
explain select r.*
from rental r
         inner join payment p on r.rental_id = p.rental_id;
-- (execution: 19 ms, fetching: 177 ms)
explain select *
        from rental r
        where exists(
                      select null
                      from payment p
                      where p.rental_id = r.rental_id
                  );
-- (execution: 20 ms, fetching: 38 ms)
explain select r.*
        from rental r
        where r.rental_id in (
            select r.rental_id
            from payment p
            where p.rental_id = r.rental_id
        );
-- (execution: 8 ms, fetching: 46 ms)

-- Fibonacci series
with recursive fibbonaci(a, b) as (
    select 1, 1
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
