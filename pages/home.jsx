import { Grid, Paper, Select, Text, Title } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { BudgetBarChart } from "components/charts/BudgetBarChart";
import { NetWorthLineChart } from "components/charts/NetWorthLineChart";
import StackedBarChart from "components/charts/StackedBarChart";

import { getUserFromCookie } from "cookies/user";
import React, { useState } from "react";
import { Calendar, Filter } from "tabler-icons-react";

export default function Home({ user }) {
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
        <Text>Recent Transactions</Text>
      </ResponsiveGrid>
    </Application>
  );
}

function BudgetCard() {
  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Budget</Title>

        <ChartRangeDropDown />
      </div>
      <BudgetBarChart />
    </>
  );
}

function IncomeAndExpensesCard() {
  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Income vs Expenses</Title>

        <ChartRangeDropDown />
      </div>
      <StackedBarChart />
    </>
  );
}

function NetWorthCard() {
  const [numberofMonths, setNumberofMonths] = useState("12");
  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Net Worth</Title>
        <ChartRangeDropDown onChange={setNumberofMonths} />
      </div>

      <NetWorthLineChart numberofMonths={numberofMonths} />
    </>
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

function ResponsiveGrid({ columns = undefined, children }) {
  if (!children) return null;
  const childComponents = Array.isArray(children) ? children : [children];
  const numberOfChildren = React.Children.count(children) ?? 0;
  const largeCloumnSize = columns ? 12 / columns : 12 / numberOfChildren ?? 1;

  return (
    <Grid>
      {childComponents.map((child, index) => {
        return (
          <Grid.Col key={index} md={12} lg={largeCloumnSize}>
            <Paper shadow="xs" p="md" style={{ flex: 1 }}>
              {child}
            </Paper>
          </Grid.Col>
        );
      })}
    </Grid>
  );
}

export async function getServerSideProps(context) {
  const user = getUserFromCookie(context.req, context.res);
  return {
    props: { user },
  };
}
