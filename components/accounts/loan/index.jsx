import React from "react";
import { Badge, Text } from "@mantine/core";
import Mortgage from "./subtypes/mortgage";

export default function Loan({ account }) {
  const componentMap = new Map([["mortgage", Mortgage]]);
  const AccountDetailComponent = componentMap.get(account.subtype) ?? Other;

  return (
    <>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Text weight={700}>{account.institution}</Text>

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
            {account.name} ...{account.mask}
          </Text>
        </div>

        <div>
          <Text size="sm" style={{ whiteSpace: "nowrap" }}>
            {account.subtype}
          </Text>
        </div>
      </div>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Text size="xs">{account.official_name}</Text>
      </div>

      <div style={{ paddingTop: 20 }}></div>
      <AccountDetailComponent account={account} />
    </>
  );
}

function Other({ account }) {
  return <>Need component for subtype {account.subtype}</>;
}
