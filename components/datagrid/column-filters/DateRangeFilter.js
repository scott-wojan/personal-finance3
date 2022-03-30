import React, { useState } from "react";
import { Menu, Divider } from "@mantine/core";
import { Search } from "tabler-icons-react";
import { DateRangePicker } from "@mantine/dates";
import FilterButtons from "./FilterButtons";

export function DateRangeFilter({ onFilter, values, setRef }) {
  const [startDate, setStartDate] = useState(values?.[0]);
  const [endDate, setEndDate] = useState(values?.[1]);

  const setSelectedDates = (dates) => {
    setStartDate(dates?.[0]);
    setEndDate(dates?.[1]);
  };

  const handleFilter = () => {
    if (!startDate || !endDate) {
      onFilter(undefined);
      return;
    }

    onFilter(startDate, endDate);
  };
  const handleClear = () => {
    setStartDate("");
    setEndDate("");
    onFilter?.(undefined, undefined);
  };
  return (
    <div>
      <Divider />
      <Menu.Label>Search by range</Menu.Label>
      <Menu.Item>
        <DateRangePicker
          size="xs"
          clearable={true}
          inputFormat="M/d/YY"
          placeholder="date range"
          allowSingleDateInRange={true}
          // closeCalendarOnChange={true}
          amountOfMonths={2}
          value={[startDate, endDate]}
          onChange={setSelectedDates}
        />
      </Menu.Item>
      <FilterButtons
        onFilterClicked={handleFilter}
        onClearClicked={handleClear}
      />
    </div>
  );
}
