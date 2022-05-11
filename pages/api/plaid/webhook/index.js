import { saveWebhook, saveWebhookError } from "database/webook";
import { holdingsHandlers } from "./handlers/holdings";
import { investmentTransactionsHandlers } from "./handlers/investmentTransactions";
import { liabilitiesHandlers } from "./handlers/liabilities";
import { transactionHandlers } from "./handlers/transactions";

export default async function handler(req, res) {
  console.log("WEBHOOK START", req.body);

  const { item_id, webhook_code, webhook_type } = req.body;

  const { id: webhookId } = await saveWebhook({
    item_id,
    webhook_code,
    webhook_type,
    json: req.body,
  });

  try {
    const webhookHandlers = new Map([
      ["TRANSACTIONS", transactionHandlers],
      ["LIABILITIES", liabilitiesHandlers],
      ["HOLDINGS", holdingsHandlers],
      ["INVESTMENTS_TRANSACTIONS", investmentTransactionsHandlers],
    ]);
    const webhookHandler = webhookHandlers.get(webhook_type);
    const webhook = webhookHandler.get(webhook_code);
    await webhook(webhookId, req.body);
  } catch (error) {
    console.log("WEBHOOK ERROR", error);

    saveWebhookError({
      id: webhookId,
      error: error?.response?.data,
    });

    return res.status(500).json();
  }

  console.log("WEBHOOK END", webhook_type, webhook_code);
  return res.status(200).json();
}
