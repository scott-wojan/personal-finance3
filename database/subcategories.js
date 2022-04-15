import sql from "./db.js";

async function getSubCategoriesAsSelectOptions({ userId, category }) {
  // @ts-ignore
  return await sql`
      select user_subcategory as value, 
             user_subcategory as label 
        from user_categories 
       where user_id = ${userId} 
         and user_category=${category} 
       order by user_subcategory; `;
}

export { getSubCategoriesAsSelectOptions };
