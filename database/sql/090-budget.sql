/************************************************************************************************************
users
************************************************************************************************************/

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
