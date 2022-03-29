import { saveUserAccounts } from "database/accounts";
import { getAccessInfoByItemId } from "database/institutions";
import {
  deleteTransactions,
  saveUserTransactions,
} from "database/transactions";
import dayjs from "dayjs";
import { getTransactions } from "integrations/plaid/transactions";

async function updateTransactions(item_id, duration, measurement) {
  const startDate = dayjs()
    .subtract(duration, measurement)
    .format("YYYY-MM-DD");

  const accessInfo = await getAccessInfoByItemId(item_id);
  if (!accessInfo) {
    return;
  }
  const {
    access_token,
    institution_id: institutionId,
    user_id: userId,
  } = accessInfo;

  const endDate = dayjs().subtract(0, "days").format("YYYY-MM-DD");

  const data = await getTransactions(access_token, startDate, endDate);
  const { accounts, transactions } = data;

  await saveUserAccounts({
    userId: userId,
    institutionId: institutionId,
    accessToken: access_token,
    accounts,
  });

  await saveUserTransactions({ userId, transactions });
}

async function initialUpdate(requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(item_id, 30, "days");
}

async function historicalUpdate(requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(item_id, 2, "years");
}

async function defaultUpdate(requestBody) {
  const { item_id } = requestBody;
  await updateTransactions(item_id, 14, "days");
}

async function transactioinsRemoved(requestBody) {
  const { removed_transactions } = requestBody;
  await deleteTransactions({ transactionIds: removed_transactions });
}

const transactionHandlers = new Map([
  ["INITIAL_UPDATE", initialUpdate],
  ["HISTORICAL_UPDATE", historicalUpdate],
  ["DEFAULT_UPDATE", defaultUpdate],
  ["TRANSACTIONS_REMOVED", transactioinsRemoved],
]);

export { transactionHandlers };
