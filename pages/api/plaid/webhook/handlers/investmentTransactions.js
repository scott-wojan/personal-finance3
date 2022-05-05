import { getAccessInfoByItemId } from "database/institutions";
import { saveWebhookData } from "database/webook";
import { getInvestmentTransactions } from "integrations/plaid/investmentTransactions";

async function updateInvestmentTransactions(webhookId, item_id) {
  const accessInfo = await getAccessInfoByItemId(item_id);
  if (!accessInfo) {
    throw new Error(`No institution_id found with item_id="${item_id}"`);
  }

  const {
    access_token,
    institution_id: institutionId,
    user_id: userId,
  } = accessInfo;

  const data = await getInvestmentTransactions(access_token);

  saveWebhookData({
    webhookId,
    institutionId,
    userId,
    json: data,
  });
}

async function defaultUpdate(webhookId, requestBody) {
  const { item_id } = requestBody;
  await updateInvestmentTransactions(webhookId, item_id);
}

const investmentTransactionsHandlers = new Map([
  ["DEFAULT_UPDATE", defaultUpdate],
]);

export { investmentTransactionsHandlers };
