import { Title } from "@mantine/core";
import { NetWorthLineChart } from "components/charts/NetWorthLineChart";
import React, { useState } from "react";
import { ChartRangeDropDown } from "./ChartRangeDropDown";
import { GridCard } from "./GridCard";

export function NetWorthCard() {
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
