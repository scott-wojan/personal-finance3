import axios from "axios";

export default async function handler(req, res) {
  const { appToken, customerId } = req.body;
  try {
    const response = await axios.post(
      `${process.env.FINICITY_API_URL}/connect/v2/generate`,
      {
        partnerId: process.env.FINICITY_PARTNER_ID,
        customerId: customerId,
        // redirectUri: "", //The url that customers will be redirected to after completing Finicity Connect.  *Required unless Connect is embedded inside your application. (iframe)*
        // webhook: "https://webhook.site/8d4421a7-d1d1-4f01-bb08-5370aff0321b",
        // webhookContentType: "application/json",
        // experience: "default",
        //fromDate: 1607450357,
        //reportCustomFields: [],
        //singleUseUrl: true,
      },
      {
        headers: {
          "Finicity-App-Key": process.env.FINICITY_APP_KEY,
          "Finicity-App-Token": appToken,
          "Content-Type": "application/json",
          Accept: "application/json",
        },
      }
    );

    return res.status(200).json(response.data);
  } catch (error) {
    return res.status(200).json(error);
  }
}
