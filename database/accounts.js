import sql from "./db.js";
import { toJsonEscaped } from "./helpers.js";

async function getUserAccounts({ userId }) {
  // @ts-ignore
  const rows = await sql`
      select *
        from user_accounts
       where user_id = ${userId}
       order by institution, name
  `;
  return rows;
}

async function saveUserAccounts({
  userId,
  institutionId,
  accessToken,
  accounts,
}) {
  const json = toJsonEscaped(accounts);
  const query = `select * from insert_plaid_accounts(${userId},'${institutionId}','${accessToken}','${json}')`;
  await sql.unsafe(query);
}

async function getAccountsAsSelectOptions({ userId }) {
  // @ts-ignore
  return await sql`select name || ' x' || mask as label, name as value from accounts where user_id = ${userId} order by name;`;
}

async function getUserAccountById({ userId, accountId }) {
  // @ts-ignore
  const rows = await sql`
      select *
        from user_accounts
       where id=${accountId} 
         and user_id = ${userId}
  `;
  return rows[0];
}

const saveSample = [
  [
    {
      account_id: "VdMjKyEn6XhrZBED6vMRsVoLjLq3alinPn8J4",
      balances: {
        available: 100,
        current: 110,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "0000",
      name: "Plaid Checking",
      official_name: "Plaid Gold Standard 0% Interest Checking",
      subtype: "checking",
      type: "depository",
    },
    {
      account_id: "wd4GrXkLwzhq3zN5bBlrFJ7ZqZaENgulol76G",
      balances: {
        available: 200,
        current: 210,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "1111",
      name: "Plaid Saving",
      official_name: "Plaid Silver Standard 0.1% Interest Saving",
      subtype: "savings",
      type: "depository",
    },
    {
      account_id: "5dWBqMADRwhG9yxPXQ84CDJVNVjXwGfp7pPDn",
      balances: {
        available: null,
        current: 1000,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "2222",
      name: "Plaid CD",
      official_name: "Plaid Bronze Standard 0.2% Interest CD",
      subtype: "cd",
      type: "depository",
    },
    {
      account_id: "Jn3qoNjZ6GHJbwX91W3pfJo9M9Qwypu5g5rL4",
      balances: {
        available: null,
        current: 410,
        iso_currency_code: "USD",
        limit: 2000,
        unofficial_currency_code: null,
      },
      mask: "3333",
      name: "Plaid Credit Card",
      official_name: "Plaid Diamond 12.5% APR Interest Credit Card",
      subtype: "credit card",
      type: "credit",
    },
    {
      account_id: "knV6gQNdPeHan4zqLRXWCaKlyl36ZES8d8VbE",
      balances: {
        available: 43200,
        current: 43200,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "4444",
      name: "Plaid Money Market",
      official_name: "Plaid Platinum Standard 1.85% Interest Money Market",
      subtype: "money market",
      type: "depository",
    },
    {
      account_id: "lbwG8QPajXU1rnoKRyWjfd6VEVNGoMirdrXvQ",
      balances: {
        available: null,
        current: 320.76,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "5555",
      name: "Plaid IRA",
      official_name: null,
      subtype: "ira",
      type: "investment",
    },
    {
      account_id: "qKzGn1Z7MmhmpGkxjy9ECMd1N15Wk6iV7VDq3",
      balances: {
        available: null,
        current: 23631.9805,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "6666",
      name: "Plaid 401k",
      official_name: null,
      subtype: "401k",
      type: "investment",
    },
    {
      account_id: "KbxKgN7M6eUKwdJy7mxBFzbDMDEd9kCmAmBvj",
      balances: {
        available: null,
        current: 65262,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "7777",
      name: "Plaid Student Loan",
      official_name: null,
      subtype: "student",
      type: "loan",
    },
    {
      account_id: "rrBGbWMe1LUgJ5vdX1KxCM8EaEXGvziD6D5vW",
      balances: {
        available: null,
        current: 56302.06,
        iso_currency_code: "USD",
        limit: null,
        unofficial_currency_code: null,
      },
      mask: "8888",
      name: "Plaid Mortgage",
      official_name: null,
      subtype: "mortgage",
      type: "loan",
    },
  ],
];

export {
  getUserAccounts,
  getUserAccountById,
  getAccountsAsSelectOptions,
  saveUserAccounts,
};
