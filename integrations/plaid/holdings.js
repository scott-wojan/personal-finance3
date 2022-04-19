import client from "./client";

export async function getHoldings(accessToken) {
  const request = {
    access_token: accessToken,
  };

  try {
    const response = await client.investmentsHoldingsGet(request);
    return response.data;
  } catch (error) {
    return error.response.data;
  }
}
