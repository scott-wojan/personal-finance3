/************************************************************************************************************
PLAID webook tables
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS plaid_webhook_history
(
  id SERIAL PRIMARY KEY,
  item_id text NOT NULL,
  webhook_code citext NOT NULL,
  webhook_type citext NOT NULL,
  error jsonb,
  jsonDoc jsonb NOT NULL,
  created_at timestamptz default now()
);


CREATE TABLE IF NOT EXISTS plaid_webhook_history_data
(
  id SERIAL PRIMARY KEY,
  plaid_webhook_history_id integer REFERENCES plaid_webhook_history(id) ON DELETE CASCADE ON UPDATE CASCADE,
  user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
  institution_id text REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
  jsonDoc jsonb NOT NULL,  
  importError jsonb,
  imported_at timestamptz,
  created_at timestamptz default now()    
);

/************************************************************************************************************
Webook ERROR processing
************************************************************************************************************/
create or replace function process_webhook_history_error() 
  returns trigger
  language plpgsql
 as $$
  declare
    error_type citext;
    error_code citext;
    itemid text;
  begin
    
    select pwh.item_id
         , pwh.error->>'error_type' "error_type"
         , pwh.error->>'error_code' "error_code"
      into itemid, error_type, error_code
      from plaid_webhook_history pwh
     where id = NEW.id;

    if (error_type = 'ITEM_ERROR' and error_code = 'ITEM_LOGIN_REQUIRED') 
        or 
       (error_type = 'ITEM' and error_code = 'PENDING_EXPIRATION')       
    then
      update user_institutions
         set is_login_invalid = true
       where item_id = itemid;
       
    -- elsif a < b then
    --   RAISE NOTICE 'a is less than b';

    else
      RAISE NOTICE 'unhandled error: % %', error_type, error_code;
    END IF;

  end
$$;

create or replace trigger plaid_webhook_history_error_trigger
 after update of error on plaid_webhook_history
   for each row execute procedure process_webhook_history_error();    