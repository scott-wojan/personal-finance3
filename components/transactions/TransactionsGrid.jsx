import { createStyles, Title, useMantineTheme } from "@mantine/core";
import React, { useEffect, useMemo } from "react";

import { EditableCheckbox } from "components/datagrid/cellrenderers/EditableCheckbox";
import { EditableTextInput } from "components/datagrid/cellrenderers/EditableTextInput";
import { TransactionStatus } from "components/datagrid/cellrenderers/TransactionStatus";
import { DataGrid } from "components/datagrid/DataGrid";

import TransactionDetailMenu from "./TransactionDetailMenu";
import { Text } from "@mantine/core";
import { usePagingAndFilteringApi } from "hooks/usePagingAndFilteringApi";
import { CategoriesDropdown } from "./CategoriesDropdown";
import { SubCategoriesDropdown } from "./SubCategoriesDropdown";
import { ResponsiveGrid } from "components/grid/ResponsiveGrid";

export default function TransactionsGrid({ accountId = undefined }) {
  const {
    isLoading,
    error,
    data,
    setPage,
    setPageSize,
    setFiltersAndSorting,
    page,
    pageSize,
  } = usePagingAndFilteringApi({
    url: "transactions",
    payload: { accountId },
  });

  const columns = useMemo(
    () => [
      {
        Header: "Id",
        accessor: "id",
        show: false,
      },
      {
        Header: "Date",
        accessor: "date",
        dataType: "date",
        width: 100,
        canFilter: true,
      },
      {
        Header: "Account",
        accessor: "account",
        dataType: "select",
        filterUrl: "/select-options/accounts",
        width: 100,
        canFilter: true,
      },
      {
        Header: "Name",
        accessor: "name",
        dataType: "text",
        Cell: EditableTextInput,
        width: 200,
        canFilter: true,
      },
      {
        Header: "Category",
        accessor: "category",
        dataType: "select",
        filterUrl: "/select-options/categories",
        Cell: CategoriesDropdown,
        width: 200,
        canFilter: true,
      },
      {
        Header: "Sub Category",
        accessor: "subcategory",
        dataType: "select",
        filterUrl: "/select-options/subcategories",
        width: 200,
        Cell: SubCategoriesDropdown,
        canFilter: true,
      },
      {
        Header: "Amount",
        accessor: "amount",
        dataType: "numeric",
        canFilter: true,
        width: 80,
        align: "end",
        formatting: {
          type: "currency",
          settings: {
            currencyCode: (x) => x.iso_currency_code,
          },
        },
      },
      {
        Header: "Status",
        accessor: "is_pending",
        dataType: "select",
        canFilter: true,
        width: 80,
        align: "center",
        useDefaultRendererForNonEdit: false,
        Cell: TransactionStatus,
      },
      {
        Header: "Recurring",
        accessor: "is_recurring",
        width: 80,
        align: "center",
        useDefaultRendererForNonEdit: false,
        Cell: EditableCheckbox,
        dataType: "select",
        canFilter: true,
      },
      {
        Header: "Currency Code",
        accessor: "iso_currency_code",
        show: false,
      },
    ],
    []
  );

  const onRowChange = (row) => {
    console.log("onRowChange", row);
  };
  const onFilterAndSort = (filter) => {
    //console.log("TransactionGrid onFilter", filter);
    setFiltersAndSorting(filter);
  };

  const getSubRow = (row) => {
    return <DataGridSubRow />;
  };

  // const rows = transactions.data;

  const onCellChange = ({ row, propertyName, newValue, oldValue }) => {
    if (propertyName === "category") {
      return { ...row, subcategory: null };
    }
  };

  const onPageChange = (newPage) => {
    setPage(newPage);
  };

  const onRowCountChange = (newRowCount) => {
    setPageSize(newRowCount);
  };

  useEffect(() => {
    if (error) console.log("error", error);
  }, [error]);

  useEffect(() => {
    console.log("data", data);
  }, [data]);

  return (
    <>
      {isLoading && <>Loading...</>}
      {error && <>Error!! {error?.message}</>}
      {data && (
        <>
          <DataGrid
            columns={columns}
            rows={data.data}
            getSubRow={getSubRow}
            onCellChange={onCellChange}
            onRowChange={onRowChange}
            onFilterAndSort={onFilterAndSort}
            pagination={{
              total: data.count,
              page: page,
              pageSize: pageSize,
              onPageChange,
              onRowCountChange,
            }}
          />
        </>
      )}
    </>
  );
}

function DataGridSubRow() {
  const theme = useMantineTheme();
  const useStyles = createStyles((theme) => ({
    table: {
      tr: {
        "&:hover": {},
        td: {
          border: "0 !important",
          padding: "0 !important",
          fontSize: `${theme.fontSizes.xs}px !important`,
        },
      },
    },
  }));
  const { classes } = useStyles();
  return (
    <tr>
      <td colSpan={9999} style={{ padding: 0 }}>
        <div style={{ display: "flex" }}>
          <div>
            <TransactionDetailMenu />
          </div>
          <div
            style={{
              width: "100%",
              paddingLeft: theme.spacing.lg,
              paddingTop: theme.spacing.sm,
            }}
          >
            <ResponsiveGrid>
              <div>
                <Text weight={600} size="sm">
                  Received As
                </Text>
                <table className={classes.table}>
                  <tbody>
                    <tr>
                      <td>Name:</td>
                      <td>
                        <a
                          href="https://www.google.com/search?q=COINBASE.COM 8889087930 ***********1D5D"
                          target="_blank"
                          rel="noreferrer"
                        >
                          COINBASE.COM 8889087930 ***********1D5D
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>Category:</td>
                      <td>Online Services</td>
                    </tr>
                    <tr>
                      <td>Sub Category:</td>
                      <td>Expense</td>
                    </tr>
                    <tr>
                      <td>Check #:</td>
                      <td> 1232</td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <div>
                <Text weight={600} size="sm">
                  Merchant Info
                </Text>

                <table className={classes.table}>
                  <tbody>
                    <tr>
                      <td>Name:</td>
                      <td>
                        <a
                          href="https://www.google.com/search?q=Best Buy"
                          target="_blank"
                          rel="noreferrer"
                        >
                          Best Buy
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>Store #:</td>
                      <td>1234</td>
                    </tr>
                    <tr>
                      <td>Address:</td>
                      <td>
                        <a
                          href="https://www.google.com/maps/search/?api=1&query=6405 wexley ln the colony tx 75056"
                          target="_blank"
                          rel="noreferrer"
                        >
                          1234 Main Street, Dallas, TX 75056
                        </a>
                      </td>
                    </tr>
                    <tr>
                      <td>Authorized On: </td>
                      <td>01/04/2022</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </ResponsiveGrid>
          </div>
        </div>
      </td>
    </tr>
  );
}
