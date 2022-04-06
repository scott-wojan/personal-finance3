// import { saveCategories } from "database/queries/categories";
import { getAllCategories } from "integrations/plaid/categories";

export default async function handler(req, res) {
  try {
    const categories = await getAllCategories();
    // saveCategories(categories);
    console.log(categories);
    return res.status(200).json(categories);
  } catch (error) {
    return res.status(200).json(error);
  }
}
