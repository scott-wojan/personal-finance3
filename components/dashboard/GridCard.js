import { Paper } from "@mantine/core";
import React from "react";

export function GridCard({ children, flex = 1 }) {
  return (
    <Paper shadow="xs" pl="md" pr="md" style={{ flex }}>
      {children}
    </Paper>
  );
}
