import client from "./client";

export async function getTransactions(accessToken, startDate, endDate) {
  let request;

  request = {
    start_date: new Date(startDate).toISOString().substring(0, 10),
    end_date: new Date(endDate).toISOString().substring(0, 10),
    access_token: accessToken,
  };

  try {
    const response = await client.transactionsGet(request);
    let transactions = response.data.transactions;

    const total_transactions = response.data.total_transactions;
    let resultData = {
      transactions: response.data.transactions,
      accounts: response.data.accounts,
    };

    while (transactions.length < total_transactions) {
      const paginatedRequest = {
        access_token: request.access_token,
        start_date: request.start_date,
        end_date: request.end_date,
        options: {
          offset: transactions.length,
        },
      };
      const paginatedResponse = await client.transactionsGet(paginatedRequest);

      resultData = {
        transactions: [
          ...resultData.transactions,
          ...paginatedResponse.data.transactions,
        ],
        accounts: response.data.accounts,
      };

      transactions = transactions.concat(paginatedResponse.data.transactions);
    }
    resultData.request_id = response.data.request_id;
    return resultData;
  } catch (error) {
    return error.response.data;
  }
}
