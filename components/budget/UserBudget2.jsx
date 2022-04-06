import {
  RangeSlider,
  Button,
  Table,
  Text,
  Tooltip,
  NumberInput,
} from "@mantine/core";
import axios from "axios";
import { getFormattedCurrency, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import numeral from "numeral";
import React, { Fragment, useEffect, useState } from "react";
import { useMutation } from "react-query";
import { AlertCircle } from "tabler-icons-react";

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
            "thead tr th:not(:first-of-type)": {
              textAlign: "center",
            },
            "tbody td:not(:first-of-type)": {
              textAlign: "center",
            },
            "tbody td:last-of-type": {
              verticalAlign: "middle",
            },
            ".stat": { display: "flex", justifyContent: "space-between" },
            ".category": {
              fontWeight: 500,
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
              <th>Min</th>
              <th>Max</th>
              <th>Options</th>
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
                        <td className="category">{key}</td>
                        <td></td>
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

function BudgetRow({ subcategory }) {
  const mutation = useMutation((updatedBudgetItem) => {
    return axios.post("/todos", updatedBudgetItem);
  });

  const onBudgetSelected = ({ user_category_id, min, max }) => {
    // @ts-ignore
    mutation.mutate({
      user_category_id,
      min,
      max,
    });
    console.log(`Send update for user budget ${user_category_id} `, min, max);
  };

  const [minBudgetedAmount, setMinBudgetedAmount] = useState(
    subcategory.min_budgeted_amount * -1
  );
  const [maxBudgetedAmount, setMaxBudgetedAmount] = useState(
    subcategory.max_budgeted_amount * -1
  );
  // console.log(minBudgetedAmount, maxBudgetedAmount);
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
        <BudgetRangeSlider
          value={[minBudgetedAmount, maxBudgetedAmount]}
          maxValue={subcategory.max_monthly_spend * -1 * 1.2}
          onChange={([min, max]) => {
            setMinBudgetedAmount(min);
            setMaxBudgetedAmount(max);
            onBudgetSelected({
              user_category_id: subcategory.user_category_id,
              min,
              max,
            });
          }}
        />
        <div className="stat">
          <Stat value={subcategory.min_monthly_spend} />
          <Stat value={subcategory.avg_monthly_spend * -1} />
          <Stat value={subcategory.max_monthly_spend * -1} />
        </div>
      </td>
      <td>
        <MonetaryInput
          value={minBudgetedAmount}
          onChange={setMinBudgetedAmount}
        />
      </td>
      <td>
        <MonetaryInput
          value={maxBudgetedAmount}
          onChange={setMaxBudgetedAmount}
        />
      </td>
      <td>
        <Tooltip label="Do not budget for this category" withArrow>
          <Button variant="default" size="xs">
            No budget
          </Button>
        </Tooltip>
      </td>
      <td>
        <>
          {mutation.isError ? (
            <Tooltip label={mutation.error.message} withArrow>
              <AlertCircle size={18} strokeWidth={2} color={"#bf4040"} />
            </Tooltip>
          ) : null}

          {mutation.isSuccess ? <div>Updated!</div> : null}
        </>
      </td>
    </tr>
  );
}

function BudgetRangeSlider({ value: initialValue, maxValue, onChange }) {
  const [value, setValue] = useState(
    !initialValue
      ? [0, 0]
      : [numeral(initialValue?.[0]).value(), numeral(initialValue?.[1]).value()]
  );
  useEffect(() => {
    setValue(initialValue);
  }, [initialValue]);

  const [onFocusValue, setOnFocusValue] = useState([]);

  const handleChange = () => {
    if (JSON.stringify(onFocusValue) !== JSON.stringify(value)) {
      setOnFocusValue(value);
      onChange?.(value);
      // console.log("onChange", value);
    }
  };

  return (
    <RangeSlider
      step={5}
      min={0}
      max={maxValue}
      // @ts-ignore
      value={value}
      onChange={setValue}
      onFocus={() => {
        setOnFocusValue(value);
      }}
      // onChangeEnd={handleChange}
      onTouchEnd={handleChange}
      onMouseUp={handleChange}
    />
  );
}

function MonetaryInput({ value, onChange }) {
  const [val, setVal] = useState(value);
  const [onFocusValue, setOnFocusValue] = useState(value);
  const [isFocused, setIsfocused] = useState(false);
  useEffect(() => {
    setVal(value);
  }, [value]);

  const formatter = (value) =>
    !Number.isNaN(parseFloat(value))
      ? `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
      : "$ ";

  const nonFormatter = (value) => {
    return value;
  };

  return (
    <NumberInput
      value={val}
      hideControls
      precision={2}
      size="xs"
      style={{ width: 100 }}
      parser={(value) => value.replace(/\$\s?|(,*)/g, "")}
      formatter={isFocused ? nonFormatter : formatter}
      onFocus={(e) => {
        // e.target.select();
        setIsfocused(true);
        setOnFocusValue(numeral(e.target.value).value());
      }}
      onBlur={(e) => {
        setIsfocused(false);
        const newValue = numeral(e.currentTarget.value).value();
        if (onFocusValue !== newValue) {
          // console.log("onBlur", numeral(e.currentTarget.value).value());
          onChange?.(numeral(e.currentTarget.value).value());
        }
      }}
    />
  );
}
