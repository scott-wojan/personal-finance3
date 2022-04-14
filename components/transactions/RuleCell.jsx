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
import { CategoriesSelect } from "components/categories/CategoriesSelect";
import { SubCategoriesSelect } from "components/categories/SubCategoriesSelect";
import { useDataGrid } from "components/datagrid/DataGridContext";
import React, { useState } from "react";
import { Bolt } from "tabler-icons-react";

export function RuleCell({ row, onChange }) {
  const [popoverVisible, setPopoverVisible] = useState(false);
  const { rows, updateRow } = useDataGrid();
  const [state, setState] = useSetState({
    hasChanged: false,
    oldName: row.name,
    name: row.name,
    category: row.category,
    subcategory: row.subcategory,
    operator: "Equals",
  });

  const onOldNameChange = (newValue) => {
    setState({ oldName: newValue, hasChanged: true });
  };
  const onNameChange = (newValue) => {
    setState({ name: newValue, hasChanged: true });
  };
  const onCategoryChange = (newValue) => {
    setState({
      category: newValue,
      subcategory: undefined,
      hasChanged: true,
    });
  };
  const onSubCategoryChange = (newValue) => {
    setState({ subcategory: newValue, hasChanged: true });
  };
  const onOperatorChange = (newValue) => {
    setState({ operator: newValue, hasChanged: true });
  };

  return (
    <Popover
      position="bottom"
      placement="start"
      trapFocus={false}
      opened={popoverVisible}
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
      width={360}
      style={{ width: "100%" }}
      withArrow
      // onFocusCapture={() => setVisible(true)}
      // onBlurCapture={() => setVisible(false)}
    >
      <Text size="md" weight={700}>
        Create Rule?
      </Text>
      <Group>
        <Text size="xs" weight={700}>
          When name
        </Text>
        <Select
          size="xs"
          value={state.operator}
          style={{ width: 110 }}
          data={["Equals", "Starts with", "Contains", "Ends with"]}
          onChange={(newValue) => {
            onOperatorChange(newValue);
          }}
        />
      </Group>
      <Text size="xs" pb="sm">
        <TextInput
          placeholder="Original name"
          size="xs"
          pb="sm"
          value={state.oldName}
          onChange={(e) => {
            onOldNameChange(e.target.value);
          }}
        />
      </Text>

      <Text size="xs" weight={700}>
        Rename to
      </Text>
      <TextInput
        placeholder="New name"
        size="xs"
        pb="sm"
        value={state.name}
        onChange={(e) => {
          onNameChange(e.target.value);
        }}
      />
      <Text size="xs" weight={700}>
        And categorize as
      </Text>
      <Group pb="sm">
        <CategoriesSelect
          style={{ width: 154 }}
          value={state.category}
          onChange={onCategoryChange}
        />
        <SubCategoriesSelect
          style={{ width: 154 }}
          category={state.category}
          onChange={onSubCategoryChange}
          value={state.subcategory}
        />
      </Group>
      <Group position="right">
        <Button
          variant="outline"
          onClick={() => {
            setPopoverVisible(false);
          }}
        >
          Cancel
        </Button>
        <Button
          disabled={!state.hasChanged}
          onClick={() => {
            // updateRow({
            //   rowIndex: row.index,
            //   propertyName: "name",
            //   newValue: state.name,
            // });
            onChange?.();
            row.name = state.name;
          }}
        >
          Save
        </Button>
      </Group>
    </Popover>
  );
}
