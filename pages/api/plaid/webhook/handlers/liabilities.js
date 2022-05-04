import { getAccessInfoByItemId } from "database/institutions";
import { saveWebhookData } from "database/webook";
import { getLiabilities } from "integrations/plaid/liabilities";

async function updateLiabilities(item_id, webhookId) {
  const accessInfo = await getAccessInfoByItemId(item_id);
  if (!accessInfo) {
    throw new Error(`No institution_id found with item_id="${item_id}"`);
  }

  const {
    access_token: accessToken,
    institution_id: institutionId,
    user_id: userId,
  } = accessInfo;

  const data = await getLiabilities(accessToken);

  saveWebhookData({
    webhookId,
    institutionId,
    userId,
    json: data,
  });
}

async function defaultUpdate(webhookId, requestBody) {
  const {
    item_id,
    account_ids_with_new_liabilities,
    account_ids_with_updated_liabilities,
  } = requestBody;

  // const updatedAccountIds = Object.keys(
  //   account_ids_with_updated_liabilities
  // ).map((key) => {
  //   return key;
  // });

  // const account_ids = [
  //   ...account_ids_with_new_liabilities,
  //   ...updatedAccountIds,
  // ];

  await updateLiabilities(item_id, webhookId);
}

const liabilitiesHandlers = new Map([["DEFAULT_UPDATE", defaultUpdate]]);

export { liabilitiesHandlers };
