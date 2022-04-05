import { Title, Text, Table, useMantineTheme } from "@mantine/core";
import React, { useEffect, useState } from "react";
import { Eye } from "tabler-icons-react";
import Link from "next/link";
import { GridCard } from "./GridCard";
import { usePagingAndFilteringApi } from "hooks/usePagingAndFilteringApi";

export function RecentTransactionsCard() {
  const theme = useMantineTheme();

  return (
    <GridCard>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Title order={4}>Recent Transactions</Title>
        <Link href="/transactions">
          <a style={{ textDecoration: "none", color: "black" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
              <Text size="xs">View Transactions</Text>
              <Eye size={12} strokeWidth={2} color={theme.colors.gray[5]} />
            </div>
          </a>
        </Link>
      </div>
      <RecentTransactions />
    </GridCard>
  );
}

function RecentTransactions() {
  const [tableData, setTableDate] = useState([]);

  const { isLoading, error, data } = usePagingAndFilteringApi({
    url: "transactions",
    payload: { pageSize: 6 },
  });

  useEffect(() => {
    setTableDate(
      data?.data?.map((transaction) => (
        <tr key={transaction.id}>
          <td>{transaction.date}</td>
          <td>{transaction.name}</td>
          <td>{transaction.amount}</td>
        </tr>
      ))
    );
  }, [data]);

  return (
    <>
      {isLoading && <>Loading...</>}
      {error && <>Error!! {error?.message}</>}
      {data && (
        <Table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Name</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>{tableData}</tbody>
        </Table>
      )}
    </>
  );
}
