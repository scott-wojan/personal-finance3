import sql from "./db.js";
import { toJsonEscaped } from "./helpers";

export async function saveWebhook({
  item_id,
  webhook_code,
  webhook_type,
  json,
}) {
  const escapedJson = toJsonEscaped(json);
  const query = `insert into plaid_webhook_history(item_id, webhook_code, webhook_type, jsonDoc) values ('${item_id}', '${webhook_code}', '${webhook_type}','${escapedJson}') returning id`;
  const result = await sql.unsafe(query);
  return result[0];
}

export async function saveWebhookError({ id, error }) {
  await sql` update plaid_webhook_history set error=${error} where id=${id};`;
}

export async function saveWebhookData({
  institutionId,
  userId,
  webhookId,
  json,
}) {
  const escapedJson = toJsonEscaped(json);
  const query = `insert into plaid_webhook_history_data(plaid_webhook_history_id, institution_id, user_id, jsonDoc) values ('${webhookId}','${institutionId}', '${userId}','${escapedJson}') returning id`;
  const result = await sql.unsafe(query);
  return result[0];
}
