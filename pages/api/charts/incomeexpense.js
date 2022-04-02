import { getUserFromCookie } from "cookies/user";
import { getUserIncomeAndExpense } from "database/charts/incomeAndExpenses";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) {
    return res.status(401).json();
  }

  const { startDate, endDate } = req.body;

  try {
    const transactions = await getUserIncomeAndExpense({
      userId: user?.id,
      startDate,
      endDate,
    });
    res.status(200).json(transactions);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
