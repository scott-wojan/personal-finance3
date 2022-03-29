import { Grid, Paper, Text } from "@mantine/core";
import LinkFirstAccount from "components/accounts/LinkFirstAccount";
import { Application } from "components/app/Application";
import { getUserFromCookie } from "cookies/user";
import React from "react";

export default function Home({ user }) {
  if (!user?.has_accounts) {
    return <LinkFirstAccount />;
  }
  return (
    <Application>
      <ResponsiveGrid columns={2}>
        <Text>Stacked bar chart</Text>
        <Text>Categories</Text>
        <Text>Categories</Text>
        <Text>Categories</Text>
      </ResponsiveGrid>
    </Application>
  );
}

function ResponsiveGrid({ columns, children }) {
  if (!children) return null;
  //12 columns max that I want to limit to 3 with 4 children
  // 12/3 = 4
  const numberOfChildren = React.Children.count(children) ?? 0;
  const largeCloumnSize = columns ? 12 / columns : 12 / numberOfChildren ?? 1;

  return (
    <Grid>
      {children.map((child, index) => {
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
