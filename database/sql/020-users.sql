/************************************************************************************************************
users
************************************************************************************************************/

CREATE TABLE IF NOT EXISTS users
(
  id SERIAL PRIMARY KEY,
  email citext UNIQUE NOT NULL,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);


/************************************************************************************************************
user rules
************************************************************************************************************/
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



create or replace function save_and_run_rule(userId integer, rule jsonb, ruleId integer default null)
  returns void as $$
  declare
    new_rule_id integer;
  BEGIN


    if ruleId is NULL then
        insert into user_rules(user_id, rule) 
             values (userId,rule) 
                 on conflict do nothing
          returning id into new_rule_id ;

    else
        update user_rules
           set rule = $2
         where user_id = userId
           and id = ruleId;
    end if;    


    -- RAISE NOTICE 'new_rule_id: %', new_rule_id;
    
    -- execute (
    --   select format( 'update %I set %s where user_id=%s and %s;'
    --                , 'tansactions' -- ur.rule->>'tablename'
    --                , set_columns.cols
    --                , user_id
    --                , where_columns.cols
    --                )
    --     from user_rules ur
    --     cross join lateral (
    --           select string_agg(quote_ident(col->>'name') || '=' || '' ||  quote_literal(col->>'value'), ', ') AS cols
    --             from jsonb_array_elements(ur.rule->'set') col
    --           ) set_columns
    --     cross join lateral (
    --           select string_agg(quote_ident(col->>'name') || ' ' 
    --                             || case (col->>'condition')::citext when 'equals' then '=' else 'like 'end 
    --                             || '' 
    --                             || 
    --                            case (col->>'condition')::citext
    --                            when 'equals' then quote_literal(col->>'value')
    --                            when 'starts with' then quote_literal(col->>'value'||'%')
    --                            when 'ends with' then quote_literal( format('%s%s', '%',col->>'value' )  )
    --                            else 'like'
    --                             end
    --                            , ' and ') AS cols
    --             from jsonb_array_elements(ur.rule->'where') col
    --           ) where_columns
    --     where user_id=userId
    --       and id=new_rule_id
    --   );
  END;
$$ language plpgsql;