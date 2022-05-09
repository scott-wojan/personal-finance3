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
