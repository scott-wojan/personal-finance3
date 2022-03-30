import React, { useState } from "react";
import { ActionIcon } from "@mantine/core";
import { ChevronRight, ChevronDown } from "tabler-icons-react";

export function RowExpandCollapse({ expanded = false, onChange }) {
  const [isExpanded, setIsExpanded] = useState(expanded);
  return (
    <ActionIcon
      onClick={() => {
        const newVal = !isExpanded;
        setIsExpanded(newVal);
        onChange?.(newVal);
      }}
    >
      {isExpanded ? <ChevronDown size={18} /> : <ChevronRight size={18} />}
    </ActionIcon>
  );
}
