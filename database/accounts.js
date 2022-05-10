import sql from "./db.js";

export async function getUserMortgageAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
    select ma.*
    from mortgage_accounts ma
         join accounts a on a.id=ma.id 
   where a.user_id = ${userId}
     and a.id = ${accountId};
  `;
  return rows[0];
}

export async function getUserCreditAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
    select ca.*
    from credit_accounts ca
         join accounts a on a.id=ca.id
   where a.user_id = ${userId}
     and a.id = ${accountId};
  `;
  return rows[0];
}

export async function getUserAccounts({ userId }) {
  // @ts-ignore
  const rows = await sql`
      select *
    from user_accounts
    where user_id = ${userId}
    order by type, subtype, institution, name;
  `;
  return rows;
}

export async function getUserAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
          select *
          from user_accounts ua
        where user_id = ${userId}    
          and id = ${accountId} 
`;
  return rows[0];
}

export async function saveUserAccounts({ userId, institutionId, accounts }) {
  accounts?.forEach(async (account) => {
    await sql`insert into accounts(id,user_id,institution_id,name,mask,type,subtype) 
                            values(${account.id},${userId},${institutionId},${account.name},${account.mask},${account.type},${account.subtype})`;
  });
}

export async function getAccountsAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`select name || ' x' || mask as label, name as value from accounts where user_id = ${userId} order by name;`;
}
