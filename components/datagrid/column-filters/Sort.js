import React from "react";
import { Menu, useMantineTheme } from "@mantine/core";
import {
  SortAscendingLetters,
  SortDescendingLetters,
  SortAscendingNumbers,
  SortDescendingNumbers,
} from "tabler-icons-react";
import { sortDirections } from "./sortDirections";

export function Sort({ onSort, sortDirection, column }) {
  const theme = useMantineTheme();
  let SortAscendingIcon = SortAscendingLetters;
  let SortDescendingIcon = SortDescendingLetters;
  if (column.dataType === "numeric" || column.dataType === "date") {
    SortAscendingIcon = SortAscendingNumbers;
    SortDescendingIcon = SortDescendingNumbers;
  }

  return (
    <>
      <Menu.Label>Sort</Menu.Label>

      <Menu.Item
        color={
          sortDirection === sortDirections.asc
            ? theme.colors[theme.primaryColor][8]
            : null
        }
        onClick={() => {
          onSort(sortDirections.asc);
        }}
        icon={<SortAscendingIcon size={18} />}
      >
        Ascending
      </Menu.Item>

      <Menu.Item
        color={
          sortDirection === sortDirections.desc
            ? theme.colors[theme.primaryColor][8]
            : null
        }
        icon={<SortDescendingIcon size={18} />}
        onClick={() => {
          onSort(sortDirections.desc);
        }}
      >
        Desending
      </Menu.Item>
    </>
  );
}
