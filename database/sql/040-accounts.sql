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
    last_import_date  timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    user_id integer REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,    
    institution_id citext REFERENCES institutions(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (type, subtype) REFERENCES account_subtypes (account_type, account_subtype)
);

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

create or replace view mortgages as
select user_id
     , i.name as institution_name
     , i.url as institution_url
     , i.primary_color as institution_color
     , i.logo as institution_logo
     , a.name as account_name
     , a.mask as account_mask
     , a.current_balance as account_balance
     , a.iso_currency_code
     , a.created_at as account_created_at
     , a.updated_at as account_updated_at
     , ma.account_number
     , ma.current_late_fee
     , ma.escrow_balance
     , ma.has_pmi
     , ma.has_prepayment_penalty
     , ma.interest_rate_percentage
     , ma.interest_rate_type
     , ma.last_payment_amount
     , ma.last_payment_date
     , ma.loan_type_description
     , ma.loan_term
     , ma.maturity_date
     , ma.next_monthly_payment
     , ma.next_payment_due_date
     , ma.origination_date
     , ma.origination_principal_amount
     , ma.past_due_amount
     , ma.street
     , ma.city
     , ma.region
     , ma.postal_code
     , ma.country
     , ma.ytd_interest_paid
     , ma.ytd_principal_paid
  from accounts a
       inner join institutions i on i.id = a.institution_id
       inner join mortgage_accounts ma on ma.id = a.id
 where type='loan'
   and subtype = 'mortgage';






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