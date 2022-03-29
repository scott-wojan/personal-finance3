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
 *
 * @param {Object} request the request settings.
 * @returns the accounts at the bank.
 */
export async function getLinkToken(request) {
  const createTokenResponse = await client.linkTokenCreate(request);
  return createTokenResponse;
}
