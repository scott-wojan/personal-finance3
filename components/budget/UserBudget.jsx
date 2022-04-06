import {
  Button,
  createStyles,
  RangeSlider,
  Title,
  Tooltip,
} from "@mantine/core";
import { getFormattedCurrency, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import React, { Fragment, useEffect, useState } from "react";

export default function UserBudget() {
  // @ts-ignore
  const useStyles = createStyles((theme) => ({
    table: {
      // tableLayout: "fixed",
      fontSize: 14,
      borderCollapse: "collapse",
      tr: {
        borderBottom: "1px solid #ddd",
      },
      "thead th": {
        textAlign: "center !important",
      },

      "tbody td": {
        minWidth: 80,
      },

      "thead tr:nth-of-type(1)": {
        borderBottom: 0,
      },
      "table, th, td": {
        // borderLeft: "1px solid",
        // borderRight: "1px solid",
      },
      td: {
        // paddingTop: "12px !important",
        // paddingBottom: "2px !important",
        // borderBottom: "0 !important",
      },
      "tbody td:nth-of-type(n+2)": {
        textAlign: "center",
      },
      "tbody tr td:nth-of-type(2)": {
        minWidth: 500,
      },
      th: {
        fontWeight: "400 !important",
      },
      "th.main": {
        // fontWeight: "700 !important",
        textAlign: "left !important",
      },
    },
    category: {
      fontWeight: 600,
    },
  }));

  const { classes, cx } = useStyles();

  const { isLoading, error, data } = useApi({
    url: "budget",
    payload: {
      startDate: "04/01/2021",
      endDate: "04/01/2022",
    },
  });

  useEffect(() => {
    console.log("data", data);
    if (data) {
      console.log(groupBy(data, "user_category"));
    }
  }, [data]);

  if (error) {
    // @ts-ignore
    return <div>ERROR... {error.message}</div>;
  }

  const onBudgetSelected = ({ categoryId, min, max }) => {
    console.log(
      `Update user's budget for categoryId: ${categoryId} with min: ${min} and maxL ${max}`
    );
  };

  return (
    <>
      <Title order={3} pb="sm">
        Budget
      </Title>

      <table className={cx(classes.table)}>
        <thead>
          <tr>
            <th className="main">Category</th>
            <th>Budget Range Selection</th>
            <th>Minimum</th>
            <th>Max</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {data &&
            Object.entries(groupBy(data, "user_category")).map(
              ([key, value]) => {
                return (
                  <Fragment key={key}>
                    <tr>
                      <td className={cx(classes.category)}>{key}</td>
                      <td></td>
                      <td></td>
                      <td></td>
                    </tr>
                    {value.map((subcategory) => {
                      return (
                        <BudgetRow
                          key={subcategory.user_subcategory}
                          subcategory={subcategory}
                          onChange={onBudgetSelected}
                        />
                      );
                    })}
                  </Fragment>
                );
              }
            )}
        </tbody>
      </table>
    </>
  );
}

function BudgetRow({ subcategory, onChange }) {
  const [minValue, setMinValue] = useState(subcategory.min_budgeted_amount);
  const [maxValue, setMaxValue] = useState(subcategory.max_budgeted_amount);
  const [tooltipOpen, setTooltipOpen] = useState(false);
  //console.log("subcategory", subcategory);
  const useStyles = createStyles((theme) => ({
    subcategory: {
      "td:first-of-type": {
        paddingLeft: `${theme.spacing.lg}px !important`,
      },
      td: {
        paddingBottom: `16px !important`,
      },
    },
  }));
  const { classes, cx } = useStyles();

  const onRangeSelection = ([min, max]) => {
    console.log(min, max);
    setMinValue(min);
    setMaxValue(max);
    onChange?.({ categoryId: subcategory.user_category_id, min, max });
  };
  return (
    <tr className={cx(classes.subcategory)}>
      <td>{subcategory.user_subcategory}</td>

      <td className="center">
        {/* <BudgetRangeSlider2 onChange={onRangeSelection} /> */}
        <BudgetRangeSlider
          min={0}
          max={subcategory.max_monthly_spend * 1.2}
          onChange={onRangeSelection}
          marks={[
            {
              value: subcategory.min_monthly_spend * -1,
              label: `Min ${getFormattedCurrency(
                subcategory.min_monthly_spend
              )}`,
            },
            {
              value: subcategory.max_monthly_spend * -1 * 0.5,
              label: `Avg ${getFormattedCurrency(
                subcategory.avg_monthly_spend
              )}`,
            },
            {
              value: subcategory.max_monthly_spend * -1,
              label: `Max ${getFormattedCurrency(
                subcategory.max_monthly_spend
              )}`,
            },
          ]}
        />
      </td>

      <td className="center">{getFormattedCurrency(minValue)}</td>
      <td className="center">{getFormattedCurrency(maxValue)}</td>
      <td>
        <Tooltip
          label="Do not budget for this category"
          opened={tooltipOpen}
          withArrow
        >
          <Button
            variant="default"
            size="xs"
            onMouseOver={() => setTooltipOpen(true)}
            onMouseOut={() => {
              setTooltipOpen(false);
            }}
          >
            No budget
          </Button>
        </Tooltip>
      </td>
    </tr>
  );
}

function BudgetRangeSlider({ marks, onChange, min = 0, max = 100 }) {
  const [showMarks, setShowMarks] = useState(true);

  // @ts-ignore
  const useStyles = createStyles((theme) => ({
    slider: {
      " .mantine-Slider-markWrapper": {
        whiteSpace: "nowrap",
      },
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <div
      onFocus={(e) => {
        //setShowMarks(true);
      }}
      onBlur={(e) => {
        //setShowMarks(false);
      }}
    >
      <RangeSlider
        className={cx(classes.slider)}
        labelAlwaysOn={false}
        precision={0}
        minRange={0}
        // size="xs"
        label={(val) => `$${val}`}
        showLabelOnHover={true}
        onChangeEnd={onChange}
        min={min * -1}
        max={max * -1}
        step={1}
        defaultValue={[0, 0]}
        marks={showMarks ? marks : []}
        styles={(theme) => ({
          markLabel: {
            // fontSize: theme.fontSizes.xs,
            // marginBottom: 5,
            marginTop: 0,
          },
        })}
      />
    </div>
  );
}
