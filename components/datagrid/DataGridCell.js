import { createStyles } from "@mantine/core";
import React, { useState } from "react";
import { DefaultCellRenderer } from "components/datagrid/cellrenderers/DefaultCellRenderer";
import { formattingHandler } from "components/datagrid/cellrenderers/formatting";
import { useDataGrid } from "./DataGridContext";

export function DataGridCell(props) {
  const { column, onChange, row, children, isEditing = false } = props;
  const { tbodyRef, rows, setSelectedRow } = useDataGrid();
  const [formatting, setFormatting] = useState(
    column?.formatting &&
      new Proxy(
        {
          ...column.formatting,
          data: row,
        },
        formattingHandler
      )
  );

  const getComponent = () => {
    if (isEditing && column?.Cell) {
      return column?.Cell;
    }
    if (column?.useDefaultRendererForNonEdit === false && column?.Cell) {
      return column?.Cell;
    }
    return DefaultCellRenderer;
  };

  const Component = getComponent();

  const onCellChange = (newValue, oldValue) => {
    onChange?.({
      propertyName: column?.accessor,
      newValue,
      oldValue,
    });
  };

  // useEffect(() => {
  //   if (!formatting && column && formatters.has(column.dataType)) {
  //     const formatter = formatters.get(column.dataType);

  //     if (formatter) {
  //       console.log("formatter", formatter);
  //       setFormatting(formatter(value, null));
  //       return;
  //     }
  //   }
  // }, [column, formatting, value]);

  const componentProps = {
    ...props,
    onChange: onCellChange,
    align: column?.align,
    formatting: formatting,
  };

  // if (isReactComponent(Component)) {
  //   return (
  //     <td style={{ padding: 1, textAlign: column?.align }}>
  //       <Component {...componentProps} />
  //     </td>
  //   );
  // }

  const onActiveRowIndexChange = async (newIndex) => {
    const newRow = rows[newIndex];
    if (newRow) {
      await setSelectedRow(newRow);
    }
  };

  const useStyles = createStyles((theme) => ({
    td: {
      paddingRight: "5px !important",
      paddingLeft: "5px !important",
      input: {
        paddingLeft: 2,
        fontSize: 14,
      },
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <td
      className={cx(classes.td)}
      onKeyDown={(e) => {
        handleTableRowKeyDown(e, tbodyRef, row, onActiveRowIndexChange);
      }}
    >
      <Component {...componentProps} />
      {children}
    </td>
  );
}

// function isReactComponent(component) {
//   return (
//     isClassComponent(component) ||
//     typeof component === "function" ||
//     isOtherComponent(component)
//   );
// }

// function isClassComponent(component) {
//   return (
//     typeof component === "function" &&
//     (() => {
//       const proto = Object.getPrototypeOf(component);
//       return proto.prototype && proto.prototype.isReactComponent;
//     })()
//   );
// }

// function isOtherComponent(component) {
//   return (
//     typeof component === "object" &&
//     typeof component.$$typeof === "symbol" &&
//     ["react.memo", "react.forward_ref"].includes(component.$$typeof.description)
//   );
// }

const handleTableRowKeyDown = async (
  event,
  tbodyRef,
  row,
  onActiveRowIndexChange
) => {
  event.stopPropagation();
  if (!row) {
    return;
  }
  const currentRow = tbodyRef.current?.children[row.index];
  const rowInputs =
    Array.from(event.currentTarget.parentElement.querySelectorAll("input")) ||
    [];
  const currentPosition = rowInputs.indexOf(event.target);

  switch (event.key) {
    case "Right": // IE/Edge specific value
    case "ArrowRight":
      rowInputs[currentPosition + 1] && rowInputs[currentPosition + 1].focus();
      break;
    case "Left": // IE/Edge specific value
    case "ArrowLeft":
      rowInputs[currentPosition - 1] && rowInputs[currentPosition - 1].focus();
      break;
    case "Up": // IE/Edge specific value
    case "ArrowUp":
      const prevRow = currentRow?.previousElementSibling;
      if (prevRow) {
        await onActiveRowIndexChange(prevRow.rowIndex - 1);
      }
      const prevRowInputs = prevRow?.querySelectorAll("input") || [];
      prevRowInputs[currentPosition] && prevRowInputs[currentPosition].focus();
      break;
    case "Down": // IE/Edge specific value
    case "ArrowDown":
      const nextRow = currentRow?.nextElementSibling;
      if (nextRow) {
        await onActiveRowIndexChange(nextRow.rowIndex - 1);
        const nextRowInputs = nextRow?.querySelectorAll("input") || [];
        nextRowInputs[currentPosition] &&
          nextRowInputs[currentPosition].focus();
      }

      break;
    default:
      break;
  }
};
