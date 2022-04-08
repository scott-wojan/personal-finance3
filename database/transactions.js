import sql from "./db.js";
import { toJsonEscaped, toOrderBy, toWhere } from "./helpers.js";

export async function getUserTransactions({
  userId,
  page = 1,
  pageSize = 10,
  sort = undefined,
  filter = undefined,
  accountId = undefined,
}) {
  // const filterExample = [{ name: "account", value: "Capital One Venture One" }];
  // const sortExample = [{ name: "amount", direction: "asc" }];

  let where = toWhere(filter) ?? "";
  if (accountId) {
    where = where + ` and account_id='${accountId}' `;
  }
  const orderBy = toOrderBy(sort) ?? "date desc";

  const query = `
  SELECT(  SELECT COUNT(*) FROM user_transactions WHERE user_id = '${userId}' ${where}) as count,
          (SELECT json_agg(t.*)
            FROM (
                SELECT id, account, date, name, amount, category, subcategory, iso_currency_code, is_pending
                  FROM user_transactions WHERE user_id = '${userId}' ${where}
                 ORDER BY ${orderBy}
                OFFSET ${page} - 1 --use 1 based indexing to match UI
                 LIMIT ${pageSize}
             ) AS t
        ) AS data;
  `;

  // @ts-ignore
  const rows = await sql.unsafe(query);
  // console.log(rows.statement, rows);
  return rows[0];
}

export async function saveUserTransactions({
  userId,
  requestId,
  transactions,
}) {
  const json = toJsonEscaped(transactions);
  const query = `select * from insert_plaid_transactions(${userId},'${requestId}','${json}')`;
  await sql.unsafe(query);
}

export async function deleteTransactions({ transactionIds }) {
  const list = transactionIds.map((transationId, index) => {
    return ` ${index !== 0 ? "," : ""} '${transationId}'`;
  });
  const query = `delete from transactions where  id in (${list})`;
  await sql.unsafe(query);
}

export async function getUserTransactionDetails({ userId, transactionId }) {
  // @ts-ignore
  const rows = await sql`
     select imported_category, 
            imported_subcategory, 
            imported_name, 
            merchant_name, 
            check_number, 
            authorized_date, 
            address, 
            city, 
            region, 
            postal_code, 
            country, 
            store_number, 
            payment_channel,
            created_at, 
            updated_at
      from transactions
     where user_id = ${userId}
       and id = ${transactionId};
  ;`;
  return rows[0];
}

export async function updateUserTransaction({
  userId,
  id,
  name,
  category,
  subcategory,
}) {
  // @ts-ignore
  await sql`
    update transactions
    set name = ${name},
        category=${category},
        subcategory=${subcategory}
  where user_id = ${userId}
    and id = ${id};
  ;`;
}

/*
async function saveTransactions(userId, transactions) {
  let category, categorySub, categoryDetail;

  if (transaction.category?.length > 0) {
    category = transaction.category[0];
  }
  if (transaction.category?.length > 1) {
    categorySub = transaction.category[1];
  }
  // @ts-ignore
  await sql`
  INSERT INTO transactions
  (
    id,	
    account_id,
    amount,
    iso_currency_code,
    check_number,
    date,
    authorized_date,
    address,
    city,
    region,
    postal_code,
    country,
    lat,
    lon,
    store_number,
    name,
    merchant_name,
    payment_channel,
    is_pending,
    type,
    category,
    subcategory,
    transaction_code,
    user_id
  )
VALUES
  ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24)
ON CONFLICT
  (id)
DO UPDATE SET
  account_id = $2,
  amount = $3,
  iso_currency_code = $4,
  check_number = $5,
  date = $6,
  authorized_date = $7,
  address = $8,
  city = $9,
  region = $10,
  postal_code = $11,
  country = $12,
  lat = $13,
  lon = $14,
  store_number = $15,
  name = $16,
  merchant_name = $17,
  payment_channel = $18,
  is_pending = $19,
  type = $20,
  category = $21,
  subcategory = $22,
  transaction_code = $23
  `;
  return;
}
*/
