import axios from "axios";

export default async function handler(req, res) {
  try {
    const response = await axios.post(
      `${process.env.FINICITY_API_URL}/aggregation/v2/partners/authentication`,
      {
        partnerId: process.env.FINICITY_PARTNER_ID,
        partnerSecret: process.env.FINICITY_PARTNER_SECRET,
      },
      {
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "Finicity-App-Key": process.env.FINICITY_APP_KEY,
        },
      }
    );

    return res.status(200).json(response.data);
  } catch (error) {
    return res.status(200).json(error);
  }
}
