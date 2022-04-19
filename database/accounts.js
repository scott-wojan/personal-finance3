import sql from "./db.js";
import { toJsonEscaped } from "./helpers.js";

export async function getUserAccounts({ userId }) {
  // @ts-ignore
  const rows = await sql`
      select *
        from user_accounts
       where user_id = ${userId}
       order by institution, name
  `;
  return rows;
}

export async function saveUserAccounts({
  userId,
  institutionId,
  accessToken,
  accounts,
  requestId,
}) {
  const json = toJsonEscaped(accounts);
  const query = `select * from insert_plaid_accounts(${userId},'${requestId}','${institutionId}','${accessToken}','${json}')`;
  await sql.unsafe(query);
}

export async function getAccountsAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`select name || ' x' || mask as label, name as value from accounts where user_id = ${userId} order by name;`;
}

export async function getUserAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
    select *
      from user_accounts
     where id=${accountId} 
       and user_id = ${userId}
`;
  return rows[0];
}
