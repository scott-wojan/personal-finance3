import React from "react";
import useFormattedValueState from "../hooks/useFormattedValueState";

export function DefaultCellRenderer({ value, formatting, align = undefined }) {
  const [formattedValue] = useFormattedValueState({
    value,
    formatting,
  });

  return (
    <div style={{ whiteSpace: "nowrap", textAlign: align }}>
      {formattedValue?.toString()}
    </div>
  );
}
