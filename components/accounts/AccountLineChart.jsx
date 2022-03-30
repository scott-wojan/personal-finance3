import React, { useEffect, useRef, useState } from "react";
import "chartjs-adapter-moment";
import {
  Chart as ChartJS,
  Filler,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  TimeSeriesScale,
} from "chart.js";

import { Line } from "react-chartjs-2";
import { useMantineTheme } from "@mantine/core";
import { getFormattedCurrency, getFormattedDate } from "formatting";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
  TimeSeriesScale
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

export function AccountLineChart({ numberofMonths }) {
  const theme = useMantineTheme();
  const chartRef = useRef();

  const [chartData, setChartData] = useState({
    // labels,
    datasets: [],
  });

  const options = {
    //maintainAspectRatio: false,
    responsive: true,
    plugins: {
      legend: {
        display: false,
      },
      tooltip: {
        //https://www.chartjs.org/docs/latest/configuration/tooltip.html

        callbacks: {
          title: function (context) {
            return getFormattedDate(new Date(context[0].label));
          },
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

  useEffect(() => {
    const chart = chartRef.current;

    // @ts-ignore
    var positiveGradient = chart?.ctx.createLinearGradient(0, 0, 0, 100);
    positiveGradient.addColorStop(
      0,
      theme.fn.rgba(theme.colors[theme.primaryColor][5], 1)
    );
    positiveGradient.addColorStop(1, "rgba(64, 192, 87,0)");

    // @ts-ignore
    var negativeGradient = chart?.ctx.createLinearGradient(0, 0, 0, 100);
    negativeGradient.addColorStop(0, theme.fn.rgba(theme.colors.red[5], 1));
    negativeGradient.addColorStop(1, theme.fn.rgba(theme.colors.red[9], 0));

    const data = {
      labels: [new Date("01/01/2021"), new Date("06/01/2021")],
      datasets: [
        {
          //data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
          data: incomeData,
          borderColor: positiveGradient,
          backgroundColor: positiveGradient,
          fillColor: positiveGradient,
          fill: "start",
          lineTension: 0.4,
        },
        {
          //data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
          data: expenseData,
          borderColor: negativeGradient,
          backgroundColor: negativeGradient,
          fillColor: negativeGradient,
          fill: "start",
          lineTension: 0.4,
        },
      ],
    };

    setChartData(data);
  }, [theme.colors, theme.fn, theme.primaryColor]);

  return (
    <div>
      <Line
        ref={chartRef}
        height={30}
        // @ts-ignore
        options={options}
        data={chartData}
      />
    </div>
  );
}
