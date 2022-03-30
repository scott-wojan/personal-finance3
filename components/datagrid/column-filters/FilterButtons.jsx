import { Button } from "@mantine/core";
import { SecondaryButton } from "components/Buttons";
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
      <SecondaryButton size="xs" variant="outline" onClick={onClearClicked}>
        Clear
      </SecondaryButton>
      <Button size="xs" onClick={onFilterClicked}>
        Filter
      </Button>
    </div>
  );
}
