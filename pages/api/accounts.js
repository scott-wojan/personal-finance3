import { getUserFromCookie } from "cookies/user";
import { getUserAccountById, getUserAccounts } from "database/accounts";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return req.status(401).json();

  const { accountId } = req.body;

  if (accountId) {
    try {
      const account = await getUserAccountById({
        userId: user?.id,
        accountId,
      });

      return res.status(200).json(account);
    } catch (error) {
      return res.status(400).json(error.response);
    }
  }

  try {
    const accounts = await getUserAccounts({
      userId: user?.id,
    });

    res.status(200).json(accounts);
  } catch (error) {
    console.error(error);
    res.status(400).json(error.response);
  }
}
