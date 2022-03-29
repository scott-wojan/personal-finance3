import React, { useEffect, useRef, useState } from "react";

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
} from "chart.js";

import { Line } from "react-chartjs-2";
import { faker } from "@faker-js/faker";
import { useMantineTheme } from "@mantine/core";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler
);

const labels = ["January", "February", "March", "April", "May", "June", "July"];

export function AccountLineChart() {
  const theme = useMantineTheme();
  const chartRef = useRef();

  const [chartData, setChartData] = useState({
    labels,
    datasets: [],
  });

  const options = {
    responsive: true,
    plugins: {
      legend: {
        display: false,
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
      labels,
      datasets: [
        {
          data: labels.map(() => faker.datatype.number({ min: 0, max: 1000 })),
          borderColor: positiveGradient,
          backgroundColor: positiveGradient,
          fillColor: positiveGradient,
          fill: "start",
        },
        {
          data: labels.map(() =>
            faker.datatype.number({ min: -25000, max: 1000 })
          ),
          borderColor: negativeGradient,
          backgroundColor: negativeGradient,
          fillColor: negativeGradient,
          fill: "start",
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
