import React from "react";
import {
  createStyles,
  Group,
  Paper,
  Text,
  ThemeIcon,
  useMantineTheme,
} from "@mantine/core";
import { ArrowUpRight, ArrowDownRight } from "tabler-icons-react";
import { GridCard } from "components/grid/GridCard/GridCard";

const useStyles = createStyles((theme) => ({
  root: {
    padding: theme.spacing.xl * 1.5,
  },

  label: {},
}));

export function AccountStats({ data }) {
  const theme = useMantineTheme();
  const { classes } = useStyles();

  data = data ?? [
    {
      title: "Income",
      value: "$13,456.00",
      diff: 34,
    },
    {
      title: "Expenses",
      value: "$4,145.00",
      diff: -13,
    },
    {
      title: "Net Income",
      value: "$745.00",
      diff: 18,
    },
  ];

  const stats = data.map((stat) => {
    const DiffIcon = stat.diff > 0 ? ArrowUpRight : ArrowDownRight;
    const primaryGreen = theme.colors[theme.primaryColor][6];
    return (
      <GridCard key={stat.title}>
        <Group position="apart">
          <div>
            <Text
              color="dimmed"
              transform="uppercase"
              weight={700}
              size="xs"
              className={classes.label}
            >
              {stat.title}
            </Text>
            <Text weight={700} size="xl">
              {stat.value}
            </Text>
          </div>
          <ThemeIcon
            color="gray"
            variant="light"
            sx={(theme) => ({
              color: stat.diff > 0 ? primaryGreen : theme.colors.red[6],
            })}
            size={38}
            radius="md"
          >
            <DiffIcon size={28} />
          </ThemeIcon>
        </Group>
        <Text color="dimmed" size="sm" mt="md">
          <Text
            component="span"
            color={stat.diff > 0 ? primaryGreen : "red"}
            weight={700}
          >
            {stat.diff}%
          </Text>{" "}
          {stat.diff > 0 ? "increase" : "decrease"} compared to last month
        </Text>
      </GridCard>
    );
  });

  return (
    <Group direction="column" spacing="xl" grow>
      {stats}
    </Group>
  );
}
