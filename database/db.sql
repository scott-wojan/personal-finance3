/*
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS user_institutions;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS users;
*/




-- CREATE OR REPLACE FUNCTION set_transaction_values() RETURNS trigger AS $$
--   BEGIN
--     NEW.imported_category :=COALESCE(NEW.imported_category,'General');
--     NEW.imported_subcategory :=COALESCE(NEW.imported_subcategory,'General');
--     RETURN NEW;
--   END
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER transactions_set_transaction_values
-- after insert or update on transactions
-- FOR EACH ROW EXECUTE PROCEDURE set_transaction_values();





/************************************************************************************************************
PLAID webook holdings processing
************************************************************************************************************/

-- create or replace function import_plaid_holdings(plaid_webhook_history_id integer) 
--   returns void
--   language plpgsql
--  as $$

--   begin
  
--     perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
--     perform plaid_insert_or_update_holdingss(plaid_webhook_history_id);
--     -- perform plaid_insert_or_update_categories(plaid_webhook_history_id);
--     -- perform plaid_insert_or_update_user_categories(plaid_webhook_history_id);  
   
--   end
-- $$;



-- CREATE FUNCTION category_insert_values() RETURNS trigger AS $$
--   BEGIN
--     NEW.subcategory :=COALESCE(NEW.subcategory, 'General');
--     RETURN NEW;
--   END
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER category_trigger
-- BEFORE INSERT OR UPDATE ON categories
-- FOR EACH ROW EXECUTE PROCEDURE category_insert_values();










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
    a.id
  , a.user_id
  , i.id as institution_id
  , i.name as institution
  , i.url as institution_url
  , i.primary_color as institution_color
  , i.logo as institution_logo   
  , ui.is_login_invalid
  , a.name
  , a.mask
  , a.official_name
  , a.current_balance
  , a.available_balance
  , a.account_limit
  , a.iso_currency_code
  , a.type
  , a.subtype
  , a.last_import_date
from accounts a 
     inner join institutions i on a.institution_id = i.id
     inner join user_institutions ui on ui.institution_id = i.id;








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






      -- WITH type_subtype_grouped_accounts as (
      --   select type
      --       , subtype
      --       , json_agg( 
      --         json_build_object(
      --           'id', id
      --         , 'institution', institution
      --         , 'name', name
      --         , 'mask', mask
      --         , 'official_name', official_name
      --         , 'current_balance', current_balance
      --         , 'available_balance', available_balance
      --         , 'account_limit', account_limit
      --         , 'iso_currency_code', iso_currency_code
      --         )) AS accounts
      --   from user_accounts ua
      -- where user_id = ${userId}     
      -- GROUP BY type, subtype
      -- )
      -- select type, json_object_agg(subtype, accounts) as accounts
      --   from (select type, subtype,  accounts from type_subtype_grouped_accounts) x
      --   group by type   