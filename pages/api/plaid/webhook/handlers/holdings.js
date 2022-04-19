import { getAccessInfoByItemId } from "database/institutions";
import { getHoldings } from "integrations/plaid/holdings";

async function updateHoldings(item_id) {
  const accessInfo = await getAccessInfoByItemId(item_id);
  if (!accessInfo) {
    throw new Error(`No institution_id found with item_id="${item_id}"`);
  }

  const {
    access_token,
    institution_id: institutionId,
    user_id: userId,
  } = accessInfo;

  const data = await getHoldings(access_token);
  //Save to database, run stored procedure to process accounts,holdings,and securities
  const { accounts, holdings, securities, request_id } = data;
}

async function defaultUpdate(requestBody) {
  const { item_id } = requestBody;
  await updateHoldings(item_id);
}

const transactionHandlers = new Map([["DEFAULT_UPDATE", defaultUpdate]]);

export { transactionHandlers };
