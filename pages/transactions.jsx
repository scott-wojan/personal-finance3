import { Button, Group, Title } from "@mantine/core";
import { Application } from "components/app/Application";
import TransactionsGrid from "components/transactions/TransactionsGrid";
import React from "react";
import { Bolt } from "tabler-icons-react";

export default function transactions() {
  return (
    <Application
      sidebar={
        <>
          Stats?
          <br />
          Behavioral Reinforcement?
          <br />
          ads?
        </>
      }
    >
      <Group position="apart" pb="md">
        <Title order={3}>Transactions</Title>
        <Button size="xs" leftIcon={<Bolt size={16} />}>
          Manage Rules
        </Button>
      </Group>
      <div>
        <TransactionsGrid pageSize={12} />
      </div>
    </Application>
  );
}
