import { getUserFromCookie } from "cookies/user";

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);

  if (!user) return res.status(401).json();

  res.status(200).json([
    { label: "Posted", value: "Posted" },
    { label: "Pending", value: "Pending" },
  ]);
}
