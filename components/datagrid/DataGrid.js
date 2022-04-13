import React, { useEffect, useState } from "react";
import { createStyles, Table } from "@mantine/core";
import { DataGridPagination } from "./DataGridPagination";
import { DataGridProvider, useDataGrid } from "./DataGridContext";
import { DataGridHeader } from "./DataGridHeader";
import { DataGridRows } from "./DataGridRows";
import { useClickOutside } from "@mantine/hooks";

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

  // https://htmldom.dev/resize-columns-of-a-table/
  return (
    <div>
      <DataGridProvider
        rows={gridData}
        columns={columns}
        getSubRow={getSubRow}
        onCellChange={onCellChange}
        onRowChange={onRowChange}
        pagination={pagination}
        onFilterAndSort={onFilterAndSort}
      >
        <DataTable>
          <DataGridHeader />
          <DataGridRows />
          <DataGridPagination />
        </DataTable>
      </DataGridProvider>
    </div>
  );
}

function DataTable({ children }) {
  const { setSelectedRow, selectedRow } = useDataGrid();
  const handleClickOutside = () => {
    console.log("DataTable: handleClickOutside");
    // if (selectedRow) {
    //   setSelectedRow(undefined);
    // }
  };
  const ref = useClickOutside(handleClickOutside);

  const useStyles = createStyles((theme) => ({
    table: {},
  }));

  const { classes, cx } = useStyles();
  return (
    <Table ref={ref} highlightOnHover className={cx(classes.table)}>
      {children}
    </Table>
  );
}
