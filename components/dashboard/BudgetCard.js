import { Title } from "@mantine/core";
import { BudgetBarChart } from "components/charts/BudgetBarChart";
import React from "react";
import { ChartRangeDropDown } from "./ChartRangeDropDown";
import { GridCard } from "./GridCard";

export function BudgetCard() {
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
