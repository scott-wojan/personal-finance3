import { Divider, Menu, NumberInput, TextInput } from "@mantine/core";
import React, { forwardRef, useState } from "react";
import { useRef } from "react";
import { Filter, FilterOff, Search } from "tabler-icons-react";
import FilterButtons from "./FilterButtons";

export default function NumericRangeFilter({ onFilter, values }) {
  const [startValue, setStartValue] = useState(values?.[0]);
  const [endValue, setEndValue] = useState(values?.[1]);
  const startRef = useRef();
  const endRef = useRef();

  const handleFilter = () => {
    onFilter?.(startValue, endValue);
  };

  const handleClear = () => {
    setStartValue("");
    setEndValue("");
    onFilter?.(undefined, undefined);
  };

  return (
    <>
      <Divider />
      <Menu.Label>Search by range</Menu.Label>
      <Menu.Item>
        <NumericInput
          ref={startRef}
          // @ts-ignore
          value={startValue}
          placeholder="start value"
          onChange={(e) => {
            const val = parseFloat(e.target.value);
            if (isNaN(val)) {
              setStartValue(undefined);
              return;
            }
            setStartValue(val);
          }}
        />
        <NumericInput
          ref={endRef}
          // @ts-ignore
          value={endValue}
          placeholder="end value"
          onChange={(e) => {
            // console.log(e.target.value);
            const val = parseFloat(e.target.value);
            if (isNaN(val)) {
              setEndValue(undefined);
              return;
            }
            setEndValue(val);
          }}
        />
      </Menu.Item>
      <FilterButtons
        onFilterClicked={handleFilter}
        onClearClicked={handleClear}
      />
    </>
  );
}
const NumericInput = forwardRef((props, ref) => {
  return <TextInput type="number" ref={ref} size="xs" {...props} />;
});
NumericInput.displayName = "NumericInput";

const MonetaryInput = forwardRef((props, ref) => {
  const options = {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  };

  return (
    <NumberInput
      hideControls
      ref={ref}
      size="xs"
      placeholder="start value"
      parser={(value) => value.replace(/\$\s?|(,*)/g, "")}
      formatter={(value) =>
        !Number.isNaN(parseFloat(value))
          ? `$ ${value}`.replace(/\B(?=(\d{3})+(?!\d))/g, ",")
          : "$ "
      }
    />
  );
});
MonetaryInput.displayName = "MonetaryInput";
