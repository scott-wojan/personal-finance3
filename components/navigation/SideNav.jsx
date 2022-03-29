import { createStyles, Navbar, ScrollArea } from "@mantine/core";
import { useRouter } from "next/router";
import React, { useState } from "react";
import {
  BellRinging,
  BuildingBank,
  DatabaseImport,
  Fingerprint,
  Home2,
  Key,
  Logout,
  Receipt2,
  Settings,
  TwoFA,
  Wallet,
} from "tabler-icons-react";

const useStyles = createStyles((theme, _params, getRef) => {
  const icon = getRef("icon");

  return {
    link: {
      ...theme.fn.focusStyles(),
      display: "flex",
      alignItems: "center",
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
        backgroundColor:
          theme.colorScheme === "dark"
            ? theme.colors.dark[7]
            : theme.colors.gray[0],
        color: theme.colorScheme === "dark" ? theme.white : theme.black,

        [`& .${icon}`]: {
          color: theme.colorScheme === "dark" ? theme.white : theme.black,
        },
      },
    },

    linkIcon: {
      ref: icon,
      color:
        theme.colorScheme === "dark"
          ? theme.colors.dark[2]
          : theme.colors.gray[6],
      marginRight: theme.spacing.sm,
    },

    linkActive: {
      "&, &:hover": {
        backgroundColor:
          theme.colorScheme === "dark"
            ? theme.fn.rgba(theme.colors[theme.primaryColor][9], 0.25)
            : theme.colors[theme.primaryColor][0],
        color:
          theme.colors[theme.primaryColor][
            theme.colorScheme === "dark" ? 4 : 7
          ],
        [`& .${icon}`]: {
          color:
            theme.colors[theme.primaryColor][
              theme.colorScheme === "dark" ? 4 : 7
            ],
        },
      },
    },
  };
});

const navLinks = [
  { link: "/", label: "Home", icon: Home2 },
  { link: "/accounts", label: "Accounts", icon: BuildingBank },
  { link: "/transactions", label: "Transactions", icon: Receipt2 },
  { link: "/budget", label: "Budget", icon: Wallet },
  { link: "/notifications", label: "Notifications", icon: BellRinging },
];

export default function SideNav({ opened }) {
  const { classes, cx } = useStyles();
  const [active, setActive] = useState();
  const router = useRouter();
  const links = navLinks.map((item) => (
    <a
      className={cx(classes.link, {
        [classes.linkActive]: item.link.startsWith(router.pathname),
      })}
      href={`${item.link}`}
      key={item.label}
      onClick={(event) => {
        // setActive(item.label);
      }}
    >
      <item.icon className={classes.linkIcon} />
      <span>{item.label}</span>
    </a>
  ));

  return (
    <Navbar
      p="md"
      hiddenBreakpoint="sm"
      hidden={!opened}
      width={{ sm: 200, lg: 300 }}
    >
      <Navbar.Section grow component={ScrollArea} mx="-xs" px="xs">
        {links}
      </Navbar.Section>
      <Navbar.Section>
        <a href="/signout" className={classes.link}>
          <Logout className={classes.linkIcon} />
          <span>Logout</span>
        </a>
      </Navbar.Section>
    </Navbar>
  );
}
