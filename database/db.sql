/*
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS user_institutions;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS users;
*/
CREATE EXTENSION tablefunc;
CREATE EXTENSION citext;

CREATE TABLE IF NOT EXISTS users
(
  id SERIAL PRIMARY KEY,
  email citext UNIQUE NOT NULL,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

insert into users(email) values('test@test.com')


CREATE TABLE IF NOT EXISTS institutions
(
    id text PRIMARY KEY,
    name citext NOT NULL,
    url citext,
    primary_color citext,
    logo citext,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

insert into institutions(id,name) values('usaa','USAA');
insert into institutions(id,name) values('capital_one','Capital One');


CREATE TABLE IF NOT EXISTS user_institutions
(
    item_id text NOT NULL PRIMARY KEY,
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id text REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    access_token text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


CREATE TABLE IF NOT EXISTS accounts
(
    id text PRIMARY KEY,
    access_token text NOT NULL,    
    name citext NOT NULL,
    mask citext NOT NULL,
    official_name citext,
    current_balance numeric(28,10),
    available_balance numeric(28,10),
    iso_currency_code citext,
    account_limit numeric(28,10),
    type citext NOT NULL,
    subtype citext NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id citext REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS transactions
(
    id text PRIMARY KEY,
    user_id integer references users(id) on delete cascade on update cascade NOT NULL,    
    account_id citext references accounts(id) on delete cascade on update cascade NOT NULL,
    amount numeric(28,10) default 0,
    iso_currency_code citext,
    imported_category_id citext,
    imported_category citext,
    imported_subcategory citext,
    imported_name citext,
    category citext,
    subcategory citext,
    name citext,
    check_number citext,
    date date,
    month integer GENERATED ALWAYS AS (date_part('month', date)) STORED,
    year integer GENERATED ALWAYS AS (date_part('year', date)) STORED,
    authorized_date date,
    address citext,
    city citext,
    region citext,
    postal_code citext,
    country citext,
    lat double precision,
    lon double precision,
    store_number citext,
    merchant_name citext,
    payment_channel citext,
    is_pending boolean default false,
    type citext,
    transaction_code citext,
    is_recurring boolean,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


CREATE OR REPLACE FUNCTION set_transaction_values() RETURNS trigger AS $$
  BEGIN
    NEW.imported_category :=COALESCE(NEW.imported_category,'General');
    NEW.imported_subcategory :=COALESCE(NEW.imported_subcategory,'General');
    RETURN NEW;
  END
$$ LANGUAGE plpgsql;


CREATE TRIGGER transactions_set_transaction_values
after insert or update on transactions
FOR EACH ROW EXECUTE PROCEDURE set_transaction_values();


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


CREATE TABLE IF NOT EXISTS categories
(
  id serial PRIMARY KEY,
  category_id citext,
  category citext not null,
  subcategory citext
);

--
CREATE UNIQUE INDEX categories_uidx ON categories(category, subcategory, source);;
-- unique index to not allow more than one null on subcategory
CREATE UNIQUE INDEX categories_null_uidx ON categories (source, category, (subcategory IS NULL)) WHERE subcategory IS NULL;

CREATE FUNCTION category_insert_values() RETURNS trigger AS $$
  BEGIN
    NEW.subcategory :=COALESCE(NEW.subcategory, 'General');
    RETURN NEW;
  END
$$ LANGUAGE plpgsql;


CREATE TRIGGER category_trigger
BEFORE INSERT OR UPDATE ON categories
FOR EACH ROW EXECUTE PROCEDURE category_insert_values();


CREATE TABLE IF NOT EXISTS user_categories
(
  id SERIAL PRIMARY KEY,
  user_id integer references users(id) on delete cascade on update cascade,
  user_category citext,
  user_subcategory citext,
  min_budgeted_amount numeric(28,10) default 0,
  max_budgeted_amount numeric(28,10) default 0,
  do_not_budget boolean default false
);
-- unique index to not allow more than one null on user_subcategory
create unique index user_categories_uidx  on user_categories (user_id, user_category, (user_subcategory is null)) WHERE user_subcategory is null;
create unique index user_categories_uidx2 on user_categories (user_id, user_category, user_subcategory);  

create or replace function user_category_update_values() returns trigger AS $$
  begin

	update transactions t
		   set category = subquery.user_category,
			   subcategory = subquery.user_subcategory
	  from (select c.category, c.subcategory, uc.user_category, uc.user_subcategory
			  from user_categories uc
			 inner join categories c on c.id = category_id
			 where user_id = new.user_id
			   and category_id = new.category_id) subquery
	 where t.imported_category = subquery.category
	   and t.imported_subcategory = subquery.subcategory;   
	   
    return new;
  end
$$ LANGUAGE plpgsql;

create or replace trigger user_category_update_trigger
 after update on user_categories
   for each row execute procedure user_category_update_values();


    


CREATE TABLE IF NOT EXISTS user_rules
(
  id SERIAL PRIMARY KEY,
  user_id integer references users(id) on delete cascade on update cascade,
  rule jsonb,
  created_at timestamptz default now()
); 
CREATE UNIQUE INDEX user_rules_uidx ON user_rules(user_id,rule);

-- -- starts with
-- select * from transactions
-- where imported_name ~* '^grub.*$';

-- -- ends with
-- select * from transactions
-- where imported_name ~* '.*pharmacy$'

-- -- contains
-- select * from transactions
-- where imported_name ~* '.*life.*$'

-- --equals
-- select * from transactions
-- where imported_name ~* '^COSERV ELECTRIC$'


CREATE TABLE IF NOT EXISTS transaction_import_history
(
  plaid_request_id text primary key, 
  user_id integer references users(id) on delete cascade on update cascade,
  data jsonb not null,
  created_at timestamptz default now()
);



create or replace function save_and_run_rule(userId integer, rule jsonb)
  returns void as $$
  declare
    new_rule_id integer;
  BEGIN

    insert into user_rules(user_id, rule) values (userId,rule) returning id into new_rule_id; --on conflict do nothing;

    -- RAISE NOTICE 'new_rule_id: %', new_rule_id;
    
    execute (
      select format('update %I set %s where user_id=%s and %s;',ur.rule->>'tablename', set_columns.cols,  user_id, where_columns.cols)
        from user_rules ur
        cross join lateral (
              select string_agg(quote_ident(col->>'name') || '=' || '' ||  quote_literal(col->>'value'), ', ') AS cols
                from jsonb_array_elements(ur.rule->'set') col
              ) set_columns
        cross join lateral (
              select string_agg(quote_ident(col->>'name') || ' ' ||  (col->>'operator') || '' ||  quote_literal(col->>'value'), ' and ') AS cols
                from jsonb_array_elements(ur.rule->'where') col
              ) where_columns
        where user_id=userId
          and id=new_rule_id
      );
  END;
$$ language plpgsql; 




CREATE OR REPLACE FUNCTION update_user_transactions(userId integer, requestId text)
RETURNS text
AS $$
BEGIN

  insert into user_categories(user_id, user_category, user_subcategory)
	select userId as user_id
	     , transaction->'category'->>0 as category
		   , transaction->'category'->>1 as subcategory
	  from transaction_import_history,
         lateral jsonb_array_elements(transaction_import_history.data) transaction
   where user_id = userId
     and plaid_request_id = requestId
     and not exists (
             select 1 
					     from user_categories 
					    where user_category = transaction->'category'->>0 
					      and user_subcategory = transaction->'category'->>1
		)
   on conflict do nothing;       

  -- apply rules
  return(select update_transactions(userId,match_column_name,match_condition,match_value,set_column_name,set_value)
    from user_rules
  where user_id=userId
  );

END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION insert_plaid_transactions(userId integer,  requestId text, jsonDoc JSON)
 RETURNS void 
 LANGUAGE 'plpgsql' 
 COST 100 
 VOLATILE 
 PARALLEL 
 UNSAFE 
AS $BODY$
BEGIN

  insert into transaction_import_history(user_id,plaid_request_id,data) values(userId,requestId,jsonDoc);

  insert into transactions(
    id,
    user_id,
    account_id,
    amount,
    authorized_date,
    imported_category,
    imported_subcategory,
    category,
    subcategory,
    check_number,
    date,
    iso_currency_code,
    merchant_name,
    imported_name,
    name,
    payment_channel,
    is_pending,
    transaction_code,
    type
  )
  select id 
      , userId as user_id
      , account_id
      , amount
      , authorized_date
      , category as imported_category
      , subcategory as imported_subcategory
      , category
      , subcategory
      , check_number
      , date
      , iso_currency_code
      , merchant_name	 
      , name as imported_name 
      , name
      , payment_channel
      , is_pending
      , transaction_code
      , type
  from(
        select transaction->>'transaction_id' "id" 
             , transaction->>'account_id' "account_id"
             , (transaction->>'amount')::numeric(28,4) * -1 "amount" --for some reason, positive values like payroll come in as negative numbers and expenses come in as positive
             , (transaction->>'authorized_date')::date "authorized_date"
             , transaction->'category'->>0 as category
             , transaction->'category'->>1 as subcategory	
             , transaction->>'check_number' "check_number"	 
             , (transaction->>'date')::date "date"
             , transaction->>'iso_currency_code' "iso_currency_code"	 
             , transaction->>'merchant_name' "merchant_name"		 
             , transaction->>'name' "name" 	 
             , transaction->>'payment_channel' "payment_channel"	 
             , (transaction->>'pending')::bool "is_pending"
             , transaction->>'transaction_code' "transaction_code"
             , transaction->>'transaction_type' "type"	 
          from transaction_import_history,
               lateral jsonb_array_elements(transaction_import_history.data) transaction
         where plaid_request_id = requestId
  ) as transaction_date
  on conflict (id)
      do update set
      account_id = excluded.account_id,
      amount = excluded.amount*-1, --for some reason, positive values like payroll come in as negative numbers and expenses come in as positive
      authorized_date = excluded.authorized_date,
      category = excluded.category,
      subcategory = excluded.subcategory,
      check_number = excluded.check_number,
      date = excluded.date,
      iso_currency_code = excluded.iso_currency_code,
      merchant_name = excluded.merchant_name,
      imported_name = excluded.name,
      payment_channel = excluded.payment_channel,
      is_pending = excluded.is_pending,
      transaction_code = excluded.transaction_code,
      type = excluded.type;


  --keep categories up to date
  insert into categories(category, subcategory, source)
	select transaction->'category'->>0 as category
		   , transaction->'category'->>1 as subcategory
		   , 'Plaid' as source
	  from transaction_import_history,
         lateral jsonb_array_elements(transaction_import_history.data) transaction
   where plaid_request_id = requestId
         on conflict do nothing; 
         

    perform update_user_transactions(userId,requestId);
	
  END;    
$BODY$;



CREATE TABLE IF NOT EXISTS account_import_history
(
  plaid_request_id text primary key,  
  user_id integer references users(id) on delete cascade on update cascade,
  data jsonb not null,
  created_at timestamptz default now()
);


CREATE OR REPLACE FUNCTION insert_plaid_accounts(userId integer, requestId text, institutionId text, accessToken text, jsonDoc JSON)
 RETURNS void 
 LANGUAGE 'plpgsql' 
 COST 100 
 VOLATILE 
 PARALLEL 
 UNSAFE 
AS $BODY$
BEGIN

insert into account_import_history(user_id, plaid_request_id, data) 
                            values(userId, requestId, jsonDoc);

insert into accounts(
	  id
	, user_id
	, name
	, mask
	, official_name
	, subtype
	, type
	, available_balance
	, current_balance
	, account_limit
	, iso_currency_code
	, access_token
	, institution_id
)
select account->>'account_id' "id"
     , userId as user_id
     , account->>'name' "name"	 
     , account->>'mask' "mask"
     , account->>'official_name' "official_name"		 
     , account->>'subtype' "subtype"
     , account->>'type' "type"
     , (account->'balances'->>'available')::numeric(28,4) "available_balance"
     , (account->'balances'->>'current')::numeric(28,4) "current_balance"	   
     , (account->'balances'->>'limit')::numeric(28,4) "account_limit"	 
     , account->'balances'->>'iso_currency_code' "iso_currency_code"
	   , accessToken as access_token
	   , institutionId as institution_id
 from account_import_history,
lateral jsonb_array_elements(account_import_history.data) account
where plaid_request_id = requestId
  ON CONFLICT (ID)
  DO UPDATE SET
  official_name = excluded.official_name,
	subtype = excluded.subtype,
	type = excluded.type,
	available_balance = excluded.available_balance,
	current_balance = excluded.current_balance,
	account_limit = excluded.account_limit,
	iso_currency_code = excluded.iso_currency_code,
	access_token = excluded.access_token;

  END;
$BODY$;


CREATE OR REPLACE FUNCTION user_spending_metrics_by_category_subcategory(userId integer, startDate date, endDate date, exclude_non_budgeted_categories bool default false)
RETURNS TABLE (
   user_category_id	 integer
 , user_category citext
 , user_subcategory citext
 , min_budgeted_amount numeric(28,2)	
 , max_budgeted_amount numeric(28,2)
 , min_monthly_spend numeric(28,2)	
 , avg_monthly_spend numeric(28,2)	
 , max_monthly_spend numeric(28,2)	
 , total_spend numeric(28,2)
 , do_not_budget bool
)
AS $$
DECLARE 

BEGIN
RETURN QUERY
  select user_ledger.user_category_id
      , user_ledger.user_category
      , user_ledger.user_subcategory
      , user_ledger.min_budgeted_amount
      , user_ledger.max_budgeted_amount        
      , max(user_ledger.monthly_total)::numeric(28,2) as min_monthly_spend
      , avg(user_ledger.monthly_total)::numeric(28,2) as avg_monthly_spend   
      , min(user_ledger.monthly_total)::numeric(28,2) as max_monthly_spend
      , sum(user_ledger.monthly_total)::numeric(28,2) as total_amount_spent
      , user_ledger.do_not_budget
    from (
          select timespan.user_category_id
              , timespan.end_of_month
              , timespan.user_category
              , timespan.user_subcategory
              , timespan.min_budgeted_amount
              , timespan.max_budgeted_amount      
              , coalesce(transaction_monthy_totals.monthly_total,0) as monthly_total
              , timespan.do_not_budget      
            from (
                  select uc.id as user_category_id
                      , user_categories_by_date_range.end_of_month
                      , uc.user_category
                      , uc.user_subcategory
                      , uc.min_budgeted_amount
                      , uc.max_budgeted_amount
                      , 0 as monthly_total
                      , uc.do_not_budget              
                    from user_categories uc
                  cross join (
                              select end_of_month(date_series::date) as end_of_month
                              from generate_series( startDate, endDate, '1 month'::interval) date_series
                            ) as user_categories_by_date_range
                  where uc.user_id = userId
                    and (uc.do_not_budget = false or uc.do_not_budget != exclude_non_budgeted_categories)
          ) as timespan
          left join (
                  select end_of_month(date) as end_of_month
                      , category
                      , subcategory
                      , sum(amount) monthly_total
                    from transactions
                  where user_id = userId
                    and date between startDate and endDate
                  group by end_of_month, category, subcategory
          ) as transaction_monthy_totals
            on transaction_monthy_totals.end_of_month = timespan.end_of_month
            and transaction_monthy_totals.category = timespan.user_category
            and transaction_monthy_totals.subcategory = timespan.user_subcategory
      ) as user_ledger
  group by user_ledger.user_category_id
        , user_ledger.user_category
        , user_ledger.user_subcategory
        , user_ledger.min_budgeted_amount
        , user_ledger.max_budgeted_amount        
        , user_ledger.do_not_budget
  order by user_ledger.user_category
        , user_ledger.user_subcategory;

END; $$ 
LANGUAGE 'plpgsql';










-- update transactions
--   set category = uc.user_category ,
--       subcategory = uc.user_subcategory
--  from user_categories uc
-- where transactions.user_id = 1
--   and transactions.category = uc.category
--   and transactions.subcategory = uc.subcategory




-- CREATE OR REPLACE FUNCTION get_spending_metrics_by_category_subcategory(
--   userId integer,
--   startYear integer,
--   startMonth integer,
--   endMonth integer
-- ) RETURNS TABLE (
--   category citext,
--   subcategory citext,
--   min numeric(28, 2),
--   max numeric(28, 2),
--   avg numeric(28, 2)
-- ) AS $$ 
-- BEGIN 
-- RETURN QUERY
-- select
--   ledger.category,
--   ledger.subcategory,
--   sum(ledger.min) min,
--   sum(ledger.max) max,
--   sum(ledger.avg) avg
-- from
--   (
--     select
--       t.category,
--       t.subcategory,
--       round(max(t.total), 2) min,
--       round(min(t.total), 2) max,
--       round(avg(t.total), 2) avg
--     from(
--         select
--           months.month,
--           user_categories.category,
--           user_categories.subcategory,
--           coalesce(round(sum(t.amount), 2), 0) as total
--         from
--           generate_series(startMonth, endMonth) as months(month)
--           cross join (
--             select
--               t.category,
--               t.subcategory
--             from
--               transactions t
--             where
--                  user_id = userId
--               and year = startYear
--               and month between startMonth
--               and endMonth
--               and amount < 0
--             group by
--               t.category,
--               t.subcategory
--             order by
--               t.category,
--               t.subcategory
--           ) as user_categories
--           left join transactions t on t.month = months.month
--           and t.category = user_categories.category
--           and t.subcategory = user_categories.subcategory
--           and amount < 0
--         group by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--       ) t
--     GROUP BY
--       t.category,
--       t.subcategory
--     UNION
--     select
--       t.category,
--       t.subcategory,
--       round(min(t.total), 2) min,
--       round(max(t.total), 2) max,
--       round(avg(t.total), 2) avg
--     from(
--         select
--           months.month,
--           user_categories.category,
--           user_categories.subcategory,
--           coalesce(round(sum(t.amount), 2), 0) as total
--         from
--           generate_series(1, 12) as months(month)
--           cross join (
--             select
--               t.category,
--               t.subcategory
--             from
--               transactions t
--               inner join accounts a on a.id = t.account_id
--             where
--               a.user_id = userId
--               and t.year = startYear
--               and month between startMonth
--               and endMonth
--               and amount > 0
--             group by
--               t.category,
--               t.subcategory
--             order by
--               t.category,
--               t.subcategory
--           ) as user_categories
--           left join transactions t 
-- 	        on t.month = months.month
--            and t.category = user_categories.category
--            and t.subcategory = user_categories.subcategory
--            and amount > 0
--         group by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--         order by
--           months.month,
--           user_categories.category,
--           user_categories.subcategory
--       ) t
--     GROUP BY
--       t.category,
--       t.subcategory
--   ) as ledger
-- GROUP BY
--   ledger.category,
--   ledger.subcategory
-- ORDER BY
--   ledger.category,
--   ledger.subcategory;
-- END;$$ 
-- LANGUAGE 'plpgsql';

-- select * from GetSpendingMetricsByCategoryAndSubcategory(1,2021,1,12)






-- starts with
select * from transactions
where imported_name ~* '^grub.*$';

-- ends with
select * from transactions
where imported_name ~* '.*pharmacy$'

-- contains
select * from transactions
where imported_name ~* '.*life.*$'

--equals
select * from transactions
where imported_name ~ '^COSERV ELECTRIC$'







WITH spending AS (
 SELECT * FROM crosstab(
     $$ select category || '>' || subcategory,
	           to_char(date, 'mon'), 
	           round(sum(amount),2) AS total
          from transactions
         inner join accounts on accounts.id = transactions.account_id
	     where user_id = 1
	       and year = 2021
	       and month between 1 and 12
         group by category,subcategory,2
         order by 1,2 
	 $$
    ,$$VALUES ('jan'), ('feb'), ('mar'), ('apr'), ('may'), ('jun'), ('jul'), ('aug'), ('sep'), ('oct'), ('nov'), ('dec')$$
   )
 AS ct (category citext, jan numeric(28,2), feb numeric(28,2), mar numeric(28,2), apr numeric(28,2), may numeric(28,2), jun numeric(28,2), jul numeric(28,2), aug numeric(28,2), sep numeric(28,2), oct numeric(28,2), nov numeric(28,2), dec numeric(28,2))	
)
SELECT 
    (regexp_split_to_array(category, '>'))[1] as category, 
    (regexp_split_to_array(category, '>'))[2] as subcategory, 
    COALESCE(jan, 0) jan,
    COALESCE(feb, 0) feb,
    COALESCE(mar, 0) mar,
    COALESCE(apr, 0) apr,
    COALESCE(may, 0) may,
    COALESCE(jun, 0) jun,
    COALESCE(jul, 0) jul,
    COALESCE(aug, 0) aug,
    COALESCE(sep, 0) sep,
    COALESCE(oct, 0) oct,
    COALESCE(nov, 0) nov,
    COALESCE(dec, 0) dec,
	round((
		COALESCE(jan, 0) +
		COALESCE(feb, 0) +
		COALESCE(mar, 0) +
		COALESCE(apr, 0) +
		COALESCE(may, 0) +
		COALESCE(jun, 0) +
		COALESCE(jul, 0) +
		COALESCE(aug, 0) +
		COALESCE(sep, 0) +
		COALESCE(oct, 0) +
		COALESCE(nov, 0) +
		COALESCE(dec, 0)		
	)/12,2) as yearly_average
FROM spending;




























CREATE OR REPLACE FUNCTION GetSpendingByCategory(userId integer, startDate date, endDate date)
RETURNS TABLE (
 category text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY select t.category, sum(t.amount) as amount
  from transactions t
 INNER JOIN accounts a on a.id = t.account_id
 WHERE a.user_id = userId
   and date between startDate and endDate
   and t.category != 'Payment'
   and t.category != 'Transfer'
   and t.category != 'Interest'
 GROUP BY t.category;
END; $$ 
LANGUAGE 'plpgsql';





CREATE OR REPLACE FUNCTION GetSpendingBySubCategory(userId integer, category text, startDate date, endDate date)
RETURNS TABLE (
 sub_category text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY 
SELECT subcategory, sum(t.amount) as amount
  FROM transactions t
 INNER JOIN accounts a on a.id = t.account_id  
 WHERE a.user_id = userId
   and t.category = $2
   and t.date between startDate and endDate
   and t.category != 'Payment'
   and t.category != 'Transfer'
   and t.category != 'Interest'   
 group by sub_category;
END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION GetSpendingByDates(userId integer, startDate date, endDate date)
RETURNS TABLE (
 date text,
 amount numeric(28,10)
)
AS $$
BEGIN
RETURN QUERY 
	SELECT to_char(summed_transactions.date, 'Mon YYYY') date , sum(summed_transactions.amount) amount 
	FROM (
		SELECT t.date, to_date(to_char(t.date, 'Mon YYYY'), 'Mon YYYY') formatted_date, sum(t.amount) amount
		  FROM transactions t
	 INNER JOIN accounts a on a.id = t.account_id
		  WHERE a.user_id = userId
		   and t.category != 'Payment'
		   and t.category != 'Transfer'
		   and t.category != 'Interest'
		 group by t.date
		 order by t.date desc
	) as summed_transactions
	group by 1, summed_transactions.formatted_date
	order by summed_transactions.formatted_date desc;
END; $$ 
LANGUAGE 'plpgsql';

--http://johnatten.com/2015/04/22/use-postgres-json-type-and-aggregate-functions-to-map-relational-data-to-json/
/*
    SELECT
    (SELECT COUNT(t.*) FROM transactions t INNER JOIN accounts a on a.id = t.account_id WHERE a.user_id = userId AND date BETWEEN startDate AND endDate) as count, 
    (SELECT json_agg(t.*) 
       FROM (
           SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
		     FROM transactions t
	        INNER JOIN accounts a on a.id = t.account_id		   
		   	WHERE a.user_id = userId
              AND date BETWEEN startDate AND endDate		   
            ORDER BY date desc
           OFFSET page - 1 --use 1 based indexing to match UI
            LIMIT pageSize
     ) AS t
    ) AS data;
*/


-- CREATE OR REPLACE FUNCTION get_transactions_by_date_range(userId integer, startDate date, endDate date, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
--         AND date BETWEEN startDate AND endDate
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
--               AND date BETWEEN startDate AND endDate		   
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_transactions(userId integer, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	    INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account, t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_account_transactions(userId integer, accountId text, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
-- 	    AND a.id = accountId
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            SELECT t.id, a.name as account,t.date, t.name, t.amount, t.category, t.subcategory, t.iso_currency_code, is_pending
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
-- 	          AND a.id = accountId		   
--             ORDER BY date desc
--            OFFSET page - 1 --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';


-- CREATE OR REPLACE FUNCTION get_account_transactions_by_daterange(userId integer, accountId text, startDate date, endDate date, page integer, pageSize integer)
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- BEGIN
-- RETURN QUERY 
--     SELECT
--     (SELECT COUNT(t.*)
--        FROM transactions t
-- 	  INNER JOIN accounts a on a.id = t.account_id
-- 	  WHERE a.user_id = userId
-- 	    AND a.id = accountId	 
--         AND date BETWEEN startDate AND endDate
--     ) as count, 
--     (SELECT json_agg(t.*) 
--        FROM (
--            select t.id, t.date, a.name account, t.name, t.category as category, t.subcategory as subcategory, t.amount, t.iso_currency_code
-- 		     FROM transactions t
-- 	        INNER JOIN accounts a on a.id = t.account_id		   
-- 		   	WHERE a.user_id = userId
-- 		   	  AND a.id = accountId
--               AND date BETWEEN startDate AND endDate		   
--             ORDER BY date desc
--            OFFSET page  --use 1 based indexing to match UI
--             LIMIT pageSize
--      ) AS t
--     ) AS data;
-- END; $$ 
-- LANGUAGE 'plpgsql';







-- CREATE OR REPLACE FUNCTION get_transactions(userId integer, accountId text default null, startDate date default null, endDate date default null, page integer default 1, pageSize integer default 1, sortBy text default 'date', sortDirection text default'asc')
-- RETURNS TABLE (
--  total bigint,
--  data json	
-- )
-- AS $$
-- DECLARE 
--  selectStmt VARCHAR;
--  whereStmt VARCHAR := ' WHERE a.user_id = '|| quote_literal(userId); 
--  sortByColumn VARCHAR := sortBy;
--  sortColumnDirection VARCHAR := sortDirection; 
-- BEGIN
--     IF sortByColumn IS NULL THEN
--      sortByColumn := 'date';
--     END IF;
	

--      IF sortColumnDirection IS NULL THEN
--  		IF sortByColumn = 'date' THEN
--  		   sortColumnDirection := 'desc';
-- 		ELSE
--  		   sortColumnDirection := 'asc';
--  		END IF;
--      END IF;
	
-- -- 	raise notice 'sortByColumn: %', sortByColumn;
-- -- 	raise notice 'sortColumnDirection: %', sortColumnDirection;
	
--     IF accountId IS NOT NULL THEN
--         whereStmt := whereStmt || ' AND a.id = '|| quote_literal(accountId) ||' ';
--     END IF;
   
--     IF startDate IS NOT NULL AND endDate IS NOT NULL THEN
-- 	    whereStmt := whereStmt || ' AND date BETWEEN '|| quote_literal(startDate) ||' AND '|| quote_literal(endDate) ||' ';
--     END IF;   
   
--    selectStmt := 'SELECT (SELECT COUNT(t.*) FROM transactions t INNER JOIN accounts a on a.id = t.account_id '
--    || whereStmt ||
--    ') as count, ' 
--    '(SELECT json_agg(t.*) '
-- 	  'FROM ( '
-- 	  ' select t.id, t.date, a.name account, t.name, t.category as category, t.subcategory as subcategory, t.amount, t.iso_currency_code FROM transactions t '
-- 	  ' INNER JOIN accounts a on a.id = t.account_id '
-- 	  || whereStmt ||
--       ' ORDER BY '|| sortByColumn ||' ' || sortColumnDirection ||
--       '  OFFSET '|| quote_literal(page) ||' '
--       '  LIMIT '|| quote_literal(pageSize) ||' '
-- 	  ') AS t'
-- 	 ' ) as data';
   
-- -- raise notice 'SQL: %', selectStmt;   
   
-- RETURN QUERY EXECUTE selectStmt;

-- END; $$ 
-- LANGUAGE 'plpgsql';


create or replace view user_transactions as
select a.user_id
      ,t.id
      ,a.name as account
	    ,a.id as account_id
	    ,t.date
      ,t.name
      ,t.category as category
      ,t.subcategory as subcategory
      ,t.amount
      ,t.iso_currency_code
	    ,t.is_pending
  from transactions t
 inner join accounts a on a.id = t.account_id;

create or replace view user_accounts as
select 
   a.id,
   a.user_id,
   i.name as institution,
   a.name,
   a.mask,
   a.official_name,
   a.current_balance,
   a.available_balance,
   a.account_limit,
   a.iso_currency_code,
   a.subtype
from accounts a inner join institutions i on a.institution_id = i.id;









SELECT
  (SELECT COUNT(*)
     FROM transactions
    WHERE  account_id = 'mzd5mpxAonCE3NpPmvLEFGdj1dEogWhLkpzbA'
  ) as count, 
  (SELECT json_agg(t.*) 
     FROM (
	       SELECT * FROM transactions
	        WHERE  account_id = 'mzd5mpxAonCE3NpPmvLEFGdj1dEogWhLkpzbA'
	        ORDER BY date
	       OFFSET 0
	        LIMIT 5
	 ) AS t
  ) AS rows


 select date_trunc('month', t.date) as month, category, sum(amount) amount
  from transactions t 
  group by 1, 2
  order by 1 desc, 2;

select distinct category, 
       avg(sum(amount)) over (partition by category)  amount
  from (
	    select category, 
	           amount,
	           date
    from transactions
 INNER JOIN accounts a on a.id = account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 	  
  ) x
 group by date_trunc('month', date), category
 
 select distinct t.category, avg(sum(t.amount)) over (partition by t.category)  amount
  from transactions t
 INNER JOIN accounts a on a.id = t.account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 
 group by date_trunc('month', t.date), category
 order by 1;



  
select distinct category, 
       avg(sum(amount)) over (partition by category)  amount
  from (
	    select category,
	      amount,
	  date
    from transactions
 INNER JOIN accounts a on a.id = account_id
 WHERE a.user_id = 1
   and date between '2021/11/01' and '2021/11/30' 	  
  ) x
 group by date_trunc('month', date), category;  



 -- Category spend trends year over year
select year, 
       month, 
       category, 
	   average_amount,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY year, month ) as previous_year,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY year, month ) - average_amount as difference,
       (100 * (average_amount - lag(average_amount, 1) over (PARTITION BY month, category ORDER BY year, month)) / lag(average_amount, 1) over (PARTITION BY month, category ORDER BY year, month)) as percent_diff
from (
	select distinct year, month, 
		   category,
		   avg(amount) OVER (PARTITION BY month, category ORDER BY year, month) average_amount
	from transactions
	order by category, month
) t

-- Category spend trends by month
select month, 
       category, 
	   average_amount,
	   lag(average_amount, 1) OVER (PARTITION BY month, category ORDER BY month ) as previous_month
from (
	select distinct month, 
		   category,
		   avg(amount) OVER (PARTITION BY month, category ORDER BY month ) as average_amount
	from transactions
	where year = 2021
	order by category, month
) t



-- Categories JSON Hierarchy
-- select json_agg(json_user_categories)
-- from (
--   select cats.user_category as label, cats.user_category as value, json_agg(json_build_object('label', subCats.user_subcategory,'value', subCats.user_subcategory)) as subcategories
--   from (
-- 	  select distinct cats.user_category from user_categories cats where user_id = 1
--   ) cats
--   join (
-- 	  select distinct user_category, user_subcategory from user_categories where user_id = 1
--   ) subCats on cats.user_category = subCats.user_category
--  group by cats.user_category
-- 	order by cats.user_category
-- ) json_user_categories









-- select *
--      , category as imported_category
--      , subcategory as imported_subcategory
--      , name as imported_name	 
-- from(
-- 	select transaction->>'transaction_id' "transaction_id" 
-- 		 , transaction->>'account_id' "account_id"
-- 		 , (transaction->>'amount')::numeric(28,4) "amount"
-- 		 , transaction->>'authorized_date' "authorized_date"
-- 		 , transaction->'category'->>0 as category
-- 		 , transaction->'category'->>1 as subcategory	
-- 		 , transaction->>'check_number' "check_number"	 
-- 		 , (transaction->>'date')::date "date"
-- 		 , transaction->>'iso_currency_code' "iso_currency_code"	 
-- 		 , transaction->>'merchant_name' "merchant_name"		 
-- 		 , transaction->>'name' "name" 	 
-- 		 , transaction->>'payment_channel' "payment_channel"	 
-- 		 , transaction->>'pending' "is_pending"
-- 		 , transaction->>'transaction_code' "transaction_code"
-- 		 , transaction->>'transaction_type' "transaction_type"	 
-- 	from transaction_import_history,
--          lateral jsonb_array_elements(transaction_import_history.data) transaction
-- ) as transaction_date


-- select account->>'account_id' "name"
--      , account->>'mask' "mask"
--      , account->>'name' "name"
--      , account->>'type' "type"
--      , account->>'subtype' "name"
--      , account->>'account_id' "account_id"
--      , (account->'balances'->>'limit')::numeric(28,4) "limit"	
--      , (account->'balances'->>'current')::numeric(28,4) "current"	 
--      , (account->'balances'->>'available')::numeric(28,4) "available"
--      , account->'balances'->>'iso_currency_code' "iso_currency_code"
--   from account_import_history,
-- lateral jsonb_array_elements(account_import_history.data) account;