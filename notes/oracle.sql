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

create table small_rental
(
    id           number primary key,
    rental_date  date   not null,
    inventory_id number not null references INVENTORY
);

drop function COPY_RENTAL;
create or replace function copy_rental(id in number)
    return rental%rowtype
    is
begin
    declare
        tmp_rent rental%rowtype;
    begin
        select *
        into tmp_rent
        from RENTAL
        where RENTAL_ID = id;
        return tmp_rent;
    end;
end;
/

declare
    res rental%rowtype;
begin
    res := copy_rental(169);
    dbms_output.PUT_LINE(res.RENTAL_DATE);
end;

begin
    for rental in (select * from RENTAL)
        loop
            insert into small_rental (id, rental_date, inventory_id)
            values (rental.RENTAL_ID, rental.RENTAL_DATE, rental.INVENTORY_ID);
        end loop;
    commit;
end;
/

-- huge performance issues
declare
    cursor cur(stid number)
        is
        select *
        from RENTAL
        where STAFF_ID = stid;
    nr rental%rowtype;
begin
    open cur(2);
    loop
        fetch cur into nr;
        exit when cur%notfound;
        insert into small_rental (id, rental_date, inventory_id)
        values (nr.RENTAL_ID, nr.RENTAL_DATE, nr.INVENTORY_ID);
    end loop;
    close cur;
end;
/

declare
    type rental_cursor is ref cursor return rental%rowtype;
    cur         rental_cursor;
    placeholder rental%rowtype;
begin
    open cur for select *
                 from RENTAL
                 where STAFF_ID = 1;
    loop
        fetch cur into placeholder;
        exit when cur%notfound;
        dbms_output.PUT_LINE('Processing id ' || placeholder.RENTAL_ID);
    end loop;
    close cur;
end;
/

declare
    cursor cur
        is
        select *
        from small_rental
            for update;
begin
    null;
end;
