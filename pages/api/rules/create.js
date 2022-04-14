import { getUserFromCookie } from "cookies/user";
import { saveRule } from "database/rules";
import { preventSqlInjection } from "../hoc/preventSqlInjection";

export default preventSqlInjection({
  post: handler,
});

export async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) return res.status(401).json();

  const { oldName, name, operator, category, subcategory } = req.body;

  if (!oldName || !name || !operator) {
    return res.status(400).json({ message: "missing required data" });
  }

  if (!operatorMap.has(operator)) {
    return res.status(400).json({ message: "invalid operator" });
  }
  const formatted = operatorMap.get(operator)(oldName);
  const setValues = [];
  if (oldName != name) {
    setValues.push({
      name: "name",
      operator: "=",
      value: name,
    });
  }

  if (category) {
    setValues.push({
      name: "category",
      operator: "=",
      value: category,
    });
  }

  if (subcategory) {
    setValues.push({
      name: "subcategory",
      operator: "=",
      value: subcategory,
    });
  }

  const rule = {
    tablename: "transactions",
    where: [
      {
        name: "name",
        operator: formatted.operator,
        value: formatted.value,
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

const operatorMap = new Map([
  [
    "Equals",
    (val) => {
      return { operator: "=", value: `${val}` };
    },
  ],
  [
    "Starts with",
    (val) => {
      return { operator: "like", value: `${val}%` };
    },
  ],
  [
    "Contains",
    (val) => {
      return { operator: "like", value: `%${val}%` };
    },
  ],
  [
    "Ends with",
    (val) => {
      return { operator: "like", value: `%${val}` };
    },
  ],
]);
