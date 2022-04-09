import {
  RangeSlider,
  Button,
  Table,
  Text,
  Tooltip,
  NumberInput,
  Title,
  ActionIcon,
  Menu,
} from "@mantine/core";
import axios from "axios";
import { ChartRangeDropDown } from "components/dashboard/ChartRangeDropDown";
import dayjs from "dayjs";
import { getFormattedCurrency, groupBy } from "formatting";
import { useApi } from "hooks/useApi";
import numeral from "numeral";
import React, { Fragment, useEffect, useState } from "react";
import { useMutation } from "react-query";
import { AlertCircle, Filter, Square, SquareCheck } from "tabler-icons-react";

export function UserBudget() {
  const [numberOfMonths, setNumberOfMonths] = useState("12");
  const [showBudgetedCategoriesOnly, setShowBudgetedCategoriesOnly] =
    useState(true);

  const { isLoading, error, data } = useApi({
    url: "budget",
    payload: {
      startDate: dayjs()
        .subtract(parseInt(numberOfMonths), "month")
        .startOf("month")
        .format("YYYY-MM-DD"),
      endDate: dayjs().startOf("month").format("YYYY-MM-DD"),
      showBudgetedCategoriesOnly,
    },
  });

  // useEffect(() => {
  //   console.log(data);
  // }, [data]);

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
              <th colSpan={6}>
                <div
                  style={{ display: "flex", justifyContent: "space-between" }}
                >
                  <Title order={4}>Budget</Title>

                  <Tooltip
                    width={180}
                    wrapLines
                    position="bottom"
                    label="The number of months used to calculate the spending stats"
                    withArrow
                  >
                    <ChartRangeDropDown onChange={setNumberOfMonths} />
                  </Tooltip>
                </div>
              </th>
            </tr>
            <tr>
              <th>Category</th>
              <th style={{ width: 280, textAlign: "center" }}>Budget</th>
              <th>Min</th>
              <th>Max</th>
              <th style={{ display: "flex", alignItems: "center" }}>
                Options
                <OptionsMenu
                  showBudgetedCategoriesOnly={showBudgetedCategoriesOnly}
                  setShowBudgetedCategoriesOnly={setShowBudgetedCategoriesOnly}
                />
              </th>
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

function OptionsMenu({
  showBudgetedCategoriesOnly,
  setShowBudgetedCategoriesOnly,
}) {
  const [showBudgetedOnly, setShowBudgetedOnly] = useState(
    showBudgetedCategoriesOnly
  );

  useEffect(() => {
    setShowBudgetedOnly(showBudgetedCategoriesOnly);
  }, [showBudgetedCategoriesOnly]);

  const BudgetedOnly = showBudgetedCategoriesOnly ? SquareCheck : Square;
  const All = !showBudgetedCategoriesOnly ? SquareCheck : Square;
  return (
    <Menu
      control={
        <ActionIcon>
          <Filter size={18} strokeWidth={1} color="gray" />
        </ActionIcon>
      }
      styles={{
        body: { width: 230 },
      }}
    >
      <Menu.Item
        icon={<BudgetedOnly size={14} />}
        onClick={() => {
          if (!showBudgetedCategoriesOnly) {
            setShowBudgetedCategoriesOnly(true);
          }
        }}
      >
        Budgeted categories only
      </Menu.Item>
      <Menu.Item
        icon={<All size={14} />}
        onClick={() => {
          if (showBudgetedCategoriesOnly) {
            setShowBudgetedCategoriesOnly(false);
          }
        }}
      >
        Show all categories
      </Menu.Item>
    </Menu>
  );
}

function BudgetRow({ subcategory }) {
  console.log(subcategory.do_not_budget);

  const [minBudgetedAmount, setMinBudgetedAmount] = useState(
    subcategory.min_budgeted_amount * -1
  );

  const [maxBudgetedAmount, setMaxBudgetedAmount] = useState(
    subcategory.max_budgeted_amount * -1
  );

  const [hide, setHide] = useState(false);

  const budgetItemMutation = useMutation((updatedBudgetItem) => {
    return axios.post("api/budget/updateitem", updatedBudgetItem);
  });

  const onBudgetSelected = ({ userCategoryId, min, max }) => {
    // @ts-ignore
    budgetItemMutation.mutate({
      userCategoryId,
      min,
      max,
    });
  };
  const onRowButtonClicked = (doNotBudget) => {
    // @ts-ignore
    budgetItemMutation
      // @ts-ignore
      .mutateAsync({
        userCategoryId: subcategory.user_category_id,
        min: minBudgetedAmount,
        max: maxBudgetedAmount,
        doNotBudget: doNotBudget,
      })
      .then((x) => {
        setHide(true);
      })
      .catch(() => {
        setHide(false);
      });
  };

  return (
    <>
      {!hide && (
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
                  userCategoryId: subcategory.user_category_id,
                  min,
                  max,
                });
              }}
            />
            <div className="stat">
              <Text size="xs" color="gray">
                Stats:
              </Text>
              <Stat
                value={subcategory.min_monthly_spend}
                type="minimum"
                subcategory_name={subcategory.user_subcategory}
              />
              <Stat
                value={subcategory.avg_monthly_spend * -1}
                type="average"
                subcategory_name={subcategory.user_subcategory}
              />
              <Stat
                value={subcategory.max_monthly_spend * -1}
                type="maximum"
                subcategory_name={subcategory.user_subcategory}
              />
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
            <Tooltip
              width={180}
              wrapLines
              position="bottom"
              label={
                subcategory.do_not_budget
                  ? "Include this category in my budget"
                  : "Do not include this category in my budget"
              }
              withArrow
            >
              <Button
                onClick={() => {
                  onRowButtonClicked(!subcategory.do_not_budget);
                }}
                variant="default"
                size="xs"
              >
                {subcategory.do_not_budget
                  ? "Include in budget"
                  : "Do not budget"}
              </Button>
            </Tooltip>
          </td>
          <td>
            <>
              {budgetItemMutation.isError ? (
                <Tooltip
                  width={180}
                  wrapLines
                  position="bottom"
                  label={budgetItemMutation.error.message}
                  withArrow
                  sx={(theme) => ({
                    svg: {
                      color: theme.colors.red[7],
                    },
                  })}
                >
                  <AlertCircle size={18} strokeWidth={2} />
                </Tooltip>
              ) : null}
              {/* {mutation.isSuccess ? <div>Updated!</div> : null} */}
            </>
          </td>
        </tr>
      )}
    </>
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
      style={{ width: 90 }}
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

function Stat({ value, type, subcategory_name }) {
  const formattedValue = getFormattedCurrency(value);
  return (
    <Tooltip
      width={200}
      wrapLines
      label={`${formattedValue} is the ${type} monthly amount you have spent on ${subcategory_name}`}
      withArrow
      position="bottom"
    >
      <Text size="xs" color="gray">
        {formattedValue}
      </Text>
    </Tooltip>
  );
}
