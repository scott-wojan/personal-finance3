import React from "react";
import { Badge, Title, Text, useMantineTheme } from "@mantine/core";
import { AccountLineChart } from "../AccountLineChart";
import TransactionsGrid from "components/transactions/TransactionsGrid";
import { useApi } from "hooks/useApi";
import {
  formatCurrency,
  formatDate,
} from "components/datagrid/cellrenderers/formatting";

export default function Credit({ account }) {
  const theme = useMantineTheme();

  const { isLoading, error, data } = useApi({
    url: `accounts/credit/${account.id}`,
  });

  if (!data) return <></>;

  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Text weight={700}>{account.institution}</Text>

        <div>
          <Badge
            color="green"
            variant="outline"
            size="sm"
            style={{ textOverflow: "none", overflow: "initial" }}
          >
            11 hours ago
          </Badge>
        </div>
      </div>

      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <div>
          <Text weight={500} size="sm">
            {account.name} ...{account.mask}
          </Text>
        </div>

        <div>
          <Text size="sm" style={{ whiteSpace: "nowrap" }}>
            {account.subtype}
          </Text>
        </div>
      </div>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Text size="xs">{account.official_name}</Text>
      </div>

      <div>apr_percentage: {data.apr_percentage}</div>
      <div>apr_type: {data.apr_type}</div>
      <div>
        balance_subject_to_apr:
        {formatCurrency(data.balance_subject_to_apr, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        interest_charge_amount:
        {formatCurrency(data.interest_charge_amount, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>is_overdue: {data.is_overdue}</div>
      <div>
        last_payment_amount:
        {formatCurrency(data.last_payment_amount, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        last_payment_date:
        {formatDate(data.last_payment_date)}
      </div>
      <div>
        last_statement_issue_date:
        {formatDate(data.last_statement_issue_date)}
      </div>
      <div>
        last_statement_balance:
        {formatCurrency(data.last_statement_balance, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        minimum_payment_amount:
        {formatCurrency(data.minimum_payment_amount, {
          currencyCode: account.iso_currency_code,
        })}
      </div>
      <div>
        next_payment_due_date:
        {formatDate(data.next_payment_due_date)}
      </div>

      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <div style={{ width: "100%" }}>
          <div style={{ paddingBottom: theme.spacing.md }}>
            <AccountLineChart numberOfMonths={12} accountId={account.id} />
          </div>
          <div style={{ paddingRight: theme.spacing.md }}>
            <Title pb="sm" order={4}>
              Transactions
            </Title>
            <TransactionsGrid pageSize={7} accountId={account.id} />
          </div>
        </div>
      </div>

      <div style={{ paddingTop: 20 }}></div>
    </>
  );
}
