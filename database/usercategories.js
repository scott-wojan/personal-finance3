import sql from "./db.js";

export async function getUserCategoriesAndSubcategories({ userId }) {
  // @ts-ignore
  return await sql`
    select id as user_category_id
         , user_category
         , user_subcategory
      from user_categories uc
     where user_id = ${userId}
     order by user_category, user_subcategory
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
