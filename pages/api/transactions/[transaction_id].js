import { getUserFromCookie } from "cookies/user";
import { getUserTransactionDetails } from "database/transactions";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();
  const { transaction_id: transactionId } = req.query;
  try {
    const transactiondetails = await getUserTransactionDetails({
      userId: user?.id,
      transactionId,
    });

    res.status(200).json(transactiondetails);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
