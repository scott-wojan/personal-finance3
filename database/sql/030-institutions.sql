/************************************************************************************************************
institutions
************************************************************************************************************/

CREATE TABLE IF NOT EXISTS institutions
(
    id text PRIMARY KEY,
    name citext NOT NULL,
    url citext,
    primary_color citext,
    logo citext,
    jsonDoc jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_institutions
(
    item_id text NOT NULL PRIMARY KEY,
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id text REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    access_token text NOT NULL,
    is_login_invalid bool not null default false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);