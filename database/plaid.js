import sql from "./db.js";

async function getAccessInfoForItemId(itemId) {
  // @ts-ignore
  const rows = await sql`
    select access_token, institution_id, user_id from user_institutions where item_id = ${itemId}
  `;
  return rows[0];
}

export { getAccessInfoForItemId };
