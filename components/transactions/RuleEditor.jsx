import React, { useState } from "react";
import {
  Group,
  TextInput,
  Text,
  Select,
  Accordion,
  Button,
  ActionIcon,
  Tooltip,
} from "@mantine/core";
import { useSetState } from "@mantine/hooks";
import { CategoriesSelect } from "components/categories/CategoriesSelect";
import { SubCategoriesSelect } from "components/categories/SubCategoriesSelect";
import { useMutation } from "react-query";
import axios from "axios";
import { Edit, Trash } from "tabler-icons-react";

export function RuleEditor({
  data,
  onCancel,
  onSaved,
  mode: initialMode = "edit",
}) {
  const initialState = {
    hasChanged: false,
    id: data?.rule ? data?.id : null,
    name: data?.name ?? data?.rule?.where[0]?.value,
    condition: data?.rule?.where?.[0]?.condition ?? "equals",
    newName:
      data?.name ??
      data?.rule?.set.find((x) => {
        return x.name === "name";
      })?.value,
    category:
      data?.category ??
      data?.rule?.set.find((x) => {
        return x.name === "category";
      })?.value,
    subcategory:
      data?.subcategory ??
      data?.rule?.set.find((x) => {
        return x.name === "subcategory";
      })?.value,
  };

  const [state, setState] = useSetState(initialState);
  const [mode, setMode] = useState(initialMode);

  const ruleMutation = useMutation((rule) => {
    return axios.post("api/rules/manage", rule);
  });

  const handleOnCancel = () => {
    if (data?.rule) {
      setMode("display");
    }
    onCancel?.();
  };

  const handleOnSave = () => {
    console.log("state", state);
    ruleMutation
      // @ts-ignore
      .mutateAsync(state)
      .then((x) => {
        if (data?.rule) {
          setMode("display");
        }
        onSaved?.();
      })
      .catch((err) => {
        console.log(err);
      });
  };

  return (
    <>
      {mode !== "edit" && (
        <>
          <div style={{ display: "flex", flexDirection: "row" }}>
            <Text size="sm" pb={4} component="span">
              When a transaction name{" "}
              <Text size="sm" component="span" style={{ fontStyle: "italic" }}>
                {state.condition}
              </Text>
              <Text size="sm" component="span">
                "{state.name}"
              </Text>{" "}
              rename to "{state.newName}" and categorize as {state.category} /{" "}
              {state.subcategory}
            </Text>
            <div>
              <IconButton
                icon={Edit}
                tooltip="Edit"
                onClick={() => {
                  setMode("edit");
                }}
              />
              <IconButton icon={Trash} tooltip="Delete" />
            </div>
          </div>
        </>
      )}
      {mode === "edit" && (
        <>
          <Editor
            data={state}
            setState={setState}
            onSave={handleOnSave}
            onCancel={handleOnCancel}
          />
        </>
      )}
    </>
  );
}

function IconButton({ onClick, icon, tooltip }) {
  const Icon = icon;
  return (
    <Tooltip label={tooltip} position="left" withArrow disabled={!tooltip}>
      <ActionIcon onClick={onClick}>
        <Icon size={16} strokeWidth={1} />
      </ActionIcon>
    </Tooltip>
  );
}

function Editor({ data, setState, onSave, onCancel }) {
  return (
    <>
      <Group spacing="xs" pb={4}>
        <Text size="xs" weight={700}>
          When a transaction name
        </Text>
        <Select
          size="xs"
          value={data.condition}
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
        value={data.name}
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
        value={data.newName}
        onChange={(e) => {
          setState({ newName: e.target.value, hasChanged: true });
        }}
      />

      <Accordion
        iconPosition="right"
        initialItem={data.category ? 0 : -1}
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
              value={data.category ?? ""}
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
              category={data.category}
              value={data.subcategory ?? ""}
              onChange={(newValue) => {
                setState({ subcategory: newValue, hasChanged: true });
              }}
            />
          </Group>
        </Accordion.Item>
      </Accordion>
      <Group position="right">
        <Button size="xs" variant="outline" onClick={onCancel}>
          Cancel
        </Button>
        <Button size="xs" disabled={!data.hasChanged} onClick={onSave}>
          Save
        </Button>
      </Group>
    </>
  );
}
