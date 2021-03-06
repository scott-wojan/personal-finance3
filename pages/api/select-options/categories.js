import { getUserFromCookie } from "cookies/user";
import { getUserCategoriesAsSelectOptions } from "database/categories";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  try {
    const categories = await getUserCategoriesAsSelectOptions({
      userId: user?.id,
    });

    res.status(200).json(categories);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
