import { getUserFromCookie } from "cookies/user";
import { getUserBudget } from "database/budget";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  try {
    const budget = await getUserBudget({
      userId: user?.id,
    });

    res.status(200).json(budget);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
