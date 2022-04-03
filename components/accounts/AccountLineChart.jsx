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
import { getFormattedCurrency, getFormattedDate, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import dayjs from "dayjs";
import NoResults from "components/noresults";

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

export function AccountLineChart({ accountId, numberOfMonths }) {
  const theme = useMantineTheme();
  const chartRef = useRef();
  const [showNoData, setShowNoData] = useState(false);
  const startDate = dayjs()
    .subtract(numberOfMonths, "months")
    .format("YYYY-MM-DD");
  const endDate = dayjs()
    .subtract(1, "months")
    .endOf("month")
    .format("YYYY-MM-DD");

  const [chartData, setChartData] = useState({
    // labels,
    datasets: [],
  });

  const {
    isLoading,
    error,
    data: apiData,
  } = useApi({
    url: "charts/incomeexpense",
    payload: {
      startDate,
      endDate,
      accountId,
    },
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
    if (!apiData) return;
    if (apiData.length === 0) {
      setShowNoData(true);
      return;
    }
    const groupedApiData = groupBy(apiData, "type");

    const incomeData = groupedApiData.income.map((income) => {
      return {
        x: new Date(income.date),
        y: income.amount,
      };
    });

    const expenseData = groupedApiData.expense.map((expense) => {
      return {
        x: new Date(expense.date),
        y: expense.amount,
      };
    });

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
      labels: [new Date(startDate), new Date(endDate)],
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
  }, [apiData, endDate, startDate, theme.colors, theme.fn, theme.primaryColor]);

  return (
    <>
      {!showNoData && chartData && (
        <Line
          ref={chartRef}
          height={30}
          // @ts-ignore
          options={options}
          data={chartData}
        />
      )}
      {showNoData && <NoResults />}
    </>
  );
}
