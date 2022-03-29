import { Grid, Paper, Text } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { NetWorthLineChart } from "components/networth/NetWorthLineChart";

import { getUserFromCookie } from "cookies/user";
import React from "react";

export default function Home({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return (
    <Application>
      <ResponsiveGrid>
        <div>
          <div>
            <Text>Net worth</Text>
          </div>

          <NetWorthLineChart />
        </div>
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
