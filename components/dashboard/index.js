import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";

import React from "react";
import { ResponsiveGrid } from "../grid/ResponsiveGrid";
import { BudgetCard } from "./BudgetCard";
import { IncomeAndExpensesCard } from "./IncomeAndExpensesCard";
import { NetWorthCard } from "./NetWorthCard";
import { RecentTransactionsCard } from "./RecentTransactionsCard";

export default function Dashboard({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
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
      <ResponsiveGrid columns={1}>
        <NetWorthCard />
        <IncomeAndExpensesCard />
      </ResponsiveGrid>
      <ResponsiveGrid columns={2}>
        <BudgetCard />
        <RecentTransactionsCard />
      </ResponsiveGrid>
    </Application>
  );
}
