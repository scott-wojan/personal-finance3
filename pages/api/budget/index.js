import { getUserFromCookie } from "cookies/user";
import { getUserBudget } from "database/budget";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { startDate, endDate, showBudgetedCategoriesOnly = false } = req.body;
  if (!startDate || !endDate) {
    res.status(400).json({
      message: "Both start date and end date are required",
    });
  }

  try {
    const budget = await getUserBudget({
      userId: user?.id,
      startDate,
      endDate,
      excludeNonBudgetedCategories: showBudgetedCategoriesOnly,
    });

    res.status(200).json(budget);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
