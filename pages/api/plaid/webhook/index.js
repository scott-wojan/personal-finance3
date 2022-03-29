import { transactionHandlers } from "./handlers/transactions";

export default async function handler(req, res) {
  console.log("WEBHOOK START", req.body);
  const { webhook_type, webhook_code } = req.body;

  try {
    const webhookHandlers = new Map([["TRANSACTIONS", transactionHandlers]]);
    const webhookHandler = webhookHandlers.get(webhook_type);
    const webhook = webhookHandler.get(webhook_code);
    webhook(req.body);
  } catch (error) {
    console.log("WEBHOOK ERROR", error);
    return res.status(500).json();
  }

  console.log("WEBHOOK END", webhook_type, webhook_code);
  return res.status(200).json();
}
