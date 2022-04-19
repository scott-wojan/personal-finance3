import client from "./client.js";

/**
 * Gets all accounts for a bank's access token
 *
 * @param {string} access_token the access token for the bank.
 * @returns the accounts at the bank.
 */
export async function getUserAccountsForInstitution(access_token) {
  const accountsResponse = await client.accountsGet({
    access_token,
  });
  return accountsResponse.data.accounts;
}
