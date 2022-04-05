import dayjs from "dayjs";
import sql from "./db.js";

// async function getUserBudget({ userId }) {
//   // @ts-ignore
//   return await sql`
//     select category_id, user_category, user_subcategory, min_budgeted_amount, max_budgeted_amount
//       from user_categories
//     where user_id = ${userId}
//     order by user_category, user_subcategory;
//   `;
// }

async function getUserBudget({ userId, startDate, endDate }) {
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
      from user_spending_metrics_by_category_subcategory(${userId},${startDate},${endDate})
     where total_spend < 0
  `;
}

export { getUserBudget };
