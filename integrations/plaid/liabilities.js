import client from "./client";
export async function getLiabilities(accessToken, accountIds) {
  try {
    const request = {
      access_token: accessToken,
      // options: {
      //   account_ids: accountIds,
      // },
    };
    const response = await client.liabilitiesGet(request);
    return response.data;
  } catch (error) {
    return error.response.data;
  }
}
