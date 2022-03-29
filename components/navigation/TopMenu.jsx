import React, { useState } from "react";
import {
  createStyles,
  Header,
  Group,
  Burger,
  Avatar,
  MediaQuery,
  useMantineTheme,
  Button,
} from "@mantine/core";

const HEADER_HEIGHT = 50;

const useStyles = createStyles((theme) => ({
  root: {
    position: "relative",
    zIndex: 1,
  },

  dropdown: {
    position: "absolute",
    top: HEADER_HEIGHT,
    left: 0,
    right: 0,
    zIndex: 0,
    borderTopRightRadius: 0,
    borderTopLeftRadius: 0,
    borderTopWidth: 0,
    overflow: "hidden",

    [theme.fn.largerThan("sm")]: {
      display: "none",
    },
  },

  header: {
    display: "flex",
    justifyContent: "space-between",
    alignItems: "center",
    height: "100%",
    paddingLeft: theme.spacing.xs,
    paddingRight: theme.spacing.xs,
  },

  links: {
    [theme.fn.smallerThan("sm")]: {
      display: "none",
    },
  },

  burger: {
    [theme.fn.largerThan("sm")]: {
      display: "none",
    },
  },

  link: {
    display: "block",
    lineHeight: 1,
    padding: "8px 12px",
    borderRadius: theme.radius.sm,
    textDecoration: "none",
    color:
      theme.colorScheme === "dark"
        ? theme.colors.dark[0]
        : theme.colors.gray[7],
    fontSize: theme.fontSizes.sm,
    fontWeight: 500,

    "&:hover": {
      backgroundColor:
        theme.colorScheme === "dark"
          ? theme.colors.dark[6]
          : theme.colors.gray[0],
    },

    [theme.fn.smallerThan("sm")]: {
      borderRadius: 0,
      padding: theme.spacing.md,
    },
  },

  linkActive: {
    "&, &:hover": {
      backgroundColor:
        theme.colorScheme === "dark"
          ? theme.fn.rgba(theme.colors[theme.primaryColor][9], 0.25)
          : theme.colors[theme.primaryColor][0],
      color:
        theme.colors[theme.primaryColor][theme.colorScheme === "dark" ? 3 : 7],
    },
  },
}));

const links = [
  {
    link: "/about",
    label: "Features",
  },
  {
    link: "/pricing",
    label: "Pricing",
  },
  {
    link: "/learn",
    label: "Learn",
  },
  {
    link: "/community",
    label: "Community",
  },
];

export function TopNav({ opened, setOpened }) {
  const [active, setActive] = useState(links[0].link);
  const items = links.map((link) => (
    <Button
      variant="subtle"
      key={link.label}
      onClick={(event) => {
        event.preventDefault();
        setActive(link.link);
        setOpened(false);
      }}
    >
      {link.label}
    </Button>
  ));

  const theme = useMantineTheme();
  return (
    <Header height={70} p="md">
      <div
        style={{
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
          height: "100%",
          paddingLeft: theme.spacing.xs,
          paddingRight: theme.spacing.xs,
        }}
      >
        <img src="/logo.svg" alt="Logo" />
        <MediaQuery smallerThan="md" styles={{ display: "none" }}>
          <Group spacing={5}>
            {items}
            <Avatar radius="xl" />
          </Group>
        </MediaQuery>
        <MediaQuery largerThan="sm" styles={{ display: "none" }}>
          <Burger
            opened={opened}
            onClick={() => setOpened((o) => !o)}
            size="sm"
            color={theme.colors.gray[6]}
            mr="xl"
          />
        </MediaQuery>
      </div>
    </Header>
  );
}

// export function TopMenu() {
//   const [opened, toggleOpened] = useBooleanToggle(false);
//   const [active, setActive] = useState(links[0].link);
//   const { classes, cx } = useStyles();

//   const items = links.map((link) => (
//     <a
//       key={link.label}
//       href={link.link}
//       className={cx(classes.link, {
//         [classes.linkActive]: active === link.link,
//       })}
//       onClick={(event) => {
//         event.preventDefault();
//         setActive(link.link);
//         toggleOpened(false);
//       }}
//     >
//       {link.label}
//     </a>
//   ));

//   return (
//     <Header height={HEADER_HEIGHT} className={classes.root}>
//       <div className={classes.header}>
//         <img src="/logo.svg" alt="Logo" />
//         <Group spacing={5} className={classes.links}>
//           {items}
//           <Avatar radius="xl" />
//         </Group>
//         <Burger
//           opened={opened}
//           onClick={() => toggleOpened()}
//           className={classes.burger}
//           size="sm"
//         />
//         <Transition transition="pop-top-right" duration={200} mounted={opened}>
//           {(styles) => (
//             <Paper className={classes.dropdown} withBorder style={styles}>
//               {items}
//             </Paper>
//           )}
//         </Transition>
//       </div>
//     </Header>
//   );
// }
