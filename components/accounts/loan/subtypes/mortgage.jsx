import {
  formatCurrency,
  formatDate,
} from "components/datagrid/cellrenderers/formatting";
import { useApi } from "hooks/useApi";
import React from "react";
// https://plaid.com/docs/api/products/liabilities/#liabilities-get-response-liabilities-mortgage
export default function Mortgage({ account }) {
  const { isLoading, error, data } = useApi({
    url: `accounts/mortgage/${account.id}`,
  });

  if (!data) return <></>;
  console.log(account);

  return (
    <>
      <div>
        Address: {data.street} {data.city}, {data.region} {data.postal_code}
      </div>

      <div>account_number: {data.account_number}</div>
      <div>origination_date: {formatDate(data.origination_date)}</div>
      <div>
        origination_principal_amount:
        {formatCurrency(data.origination_principal_amount, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>loan_term: {data.loan_term}</div>
      <div>maturity_date: {formatDate(data.maturity_date)}</div>

      <div>
        current_late_fee:
        {formatCurrency(data.current_late_fee, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        escrow_balance:
        {formatCurrency(data.escrow_balance, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>has_pmi: {data.has_pmi}</div>
      <div>has_prepayment_penalty: {data.has_prepayment_penalty}</div>
      <div>interest_rate_percentage: {data.interest_rate_percentage}%</div>
      <div>interest_rate_type: {data.interest_rate_type}</div>
      <div>
        last_payment_amount:
        {formatCurrency(data.last_payment_amount, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>last_payment_date: {formatDate(data.last_payment_date)}</div>
      <div>loan_type_description: {data.loan_type_description}</div>

      <div>
        next_monthly_payment:
        {formatCurrency(data.next_monthly_payment, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>next_payment_due_date: {formatDate(data.next_payment_due_date)}</div>

      <div>past_due_amount: {data.past_due_amount}</div>

      {/* <div>country: {data.country}</div> */}

      <div>
        ytd_interest_paid:
        {formatCurrency(data.ytd_interest_paid, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        ytd_principal_paid:
        {formatCurrency(data.ytd_principal_paid, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
    </>
  );
}
