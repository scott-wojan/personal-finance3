import { getUserFromCookie } from "cookies/user";
import { updateUserBudgetItem } from "database/budget";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  let { userCategoryId, min, max } = req.body;

  min = min > 0 ? min * -1 : min;
  max = max > 0 ? max * -1 : max;

  try {
    const budget = await updateUserBudgetItem({
      userId: user?.id,
      userCategoryId,
      min,
      max,
    });

    res.status(200).json(budget);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
