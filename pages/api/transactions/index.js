import { getUserFromCookie } from "cookies/user";
import { getTransactions } from "database/transactions";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  const { accountId } = req.body;
  const { page = 2, pageSize = 10, sort, filter } = req.body;

  if (!user) return res.status(401).json();

  // console.log("API Transactions", {
  //   userId: user?.id,
  //   page,
  //   pageSize,
  //   sort,
  //   filter: JSON.stringify(filter),
  // });

  try {
    let transactions = await getTransactions({
      userId: user?.id,
      page,
      pageSize,
      sort,
      filter,
      accountId,
    });
    res.status(200).json(transactions);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
