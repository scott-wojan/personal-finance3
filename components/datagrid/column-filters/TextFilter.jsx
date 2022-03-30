import { Divider, Menu, TextInput } from "@mantine/core";
import { getHotkeyHandler } from "@mantine/hooks";
import React, { useState } from "react";
import FilterButtons from "./FilterButtons";

export default function TextFilter({ onFilter, values, setRef }) {
  const [value, setValue] = useState(values?.[0]);

  const handleFilter = () => {
    onFilter?.(value?.trim());
  };
  const handleClear = () => {
    setValue("");
    onFilter?.(undefined);
  };

  return (
    <div ref={setRef}>
      <Divider />
      <Menu.Label>Search</Menu.Label>
      <Menu.Item>
        <TextInput
          value={!value ? "" : value}
          size="xs"
          placeholder="search text"
          onChange={(e) => {
            const val = e.target?.value;
            setValue(val.trim() == "" ? undefined : val);
          }}
          onKeyDown={getHotkeyHandler([["Enter", handleFilter]])}
        />
      </Menu.Item>
      <FilterButtons
        onFilterClicked={handleFilter}
        onClearClicked={handleClear}
      />
    </div>
  );
}
