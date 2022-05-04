/*
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS user_institutions;
DROP TABLE IF EXISTS institutions;
DROP TABLE IF EXISTS users;
*/

/************************************************************************************************************
extensions
************************************************************************************************************/

CREATE EXTENSION tablefunc;
CREATE EXTENSION citext;

/************************************************************************************************************
'ookup tables
************************************************************************************************************/
DROP TABLE IF EXISTS countries;

CREATE TABLE countries (
  alpha_3 citext PRIMARY KEY,
  alpha_2 citext,
  name citext NOT NULL
);

insert into countries(alpha_3, alpha_2, "name") values
('afg','af','Afghanistan'),
('alb','al','Albania'),
('dza','dz','Algeria'),
('and','ad','Andorra'),
('ago','ao','Angola'),
('atg','ag','Antigua and Barbuda'),
('arg','ar','Argentina'),
('arm','am','Armenia'),
('aus','au','Australia'),
('aut','at','Austria'),
('aze','az','Azerbaijan'),
('bhs','bs','Bahamas'),
('bhr','bh','Bahrain'),
('bgd','bd','Bangladesh'),
('brb','bb','Barbados'),
('blr','by','Belarus'),
('bel','be','Belgium'),
('blz','bz','Belize'),
('ben','bj','Benin'),
('btn','bt','Bhutan'),
('bol','bo','Bolivia (Plurinational State of)'),
('bih','ba','Bosnia and Herzegovina'),
('bwa','bw','Botswana'),
('bra','br','Brazil'),
('brn','bn','Brunei Darussalam'),
('bgr','bg','Bulgaria'),
('bfa','bf','Burkina Faso'),
('bdi','bi','Burundi'),
('cpv','cv','Cabo Verde'),
('khm','kh','Cambodia'),
('cmr','cm','Cameroon'),
('can','ca','Canada'),
('caf','cf','Central African Republic'),
('tcd','td','Chad'),
('chl','cl','Chile'),
('chn','cn','China'),
('col','co','Colombia'),
('com','km','Comoros'),
('cog','cg','Congo'),
('cod','cd','Congo, Democratic Republic of the'),
('cri','cr','Costa Rica'),
('civ','ci','C√¥te d''Ivoire'),
('hrv','hr','Croatia'),
('cub','cu','Cuba'),
('cyp','cy','Cyprus'),
('cze','cz','Czechia'),
('dnk','dk','Denmark'),
('dji','dj','Djibouti'),
('dma','dm','Dominica'),
('dom','do','Dominican Republic'),
('ecu','ec','Ecuador'),
('egy','eg','Egypt'),
('slv','sv','El Salvador'),
('gnq','gq','Equatorial Guinea'),
('eri','er','Eritrea'),
('est','ee','Estonia'),
('swz','sz','Eswatini'),
('eth','et','Ethiopia'),
('fji','fj','Fiji'),
('fin','fi','Finland'),
('fra','fr','France'),
('gab','ga','Gabon'),
('gmb','gm','Gambia'),
('geo','ge','Georgia'),
('deu','de','Germany'),
('gha','gh','Ghana'),
('grc','gr','Greece'),
('grd','gd','Grenada'),
('gtm','gt','Guatemala'),
('gin','gn','Guinea'),
('gnb','gw','Guinea-Bissau'),
('guy','gy','Guyana'),
('hti','ht','Haiti'),
('hnd','hn','Honduras'),
('hun','hu','Hungary'),
('isl','is','Iceland'),
('ind','in','India'),
('idn','id','Indonesia'),
('irn','ir','Iran (Islamic Republic of)'),
('irq','iq','Iraq'),
('irl','ie','Ireland'),
('isr','il','Israel'),
('ita','it','Italy'),
('jam','jm','Jamaica'),
('jpn','jp','Japan'),
('jor','jo','Jordan'),
('kaz','kz','Kazakhstan'),
('ken','ke','Kenya'),
('kir','ki','Kiribati'),
('prk','kp','Korea (Democratic People''s Republic of)'),
('kor','kr','Korea, Republic of'),
('kwt','kw','Kuwait'),
('kgz','kg','Kyrgyzstan'),
('lao','la','Lao People''s Democratic Republic'),
('lva','lv','Latvia'),
('lbn','lb','Lebanon'),
('lso','ls','Lesotho'),
('lbr','lr','Liberia'),
('lby','ly','Libya'),
('lie','li','Liechtenstein'),
('ltu','lt','Lithuania'),
('lux','lu','Luxembourg'),
('mdg','mg','Madagascar'),
('mwi','mw','Malawi'),
('mys','my','Malaysia'),
('mdv','mv','Maldives'),
('mli','ml','Mali'),
('mlt','mt','Malta'),
('mhl','mh','Marshall Islands'),
('mrt','mr','Mauritania'),
('mus','mu','Mauritius'),
('mex','mx','Mexico'),
('fsm','fm','Micronesia (Federated States of)'),
('mda','md','Moldova, Republic of'),
('mco','mc','Monaco'),
('mng','mn','Mongolia'),
('mne','me','Montenegro'),
('mar','ma','Morocco'),
('moz','mz','Mozambique'),
('mmr','mm','Myanmar'),
('nam','na','Namibia'),
('nru','nr','Nauru'),
('npl','np','Nepal'),
('nld','nl','Netherlands'),
('nzl','nz','New Zealand'),
('nic','ni','Nicaragua'),
('ner','ne','Niger'),
('nga','ng','Nigeria'),
('mkd','mk','North Macedonia'),
('nor','no','Norway'),
('omn','om','Oman'),
('pak','pk','Pakistan'),
('plw','pw','Palau'),
('pan','pa','Panama'),
('png','pg','Papua New Guinea'),
('pry','py','Paraguay'),
('per','pe','Peru'),
('phl','ph','Philippines'),
('pol','pl','Poland'),
('prt','pt','Portugal'),
('qat','qa','Qatar'),
('rou','ro','Romania'),
('rus','ru','Russian Federation'),
('rwa','rw','Rwanda'),
('kna','kn','Saint Kitts and Nevis'),
('lca','lc','Saint Lucia'),
('vct','vc','Saint Vincent and the Grenadines'),
('wsm','ws','Samoa'),
('smr','sm','San Marino'),
('stp','st','Sao Tome and Principe'),
('sau','sa','Saudi Arabia'),
('sen','sn','Senegal'),
('srb','rs','Serbia'),
('syc','sc','Seychelles'),
('sle','sl','Sierra Leone'),
('sgp','sg','Singapore'),
('svk','sk','Slovakia'),
('svn','si','Slovenia'),
('slb','sb','Solomon Islands'),
('som','so','Somalia'),
('zaf','za','South Africa'),
('ssd','ss','South Sudan'),
('esp','es','Spain'),
('lka','lk','Sri Lanka'),
('sdn','sd','Sudan'),
('sur','sr','Suriname'),
('swe','se','Sweden'),
('che','ch','Switzerland'),
('syr','sy','Syrian Arab Republic'),
('tjk','tj','Tajikistan'),
('tza','tz','Tanzania, United Republic of'),
('tha','th','Thailand'),
('tls','tl','Timor-Leste'),
('tgo','tg','Togo'),
('ton','to','Tonga'),
('tto','tt','Trinidad and Tobago'),
('tun','tn','Tunisia'),
('tur','tr','Turkey'),
('tkm','tm','Turkmenistan'),
('tuv','tv','Tuvalu'),
('uga','ug','Uganda'),
('ukr','ua','Ukraine'),
('are','ae','United Arab Emirates'),
('gbr','gb','United Kingdom of Great Britain and Northern Ireland'),
('usa','us','United States of America'),
('ury','uy','Uruguay'),
('uzb','uz','Uzbekistan'),
('vut','vu','Vanuatu'),
('ven','ve','Venezuela (Bolivarian Republic of)'),
('vnm','vn','Viet Nam'),
('yem','ye','Yemen'),
('zmb','zm','Zambia'),
('zwe','zw','Zimbabwe');

