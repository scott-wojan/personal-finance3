import { Application } from "components/app/Application";
import UserBudget from "components/budget/UserBudget";
import React from "react";

export default function Budget() {
  return (
    <Application>
      <UserBudget />
    </Application>
  );
}
