import { PrimaryButton, SecondaryButton } from "components/Buttons";
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
      <PrimaryButton size="xs" onClick={onFilterClicked}>
        Filter
      </PrimaryButton>
    </div>
  );
}
