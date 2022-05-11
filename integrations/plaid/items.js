import client from "./client";

/**
 * Removes a link token
 *
 * @param {string} access_token the access_token.
 * @returns
 */
export async function removeItem(access_token) {
  const response = await client.itemRemove({
    access_token,
  });
  return response;
}
