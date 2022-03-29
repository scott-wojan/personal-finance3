import { setUserCookie } from "cookies/user";
import { getUserByEmail } from "database/users";

export default async function handler(req, res) {
  const { email } = req.body;
  try {
    const user = await getUserByEmail(email);
    if (!user) {
      return res.status(200).json();
    }

    setUserCookie(req, res, user);

    return res.status(200).json(user);
  } catch (error) {
    return res.status(400).json(error);
  }
}
