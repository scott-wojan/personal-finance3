import React, { useEffect, useState } from "react";
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
import { getFormattedCurrency, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import dayjs from "dayjs";

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

export default function IncomeToExpensesChart({
  height = 50,
  startDate = dayjs().subtract(12, "months").format("YYYY-MM-DD"),
  endDate = dayjs().subtract(0, "days").format("YYYY-MM-DD"),
}) {
  const theme = useMantineTheme();
  const [chartDatas, setChartDatas] = useState();
  console.log(dayjs());
  const {
    isLoading,
    error,
    data: apiData,
  } = useApi({
    url: "charts/incomeexpense",
    payload: {
      startDate,
      endDate,
    },
  });

  useEffect(() => {
    if (!apiData) return;
    console.log("data", apiData);
    const poop = groupBy(apiData, "type");
    // const chartDatas = groupBy(apiData, "type");
    // console.log("chartDatas", chartDatas);
    const incomeData = poop.income.map((income) => {
      return {
        x: new Date(income.date),
        y: parseFloat(income.amount),
      };
    });

    const expenseData = poop.expense.map((expense) => {
      return {
        x: new Date(expense.date),
        y: parseFloat(expense.amount),
      };
    });

    const netData = poop.income.map((income, index) => {
      const expense = poop.expense.find((ex) => {
        return ex.date === income.date;
      }) ?? { amount: 0 };
      return {
        x: new Date(income.date),
        y: parseFloat(income.amount) + parseFloat(expense.amount),
      };
    });

    const chartData = {
      labels: [new Date(startDate), new Date(endDate)],
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
    setChartDatas(chartData);
  }, [apiData, theme.colors, theme.primaryColor]);

  const options = {
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

  // @ts-ignore
  return (
    <>
      {chartDatas && (
        <Bar height={height} options={options} data={chartDatas} />
      )}
    </>
  );
}