create unique index countries_alpha_2_uidx on countries(alpha_2);

drop table if exists account_types;

create table account_types (
  account_type citext PRIMARY KEY,
  description citext NOT NULL
);

insert into account_types(account_type,description) values
('depository', 'An account type holding cash, in which funds are deposited. Supported products for depository accounts are: Auth (checking and savings types only), Balance, Transactions, Identity, Payment Initiation, and Assets.'),
('credit','A credit card type account. Supported products for credit accounts are: Balance, Transactions, Identity, and Liabilities.'),
('loan','A loan type account. Supported products for loan accounts are: Balance, Liabilities, and Transactions.'),
('investment','An investment account. Supported products for investment accounts are: Balance and Investments. In API versions 2018-05-22 and earlier, this type is called brokerage.'),
('other','Other or unknown account type. Supported products for other accounts are: Balance, Transactions, Identity, and Assets.');


DROP TABLE IF EXISTS account_subtypes;

CREATE TABLE account_subtypes (
  id serial PRIMARY KEY,
  account_type citext REFERENCES account_types(account_type) ON DELETE CASCADE ON UPDATE CASCADE,       
  account_subtype citext not null, 
  description citext NOT NULL,
  country citext REFERENCES countries(alpha_3) ON DELETE CASCADE ON UPDATE CASCADE
);

