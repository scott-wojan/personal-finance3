import { getUserFromCookie } from "cookies/user";
import { getUserTransactions } from "database/transactions";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) {
    return res.status(401).json();
  }

  const { accountId, page = 2, pageSize = 10, sort, filter } = req.body;

  // console.log("API Transactions", {
  //   userId: user?.id,
  //   page,
  //   pageSize,
  //   sort,
  //   filter: JSON.stringify(filter),
  // });

  try {
    const transactions = await getUserTransactions({
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
