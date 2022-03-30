import sql from "./db.js";

export async function getUserCategoriesAndSubcategories({ userId }) {
  // @ts-ignore
  return await sql`
    select category_id, c.category as imported_category, c.subcategory as imported_subcategory, user_category, user_subcategory
      from user_categories uc
     inner join categories c on c.id = category_id
     where user_id = ${userId}
     order by imported_category, imported_subcategory
  ;`;
}

export async function updateUserCategoryAndSubcategory({
  userId,
  categoryId,
  category,
  subcategory,
}) {
  // @ts-ignore
  return await sql`
   update user_categories 
      set user_category = ${category},
          user_subcategory = ${subcategory}
    where user_id=${userId}
      and category_id=${categoryId}
  ;`;
}
