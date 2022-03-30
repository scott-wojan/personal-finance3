import React, { useState } from "react";
import { Menu, Divider, Select } from "@mantine/core";
import FilterButtons from "./FilterButtons";
import { useApi } from "hooks/useApi";

export function SelectFilter({ onFilter, values, column }) {
  const [value, setValue] = useState(values?.[0]);

  const { isLoading, error, data } = useApi({
    url: column.filterUrl,
  });

  const handleFilter = () => {
    onFilter?.(!value ? undefined : value);
  };

  const handleClear = () => {
    setValue("");
    onFilter?.(undefined);
  };

  if (error) {
    return <div>ERROR... {error.message}</div>;
  }

  return (
    <>
      <Divider />
      <Menu.Label>Select</Menu.Label>
      <Menu.Item>
        {isLoading && <div>Loading...</div>}

        <Select
          size="xs"
          disabled={isLoading || error}
          value={value}
          searchable
          nothingFound="No matches"
          clearable
          allowDeselect
          placeholder="select one"
          data={data ?? []}
          onChange={(selectedValue) => {
            setValue(selectedValue);
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
