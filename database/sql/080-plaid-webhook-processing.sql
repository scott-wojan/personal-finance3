
/************************************************************************************************************
ACCOUNT webook processing
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
        , last_import_date
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
         , now() as last_import_date
    from(
        select user_id, institution_id, jsonb_array_elements(jsondoc->'accounts') "account"
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
    ) as accounts
    ON CONFLICT (ID)
    DO UPDATE SET
    official_name = excluded.official_name,
    subtype = excluded.subtype,
    type = excluded.type,
    available_balance = excluded.available_balance,
    current_balance = excluded.current_balance,
    account_limit = excluded.account_limit,
    iso_currency_code = excluded.iso_currency_code,
    last_import_date = excluded.last_import_date
    ;

  end;
$BODY$;

/************************************************************************************************************
CATEGORY webook processing
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
          where plaid_webhook_history_id = webhookHistoryId
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
          where plaid_webhook_history_id = webhookHistoryId
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
TRANSACTION webhook processing
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
         where plaid_webhook_history_id = webhookHistoryId
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

/************************************************************************************************************
LIABILITIES webook processing
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
                case jsonb_typeof(jsondoc->'liabilities'->'credit') 
                    when 'array' then jsondoc->'liabilities'->'credit' 
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
                case jsonb_typeof(jsondoc->'liabilities'->'student') 
                     when 'array' then jsondoc->'liabilities'->'student' 
                     else '[]' 
                end
                ) as student_loan
          from plaid_webhook_history_data
         where plaid_webhook_history_id = webhookHistoryId
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
                case jsonb_typeof(jsondoc->'liabilities'->'mortgage') 
                     when 'array' then jsondoc->'liabilities'->'mortgage' 
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
    perform plaid_insert_or_update_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_credit_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_student_loan_accounts(plaid_webhook_history_id);
    perform plaid_insert_or_update_mortgage_accounts(plaid_webhook_history_id);
  end
$$;



/************************************************************************************************************
Webook processing
************************************************************************************************************/

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
    webhooktype text;
  begin
    select webhook_type from plaid_webhook_history where id = NEW.plaid_webhook_history_id into webhooktype;
    -- raise notice 'webhook_type: %', webhooktype;

    if webhooktype = 'LIABILITIES' then
       perform import_plaid_liabilities(NEW.plaid_webhook_history_id);
    elsif webhooktype = 'TRANSACTIONS' then
       perform import_plaid_transactions(NEW.plaid_webhook_history_id);
    -- elsif webhooktype = 'HOLDINGS' then
    --    perform import_plaid_holdings(NEW.plaid_webhook_history_id);
    -- elsif webhooktype = 'INVESTMENTS_TRANSACTIONS' then
    --    perform import_plaid_investment_holdings(NEW.plaid_webhook_history_id);             
    end if;


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