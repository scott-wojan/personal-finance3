import sql from "./db.js";
import { toJsonEscaped } from "./helpers.js";

export async function getUserAccounts({ userId }) {
  // @ts-ignore
  const rows = await sql`
      WITH type_subtype_grouped_accounts as (
        select type
            , subtype
            , json_agg( 
              json_build_object(
                'id', id
              , 'institution', institution
              , 'name', name
              , 'mask', mask
              , 'official_name', official_name
              , 'current_balance', current_balance
              , 'available_balance', available_balance
              , 'account_limit', account_limit
              , 'iso_currency_code', iso_currency_code
              )) AS accounts
        from user_accounts ua
      where user_id = ${userId}     
      GROUP BY type, subtype
      )
      select type, json_object_agg(subtype, accounts) as accounts
        from (select type, subtype,  accounts from type_subtype_grouped_accounts) x
        group by type   
  `;
  return rows;
}

export async function getUserAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
        WITH type_subtype_grouped_accounts as (
          select type
              , subtype
              , json_agg( 
                json_build_object(
                  'id', id
                , 'institution', institution
                , 'name', name
                , 'mask', mask
                , 'official_name', official_name
                , 'current_balance', current_balance
                , 'available_balance', available_balance
                , 'account_limit', account_limit
                , 'iso_currency_code', iso_currency_code
                )) AS accounts
          from user_accounts ua
        where user_id = ${userId}    
          and id = ${accountId} 
        GROUP BY type, subtype
        )
        select type, json_object_agg(subtype, accounts) as accounts
          from (select type, subtype,  accounts from type_subtype_grouped_accounts) x
          group by type   
`;
  return rows[0];
}

export async function getAccountsAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`select name || ' x' || mask as label, name as value from accounts where user_id = ${userId} order by name;`;
}
