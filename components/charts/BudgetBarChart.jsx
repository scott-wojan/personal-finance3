import React from "react";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { Bar } from "react-chartjs-2";
import faker from "@faker-js/faker";
import { useMantineTheme } from "@mantine/core";
import { getFormattedCurrency } from "formatting";

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const dollarAmounts = {
  budget: [
    // { date: "01/01/2021", amount: 8824.29 },
    // { date: "02/01/2021", amount: 8832.5 },
    // { date: "03/01/2021", amount: 10536.16 },
    // { date: "04/01/2021", amount: 8834.06 },
    // { date: "05/01/2021", amount: 8930.09 },
    // { date: "06/01/2021", amount: 8992.19 },
    { date: "07/01/2021", amount: 10000.0 },
    { date: "08/01/2021", amount: 10000 },
    { date: "09/01/2021", amount: 10000 },
    { date: "10/01/2021", amount: 10000 },
    { date: "11/01/2021", amount: 10000 },
    { date: "12/01/2021", amount: 10000 },
  ],
  spend: [
    // { date: "01/01/2021", amount: 8724.29 },
    // { date: "02/01/2021", amount: 8832.5 },
    // { date: "03/01/2021", amount: 14536.16 },
    // { date: "04/01/2021", amount: 7834.06 },
    // { date: "05/01/2021", amount: 8430.09 },
    // { date: "06/01/2021", amount: 8892.19 },
    { date: "07/01/2021", amount: 11000 },
    { date: "08/01/2021", amount: 9500 },
    { date: "09/01/2021", amount: 10000 },
    { date: "10/01/2021", amount: 12500 },
    { date: "11/01/2021", amount: 8000 },
    { date: "12/01/2021", amount: 9800 },
  ],
};

export const options = {
  elements: {
    bar: {
      borderWidth: 2,
    },
  },
  responsive: true,
  plugins: {
    legend: {
      position: "bottom",
    },
    title: {
      display: false,
    },
  },
  scales: {
    xAxes: {
      type: "time",
      time: {
        unit: "month", //quarter, year
      },
    },
    yAxes: {
      ticks: {
        // Include a dollar sign in the ticks
        callback: function (value, index, ticks) {
          return getFormattedCurrency(value);
        },
      },
    },
  },
};

// const labels = ["January", "February", "March", "April", "May", "June", "July"];

export function BudgetBarChart() {
  const theme = useMantineTheme();

  const budgetData = dollarAmounts.budget.map((budget) => {
    return {
      x: new Date(budget.date),
      y: budget.amount,
    };
  });

  const spendData = dollarAmounts.spend.map((spend) => {
    return {
      x: new Date(spend.date),
      y: spend.amount,
    };
  });

  const data = {
    labels: [new Date("07/01/2021"), new Date("12/01/2021")],
    datasets: [
      {
        label: "Goal",
        data: budgetData,
        borderColor: theme.colors.blue[3],
        backgroundColor: theme.colors.blue[3],
      },
      {
        label: "Spend",
        data: spendData,
        borderColor: theme.colors.red[3],
        backgroundColor: theme.colors.red[3],
      },
    ],
  };

  return <Bar options={options} data={data} />;
}