create unique index account_subtypes_uidx on account_subtypes(account_type,account_subtype);

insert into account_subtypes(account_subtype,account_type,description,country) values
('checking','depository','Checking account','usa'),
('savings','depository','Savings account',null),
('has','depository','Health Savings Account (US only) that can only hold cash',null),
('cd','depository','Certificate of deposit account',null),
('money market','depository','Money market account',null),
('paypal','depository','PayPal depository account',null),
('prepaid','depository','Prepaid debit card',null),
('cash management','depository','A cash management account, typically a cash account at a brokerage',null),
('ebt','depository','An Electronic Benefit Transfer (EBT) account, used by certain public assistance programs to distribute funds','usa'),
('credit card','credit','Bank-issued credit card',null),
('paypal','credit','PayPal-issued credit card',null),
('auto','loan','Auto loan',null),
('business','loan','Business loan',null),
('commercial','loan','Commercial loan',null),
('construction','loan','Construction loan',null),
('consumer','loan','Consumer loan',null),
('home equity','loan','Home Equity Line of Credit (HELOC)',null),
('loan','loan','General loan',null),
('mortgage','loan','Mortgage loan',null),
('overdraft','loan','Pre-approved overdraft account, usually tied to a checking account',null),
('line of credit','loan','Pre-approved line of credit',null),
('student','loan','Student loan',null),
('other','loan','Other loan type or unknown loan type',null),
('529','investment','Tax-advantaged college savings and prepaid tuition 529 plans','usa'),
('401a','investment','Employer-sponsored money-purchase 401(a) retirement plan','usa'),
('401k','investment','Standard 401(k) retirement account','usa'),
('403B','investment','Retirement savings account for non-profits and schools ','usa'),
('457b','investment','Tax-advantaged deferred-compensation 457(b) retirement plan for governments and non-profits','usa'),
('brokerage','investment','Standard brokerage account',null),
('cash isa','investment','Individual Savings Account (ISA) that pays interest tax-free','gbr'),
('education savings account','investment','Tax-advantaged Coverdell Education Savings Account ','usa'),
('fixed annuity','investment','Fixed annuity',null),
('gic','investment','Guaranteed Investment Certificate ','can'),
('health reimbursement arrangement','investment','Tax-advantaged Health Reimbursement Arrangement (HRA) benefit plan','usa'),
('has','investment','Non-cash tax-advantaged medical Health Savings Account (HSA)','usa'),
('ira','investment','Traditional Invididual Retirement Account (IRA)','usa'),
('isa','investment','Non-cash Individual Savings Account (ISA)','gbr'),
('keogh','investment','Keogh self-employed retirement plan','usa'),
('lif','investment','Life Income Fund (LIF) retirement account','can'),
('life insurance','investment','Life insurance account',null),
('lira','investment','Locked-in Retirement Account (LIRA)','can'),
('lrif','investment','Locked-in Retirement Income Fund (LRIF)','can'),
('lrsp','investment','Locked-in Retirement Savings Plan','can'),
('mutual fund','investment','Mutual fund account',null),
('non-taxable brokerage account','investment','A non-taxable brokerage account that is not covered by a more specific subtype',null),
('other','investment','An account whose type could not be determined',null),
('other annuity','investment','An annuity account not covered by other subtypes',null),
('other insurance','investment','An insurance account not covered by other subtypes',null),
('pension','investment','Standard pension account',null),
('prif','investment','Prescribed Registered Retirement Income Fund','can'),
('profit sharing plan','investment','Plan that gives employees share of company profits',null),
('qshr','investment','Qualifying share account',null),
('rdsp','investment','Registered Disability Savings Plan (RSDP)','can'),
('resp','investment','Registered Education Savings Plan','can'),
('retirement','investment','Retirement account not covered by other subtypes',null),
('rlif','investment','Restricted Life Income Fund (RLIF)','can'),
('roth','investment','Roth IRA','usa'),
('roth 401k','investment','Employer-sponsored Roth 401(k) plan','usa'),
('rrif','investment','Registered Retirement Income Fund (RRIF)','can'),
('rrsp','investment','Registered Retirement Savings Plan','can'),
('sarsep','investment','Salary Reduction Simplified Employee Pension Plan (SARSEP), discontinued retirement plan','usa'),
('sep ira','investment','Simplified Employee Pension IRA, retirement plan for small businesses and self-employed','usa'),
('simple ira','investment','Savings Incentive Match Plan for Employees IRA, retirement plan for small businesses',null),
('sipp','investment','Self-Invested Personal Pension (SIPP)','gbr'),
('stock plan','investment','Standard stock plan account',null),
('tfsa','investment','Tax-Free Savings Account ','can'),
('trust','investment','Account representing funds or assets held by a trustee for the benefit of a beneficiary. Includes both revocable and irrevocable trusts.',null),
('ugma','investment','Uniform Gift to Minors Act (brokerage account for minors)','usa'),
('utma','investment','Uniform Transfers to Minors Act (brokerage account for minors)',null),
('variable annuity','investment','Tax-deferred capital accumulation annuity contract',null),
('other','other','Other or unknown account type. Supported products for other accounts are: Balance, Transactions, Identity, and Assets.',null)
;

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
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


