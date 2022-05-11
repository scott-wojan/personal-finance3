import { Configuration, PlaidApi, PlaidEnvironments } from "plaid";
import { plaid as settings } from "appconfig";

const configuration = new Configuration({
  basePath: PlaidEnvironments[process.env.PLAID_ENV],
  baseOptions: {
    headers: {
      "PLAID-CLIENT-ID": settings.clientId,
      "PLAID-SECRET": settings.secret,
      "Plaid-Version": "2020-09-14", //https://plaid.com/docs/api/versioning/
    },
  },
});

const client = new PlaidApi(configuration);
export default client;
