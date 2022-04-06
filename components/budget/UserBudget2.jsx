import { RangeSlider, Button, Table, Text, Tooltip } from "@mantine/core";
import { getFormattedCurrency, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import React, { Fragment, useState } from "react";

export function UserBudget2() {
  const { isLoading, error, data } = useApi({
    url: "budget",
    payload: {
      startDate: "04/01/2021",
      endDate: "04/01/2022",
    },
  });

  return (
    <>
      {data && (
        <Table
          style={{ width: "auto" }}
          sx={(theme) => ({
            td: {
              verticalAlign: "top",
            },
            "thead tr th": {
              // backgroundColor: "red",
            },
            "tbody td:nth-of-type(n+2)": {
              textAlign: "center",
            },
            ".stat": { display: "flex", justifyContent: "space-between" },
            ".category": {
              // fontWeight: 500,
            },
            ".subcategory": {
              paddingLeft: 20,
            },
          })}
        >
          <thead>
            <tr>
              <th>Category</th>
              <th style={{ width: 250, textAlign: "center" }}>Budget</th>
              <th style={{ textAlign: "center" }}>Min</th>
              <th style={{ textAlign: "center" }}>Max</th>
              <th style={{ textAlign: "center" }}>Options</th>
            </tr>
          </thead>
          <tbody>
            {data &&
              Object.entries(groupBy(data, "user_category")).map(
                ([key, value]) => {
                  return (
                    <Fragment key={key}>
                      <tr>
                        <td className="category">{key}</td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                      </tr>
                      {value.map((subcategory) => {
                        return (
                          <BudgetRow
                            key={subcategory.user_subcategory}
                            subcategory={subcategory}
                            // onChange={onBudgetSelected}
                          />
                        );
                      })}
                    </Fragment>
                  );
                }
              )}
          </tbody>
        </Table>
      )}
    </>
  );
}

function BudgetRow({ subcategory, onChange }) {
  console.log(subcategory);
  const [minValue, setMinValue] = useState(subcategory.min_budgeted_amount);
  const [maxValue, setMaxValue] = useState(subcategory.max_budgeted_amount);
  const onRangeSelection = ([min, max]) => {
    setMinValue(min * -1);
    setMaxValue(max * -1);
    onChange?.({ categoryId: subcategory.user_category_id, min, max });
  };

  const Stat = ({ value }) => {
    return (
      <Text size="xs" color="gray">
        {getFormattedCurrency(value)}
      </Text>
    );
  };
  return (
    <tr>
      <td className="subcategory">{subcategory.user_subcategory}</td>
      <td>
        <RangeSlider
          onChange={onRangeSelection}
          defaultValue={[minValue * -1, maxValue * -1]}
          min={0}
          max={subcategory.max_monthly_spend * -1 * 1.2}
        />
        <div className="stat">
          <Stat value={subcategory.min_monthly_spend} />
          <Stat value={subcategory.avg_monthly_spend * -1} />
          <Stat value={subcategory.max_monthly_spend * -1} />
        </div>
      </td>
      <td>{getFormattedCurrency(minValue * -1)}</td>
      <td>{getFormattedCurrency(maxValue * -1)}</td>
      <td>
        <Tooltip label="Do not budget for this category" withArrow>
          <Button variant="default" size="xs">
            No budget
          </Button>
        </Tooltip>
      </td>
    </tr>
  );
}
