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

ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  Title,
  Tooltip,
  Legend
);

export const options = {
  indexAxis: "y",
  elements: {
    bar: {
      borderWidth: 2,
    },
  },
  responsive: true,
  plugins: {
    legend: {
      position: "right",
    },
    title: {
      display: false,
    },
  },
};

const labels = ["January", "February", "March", "April", "May", "June", "July"];

export function BudgetBarChart() {
  const theme = useMantineTheme();

  const data = {
    labels,
    datasets: [
      {
        label: "Spend",
        data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
        borderColor: theme.colors.red[3],
        backgroundColor: theme.colors.red[3],
      },
      {
        label: "Goal",
        data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
        borderColor: theme.colors.blue[3],
        backgroundColor: theme.colors.blue[3],
      },
    ],
  };

  return <Bar options={options} data={data} />;
}
