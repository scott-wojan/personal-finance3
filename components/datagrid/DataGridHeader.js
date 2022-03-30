import React from "react";
import { createStyles } from "@mantine/core";
import { DataGridColumn } from "./DataGridColumn";
import { useDataGrid } from "./DataGridContext";

export function DataGridHeader() {
  const { columns, getSubRow } = useDataGrid();

  const useStyles = createStyles((theme) => ({
    thead: {
      backgroundColor: theme.colors.gray[1],
    },
  }));
  const { classes, cx } = useStyles();

  return (
    <thead className={cx(classes.thead)}>
      <tr>
        {getSubRow && <DataGridColumn width={8} />}

        {columns.map((column, columnIndex) => {
          if (column?.show !== false) {
            return (
              <DataGridColumn
                key={columnIndex}
                column={column}
                className={column?.classNames}
              >
                {column.Header}
              </DataGridColumn>
            );
          }
        })}
      </tr>
    </thead>
  );
}
