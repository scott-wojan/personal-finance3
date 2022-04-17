import sql from "./db.js";

async function getSubCategoriesAsSelectOptions({ userId, category }) {
  // @ts-ignore
  return await sql`
      select coalesce(user_subcategory,'') as value, 
             coalesce(user_subcategory,'n/a') as label 
        from user_categories 
       where user_id=${userId} 
         and user_category=${category} 
       order by user_subcategory; `;
}

export { getSubCategoriesAsSelectOptions };
