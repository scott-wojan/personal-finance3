import { Grid, Paper, Select, Text } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { NetWorthLineChart } from "components/networth/NetWorthLineChart";

import { getUserFromCookie } from "cookies/user";
import React, { useState } from "react";
import { Calendar, Filter } from "tabler-icons-react";

export default function Home({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return (
    <Application>
      <ResponsiveGrid>
        <NetWorthCard />
      </ResponsiveGrid>
      <ResponsiveGrid columns={2}>
        <Text>Stacked bar chart</Text>
        <Text>Categories</Text>
        <Text>Recent Transactions</Text>
        <Text>Budget</Text>
      </ResponsiveGrid>
    </Application>
  );
}

function NetWorthCard() {
  const [numberofMonths, setNumberofMonths] = useState("12");
  return (
    <div>
      <div style={{ display: "flex", justifyContent: "space-between" }}>
        <Text>Net worth</Text>
        <Select
          style={{ width: 145, textAlign: "right" }}
          size="xs"
          variant="unstyled"
          onChange={setNumberofMonths}
          value={numberofMonths}
          icon={<Calendar size={14} />}
          placeholder="Pick one"
          data={[
            { value: "12", label: "Last 12 months" },
            { value: "18", label: "Last 18 months" },
            { value: "24", label: "Last 24 months" },
          ]}
        />
      </div>

      <NetWorthLineChart numberofMonths={numberofMonths} />
    </div>
  );
}

function ResponsiveGrid({ columns = undefined, children }) {
  if (!children) return null;
  const childComponents = Array.isArray(children) ? children : [children];
  const numberOfChildren = React.Children.count(children) ?? 0;
  const largeCloumnSize = columns ? 12 / columns : 12 / numberOfChildren ?? 1;

  return (
    <Grid>
      {childComponents.map((child, index) => {
        return (
          <Grid.Col key={index} md={12} lg={largeCloumnSize}>
            <Paper shadow="xs" p="md" style={{ flex: 1 }}>
              {child}
            </Paper>
          </Grid.Col>
        );
      })}
    </Grid>
  );
}

export async function getServerSideProps(context) {
  const user = getUserFromCookie(context.req, context.res);
  return {
    props: { user },
  };
}
