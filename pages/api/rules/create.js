import { getUserFromCookie } from "cookies/user";
import { saveRule } from "database/rules";
import { preventSqlInjection } from "../hoc/preventSqlInjection";

export default preventSqlInjection({
  post: handler,
});

export async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { name, newName, condition, category, subcategory } = req.body;

  if (!name || !newName || !condition) {
    return res.status(400).json({ message: "missing required data" });
  }

  if (!conditions.includes(condition)) {
    return res.status(400).json({ message: "invalid operator" });
  }

  const setValues = [];
  setValues.push({
    name: "name",
    value: newName,
  });

  if (category) {
    setValues.push({
      name: "category",
      value: category,
    });
  }

  if (subcategory) {
    setValues.push({
      name: "subcategory",
      value: subcategory,
    });
  }

  const rule = {
    where: [
      {
        name: "name",
        condition: condition,
        value: newName,
      },
    ],
    set: setValues,
  };

  try {
    await saveRule({
      userId: user?.id,
      rule,
    });

    res.status(200).json();
  } catch (error) {
    res.status(400).json(error.response);
  }
}

const conditions = ["equals", "starts with", "contains", "ends with"];
