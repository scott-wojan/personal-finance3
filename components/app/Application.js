import React, { useState } from "react";
import {
  AppShell,
  Text,
  Center,
  MediaQuery,
  Aside,
  Footer,
} from "@mantine/core";
import { TopNav } from "components/navigation/TopMenu";
import SideNav from "components/navigation/SideNav";

function Application({ children, sidebar = undefined, centerContent = false }) {
  const [opened, setOpened] = useState(false);

  return (
    <AppShell
      styles={
        {
          // main: {
          //   background:
          //     theme.colorScheme === "dark"
          //       ? theme.colors.dark[8]
          //       : theme.colors.gray[0],
          // },
        }
      }
      navbarOffsetBreakpoint="sm"
      fixed
      header={<TopNav opened={opened} setOpened={setOpened} />}
      navbar={<SideNav opened={opened} />}
      aside={
        sidebar && (
          <MediaQuery smallerThan="sm" styles={{ display: "none" }}>
            <Aside p="md" hiddenBreakpoint="sm" width={{ sm: 200, lg: 300 }}>
              {sidebar}
            </Aside>
          </MediaQuery>
        )
      }
      footer={
        <Footer height={60} p="md">
          Application footer
        </Footer>
      }
    >
      {centerContent && <Center style={{ height: "100%" }}>{children}</Center>}
      {!centerContent && <>{children}</>}
    </AppShell>
  );
}

export { Application };