/************************************************************************************************************
accounts
************************************************************************************************************/
CREATE TABLE IF NOT EXISTS accounts
(
    id text PRIMARY KEY,
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
    institution_id citext REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type, subtype) REFERENCES account_subtypes (account_type, account_subtype)
);


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
categories
************************************************************************************************************/
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

/************************************************************************************************************
helper functions
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
PLAID webook account processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin

    insert into accounts(
          id
        , user_id
        , name
        , mask
        , official_name
        , type
        , subtype
        , available_balance
        , current_balance
        , account_limit
        , iso_currency_code
        , institution_id
    )
    select account->>'account_id' "id"
         , user_id
         , account->>'name' "name"	 
         , account->>'mask' "mask"
         , account->>'official_name' "official_name"		 
         , account->>'type' "type"
         , account->>'subtype' "subtype"
         , (account->'balances'->>'available')::numeric(28,4) "available_balance"
         , (account->'balances'->>'current')::numeric(28,4) "current_balance"	   
         , (account->'balances'->>'limit')::numeric(28,4) "account_limit"	 
         , account->'balances'->>'iso_currency_code' "iso_currency_code"
         , institution_id
    from(
        select user_id, institution_id, jsonb_array_elements(jsondoc->'accounts') "account"
          from plaid_webhook_history_data
         where plaid_webhook_history_id=webhookHistoryId
    ) as accounts
    ON CONFLICT (ID)
    DO UPDATE SET
    official_name = excluded.official_name,
    subtype = excluded.subtype,
    type = excluded.type,
    available_balance = excluded.available_balance,
    current_balance = excluded.current_balance,
    account_limit = excluded.account_limit,
    iso_currency_code = excluded.iso_currency_code;

  end;
$BODY$;

/************************************************************************************************************
PLAID webook category processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_categories(webhookHistoryId integer)
RETURNS void
AS $$
BEGIN

  insert into categories(category, subcategory, source)
  select coalesce(transaction->'category'->>0, 'Unassigned') as category
       , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
       , 'Plaid' as source
   from  (
         select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
           from plaid_webhook_history_data
          where plaid_webhook_history_id=webhookHistoryId
       ) as transactions  
      on conflict do nothing; 

END; $$ 
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION plaid_insert_or_update_user_categories(webhookHistoryId integer)
RETURNS void
AS $$
BEGIN

  insert into user_categories(user_id, user_category, user_subcategory)
  select user_id
       , coalesce(transaction->'category'->>0, 'Unassigned') as category
       , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
   from  (
         select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
           from plaid_webhook_history_data
          where plaid_webhook_history_id=webhookHistoryId
       ) as transactions
   where not exists (
         select 1 
           from user_categories uc
          where user_category = transaction->'category'->>0 
            and user_subcategory = transaction->'category'->>1
            and uc.user_id=transactions.user_id
		)
      on conflict do nothing;

END; $$ 
LANGUAGE 'plpgsql';


/************************************************************************************************************
PLAID webook transaction processing
************************************************************************************************************/
CREATE OR REPLACE FUNCTION plaid_insert_or_update_transactions(webhookHistoryId integer)
 RETURNS void 
 LANGUAGE 'plpgsql' 
 COST 100 
 VOLATILE 
 PARALLEL 
 UNSAFE 
