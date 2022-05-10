import { Title, useMantineTheme } from "@mantine/core";
import React from "react";
import { Application } from "components/app/Application";
import { AccountStats } from "components/accounts/AccountStats";
import { useApi } from "hooks/useApi";
import Depository from "components/accounts/depository";
import Credit from "components/accounts/credit";
import Loan from "components/accounts/loan";
import Investment from "components/accounts/investment";
import Other from "components/accounts/other";

//https://nextjs.org/docs/routing/dynamic-routes

export default function AccountDetail({ accountId }) {
  console.log(accountId);
  const theme = useMantineTheme();

  const { isLoading, error, data } = useApi({
    url: `accounts/${accountId}`,
  });

  if (!data) return <></>;

  const componentMap = new Map([
    ["depository", Depository],
    ["credit", Credit],
    ["loan", Loan],
    ["investment", Investment],
    ["other", Other],
  ]);

  const AccountDetailComponent = componentMap.get(data.type);

  return (
    <Application sidebar={<AccountStats />}>
      <Title order={3}>Account Details</Title>
      <AccountDetailComponent account={data} />
    </Application>
  );
}

export async function getServerSideProps(context) {
  const accountId = context?.params?.id?.[0];

  if (!accountId) {
    return {
      props: { accountId: null },
    };
  }

  return {
    props: { accountId: accountId },
  };
}
