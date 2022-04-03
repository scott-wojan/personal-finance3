import { Title } from "@mantine/core";
import IncomeToExpensesChart from "components/charts/IncomeToExpensesChart";
import React, { useState } from "react";
import { ChartRangeDropDown } from "./ChartRangeDropDown";
import { GridCard } from "./GridCard";

export function IncomeAndExpensesCard() {
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
