import {
  createStyles,
  Group,
  Navbar,
  Stack,
  Tooltip,
  UnstyledButton,
  useMantineTheme,
} from "@mantine/core";
import React, { useState } from "react";

import { Bolt, ListSearch, Notes, History } from "tabler-icons-react";

export function TransactionDetailMenu() {
  const theme = useMantineTheme();
  const [active, setActive] = useState(0);

  const linkData = [
    { Icon: ListSearch, label: "Details" },
    { Icon: Notes, label: "Notes" },
    { Icon: Bolt, label: "Rules" },
    { Icon: History, label: "History" },
  ];

  const links = linkData.map((link, index) => (
    <NavbarLink
      height={22}
      width={22}
      {...link}
      key={index}
      active={index === active}
      onClick={() => setActive(index)}
    />
  ));

  return (
    <Stack spacing="xs" pt="sm" pl="xs">
      {links}
    </Stack>
    // <Navbar height="100%" width={{ base: 50 }} p="xs" style={{}}>
    //   <Navbar.Section grow>
    //     <Group direction="column" align="center" spacing={0}>
    //       {links}
    //     </Group>
    //   </Navbar.Section>
    // </Navbar>
  );
}

function NavbarLink({ Icon, label, active, onClick, width = 50, height = 50 }) {
  const useStyles = createStyles((theme) => ({
    link: {
      width: width,
      height: height,
      borderRadius: theme.radius.xs,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      color:
        theme.colorScheme === "dark"
          ? theme.colors.dark[0]
          : theme.colors.gray[7],

      "&:hover": {
        backgroundColor:
          theme.colorScheme === "dark"
            ? theme.colors.dark[5]
            : theme.colors.gray[0],
      },
    },

    active: {
      "&, &:hover": {
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
  }));
  const { classes, cx } = useStyles();
  return (
    <Tooltip label={label} position="right" withArrow transitionDuration={0}>
      <UnstyledButton
        onClick={onClick}
        className={cx(classes.link, { [classes.active]: active })}
      >
        <Icon size={20} strokeWidth={1.5} />
      </UnstyledButton>
    </Tooltip>
  );
}
