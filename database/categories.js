import sql from "./db.js";

async function getUserCategoriesAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`
      select distinct user_category as label, 
             user_category as value 
        from user_categories 
       where user_id = ${userId}
       order by user_category;   
  `;
}

export { getUserCategoriesAsSelectOptions };
