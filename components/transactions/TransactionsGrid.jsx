import {
  ActionIcon,
  Button,
  Center,
  createStyles,
  Group,
  Paper,
  Popover,
  Popper,
  Select,
  TextInput,
  Title,
  Tooltip,
  useMantineTheme,
} from "@mantine/core";
import React, { useEffect, useMemo, useState } from "react";
import { EditableCheckbox } from "components/datagrid/cellrenderers/EditableCheckbox";
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
import { Bolt } from "tabler-icons-react";
import { useSetState } from "@mantine/hooks";

export default function TransactionsGrid({
  pageSize = 10,
  accountId = undefined,
}) {
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
      // },
      {
        Header: "",
        Cell: ({ row }) => {
          const [state, setState] = useSetState({
            oldName: row.name,
            name: row.name,
            category: row.category,
            subcategory: row.subcategory,
            operator: "Equals",
          });
          const [visible, setVisible] = useState(false);
          const onOldNameChange = (newValue) => {
            setState({ oldName: newValue });
          };
          const onNameChange = (newValue) => {
            setState({ name: newValue });
          };
          const onCategoryChange = (newValue) => {
            setState({ category: newValue, subcategory: undefined });
          };
          const onSubCategoryChange = (newValue) => {
            setState({ subcategory: newValue });
          };
          const onOperatorChange = (newValue) => {
            setState({ operator: newValue });
          };

          return (
            <Popover
              position="bottom"
              placement="start"
              trapFocus={false}
              opened={visible}
              onClose={() => setVisible(false)}
              target={
                <Tooltip
                  width={120}
                  wrapLines
                  position="bottom"
                  label="Create a rule for this data"
                  withArrow
                >
                  <ActionIcon
                    onClick={() => {
                      setVisible(true);
                    }}
                  >
                    <Bolt size={16} />
                  </ActionIcon>
                </Tooltip>
              }
              width={360}
              style={{ width: "100%" }}
              withArrow
              // onFocusCapture={() => setVisible(true)}
              // onBlurCapture={() => setVisible(false)}
            >
              <Text size="md" weight={700}>
                Create Rule?
              </Text>
              <Group>
                <Text size="xs" weight={700}>
                  When name
                </Text>
                <Select
                  size="xs"
                  value={state.operator}
                  style={{ width: 110 }}
                  data={["Equals", "Starts with", "Contains", "Ends with"]}
                  onChange={(newValue) => {
                    onOperatorChange(newValue);
                  }}
                />
              </Group>
              <Text size="xs" pb="sm">
                <TextInput
                  placeholder="Original name"
                  size="xs"
                  pb="sm"
                  value={state.oldName}
                  onChange={(e) => {
                    onOldNameChange(e.target.value);
                  }}
                />
              </Text>

              <Text size="xs" weight={700}>
                Rename to
              </Text>
              <TextInput
                placeholder="New name"
                size="xs"
                pb="sm"
                value={state.name}
                onChange={(e) => {
                  onNameChange(e.target.value);
                }}
              />
              <Text size="xs" weight={700}>
                And categorize as
              </Text>
              <Group pb="sm">
                <CategoriesSelect
                  style={{ width: 154 }}
                  value={state.category}
                  onChange={onCategoryChange}
                />
                <SubCategoriesSelect
                  style={{ width: 154 }}
                  category={state.category}
                  onChange={onSubCategoryChange}
                  value={state.subcategory}
                />
              </Group>
              <Group position="right">
                <Button
                  variant="outline"
                  onClick={() => {
                    alert("sss");
                  }}
                >
                  Cancel
                </Button>
                <Button
                  onClick={() => {
                    alert("sss");
                  }}
                >
                  Save
                </Button>
                <div>{JSON.stringify(state)}</div>
              </Group>
            </Popover>
          );
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
