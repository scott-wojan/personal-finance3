import client from "./client";

export async function getHoldings(accessToken) {
  const request = {
    access_token: accessToken,
  };

  const response = await client.investmentsHoldingsGet(request);
  return response.data;
}
