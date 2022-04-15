import { getUserFromCookie } from "cookies/user";
import { getUserRules } from "database/rules";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  try {
    const rules = await getUserRules({
      userId: user?.id,
    });

    res.status(200).json(rules);
  } catch (error) {
    res.status(400).json(error.response);
  }
}
