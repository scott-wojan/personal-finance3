import { Application } from "components/app/Application";
import { UserBudget } from "components/budget/UserBudget";
import React from "react";

export default function Budget() {
  return (
    <Application>
      {/* <ResponsiveGrid columns={4}>
        <div>SubCategory</div>
        <GridCard>Min</GridCard>
        <GridCard>Avg</GridCard>
        <GridCard>Max</GridCard>
      </ResponsiveGrid> */}

      <UserBudget />
    </Application>
  );
}