AS $BODY$
BEGIN

    insert into transactions(
           id
         , user_id
         , account_id
         , amount
         , authorized_date
         , imported_category
         , imported_subcategory
         , category
         , subcategory
         , check_number
         , date
         , iso_currency_code
         , merchant_name
         , imported_name
         , name
         , payment_channel
         , is_pending
         , transaction_code
         , type
    )
    select transaction->>'transaction_id' "id" 
         , user_id
         , transaction->>'account_id' "account_id"
         , (transaction->>'amount')::numeric(28,4) * -1 "amount" --for some reason, positive values like payroll come in as negative numbers and expenses come in as positive
         , (transaction->>'authorized_date')::date "authorized_date"
         , coalesce(transaction->'category'->>0, 'Unassigned') as imported_category
         , coalesce(transaction->'category'->>1, 'Unassigned') as imported_subcategory	         
         , coalesce(transaction->'category'->>0, 'Unassigned') as category
         , coalesce(transaction->'category'->>1, 'Unassigned') as subcategory
         , transaction->>'check_number' "check_number"	 
         , (transaction->>'date')::date "date"
         , transaction->>'iso_currency_code' "iso_currency_code"	 
         , transaction->>'merchant_name' "merchant_name"		 
         , transaction->>'name' "imported_name"          
         , transaction->>'name' "name" 	 
         , transaction->>'payment_channel' "payment_channel"	 
         , (transaction->>'pending')::bool "is_pending"
         , transaction->>'transaction_code' "transaction_code"
         , transaction->>'transaction_type' "type"	 
    from(
        select user_id, institution_id, jsonb_array_elements(jsondoc->'transactions') "transaction"
          from plaid_webhook_history_data
         where plaid_webhook_history_id=webhookHistoryId
    ) as transactions
  on conflict (id)
      do update set
      account_id = excluded.account_id,
      amount = excluded.amount,
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

	
  END;
$BODY$;


create or replace function import_plaid_transactions(plaid_webhook_history_id integer) 
  returns void
  language plpgsql
 as $$

  begin
  
    perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_transactions(plaid_webhook_history_id);
    perform plaid_insert_or_update_categories(plaid_webhook_history_id);
    perform plaid_insert_or_update_user_categories(plaid_webhook_history_id);    
   
  end
$$;



--TODO: Remove from account table??
CREATE TABLE IF NOT EXISTS depository_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    current_balance numeric(28,10),
    available_balance numeric(28,10),
    account_limit numeric(28,10),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes




CREATE TABLE IF NOT EXISTS credit_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    apr_percentage numeric(28,10),
    apr_type citext,
    balance_subject_to_apr numeric(28,10),
    interest_charge_amount numeric(28,10),
    is_overdue boolean default false,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    last_statement_issue_date date,
    last_statement_balance numeric(28,10),
    minimum_payment_amount numeric(28,10),
    next_payment_due_date date,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes

CREATE TABLE IF NOT EXISTS mortgage_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    account_number citext,
    current_late_fee numeric(28,10),
    escrow_balance numeric(28,10),
    has_pmi boolean default false,
    has_prepayment_penalty boolean default false,
    interest_rate_percentage double precision,
    interest_rate_type citext,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    loan_type_description citext,
    loan_term citext,
    maturity_date date,
    next_monthly_payment numeric(28,10),
    next_payment_due_date date,
    origination_date date,
    origination_principal_amount numeric(28,10),
    past_due_amount numeric(28,10),
    street citext,
    city citext,
    region citext,
    postal_code citext,
    country citext,
    ytd_interest_paid numeric(28,10),
    ytd_principal_paid numeric(28,10),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes

