import React from "react";
import {
  Popover,
  ActionIcon,
  Group,
  TextInput,
  Button,
  Tooltip,
  Text,
  Select,
  Accordion,
} from "@mantine/core";
import { useSetState } from "@mantine/hooks";
import { CategoriesSelect } from "components/categories/CategoriesSelect";
import { SubCategoriesSelect } from "components/categories/SubCategoriesSelect";

const sampleData = {
  set: [{ name: "name", value: "USAA Life Insurance", operator: "=" }],
  where: [{ name: "name", value: "USAA.COM PAY INT LIFE%", operator: "like" }],
  tablename: "transactions",
};
// const sampleData = {
//   name: "xxxx",
//   category: "Shops",
//   subcategory: "Hardware Store",
// };

export default function Test({ data = sampleData }) {
  const initialState = {
    hasChanged: false,
    name: data?.name ?? data?.where[0]?.value.replace("%", ""),
    operator: data?.where?.[0]?.operator ?? "=",
    newName: data?.name ?? data?.set[0]?.value,
    category: data?.category,
    subcategory: data?.subcategory,
  };
  // console.log("initialState", initialState);

  const [state, setState] = useSetState(initialState);

  return (
    <div
      style={{ width: 360, border: "1px solid black", margin: 40, padding: 10 }}
    >
      <Group spacing="xs" pb={4}>
        <Text size="xs" weight={700}>
          When a transaction name
        </Text>
        <Select
          size="xs"
          value={state.operator}
          style={{ width: 110 }}
          data={[
            { label: "Equals", value: "=" },
            { label: "Starts with", value: "like" },
            { label: "Contains", value: "like" },
            { label: "Ends with", value: "like" },
          ]}
          onChange={(newValue) => {
            setState({ operator: newValue, hasChanged: true });
          }}
          sx={(theme) => ({
            input: {
              height: 18,
              minHeight: 18,
            },
          })}
        />
      </Group>
      <TextInput
        placeholder="imported name"
        size="xs"
        pb="sm"
        value={state.name}
        onChange={(newValue) => {
          setState({ name: newValue, hasChanged: true });
        }}
      />

      <Text size="xs" weight={700} pb={4}>
        Rename to
      </Text>

      <TextInput
        placeholder="new name"
        size="xs"
        pb="sm"
        value={state.newName}
        onChange={(newValue) => {
          setState({ newName: newValue, hasChanged: true });
        }}
      />

      <Accordion
        iconPosition="right"
        initialItem={state.category ? 0 : -1}
        sx={(theme) => ({
          ".mantine-Accordion-label": {
            fontSize: theme.fontSizes.xs,
            fontWeight: 700,
          },
          ".mantine-Accordion-control, .mantine-Accordion-contentInner": {
            padding: 0,
          },
          ".mantine-Accordion-item": {
            borderBottom: 0,
          },
        })}
      >
        <Accordion.Item label="And categorize as">
          <Group pb="sm" position="apart" pt={4}>
            <CategoriesSelect
              style={{ width: "46%" }}
              value={state.category ?? ""}
              // onChange={onCategoryChange}
            />
            <SubCategoriesSelect
              style={{ width: "46%" }}
              category={state.category}
              value={state.subcategory ?? ""}

              // onChange={onSubCategoryChange}
            />
          </Group>
        </Accordion.Item>
      </Accordion>
    </div>
  );
}
