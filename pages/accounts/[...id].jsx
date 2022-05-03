import { Badge, Title, Text, useMantineTheme } from "@mantine/core";
import { AccountLineChart } from "components/accounts/AccountLineChart";
import { useRouter } from "next/router";
import React, { useEffect, useState } from "react";
import { Application } from "components/app/Application";
import { AccountStats } from "components/accounts/AccountStats";
import TransactionsGrid from "components/transactions/TransactionsGrid";
import axios from "axios";

//https://nextjs.org/docs/routing/dynamic-routes

export default function AccountDetail() {
  const theme = useMantineTheme();

  const router = useRouter();
  const [data, setData] = useState();

  useEffect(() => {
    async function fetchData() {
      if (router.isReady) {
        const res = await axios.post(`/api/accounts`, {
          accountId: router.query.id[0],
        });
        setData(res.data);
        console.log("data", res.data);
      }
    }
    fetchData();
  }, [router.isReady, router.query.id]); // Or [] if effect doesn't need props or state

  if (!data) return <></>;

  return (
    <Application sidebar={<AccountStats />}>
      <Title order={3}>Account Details</Title>
      {data && (
        <>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <Text weight={700}>{data.institution}</Text>

            <div>
              <Badge
                color="green"
                variant="outline"
                size="sm"
                style={{ textOverflow: "none", overflow: "initial" }}
              >
                11 hours ago
              </Badge>
            </div>
          </div>

          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <div>
              <Text weight={500} size="sm">
                {data.name} ...{data.mask}
              </Text>
            </div>

            <div>
              <Text size="sm" style={{ whiteSpace: "nowrap" }}>
                {data.subtype}
              </Text>
            </div>
          </div>
          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <Text size="xs">{data.official_name}</Text>
          </div>

          <div style={{ display: "flex", justifyContent: "space-between" }}>
            <div style={{ width: "100%" }}>
              <div style={{ paddingBottom: theme.spacing.md }}>
                <AccountLineChart numberOfMonths={12} accountId={data.id} />
              </div>
              <div style={{ paddingRight: theme.spacing.md }}>
                <Title pb="sm" order={4}>
                  Transactions
                </Title>
                <TransactionsGrid pageSize={7} accountId={data.id} />
              </div>
            </div>
          </div>

          <div style={{ paddingTop: 20 }}></div>
        </>
      )}
    </Application>
  );
}
