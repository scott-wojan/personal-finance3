import { getUserFromCookie } from "cookies/user";
import { getSubCategoriesAsSelectOptions } from "database/subcategories";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  const { category } = req.body;

  if (!user) {
    return res.status(401).json();
  }
  if (!category)
    return res.status(400).json({ message: "Must specifify category" });

  try {
    const subcategories = await getSubCategoriesAsSelectOptions({
      userId: user?.id,
      category,
    });

    res.status(200).json(subcategories);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
