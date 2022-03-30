import React from "react";
import { MoodSad } from "tabler-icons-react";
import { useDataGrid } from "./DataGridContext";
import { DataGridRow } from "./DataGridRow";
import { Text } from "@mantine/core";
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
            <div>
              <Text size="xl" weight={700}>
                Oh No
              </Text>
            </div>
            <MoodSad size={48} strokeWidth={1} color={"gray"} />
            <div>No results were found</div>
          </td>
        </tr>
      )}
    </tbody>
  );
}
