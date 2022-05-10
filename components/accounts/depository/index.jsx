import React from "react";
import { Badge, Title, Text, useMantineTheme } from "@mantine/core";
import { AccountLineChart } from "../AccountLineChart";
import TransactionsGrid from "components/transactions/TransactionsGrid";

export default function Depository({ account }) {
  const theme = useMantineTheme();
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
