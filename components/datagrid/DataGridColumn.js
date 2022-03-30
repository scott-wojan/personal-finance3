import React, { useState } from "react";
import { createStyles } from "@mantine/core";
import { HeaderFilter } from "./column-filters/HeaderFilter";
import { useDataGrid } from "./DataGridContext";

export function DataGridColumn({
  children = undefined,
  column = undefined,
  className = undefined,
  width = undefined,
}) {
  const [showMenu, setShowMenu] = useState(false);
  const { setSort, setFilter } = useDataGrid();

  const onColumnClicked = () => {
    setShowMenu(!showMenu);
  };

  const useStyles = createStyles((theme) => ({
    th: {
      cursor: column?.isFilterable ? "pointer" : "",
      width: column?.width ?? width,
    },
  }));

  const { classes, cx } = useStyles();

  const filterComponentProps = {
    column: column,
    onSort: (direction) => {
      setSort(column.accessor, direction);
    },
    onFilter: (startValue, endValue) => {
      // console.log("DataGridColumn", startValue, endValue);
      setFilter(column.accessor, startValue, endValue);
    },
    showMenu: showMenu,
  };

  return (
    <th
      className={className ?? cx(classes.th)}
      onClick={() => {
        onColumnClicked();
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: column?.align ?? "space-between",
        }}
      >
        <div>{children}</div>
        {column?.canFilter && <HeaderFilter {...filterComponentProps} />}
      </div>
    </th>
  );
}
