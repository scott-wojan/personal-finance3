import React, { useEffect, useState } from "react";
import { createStyles, Table } from "@mantine/core";
import { DataGridPagination } from "./DataGridPagination";
import { DataGridProvider } from "./DataGridContext";
import { DataGridHeader } from "./DataGridHeader";
import { DataGridRows } from "./DataGridRows";

export function DataGrid({
  pagination = undefined,
  columns,
  rows,
  getSubRow = undefined,
  onRowChange = undefined,
  onCellChange = undefined,
  onFilterAndSort = undefined,
}) {
  const [gridData, setGridData] = useState(
    rows?.map((row, rowIndex) => {
      return { ...row, index: rowIndex };
    })
  );

  useEffect(() => {
    setGridData(
      rows?.map((row, rowIndex) => {
        return { ...row, index: rowIndex };
      })
    );
  }, [rows]);

  const useStyles = createStyles((theme) => ({
    table: {},
  }));

  const { classes, cx } = useStyles();

  // https://htmldom.dev/resize-columns-of-a-table/
  return (
    <DataGridProvider
      rows={gridData}
      columns={columns}
      getSubRow={getSubRow}
      onCellChange={onCellChange}
      onRowChange={onRowChange}
      pagination={pagination}
      onFilterAndSort={onFilterAndSort}
    >
      <Table highlightOnHover className={cx(classes.table)}>
        <DataGridHeader />
        <DataGridRows />
        <DataGridPagination />
      </Table>
    </DataGridProvider>
  );
}
