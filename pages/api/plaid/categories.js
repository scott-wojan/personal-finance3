import { saveCategories } from "database/categories";
import { getAllCategories } from "integrations/plaid/categories";

export default async function handler(req, res) {
  try {
    const categories = await getAllCategories();
    const mappedCategories = categories.map((category) => {
      return {
        source_id: category.category_id,
        category: category.hierarchy?.[0],
        subcategory: category.hierarchy?.[1] ?? null,
        source: "Plaid",
      };
    });
    saveCategories({ categories: mappedCategories });

    return res.status(200).json(mappedCategories);
  } catch (error) {
    return res.status(200).json(error);
  }
}
