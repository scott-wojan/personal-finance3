import { Grid, Paper } from "@mantine/core";
import React from "react";

export function ResponsiveGrid({ columns = undefined, children }) {
  if (!children) return null;
  const components = Array.isArray(children) ? children : [children];
  const numberOfChildren = React.Children.count(children) ?? 0;
  const largeCloumnSize = columns ? 12 / columns : 12 / numberOfChildren ?? 1;

  return (
    <Grid>
      {components.map((child, index) => {
        return (
          <Grid.Col key={index} md={12} lg={largeCloumnSize}>
            <>{child}</>
          </Grid.Col>
        );
      })}
    </Grid>
  );
}
