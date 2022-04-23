import axios from "axios";
import { CountryCode, Products } from "plaid";
import { environment, application } from "appconfig";
import { getUserFromCookie } from "cookies/user";
import { getLinkToken } from "integrations/plaid/tokens";

async function getWebhookUrl() {
  //if (environment.isDevelopment) { //TODO: production should not use this
  try {
    const nGrokResponse = await axios.get("http://127.0.0.1:4040/api/tunnels");
    const { tunnels } = await nGrokResponse.data;
    const httpTunnel = tunnels.find((t) => t.proto === "http");
    return httpTunnel.public_url;
  } catch (error) {
    if (error.code === "ECONNREFUSED") {
      throw new Error("nGrok probably not running");
    }
    throw error;
  }
  //}
}

export default async function handler(req, res) {
  const user = getUserFromCookie(req, res);
  if (!user) {
    return res.status(401);
  }

  const { products } = req.body;

  let webhookUrl = null;
  try {
    webhookUrl = `${await getWebhookUrl()}/api/plaid/webhook`;
  } catch (error) {
    return res.status(500).json(error);
  }

  const request = {
    user: {
      // The unique id for the current user.
      client_user_id: user.id.toString(),
      //The user's email address. This field is optional, but required to enable the pre-authenticated returning user flow. https://plaid.com/docs/link/returning-user/#enabling-the-returning-user-experience
      email_address: user.email,
    },
    client_name: application.name,
    products,
    // [
    //   //List of Plaid product(s) you wish to use. If launching Link in update mode, should be omitted; required otherwise.
    //   //Only institutions that support all requested products will be shown in Link; to maximize the number of institutions listed, it is recommended to initialize Link with the minimal product set required for your use case. Additional products can be added after Link initialization by calling the relevant endpoints. For details and exceptions, see Choosing when to initialize products.
    //   // Products.Auth,
    //   // Products.Transactions,
    //   // Products.Investments,
    //   // Products.Assets,
    //   // Products.Balance,
    //   // Products.Liabilities,
    //   // Products.CreditDetails,
    // ]
    country_codes: [CountryCode.Us],
    webhook: webhookUrl,
    language: "en",
  };
  // console.log(request);
  try {
    const createTokenResponse = await getLinkToken(request);
    res.status(200).json(createTokenResponse.data);
  } catch (error) {
    res.status(400).json(error.response.data);
  }
}
