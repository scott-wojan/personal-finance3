import { Paper, Select, Table, Title } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { BudgetBarChart } from "components/charts/BudgetBarChart";
import { NetWorthLineChart } from "components/charts/NetWorthLineChart";
import IncomeToExpensesChart from "components/charts/IncomeToExpensesChart";
import { usePagingAndFilteringApi } from "hooks/usePagingAndFilteringApi";

import React, { useEffect, useState } from "react";
import { Calendar } from "tabler-icons-react";
import { ResponsiveGrid } from "../grid/ResponsiveGrid";

export default function Dashboard({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return (
    <Application sidebar={<>TBD</>}>
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
      </div>
      <RecentTransactions />
    </GridCard>
  );
}

function RecentTransactions() {
  const [tableData, setTableDate] = useState([]);

  const { isLoading, error, data } = usePagingAndFilteringApi({
    url: "transactions",
    payload: { pageSize: 6 },
  });

  useEffect(() => {
    setTableDate(
      data?.data?.map((transaction) => (
        <tr key={transaction.id}>
          <td>{transaction.date}</td>
          <td>{transaction.name}</td>
          <td>{transaction.amount}</td>
        </tr>
      ))
    );
  }, [data]);

  return (
    <>
      {isLoading && <>Loading...</>}
      {error && <>Error!! {error?.message}</>}
      {data && (
        <Table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Name</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>{tableData}</tbody>
        </Table>
      )}
    </>
  );
}

function BudgetCard() {
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Budget*</Title>
        <ChartRangeDropDown value="3" />
      </div>
      <BudgetBarChart />
    </GridCard>
  );
}

function IncomeAndExpensesCard() {
  const [numberOfMonths, setNumberOfMonths] = useState("12");
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Income vs Expenses</Title>

        <ChartRangeDropDown onChange={setNumberOfMonths} />
      </div>
      <IncomeToExpensesChart numberOfMonths={numberOfMonths} />
    </GridCard>
  );
}

function NetWorthCard() {
  const [numberOfMonths, setNumberOfMonths] = useState("12");
  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Net Worth*</Title>
        <ChartRangeDropDown onChange={setNumberOfMonths} />
      </div>

      <NetWorthLineChart numberOfMonths={numberOfMonths} />
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
