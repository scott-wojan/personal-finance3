import { setUserCookie } from "cookies/user";
import { createUser } from "database/users";

export default async function handler(req, res) {
  const { email } = req.body;

  if (!email) {
    return res.status(400).json({ message: "Email required" });
  }

  try {
    const user = await createUser(email);
    if (!user) {
      return res.status(200).json();
    }

    setUserCookie(req, res, user);

    return res.status(200).json(user);
  } catch (error) {
    return res.status(400).json(error);
  }
}
