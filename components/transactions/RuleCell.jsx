import {
  Popover,
  ActionIcon,
  Group,
  TextInput,
  Button,
  Tooltip,
  Text,
  Select,
} from "@mantine/core";
import { useSetState } from "@mantine/hooks";
import axios from "axios";
import { CategoriesSelect } from "components/categories/CategoriesSelect";
import { SubCategoriesSelect } from "components/categories/SubCategoriesSelect";
import React, { useState } from "react";
import { useMutation } from "react-query";
import { Bolt } from "tabler-icons-react";
import { RuleEditor } from "./RuleEditor";

export function RuleCell({ row, onChange }) {
  const [popoverVisible, setPopoverVisible] = useState(false);

  return (
    <Popover
      position="bottom"
      placement="end"
      trapFocus={false}
      opened={popoverVisible}
      width={360}
      withArrow
      onClose={() => setPopoverVisible(false)}
      target={
        <Tooltip
          width={120}
          wrapLines
          position="bottom"
          label="Create a rule for this data"
          withArrow
        >
          <ActionIcon
            onClick={() => {
              setPopoverVisible(true);
            }}
          >
            <Bolt size={16} />
          </ActionIcon>
        </Tooltip>
      }

      // onFocusCapture={() => setVisible(true)}
      // onBlurCapture={() => setVisible(false)}
    >
      <RuleEditor
        data={row}
        onCancel={() => {
          setPopoverVisible(false);
        }}
        onSaved={() => {
          setPopoverVisible(false);
        }}
      />
    </Popover>
  );
}
