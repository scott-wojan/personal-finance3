import { Button } from "@mantine/core";
import React from "react";

export default function FilterButtons({ onFilterClicked, onClearClicked }) {
  return (
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        paddingLeft: 12,
        paddingRight: 12,
      }}
    >
      <Button
        variant="default"
        size="xs"
        variant="outline"
        onClick={onClearClicked}
      >
        Clear
      </Button>
      <Button size="xs" onClick={onFilterClicked}>
        Filter
      </Button>
    </div>
  );
}