CREATE TABLE IF NOT EXISTS student_loan_accounts
(
    id text PRIMARY KEY REFERENCES accounts(id) ON DELETE CASCADE ON UPDATE CASCADE,
    account_number citext,
    --disbursement_dates date,
    expected_payoff_date date,
    interest_rate_percentage double precision,
    guarantor citext,
    is_overdue boolean default false,
    last_payment_amount numeric(28,10),
    last_payment_date date,
    last_statement_issue_date date,
    loan_name citext,
    loan_status_end_date date,
    loan_status_type citext,
    minimum_payment_amount numeric(28,10),
    next_payment_due_date date,
    origination_date date,
    origination_principal_amount numeric(28,10),
    outstanding_interest_amount numeric(28,10),
    payment_reference_number citext,
    pslf_estimated_eligibility_date date,
    pslf_payments_made integer,
    pslf_payments_remaining integer,
    repayment_plan_type citext,
    repayment_plan_description citext,
    sequence_number citext,
    servicer_street citext,
    servicer_city citext,
    servicer_region citext,
    servicer_postal_code citext,
    servicer_country citext,
    ytd_interest_paid numeric(28,10),
    ytd_principal_paid numeric(28,10),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
--todo need trigger to audit/log changes


/************************************************************************************************************
PLAID webook liabilities processing
************************************************************************************************************/

CREATE OR REPLACE FUNCTION plaid_insert_or_update_credit_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into credit_accounts(
          id
        , apr_percentage
        , apr_type
        , balance_subject_to_apr
        , interest_charge_amount
        , is_overdue
        , last_payment_amount
        , last_payment_date
        , last_statement_issue_date
        , last_statement_balance
        , minimum_payment_amount
        , next_payment_due_date
    )
    select credit->>'account_id' "id"
          , (credit->'aprs'->>'apr_percentage')::numeric(28,4) "apr_percentage"
          , (credit->'aprs'->>'apr_type') "apr_type"
          , (credit->'aprs'->>'balance_subject_to_apr')::numeric(28,4) "balance_subject_to_apr"
          , (credit->'aprs'->>'interest_charge_amount')::numeric(28,4) "interest_charge_amount"
          , coalesce(credit->>'is_overdue', 'false')::boolean "is_overdue"
          , (credit->>'last_payment_amount')::numeric(28,4) "last_payment_amount"
          , (credit->>'last_payment_date')::date "last_payment_date"
          , (credit->>'last_statement_issue_date')::date "last_statement_issue_date"         
          , (credit->>'last_statement_balance')::numeric(28,4)  "last_statement_balance"   
          , (credit->>'minimum_payment_amount')::numeric(28,4) "minimum_payment_amount"   
          , (credit->>'next_payment_due_date')::date "next_payment_due_date"              
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'credit') 
                    when 'array' then jsondoc->'credit' 
                    else '[]' end
                ) as credit     
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as credit_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
    apr_percentage = excluded.apr_percentage,
    apr_type = excluded.apr_type,
    balance_subject_to_apr = excluded.balance_subject_to_apr,
    interest_charge_amount = excluded.interest_charge_amount,
    is_overdue = excluded.is_overdue,
    last_payment_amount = excluded.last_payment_amount,
    last_payment_date = excluded.last_payment_date,
    last_statement_issue_date = excluded.last_statement_issue_date,
    last_statement_balance = excluded.last_statement_balance,
    minimum_payment_amount = excluded.minimum_payment_amount,
    next_payment_due_date = excluded.next_payment_due_date
    ;

  end;
$BODY$;

CREATE OR REPLACE FUNCTION plaid_insert_or_update_student_loan_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into student_loan_accounts(
          id
        , account_number
        , expected_payoff_date
        , interest_rate_percentage
        , guarantor
        , is_overdue
        , last_payment_amount
        , last_payment_date
        , last_statement_issue_date
        , loan_name
        , loan_status_end_date
        , loan_status_type
        , minimum_payment_amount
        , next_payment_due_date
        , origination_date
        , origination_principal_amount
        , outstanding_interest_amount
        , payment_reference_number
        , pslf_estimated_eligibility_date
        , pslf_payments_made
        , pslf_payments_remaining
        , repayment_plan_type
        , repayment_plan_description
        , sequence_number
        , servicer_street
        , servicer_city
        , servicer_region
        , servicer_postal_code
        , servicer_country
        , ytd_interest_paid
        , ytd_principal_paid
    )
    select
              student_loan->>'account_id' 
            , student_loan->>'account_number' 
            , (student_loan->>'expected_payoff_date')::date 
            , (student_loan->>'interest_rate_percentage')::double precision 
            , student_loan->>'guarantor' 
            , coalesce(student_loan->>'is_overdue', 'false')::boolean 
            , (student_loan->>'last_payment_amount')::numeric(28,4) 
            , (student_loan->>'last_payment_date')::date 
            , (student_loan->>'last_statement_issue_date')::date 
            , student_loan->>'loan_name' "loan_name"
            , (student_loan->'loan_status'->>'end_date')::date       
            , (student_loan->'loan_status'->>'ltype')::date      
            , (student_loan->>'minimum_payment_amount')::numeric(28,4)
            , (student_loan->>'next_payment_due_date')::date
            , (student_loan->>'origination_date')::date
            , (student_loan->>'origination_principal_amount')::numeric(28,4)
            , (student_loan->>'outstanding_interest_amount')::numeric(28,4)
            , student_loan->>'payment_reference_number'
            , (student_loan->'pslf_status'->>'estimated_eligibility_date')::date               
            , (student_loan->'pslf_status'->>'payments_made')::integer   
            , (student_loan->'pslf_status'->>'payments_remaining')::integer   
            , student_loan->'repayment_plan'->>'type'
            , student_loan->'repayment_plan'->>'description'   
            , student_loan->>'sequence_number'
            , student_loan->'servicer_address'->>'street'
            , student_loan->'servicer_address'->>'city'
            , student_loan->'servicer_address'->>'region'
            , student_loan->'servicer_address'->>'postal_code'            
            , student_loan->'servicer_address'->>'country'  
            , (student_loan->>'ytd_interest_paid')::numeric(28,4)
            , (student_loan->>'ytd_principal_paid')::numeric(28,4)
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'student') 
                     when 'array' then jsondoc->'student' 
                     else '[]' 
                end
                ) as student_loan
          from plaid_webhook_history_data
         where plaid_webhook_history_id=webhookHistoryId
    ) as student_loan_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
      account_number = excluded.account_number
    , expected_payoff_date = excluded.expected_payoff_date
    , interest_rate_percentage = excluded.interest_rate_percentage
    , guarantor = excluded.guarantor
    , is_overdue = excluded.is_overdue
    , last_payment_amount = excluded.last_payment_amount
    , last_payment_date = excluded.last_payment_date
    , last_statement_issue_date = excluded.last_statement_issue_date
    , loan_name = excluded.loan_name
    , loan_status_end_date = excluded.loan_status_end_date
    , loan_status_type = excluded.loan_status_type
    , minimum_payment_amount = excluded.minimum_payment_amount
    , next_payment_due_date = excluded.next_payment_due_date
    , origination_date = excluded.origination_date
    , origination_principal_amount = excluded.origination_principal_amount
    , outstanding_interest_amount = excluded.outstanding_interest_amount
    , payment_reference_number = excluded.payment_reference_number
    , pslf_estimated_eligibility_date = excluded.pslf_estimated_eligibility_date
    , pslf_payments_made = excluded.pslf_payments_made
    , pslf_payments_remaining = excluded.pslf_payments_remaining
    , repayment_plan_type = excluded.repayment_plan_type
    , repayment_plan_description = excluded.repayment_plan_description
    , sequence_number = excluded.sequence_number
    , servicer_street = excluded.servicer_street
    , servicer_city = excluded.servicer_city
    , servicer_region = excluded.servicer_region
    , servicer_postal_code = excluded.servicer_postal_code
    , servicer_country = excluded.servicer_country
    , ytd_interest_paid = excluded.ytd_interest_paid
    , ytd_principal_paid = excluded.ytd_principal_paid;

  end;
