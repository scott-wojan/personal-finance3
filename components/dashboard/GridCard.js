import { Paper } from "@mantine/core";
import React from "react";

export function GridCard({ children }) {
  return (
    <Paper shadow="xs" pl="md" pr="md" style={{ flex: 1 }}>
      {children}
    </Paper>
  );
}
