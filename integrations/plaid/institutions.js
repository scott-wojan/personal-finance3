import { CountryCode } from "plaid";
import client from "./client.js";

/**
 * Gets a link token
 *
 * @param {string} institutionId the request settings.
 * @returns the accounts at the bank.
 */
export async function getInstitutionById(institutionId) {
  const request = {
    institution_id: institutionId,
    country_codes: [CountryCode.Us],
  };

  const response = await client.institutionsGetById(request);
  return response.data.institution;
}
