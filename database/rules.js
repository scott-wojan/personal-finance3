import sql from "./db.js";

export async function getUserRules({ userId }) {
  // @ts-ignore
  return await sql`
    select id
         , rule
      from user_rules uc
     where user_id = ${userId}
  ;`;
}

export async function saveRule({ userId, rule }) {
  await sql`select save_and_run_rule (${userId},${rule});`;
}
