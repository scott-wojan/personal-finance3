import { getUserFromCookie } from "cookies/user";
import { getAccountsAsSelectOptions } from "database/accounts";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  try {
    const accounts = await getAccountsAsSelectOptions({
      userId: user?.id,
    });

    res.status(200).json(accounts);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
