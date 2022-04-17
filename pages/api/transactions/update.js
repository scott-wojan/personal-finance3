import { getUserFromCookie } from "cookies/user";
import { updateUserTransaction } from "database/transactions";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { id, name, category, subcategory } = req.body;
  if (!id || !name || !category) return res.status(400).json();

  try {
    await updateUserTransaction({
      userId: user?.id,
      id,
      name,
      category,
      subcategory: subcategory?.trim() == "" ? null : subcategory?.trim(),
    });

    res.status(200).json();
  } catch (error) {
    res.status(400).json(error.response);
  }
}
