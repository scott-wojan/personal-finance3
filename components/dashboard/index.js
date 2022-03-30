import { Paper, Select, Title } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { BudgetBarChart } from "components/charts/BudgetBarChart";
import { NetWorthLineChart } from "components/charts/NetWorthLineChart";
import StackedBarChart from "components/charts/StackedBarChart";

import React, { useState } from "react";
import { Calendar } from "tabler-icons-react";
import { ResponsiveGrid } from "../grid/ResponsiveGrid";

export default function Dashboard({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return (
    <Application>
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

function RecentTransactionsCard() {
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Recent Transactions</Title>
        <ChartRangeDropDown value="3" />
      </div>
      {/* <BudgetBarChart /> */}
    </GridCard>
  );
}

function BudgetCard() {
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Budget</Title>
        <ChartRangeDropDown value="3" />
      </div>
      <BudgetBarChart />
    </GridCard>
  );
}

function IncomeAndExpensesCard() {
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Income vs Expenses</Title>

        <ChartRangeDropDown />
      </div>
      <StackedBarChart />
    </GridCard>
  );
}

function NetWorthCard() {
  const [numberofMonths, setNumberofMonths] = useState("12");
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Net Worth</Title>
        <ChartRangeDropDown onChange={setNumberofMonths} />
      </div>

      <NetWorthLineChart numberofMonths={numberofMonths} />
    </GridCard>
  );
}

function GridCard({ children }) {
  return (
    <Paper shadow="xs" pl="md" pr="md" style={{ flex: 1 }}>
      {children}
    </Paper>
  );
}

function ChartRangeDropDown({ value = "12", onChange = undefined }) {
  const [numberOfMonths, setNumberofMonths] = useState(value);
  const updateValue = (val) => {
    setNumberofMonths(val);
    onChange?.(val);
  };
  return (
    <Select
      style={{ width: 145, textAlign: "right" }}
      size="xs"
      variant="unstyled"
      onChange={updateValue}
      value={numberOfMonths}
      icon={<Calendar size={14} />}
      placeholder="Pick one"
      data={[
        { value: "3", label: "Last 3 months" },
        { value: "6", label: "Last 6 months" },
        { value: "12", label: "Last 12 months" },
        { value: "18", label: "Last 18 months" },
        { value: "24", label: "Last 24 months" },
      ]}
    />
  );
}