import { Select } from "@mantine/core";
import React, { useState } from "react";
import { Calendar } from "tabler-icons-react";

export function ChartRangeDropDown({ value = "12", onChange = undefined }) {
  const [numberOfMonths, setNumberofMonths] = useState(value);
  const updateValue = (val) => {
    setNumberofMonths(val);
    onChange?.(val);
  };
  return (
    <Select
      style={{ width: 145, textAlign: "right" }}
      size="xs"
      variant="unstyled"
      onChange={updateValue}
      value={numberOfMonths}
      icon={<Calendar size={14} />}
      placeholder="Pick one"
      data={[
        { value: "3", label: "Last 3 months" },
        { value: "6", label: "Last 6 months" },
        { value: "12", label: "Last 12 months" },
        { value: "18", label: "Last 18 months" },
        { value: "24", label: "Last 24 months" },
      ]}
    />
  );
}
