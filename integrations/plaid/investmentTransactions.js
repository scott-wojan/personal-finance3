import dayjs from "dayjs";
import client from "./client";

export async function getInvestmentTransactions(
  accessToken,
  startDate = dayjs().subtract(2, "month").format("YYYY-MM-DD"),
  endDate = dayjs().subtract(0, "days").format("YYYY-MM-DD")
) {
  const request = {
    access_token: accessToken,
    start_date: startDate,
    end_date: endDate,
  };

  const response = await client.investmentsTransactionsGet(request);
  return response.data;
}
