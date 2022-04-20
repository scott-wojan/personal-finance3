import { getAccessInfoByItemId } from "database/institutions";
import { deleteTransactions } from "database/transactions";
import { saveTransactionWebhook } from "database/webook";
import dayjs from "dayjs";
import { getTransactions } from "integrations/plaid/transactions";

async function updateTransactions(webhookId, item_id, duration, measurement) {
  const startDate = dayjs()
    .subtract(duration, measurement)
    .format("YYYY-MM-DD");

  const endDate = dayjs().subtract(0, "days").format("YYYY-MM-DD");

  const accessInfo = await getAccessInfoByItemId(item_id);
  if (!accessInfo) {
    throw new Error(`No institution_id found with item_id="${item_id}"`);
  }
  const {
    access_token: accessToken,
    institution_id: institutionId,
    user_id: userId,
  } = accessInfo;

  const data = await getTransactions(accessToken, startDate, endDate);
  saveTransactionWebhook({
    webhookId,
    institutionId,
    userId,
    json: data,
  });
}

async function initialUpdate(webhookId, requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(webhookId, item_id, 30, "days");
}

async function historicalUpdate(webhookId, requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(webhookId, item_id, 2, "years");
}

async function defaultUpdate(webhookId, requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(webhookId, item_id, 14, "days");
}

async function transactionsRemoved(webhookId, requestBody) {
  const { removed_transactions } = requestBody;
  try {
    await deleteTransactions({ transactionIds: removed_transactions });
  } catch (error) {
    throw error;
  }
}

const transactionHandlers = new Map([
  ["INITIAL_UPDATE", initialUpdate],
  ["HISTORICAL_UPDATE", historicalUpdate],
  ["DEFAULT_UPDATE", defaultUpdate],
  ["TRANSACTIONS_REMOVED", transactionsRemoved],
]);

export { transactionHandlers };
