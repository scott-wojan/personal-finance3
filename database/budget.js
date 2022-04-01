import dayjs from "dayjs";
import sql from "./db.js";

// async function getUserBudget({ userId }) {
//   // @ts-ignore
//   return await sql`
//     select category_id, user_category, user_subcategory, min_budgeted_amount, max_budgeted_amount
//       from user_categories
//     where user_id = ${userId}
//     order by user_category, user_subcategory;
//   `;
// }

async function getUserBudget({
  userId,
  averagesRange = {
    year: dayjs().year() - 1,
    startMonth: 1,
    endMonth: dayjs().month(),
  },
}) {
  // @ts-ignore
  return await sql`
    select category_id, user_category, user_subcategory, min, avg, max, min_budgeted_amount,max_budgeted_amount
      from user_categories
      left outer join (
      select category, subcategory,(min*1) as min,(avg*1) as avg, (max*1) max
      from get_spending_metrics_by_category_subcategory(
        ${userId} ,
        ${averagesRange.year} ,
        ${averagesRange.startMonth} ,
        ${averagesRange.endMonth}
      )
    ) as spend on spend.category = user_category and spend.subcategory = user_subcategory
    where user_id=${userId}
  `;
}

export { getUserBudget };
