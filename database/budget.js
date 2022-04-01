import sql from "./db.js";

async function getUserBudget({ userId }) {
  // @ts-ignore
  return await sql`
    select category_id, user_category, user_subcategory, min_budgeted_amount, max_budgeted_amount
      from user_categories
    where user_id = ${userId}
    order by user_category, user_subcategory;
  `;
}

export { getUserBudget };
