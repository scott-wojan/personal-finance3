import sql from "../db.js";

async function getUserIncomeAndExpense({ userId, startDate, endDate }) {
  // @ts-ignore
  return await sql`
  select type, TO_CHAR(month, 'fm00')||'/01/'||year as date, amount 
  from (
	  select 'income' as type, year, month,  sum(amount) as amount
	    from transactions t 
	   where user_id = ${userId}
		   and amount>0
	     and date between ${startDate} and ${endDate}	  
	    group by year, month
	    union all
	  select 'expense' as type, year, month,  sum(amount) as amount
	    from transactions t 
	   where user_id = ${userId}
		   and amount<0
	     and date between ${startDate} and ${endDate}	  
	   group by year, month
	  ) as x
  order by type, year, month
  `;
}

async function getUserIncomeAndExpenseForAccount({
  userId,
  startDate,
  endDate,
  accountId,
}) {
  // @ts-ignore
  return await sql`
  select type, TO_CHAR(month, 'fm00')||'/01/'||year as date, amount 
  from (
	  select 'income' as type, year, month,  sum(amount) as amount
	    from transactions t 
	   where user_id = ${userId}
		 	 and account_id=${accountId}		 
		   and amount>0
	     and date between ${startDate} and ${endDate}	  
	    group by year, month
	    union all
	  select 'expense' as type, year, month,  sum(amount) as amount
	    from transactions t 
	   where user_id = ${userId}
		 and account_id=${accountId}		 		 
		   and amount<0
	     and date between ${startDate} and ${endDate}	  
	   group by year, month
	  ) as x
  order by type, year, month
  `;
}

export { getUserIncomeAndExpense, getUserIncomeAndExpenseForAccount };
