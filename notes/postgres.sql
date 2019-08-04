-- User-defined function
create function select_films_by_category(cat_id int)
    returns table
            (
                film_id smallint
            )
as
$$
select film_id
from film_category
where category_id = cat_id
$$
    language sql;
select select_films_by_category(2);

explain
    select *
    from film
    where film_id in (select select_films_by_category(1));

explain
    select *
    from film f
             inner join film_category fc on f.film_id = fc.film_id
    where fc.category_id = 1;

-- Performance comparison `inner join`, `exists`, `in`
explain select r.*
        from rental r
                 inner join payment p on r.rental_id = p.rental_id;
-- (execution: 15 ms, fetching: 118 ms)
-- cost=510.99..1116.68
explain select *
        from rental r
        where exists(
                      select null
                      from payment p
                      where p.rental_id = r.rental_id
                  );
-- (execution: 13 ms, fetching: 42 ms)
-- cost=844.75..1516.18
explain select r.*
        from rental r
        where r.rental_id in (
            select r.rental_id
            from payment p
            where p.rental_id = r.rental_id
        );
-- (execution: 323 ms, fetching: 62 ms)
-- cost=0.75..3869882.58

select distinct rating
from film;

-- Compare count and where performance
explain select count(case
                 when rating in ('PG', 'R', 'G') then rating
                 else null
    end)
from film;
-- 5ms
explain select count(*)
from film
where rating in ('PG', 'R', 'G');
-- 4ms

-- Fibonacci series
with recursive fibbonaci(a, b) as (
    select 1::int, 1::int
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
