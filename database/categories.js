import sql from "./db.js";

export async function getUserCategoriesAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`
      select distinct user_category as label, 
             user_category as value 
        from user_categories 
       where user_id = ${userId}
       order by user_category;   
  `;
}

export async function saveCategories({ categories }) {
  categories.forEach(async (category) => {
    await sql`
      insert into categories (source_id, category, subcategory, source)
                       values(
                         ${category.source_id},
                         ${category.category},
                         ${category.subcategory},
                         ${category.source}
                        )
                        on conflict do nothing;
    `;
  });
}