$BODY$;

CREATE OR REPLACE FUNCTION plaid_insert_or_update_mortgage_accounts(webhookHistoryId integer)
 returns void
 language 'plpgsql' 
 cost 100 
 volatile 
 PARALLEL 
 unsafe
as $BODY$
begin
    insert into mortgage_accounts(
          id
        , account_number
        , current_late_fee
        , escrow_balance
        , has_pmi
        , has_prepayment_penalty
        , interest_rate_percentage
        , interest_rate_type
        , last_payment_amount
        , last_payment_date
        , loan_type_description
        , loan_term
        , maturity_date
        , next_monthly_payment
        , next_payment_due_date
        , origination_date
        , origination_principal_amount
        , past_due_amount
        , street
        , city
        , region
        , postal_code
        , country
        , ytd_interest_paid
        , ytd_principal_paid
    )
    select
              (mortgage->>'account_id')::text
            , (mortgage->>'account_number')::citext
            , (mortgage->>'current_late_fee')::numeric(28,8)
            , (mortgage->>'escrow_balance')::numeric(28,8)
            , coalesce(mortgage->>'has_pmi', 'false')::boolean
            , coalesce(mortgage->>'has_prepayment_penalty', 'false')::boolean   
            , (mortgage->'interest_rate'->>'percentage')::double precision
            , (mortgage->'interest_rate'->>'type')::citext
            , (mortgage->>'last_payment_amount')::numeric(28,8)
            , (mortgage->>'last_payment_date')::date
            , (mortgage->>'loan_type_description')::citext
            , (mortgage->>'loan_term')::citext
            , (mortgage->>'maturity_date')::date
            , (mortgage->>'next_monthly_payment')::numeric(28,8)
            , (mortgage->>'next_payment_due_date')::date
            , (mortgage->>'origination_date')::date
            , (mortgage->>'origination_principal_amount')::numeric(28,8)
            , (mortgage->>'past_due_amount')::numeric(28,8)
            , (mortgage->'property_address'->>'street')::citext
            , (mortgage->'property_address'->>'city')::citext
            , (mortgage->'property_address'->>'region')::citext
            , (mortgage->'property_address'->>'postal_code')::citext
            , (mortgage->'property_address'->>'country')::citext
            , (mortgage->>'ytd_interest_paid')::numeric(28,8)
            , (mortgage->>'ytd_principal_paid')::numeric(28,8)
    from(
        select user_id
             , institution_id
             , jsonb_array_elements(
                case jsonb_typeof(jsondoc->'mortgage') 
                     when 'array' then jsondoc->'mortgage' 
                     else '[]' 
                end
                ) as mortgage
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as mortgage_loan_accounts
    ON CONFLICT (ID)
    DO UPDATE SET
      account_number = excluded.account_number
    , current_late_fee = excluded.current_late_fee
    , escrow_balance = excluded.escrow_balance
    , has_pmi = excluded.has_pmi
    , has_prepayment_penalty = excluded.has_prepayment_penalty
    , interest_rate_percentage = excluded.interest_rate_percentage
    , interest_rate_type = excluded.interest_rate_type
    , last_payment_amount = excluded.last_payment_amount
    , last_payment_date = excluded.last_payment_date
    , loan_type_description = excluded.loan_type_description
    , loan_term = excluded.loan_term
    , maturity_date = excluded.maturity_date
    , next_monthly_payment = excluded.next_monthly_payment
    , next_payment_due_date = excluded.next_payment_due_date
    , origination_date = excluded.origination_date
    , origination_principal_amount = excluded.origination_principal_amount
    , past_due_amount = excluded.past_due_amount
    , street = excluded.street
    , city = excluded.city
    , region = excluded.region
    , postal_code = excluded.postal_code
    , country = excluded.country
    , ytd_interest_paid = excluded.ytd_interest_paid
    , ytd_principal_paid = excluded.ytd_principal_paid;

  end;
$BODY$;


create or replace function import_plaid_liabilities(plaid_webhook_history_id integer) 
  returns void
  language plpgsql
 as $$

  begin

    perform plaid_insert_or_update_credit_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_student_loan_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_mortgage_accounts(plaid_webhook_history_id);

  end
$$;


create or replace function import_plaid_webhook_history_data() 
  returns trigger
  language plpgsql
 as $$
  declare
    schemaName text;
    tableName text;
    columnName text;    
    sqlErrorCode text;
    constraintName text;
    dataType text;
    exceptionMessage text;
    exceptionDetail text;
    exceptionHint text;
    exceptionContext text;
    jsonError jsonb;
  begin
  
    if NEW.webhook_type = 'TRANSACTIONS' then
       perform import_plaid_liabilities(NEW.plaid_webhook_history_id);
    elsif NEW.webhook_type = 'LIABILITIES' then
       perform import_plaid_transactions(NEW.plaid_webhook_history_id);      
    end if;
    
    -- raise notice 'import complete for: %', NEW.plaid_webhook_history_id;
    update plaid_webhook_history_data 
       set imported_at=now()
     where id=NEW.id;

    return null;

  exception when others then
      get stacked diagnostics
          schemaName=SCHEMA_NAME, -- the name of the schema related to exception
          tableName=TABLE_NAME,   -- the name of the table related to exception
          columnName=COLUMN_NAME, -- the name of the column related to exception          
          sqlErrorCode=RETURNED_SQLSTATE, -- the SQLSTATE error code of the exception
          constraintName=CONSTRAINT_NAME, -- the name of the constraint related to exception
          dataType=PG_DATATYPE_NAME,      -- the name of the data type related to exception
          exceptionMessage=MESSAGE_TEXT,  -- the text of the exception's primary message
          exceptionDetail=PG_EXCEPTION_DETAIL,   -- the text of the exception's detail message, if any
          exceptionHint=PG_EXCEPTION_HINT,       -- the text of the exception's hint message, if any
          exceptionContext=PG_EXCEPTION_CONTEXT -- line(s) of text describing the call stack at the time of the exception
      ;
      
    jsonError=jsonb_build_object(
            'schemaName', schemaName,
            'tableName', tableName,
            'columnName', columnName,
            'sqlErrorCode', sqlErrorCode,
            'constraintName', constraintName,
            'dataType', dataType,
            'exceptionMessage', exceptionMessage,
            'exceptionDetail', exceptionDetail,
            'exceptionHint', exceptionHint,
            'exceptionContext', exceptionContext
         );
         
    -- raise notice 'error: %', jsonError;         

    update plaid_webhook_history_data
       set importError = jsonError
     where id=NEW.id;

    return null;
   
  end
$$;


create or replace trigger plaid_webhook_history_data_trigger
 after insert on plaid_webhook_history_data
   for each row execute procedure import_plaid_webhook_history_data();




-- CREATE FUNCTION category_insert_values() RETURNS trigger AS $$
--   BEGIN
--     NEW.subcategory :=COALESCE(NEW.subcategory, 'General');
--     RETURN NEW;
--   END
-- $$ LANGUAGE plpgsql;


-- CREATE TRIGGER category_trigger
-- BEFORE INSERT OR UPDATE ON categories
-- FOR EACH ROW EXECUTE PROCEDURE category_insert_values();


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
   a.type,
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






