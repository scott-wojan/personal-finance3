import sql from "./db.js";

const sampleInstitution = {
  country_codes: ["US"],
  institution_id: "ins_3",
  name: "Chase",
  oauth: false,
  products: [
    "assets",
    "auth",
    "transactions",
    "credit_details",
    "income",
    "identity",
    "investments",
    "liabilities",
  ],
  routing_numbers: [
    "021000021",
    "021100361",
    "021202337",
    "022300173",
    "044000037",
    "051900366",
    "061092387",
    "065400137",
    "071000013",
    "072000326",
    "074000010",
    "075000019",
    "083000137",
    "102001017",
    "103000648",
    "111000614",
    "122100024",
    "123271978",
    "124001545",
    "267084131",
    "322271627",
    "325070760",
  ],
};

async function saveInstitution(institution) {
  // @ts-ignore
  await sql`
    INSERT INTO institutions
    (
      id,
      name,
      url,
      primary_color,
      logo
    )
    VALUES (${institution.institution_id}, ${institution.name ?? null}, ${
    institution.url ?? null
  }, ${institution.primary_color ?? null}, ${institution.logo ?? null})
    ON CONFLICT (id)
    DO UPDATE SET
      name=${institution.name ?? null},
      url=${institution.url ?? null},
      primary_color=${institution.primary_color ?? null},
      logo=${institution.logo ?? null}
  `;
  return;
}

async function associateInstitutionToUser({
  itemId,
  institutionId,
  userId,
  accessToken,
}) {
  // @ts-ignore
  await sql`INSERT INTO user_institutions(item_id, user_id, institution_id, access_token) VALUES (${itemId}, ${userId}, ${institutionId}, ${accessToken})`;
  return;
}

async function getAccessInfoByItemId(item_id) {
  const rows =
    // @ts-ignore
    await sql`select access_token, institution_id, user_id from user_institutions where item_id = ${item_id}`;
  return rows[0];
}

export { saveInstitution, associateInstitutionToUser, getAccessInfoByItemId };
