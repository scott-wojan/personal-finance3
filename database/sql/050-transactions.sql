/************************************************************************************************************
transactions
************************************************************************************************************/
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


create or replace function apply_transactions_rules() 
  returns trigger 
 language plpgsql
 as $$
  declare
    record_count integer;
    statements record;
  begin
    
    select count(*) 
      from affected_rows 
      into record_count;

    for statements in        
        select format( 'update %I set %s where user_id=%s and %s;'
                       , 'transactions' -- ur.rule->>'tablename'
                       , set_columns.cols
                       , user_id
                       , where_columns.cols
                       ) as statement
            from user_rules ur
            cross join lateral (
                  select string_agg(quote_ident(col->>'name') || '=' || '' ||  quote_literal(col->>'value'), ', ') AS cols
                    from jsonb_array_elements(ur.rule->'set') col
                  ) set_columns
            cross join lateral (
                  select string_agg(quote_ident(col->>'name') || ' ' 
                                    || case (col->>'condition')::citext when 'equals' then '=' else 'like 'end 
                                    || '' 
                                    || 
                                   case (col->>'condition')::citext
                                   when 'equals' then quote_literal(col->>'value')
                                   when 'starts with' then quote_literal(col->>'value'||'%')
                                   when 'ends with' then quote_literal( format('%s%s', '%',col->>'value' )  )
                                   else 'like'
                                    end
                                   , ' and ') AS cols
                    from jsonb_array_elements(ur.rule->'where') col
                  ) where_columns
            where user_id in (select user_id from affected_rows)
      loop 
      -- raise notice '%', statements.statement;
      execute (statements.statement);  
      end loop;

    -- raise notice 'affected %:%', TG_OP, record_count;

    return null;   
  end
$$;

create or replace trigger transactions_insert_trigger
 after insert on transactions
 REFERENCING NEW TABLE AS affected_rows
   FOR EACH STATEMENT 
   WHEN (pg_trigger_depth() < 1)
   execute procedure apply_transactions_rules();


create or replace trigger transactions_update_trigger
 after update on transactions
 REFERENCING OLD TABLE AS affected_rows  
   FOR EACH STATEMENT 
   WHEN (pg_trigger_depth() < 1)
   execute procedure apply_transactions_rules();

