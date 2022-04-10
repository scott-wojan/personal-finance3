import { NumberInput } from "@mantine/core";
import numeral from "numeral";
import React, { useEffect, useState } from "react";

export function MonetaryInput({
  value,
  onChange,
  label = undefined,
  description = undefined,
  required = false,
}) {
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
      label={label}
      description={description}
      required={required}
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
