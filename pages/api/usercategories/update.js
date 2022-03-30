import { getUserFromCookie } from "cookies/user";
import { updateUserCategoryAndSubcategory } from "database/usercategories";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { categoryId, category, subcategory } = req.body;
  if (!categoryId || !category || !subcategory) return res.status(401).json();

  try {
    const categories = await updateUserCategoryAndSubcategory({
      userId: user?.id,
      categoryId,
      category,
      subcategory,
    });

    res.status(200).json(categories);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
