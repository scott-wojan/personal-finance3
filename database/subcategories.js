import sql from "./db.js";

async function getSubCategoriesAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql` select distinct category as group, subcategory as value, subcategory as label from user_transactions where user_id = ${userId} order by category,subcategory; `;
}

export { getSubCategoriesAsSelectOptions };
