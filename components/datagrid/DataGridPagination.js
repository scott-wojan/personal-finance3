import React from "react";
import { Group, Pagination, Select, useMantineTheme } from "@mantine/core";
import { useDataGrid } from "./DataGridContext";
import { ChevronDown } from "tabler-icons-react";

export function DataGridPagination({}) {
  const theme = useMantineTheme();
  const { pagination } = useDataGrid();
  const { page, total, pageSize, onPageChange, onRowCountChange, rows } =
    pagination;

  const handleRowCountChange = (newRowCount) => {
    onRowCountChange?.(parseInt(newRowCount));
  };

  const pageSizes = ["10", "20", "30", "40", "50"];
  if (pageSize) {
    pageSizes.push(pageSize.toString());
  }

  return (
    <tfoot>
      <tr>
        <td colSpan={9999} align="right">
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <Group spacing={4}>
              Show
              <Select
                // disabled={!rows}
                data={pageSizes}
                value={pageSize?.toString()}
                style={{ width: 80 }}
                onChange={handleRowCountChange}
                rightSection={
                  <ChevronDown size={14} color={theme.colors.gray[7]} />
                }
                rightSectionWidth={30}
              />
              items per page
            </Group>
            <div>
              <Pagination
                initialPage={page}
                total={Math.ceil(total / pageSize)}
                position="right"
                onChange={onPageChange}
              />
            </div>
          </div>
        </td>
      </tr>
    </tfoot>
  );
}
