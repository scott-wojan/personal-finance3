import axios from "axios";

export default async function handler(req, res) {
  const { appToken, username } = req.body;
  try {
    const response = await axios.post(
      `${process.env.FINICITY_API_URL}/aggregation/v1/customers/testing`, //TESTING!!!
      {
        partnerId: process.env.FINICITY_PARTNER_ID,
        username,
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

    return res.status(200).json(response.data); //{"id":"5027273800","username":"customerusername1","createdDate":"1649637031"}
  } catch (error) {
    return res.status(200).json(error);
  }
}
