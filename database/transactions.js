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
  const offset = page === 1 ? 0 : (page - 1) * pageSize;

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
                OFFSET ${offset}
                 LIMIT ${pageSize}
             ) AS t
        ) AS data;
  `;

  // console.log("query", query);

  // @ts-ignore
  const rows = await sql.unsafe(query);
  // console.log(rows.statement, rows);
  return rows[0];
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
