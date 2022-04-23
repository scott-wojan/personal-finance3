import React, { useState } from "react";
import {
  Card,
  Text,
  Title,
  createStyles,
  Paper,
  Anchor,
  Button,
  Group,
} from "@mantine/core";
import { CirclePlus } from "tabler-icons-react";

import { useApi } from "hooks/useApi";
import { ResponsiveGrid } from "components/grid/ResponsiveGrid";

import { getShortCurrency, groupBy } from "formatting";
import PlaidLinkButton from "components/plaid/PlaidLink";

export default function AccountsDashboard() {
  const { isLoading, error, data } = useApi({
    url: "accounts",
  });

  return (
    <>
      <Group position="apart" pb="md">
        <Title order={3}>Accounts</Title>
        {/* <PlaidLinkButton text="Add new account" /> */}
      </Group>
      <>
        {
          data && (
            <>
              {data.map((entry) => {
                return (
                  <div key={entry.type}>
                    <Title
                      pb="sm"
                      order={4}
                      style={{ textTransform: "capitalize" }}
                    >
                      {entry.type}
                    </Title>
                    {Object.entries(entry.accounts).map(
                      ([subtype, accounts]) => {
                        return (
                          <div key={subtype}>
                            <Title
                              pb="sm"
                              order={5}
                              style={{ textTransform: "capitalize" }}
                            >
                              {subtype}
                            </Title>
                            {accounts.map((account) => {
                              return (
                                <div key={account.id}>
                                  <Anchor href={`/accounts/${account.id}`}>
                                    {account.name} x{account.mask}
                                  </Anchor>
                                </div>
                              );
                            })}
                          </div>
                        );
                      }
                    )}
                  </div>
                );
              })}
            </>
          )

          // Object.entries(groupBy(data, "institution")).map(([key, value]) => {
          //   return (
          //     <div key={key}>
          //       <Title pb="sm" order={4}>
          //         {key}
          //       </Title>
          //       <ResponsiveGrid columns={4}>
          //         {value.map((account, accountIndex) => {
          //           return (
          //             <AccountCard key={account.name} account={account} />
          //           );
          //         })}
          //       </ResponsiveGrid>
          //     </div>
          //   );
          // })
        }
      </>
    </>
  );
}

function Stats({ account }) {
  const useStyles = createStyles((theme) => ({
    stats: {
      display: "flex",
      justifyContent: "space-between",
      marginTop: `${theme.spacing.xs}px`,
      textAlign: "center",
    },
  }));

  const { classes } = useStyles();
  return (
    <Card.Section className={classes.stats}>
      <Stat label="Balance" value={getShortCurrency(account.current_balance)} />
      <Stat
        label="Available"
        value={getShortCurrency(account.available_balance)}
      />
      <Stat label="Limit" value={getShortCurrency(account.account_limit)} />
    </Card.Section>
  );
}

function Stat({ label, value }) {
  const useStyles = createStyles((theme) => ({
    stat: {},
    label: {
      fontWeight: 500,
    },
    value: {},
  }));

  const { classes } = useStyles();
  return (
    <div className={classes.stat}>
      <Text size="sm" className={classes.value}>
        {value}
      </Text>
      <Text size="sm">{label}</Text>
    </div>
  );
}

function AccountCard({ account }) {
  const useStyles = createStyles((theme, _params, getRef) => {
    return {
      paperLink: {
        "&:hover": {
          backgroundColor:
            theme.colorScheme === "dark"
              ? theme.fn.rgba(theme.colors[theme.primaryColor][9], 0.25)
              : theme.colors[theme.primaryColor][0],
          color:
            theme.colors[theme.primaryColor][
              theme.colorScheme === "dark" ? 4 : 7
            ],
        },
      },
      link: {
        ...theme.fn.focusStyles(),
        textDecoration: "none",
        fontSize: theme.fontSizes.sm,
        color:
          theme.colorScheme === "dark"
            ? theme.colors.dark[1]
            : theme.colors.gray[7],
        padding: `${theme.spacing.xs}px ${theme.spacing.sm}px`,
        borderRadius: theme.radius.sm,
        fontWeight: 500,

        "&:hover": {
          textDecoration: "none",
        },
      },
    };
  });
  const { classes, cx } = useStyles();
  return (
    <Paper
      shadow="xs"
      pl="md"
      pr="md"
      style={{ flex: 1 }}
      className={cx(classes.paperLink)}
    >
      <Anchor href={`/accounts/${account.id}`} className={cx(classes.link)}>
        <div>
          <Text weight={700}>{account.name}</Text>
        </div>

        <Text size="xs" style={{ textTransform: "capitalize" }}>
          {account.subtype} ...{account.mask}
        </Text>

        <Stats account={account} />
      </Anchor>
    </Paper>
  );
}
