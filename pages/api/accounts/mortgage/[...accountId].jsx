import { getUserFromCookie } from "cookies/user";
import { getUserMortgageAccountById } from "database/accounts";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { accountId } = req.query;

  if (accountId) {
    try {
      const account = await getUserMortgageAccountById({
        userId: user?.id,
        accountId,
      });

      return res.status(200).json(account);
    } catch (error) {
      return res.status(400).json(error.response);
    }
  }
}
