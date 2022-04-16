import React from "react";
import {
  Group,
  TextInput,
  Text,
  Select,
  Accordion,
  Button,
} from "@mantine/core";
import { useSetState } from "@mantine/hooks";
import { CategoriesSelect } from "components/categories/CategoriesSelect";
import { SubCategoriesSelect } from "components/categories/SubCategoriesSelect";
import { useMutation } from "react-query";
import axios from "axios";

export function RuleEditor({ data, onCancel, onSaved }) {
  const initialState = {
    hasChanged: false,
    id: data?.where ? data?.id : null,
    name: data?.name ?? data?.where[0]?.value.replace("%", ""),
    condition: data?.where?.[0]?.condition ?? "equals",
    newName:
      data?.name ??
      data?.set.find((x) => {
        return x.name === "name";
      }).value,
    category:
      data?.category ??
      data?.set.find((x) => {
        return x.name === "category";
      })?.value,
    subcategory:
      data?.subcategory ??
      data?.set.find((x) => {
        return x.name === "subcategory";
      })?.value,
  };
  const [state, setState] = useSetState(initialState);

  const ruleMutation = useMutation((rule) => {
    return axios.post("api/rules/create", rule);
  });

  const onSave = () => {
    ruleMutation
      // @ts-ignore
      .mutateAsync(state)
      .then((x) => {
        console.log(x);
        onSaved?.();
      })
      .catch((err) => {
        console.log(err);
      });
  };

  return (
    <>
      <Group spacing="xs" pb={4}>
        <Text size="xs" weight={700}>
          When a transaction name
        </Text>
        <Select
          size="xs"
          value={state.condition}
          style={{ width: 110 }}
          data={["equals", "starts with", "contains", "ends with"]}
          onChange={(newValue) => {
            setState({ condition: newValue, hasChanged: true });
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
        onChange={(e) => {
          setState({ name: e.target.value, hasChanged: true });
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
        onChange={(e) => {
          setState({ newName: e.target.value, hasChanged: true });
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
              onChange={(newValue) => {
                setState({
                  category: newValue,
                  subcategory: undefined,
                  hasChanged: true,
                });
              }}
            />
            <SubCategoriesSelect
              style={{ width: "46%" }}
              category={state.category}
              value={state.subcategory ?? ""}
              onChange={(newValue) => {
                setState({ subcategory: newValue, hasChanged: true });
              }}
            />
          </Group>
        </Accordion.Item>
      </Accordion>
      <Group position="right">
        <Button variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button disabled={!state.hasChanged} onClick={onSave}>
          Save
        </Button>
      </Group>
    </>
  );
}
