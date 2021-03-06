import sql from "./db.js";

export async function updateUserBudgetItem({
  userId,
  userCategoryId,
  min,
  max,
  doNotBudget = false,
}) {
  // @ts-ignore
  return await sql`
   update user_categories
      set min_budgeted_amount = ${min}
        , max_budgeted_amount = ${max}
        , do_not_budget = ${doNotBudget}
    where id = ${userCategoryId}
      and user_id = ${userId}
  `;
}

export async function getUserBudget({
  userId,
  startDate,
  endDate,
  excludeNonBudgetedCategories = false,
}) {
  console.log("XXXX");
  // @ts-ignore
  return await sql`
    select user_category_id
         , user_category 
         , user_subcategory 
         , min_budgeted_amount 	
         , max_budgeted_amount 
         , min_monthly_spend 
         , avg_monthly_spend	
         , max_monthly_spend 
         , total_spend
         , do_not_budget         
      from user_spending_metrics_by_category_subcategory(${userId},${startDate},${endDate},${excludeNonBudgetedCategories})
     where total_spend < 0
  `;
}
