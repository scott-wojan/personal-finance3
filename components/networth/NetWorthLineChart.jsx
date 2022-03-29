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
import moment from "moment";

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

function getFormattedCurrency(val) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(val);
}

function getFormattedDate(val) {
  return moment(val).format("MMM DD YYYY");
}

export function NetWorthLineChart({ numberofMonths }) {
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
            return "$" + value;
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

    const chartData = dollarAmounts.map((item) => {
      return {
        x: new Date(item.date),
        y: item.amount,
      };
    });

    const data = {
      labels: [new Date("01/01/2021"), new Date("06/01/2021")],
      datasets: [
        {
          //data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
          data: chartData,
          borderColor: positiveGradient,
          backgroundColor: positiveGradient,
          fillColor: positiveGradient,
          fill: "start",
          lineTension: 0.4,
        },
      ],
    };

    setChartData(data);
  }, [theme.colors, theme.fn, theme.primaryColor]);

  return (
    <div>
      <Line ref={chartRef} height={30} options={options} data={chartData} />
    </div>
  );
}

const dollarAmounts = [
  { date: "01/01/2021", amount: 200 },
  { date: "02/01/2021", amount: 300 },
  { date: "03/01/2021", amount: 400 },
  { date: "04/01/2021", amount: 200 },
  { date: "05/01/2021", amount: 600 },
  { date: "06/01/2021", amount: 800 },
];
