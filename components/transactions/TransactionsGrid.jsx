import { createStyles, useMantineTheme } from "@mantine/core";
import React, { useEffect, useMemo, useState } from "react";
import { EditableTextInput } from "components/datagrid/cellrenderers/EditableTextInput";
import { TransactionStatus } from "components/datagrid/cellrenderers/TransactionStatus";
import { DataGrid } from "components/datagrid/DataGrid";
import { TransactionDetailMenu } from "./TransactionDetailMenu";
import { Text } from "@mantine/core";
import { usePagingAndFilteringApi } from "hooks/usePagingAndFilteringApi";
import { CategoriesSelect } from "../categories/CategoriesSelect";
import { SubCategoriesSelect } from "../categories/SubCategoriesSelect";
import { ResponsiveGrid } from "components/grid/ResponsiveGrid";
import axios from "axios";
import { useApi } from "hooks/useApi";
import dayjs from "dayjs";
import { RuleCell } from "./RuleCell";

export default function TransactionsGrid({
  pageSize = 10,
  accountId = undefined,
}) {
  const [reloadData, setReloadData] = useState(false);
  const {
    isLoading,
    error,
    data,
    setPage,
    setPageSize,
    setFiltersAndSorting,
    page,
    pageSize: tablePageSize,
  } = usePagingAndFilteringApi({
    url: "transactions",
    payload: { accountId, pageSize },
    reloadData,
  });

  // const accountColumn = accountId
  //   ? {}
  //   : {
  //       Header: "Account",
  //       accessor: "account",
  //       dataType: "select",
  //       filterUrl: "/select-options/accounts",
  //       width: 100,
  //       canFilter: true,
  //     };
  const accountColumn = {
    Header: "Account",
    accessor: "account",
    dataType: "select",
    filterUrl: "/select-options/accounts",
    width: 100,
    canFilter: true,
  };

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
        ...accountColumn,
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
        // dataType: "select",
        // filterUrl: "/select-options/categories",
        Cell: CategoriesSelect,
        width: 200,
        canFilter: true,
      },
      {
        Header: "Sub Category",
        accessor: "subcategory",
        dataType: "select",
        // Cell: ({ row }) => {
        //   return (
        //     <SubCategoriesSelect
        //       value={row.subcategory}
        //       category={row.category}
        //     />
        //   );
        // },
        filterUrl: "/select-options/subcategories",
        width: 200,
        Cell: (props) => {
          const { row, onChange } = props;
          return (
            <SubCategoriesSelect
              // @ts-ignore
              category={row.category}
              value={row.subcategory}
              onChange={onChange}
            />
          );
        },
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
        filterUrl: "/select-options/transactionstatus",
        canFilter: true,
        width: 80,
        align: "center",
        useDefaultRendererForNonEdit: false,
        Cell: TransactionStatus,
      },
      // {
      //   Header: "Recurring",
      //   accessor: "is_recurring",
      //   width: 80,
      //   align: "center",
      //   useDefaultRendererForNonEdit: false,
      //   Cell: EditableCheckbox,
      //   dataType: "select",
      //   canFilter: true,
      // }, setReloadData
      {
        Header: "",
        Cell: (props) => {
          const ruleChange = () => {
            props?.onChange();
            setReloadData(true);
          };
          return <RuleCell {...props} onChange={ruleChange} />;
        },
      },
      {
        Header: "Currency Code",
        accessor: "iso_currency_code",
        show: false,
      },
    ],
    []
  );

  const onRowChange = async ({ row }) => {
    const { id, name, category, subcategory } = row;
    await axios.post("/api/transactions/update", {
      id,
      name,
      category,
      subcategory,
    });
  };
  const onFilterAndSort = (filter) => {
    //console.log("TransactionGrid onFilter", filter);
    setFiltersAndSorting(filter);
  };

  const getSubRow = (row) => {
    // console.log(row);
    return <DataGridSubRow transactionId={row.id} />;
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

  // useEffect(() => {
  //   console.log("data", data);
  // }, [data]);

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
              pageSize: tablePageSize,
              onPageChange,
              onRowCountChange,
            }}
          />
        </>
      )}
    </>
  );
}

function DataGridSubRow({ transactionId }) {
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

  console.log(transactionId);
  const { isLoading, error, data } = useApi({
    url: `transactions/${transactionId}`,
  });

  if (error) {
    <div>Error: error.message</div>;
  }

  return (
    <>
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
                            href={`https://www.google.com/search?q=${data?.imported_name}`}
                            target="_blank"
                            rel="noreferrer"
                          >
                            {data?.imported_name}
                          </a>
                        </td>
                      </tr>
                      <tr>
                        <td>Category:</td>
                        <td>{data?.imported_category}</td>
                      </tr>
                      <tr>
                        <td>Sub Category:</td>
                        <td>{data?.imported_subcategory}</td>
                      </tr>
                      {data?.check && (
                        <tr>
                          <td>Check #:</td>
                          <td>{data?.check}</td>
                        </tr>
                      )}
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
                            href={`https://www.google.com/search?q=${data?.merchant_name}`}
                            target="_blank"
                            rel="noreferrer"
                          >
                            {data?.merchant_name}
                          </a>
                        </td>
                      </tr>
                      <tr>
                        <td>Store #:</td>
                        <td>{data?.store_number}</td>
                      </tr>
                      {data?.address && (
                        <tr>
                          <td>Address:</td>
                          <td>
                            <a
                              href={`https://www.google.com/maps/search/?api=1&query=${data?.address} ${data?.city} ${data?.region} ${data?.postal_code}`}
                              target="_blank"
                              rel="noreferrer"
                            >
                              {data?.address}, {data?.city}, {data?.region}{" "}
                              {data?.postal_code}
                            </a>
                          </td>
                        </tr>
                      )}

                      {data?.authorized_date && (
                        <tr>
                          <td>Authorized On: </td>
                          <td>
                            {dayjs(data?.authorized_date).format("MM-DD-YYYY")}
                          </td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>
              </ResponsiveGrid>
            </div>
          </div>
        </td>
      </tr>
    </>
  );
}
