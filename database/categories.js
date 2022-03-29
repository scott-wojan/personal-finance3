import sql from "./db.js";

async function getCategoriesAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`select distinct category as label, category as value from user_transactions where user_id = ${userId} order by category;`;
}

export { getCategoriesAsSelectOptions };
