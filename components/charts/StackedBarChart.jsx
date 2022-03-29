import React from "react";
import { Bar } from "react-chartjs-2";
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from "chart.js";
import { useMantineTheme } from "@mantine/core";
import { getFormattedCurrency } from "formatting";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend
);

const dollarAmounts = {
  income: [
    { date: "01/01/2021", amount: 8824.29 },
    { date: "02/01/2021", amount: 8832.5 },
    { date: "03/01/2021", amount: 104536.16 },
    { date: "04/01/2021", amount: 8834.06 },
    { date: "05/01/2021", amount: 8930.09 },
    { date: "06/01/2021", amount: 8992.19 },
    { date: "07/01/2021", amount: 7430.29 },
    { date: "08/01/2021", amount: 23676.83 },
    { date: "09/01/2021", amount: 10749.14 },
    { date: "10/01/2021", amount: 15560.2 },
    { date: "11/01/2021", amount: 20999.72 },
    { date: "12/01/2021", amount: 14451.76 },
  ],
  expense: [
    { date: "01/01/2021", amount: -36907.89 },
    { date: "02/01/2021", amount: -17414.69 },
    { date: "03/01/2021", amount: -30716.21 },
    { date: "04/01/2021", amount: -105045.59 },
    { date: "05/01/2021", amount: -28717.66 },
    { date: "06/01/2021", amount: -13112.9 },
    { date: "07/01/2021", amount: -10205.87 },
    { date: "08/01/2021", amount: -15243.04 },
    { date: "09/01/2021", amount: -14982.26 },
    { date: "10/01/2021", amount: -12700.08 },
    { date: "11/01/2021", amount: -9840.73 },
    { date: "12/01/2021", amount: -18641.12 },
  ],
};

export const options = {
  responsive: true,
  plugins: {
    // title: {
    //   display: true,
    //   text: "Income vs. Expenses",
    // },
    legend: {
      position: "bottom",
    },
    tooltip: {
      //https://www.chartjs.org/docs/latest/configuration/tooltip.html
      callbacks: {
        label: function (context) {
          let label = context.dataset.label || "";
          if (label) {
            label += ": ";
          }
          if (context.parsed.y !== null) {
            label += getFormattedCurrency(context.parsed.y);
          }
          return label;
        },
      },
    },
  },

  scales: {
    xAxes: {
      stacked: true,
      type: "time",
      time: {
        unit: "month", //quarter, year
      },
    },
    yAxes: {
      stacked: true,
      ticks: {
        // Include a dollar sign in the ticks
        callback: function (value, index, ticks) {
          return getFormattedCurrency(value);
        },
      },
    },
  },
};

const incomeData = dollarAmounts.income.map((income) => {
  return {
    x: new Date(income.date),
    y: income.amount,
  };
});

const expenseData = dollarAmounts.expense.map((expense) => {
  return {
    x: new Date(expense.date),
    y: expense.amount,
  };
});

const netData = dollarAmounts.income.map((income, index) => {
  const expense = dollarAmounts.expense[index];
  return {
    x: new Date(income.date),
    y: income.amount + expense.amount,
  };
});

export default function StackedBarChart({ height = 50 }) {
  const theme = useMantineTheme();
  const data = {
    labels: [new Date("01/01/2021"), new Date("12/01/2021")],
    datasets: [
      {
        type: "line",
        label: "Net",
        borderColor: theme.colors.gray[6],
        backgroundColor: theme.colors.gray[6],
        borderWidth: 2,
        data: netData,
      },
      {
        label: "Income",
        data: incomeData,
        backgroundColor: theme.colors[theme.primaryColor][1],
      },
      {
        label: "Expenses",
        data: expenseData,
        backgroundColor: theme.colors.red[3],
      },
    ],
  };

  // @ts-ignore
  return <Bar height={height} options={options} data={data} />;
}
