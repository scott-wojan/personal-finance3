import client from "./client.js";

/**
 * Gets the full list of categories
 *
 * @returns {Object} all plaid categories.
 */
export async function getAllCategories() {
  const response = await client.categoriesGet({});
  return response.data.categories;
}
