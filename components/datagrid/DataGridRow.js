import React, { useEffect, useState } from "react";
import { createStyles } from "@mantine/core";
import { useDataGrid } from "./DataGridContext";
import { DataGridCell } from "./DataGridCell";
import { RowExpandCollapse } from "./RowExpandCollapse";

export function DataGridRow({ row }) {
  const [subRow, setSubRow] = useState(null);
  const [dataRow, setDataRow] = useState({ ...row, isDirty: false });
  const { selectedRow, setSelectedRow, columns, getSubRow, onCellChange } =
    useDataGrid();

  useEffect(() => {
    setDataRow(row);
  }, [row]);

  const useStyles = createStyles((theme) => ({
    row: {
      height: "48px !important",
    },
    activeRow: {
      height: "48px !important",
      backgroundColor: theme.colors.gray[8],
      color: "white",
      "&:hover": {
        backgroundColor: theme.colors.gray[8] + " !important",
      },
      button: {
        color: "white",
        "&:hover": {
          color: theme.colors.gray[7],
        },
      },
    },
  }));

  const { classes, cx } = useStyles();

  const propertiesToShow = columns
    .filter((col) => col?.show !== false)
    .map((col) => col.accessor);

  const getColumnByPropertyName = (propertyName) => {
    const column = columns.find((col) => {
      return col.accessor === propertyName;
    });

    return column;
  };

  const cellChange = ({ propertyName, newValue, oldValue }) => {
    selectedRow[propertyName] = newValue;
    selectedRow.isDirty = true;

    const result = onCellChange?.({
      row: selectedRow,
      propertyName,
      newValue,
      oldValue,
    });

    if (result) {
      setDataRow(result);
    }
  };

  return (
    <>
      <tr
        className={cx(
          selectedRow?.index === dataRow.index ? classes.activeRow : classes.row
        )}
        onClick={() => {
          setSelectedRow(row);
        }}
      >
        {getSubRow && (
          <DataGridCell>
            <RowExpandCollapse
              onChange={(isExpanded) => {
                setSubRow(isExpanded ? getSubRow?.(dataRow) : null);
              }}
            />
          </DataGridCell>
        )}

        {propertiesToShow.map((propertyName) => {
          const column = getColumnByPropertyName(propertyName);
          return (
            <DataGridCell
              key={propertyName}
              onChange={cellChange}
              value={dataRow[propertyName]}
              row={dataRow}
              column={column}
              isEditing={selectedRow?.index === dataRow.index}
            />
          );
        })}
      </tr>
      {subRow}
    </>
  );
}
