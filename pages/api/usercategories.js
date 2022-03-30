import { getUserFromCookie } from "cookies/user";
import { getUserCategoriesAndSubcategories } from "database/usercategories";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  try {
    const categories = await getUserCategoriesAndSubcategories({
      userId: user?.id,
    });

    res.status(200).json(categories);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
