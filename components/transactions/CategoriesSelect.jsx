import React, { useEffect, useState } from "react";
import { createStyles, Select } from "@mantine/core";
import axios from "axios";

export function CategoriesSelect({
  onChange,
  value,
  size = "xs",
  label = undefined,
}) {
  const [selectedValue, setSelectedValue] = useState(value);
  const [options, setOptions] = useState([{ value: value, label: value }]);

  useEffect(() => {
    setSelectedValue(value);
  }, [value]);

  const onFocus = async () => {
    const res = await axios.post("api/select-options/categories");
    setOptions(res.data);
  };

  const onCreate = (newValue) => {
    //TODO: save to URL
  };

  const handleOnChange = (newSelectedValue) => {
    setSelectedValue(newSelectedValue);
    onChange?.(newSelectedValue);
  };

  const handleCreate = (newValue) => {
    setSelectedValue(newValue);
    onCreate(newValue);
  };

  const useStyles = createStyles((theme) => ({
    select: {
      "&.mantine-Select-root button": {
        color: "black !important",
      },
    },
  }));

  const { classes, cx } = useStyles();

  // if (error) {
  //   return <div>ERROR... {error.message}</div>;
  // }

  return (
    <>
      <Select
        autoComplete="off"
        className={cx(classes.select)}
        // disabled={isLoading || error}
        value={selectedValue}
        // @ts-ignore
        size={size}
        data={options}
        // withinPortal={true}
        label={label}
        placeholder="Category"
        nothingFound="Nothing found"
        getCreateLabel={(query) => `+ Create ${query}`}
        onChange={handleOnChange}
        onCreate={handleCreate}
        onFocus={onFocus}
        searchable
        creatable
        clearable
        // maxDropdownHeight={280}
        dropdownComponent="div"
        // rightSection={<ChevronDown size={14} color={theme.colors.gray[7]} />}
        // rightSectionWidth={30}
      />
    </>
  );
}
