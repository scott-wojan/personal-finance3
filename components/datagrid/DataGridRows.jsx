import React from "react";
import { useDataGrid } from "./DataGridContext";
import { DataGridRow } from "./DataGridRow";
import NoResults from "components/noresults";
export function DataGridRows() {
  const { rows, tbodyRef } = useDataGrid();

  return (
    <tbody ref={tbodyRef}>
      {rows?.map((data, dataIndex) => {
        const row = { ...data, index: dataIndex };

        return (
          <React.Fragment key={dataIndex}>
            <DataGridRow row={row} />
          </React.Fragment>
        );
      })}
      {!rows && (
        <tr>
          <td
            colSpan={9999}
            style={{
              textAlign: "center",
            }}
          >
            <NoResults />
          </td>
        </tr>
      )}
    </tbody>
  );
}
