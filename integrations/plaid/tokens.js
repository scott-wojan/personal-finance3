import client from "./client";

/**
 * Gets a link token
 *
 * @param {string} public_token the public_token.
 * @returns an access_token.
 */
export async function getAccessToken(public_token) {
  const response = await client.itemPublicTokenExchange({
    public_token,
  });
  return response.data;
}

/**
 * Gets a link token
 * https://plaid.com/docs/api/tokens/#itempublic_tokenexchange
 * @param {Object} request the request settings.
 * @returns the accounts at the bank.
 */
export async function getLinkToken(request) {
  try {
    const response = await client.linkTokenCreate(request);
    return response;
  } catch (error) {
    throw error;
  }
}
