import React, { useState } from "react";
import {
  Card,
  Text,
  Title,
  createStyles,
  Paper,
  Anchor,
  Group,
  Image,
  Table,
  Popover,
  ActionIcon,
  Button,
} from "@mantine/core";

import { useApi } from "hooks/useApi";
import { getShortCurrency } from "formatting";
import {
  formatCurrency,
  formatDate,
} from "components/datagrid/cellrenderers/formatting";
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

      {data && (
        <Table>
          <thead>
            <tr>
              <th>Institution</th>
              <th>Type</th>
              <th>Account</th>
              <th>Balance</th>
              <th>Last Import</th>
              <th style={{ textAlign: "right" }}>Status</th>
            </tr>
          </thead>
          <tbody>
            {data.map((account, i) => {
              return (
                <tr key={i}>
                  <td>
                    <div style={{ display: "flex" }}>
                      <Image
                        pr="xs"
                        radius="xl"
                        width={24}
                        height={24}
                        alt=""
                        src={
                          !account.institution_logo
                            ? null
                            : `data:image/png;base64, ${account.institution_logo}`
                        }
                      />
                      <Anchor
                        href={`https://www.capitalone.com/`}
                        target="_blank"
                      >
                        {account.institution}
                      </Anchor>
                    </div>
                  </td>
                  <td>{account.subtype}</td>
                  <td>
                    <Anchor href={`/accounts/${account.id}`}>
                      {account.name} x{account.mask}
                    </Anchor>
                  </td>

                  <td>
                    {formatCurrency(account.current_balance, {
                      currencyCode: account.iso_currency_code,
                    })}
                  </td>
                  <td>{formatDate(account.last_import_date)}</td>
                  <td style={{ textAlign: "right" }}>
                    <AccountStatus account={account} />
                  </td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      )}

      {/* <>
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
      </> */}
    </>
  );
}

function AccountStatus({ account }) {
  const [popoverVisible, setPopoverVisible] = useState(false);

  const StatusImage = () => (
    <Image
      width={24}
      height={24}
      alt="Status"
      align="right"
      src={`/images/${account.is_login_invalid ? "alert" : "ok"}.png`}
    />
  );

  if (!account.is_login_invalid) {
    return <StatusImage />;
  }

  return (
    <Popover
      position="left"
      placement="end"
      trapFocus={false}
      opened={popoverVisible}
      width={280}
      withArrow
      onClose={() => setPopoverVisible(false)}
      target={
        <ActionIcon
          onClick={() => {
            setPopoverVisible(true);
          }}
        >
          <StatusImage />
        </ActionIcon>
      }
    >
      The connection with {account.institution} is invalid
      <br />
      <PlaidLinkButton
        products={undefined}
        access_token={account.access_token}
        text="Reconnect my account"
      />
    </Popover>
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
