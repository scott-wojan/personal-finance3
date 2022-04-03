import { getUserFromCookie } from "cookies/user";
import {
  getUserIncomeAndExpense,
  getUserIncomeAndExpenseForAccount,
} from "database/charts/incomeAndExpenses";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) {
    return res.status(401).json();
  }

  const { startDate, endDate, accountId } = req.body;

  try {
    let incomeAndExpenseData;

    if (accountId) {
      incomeAndExpenseData = await getUserIncomeAndExpenseForAccount({
        userId: user?.id,
        startDate,
        endDate,
        accountId,
      });
    } else {
      incomeAndExpenseData = await getUserIncomeAndExpense({
        userId: user?.id,
        startDate,
        endDate,
      });
    }

    res.status(200).json(incomeAndExpenseData);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
