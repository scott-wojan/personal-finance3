/************************************************************************************************************
core functions
************************************************************************************************************/

create or replace function months_between (startDate timestamp, endDate timestamp)
returns integer as 
$$
select ((extract('years' from $2)::int -  extract('years' from $1)::int) * 12) 
    - extract('month' from $1)::int + extract('month' from $2)::int
$$ 
LANGUAGE SQL
immutable
returns NULL on NULL input;

create or replace function end_of_month(date)
returns date as
$$
select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date;
$$ 
language SQL
immutable strict;