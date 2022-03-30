import { Title } from "@mantine/core";
import { Application } from "components/app/Application";
import TransactionsGrid from "components/transactions/TransactionsGrid";
import React from "react";

export default function transactions() {
  return (
    <Application>
      <Title order={3} pb="sm">
        Transactions
      </Title>
      <TransactionsGrid />
    </Application>
  );
}
