import React, { useEffect, useRef, useState } from "react";
import { createStyles, Select } from "@mantine/core";
import axios from "axios";

export function CategoriesSelect({
  size = "xs",
  onChange,
  value,
  label = undefined,
}) {
  const [selectedValue, setSelectedValue] = useState(value);
  const [error, setError] = useState();
  const [options, setOptions] = useState([{ value: value, label: value }]);
  const ref = useRef();

  useEffect(() => {
    setSelectedValue(value);
  }, [value]);

  const onFocus = async () => {
    const res = await axios.post("api/select-options/categories");
    setOptions(res.data);
  };

  const handleOnChange = (newSelectedValue) => {
    setError(null);
    setSelectedValue(newSelectedValue);
    onChange?.(newSelectedValue);
  };

  const handleCreate = (newValue) => {
    setSelectedValue(newValue);
    setSelectedValue(newValue);

    setOptions(prevState => {
      // Object.assign would also work
      const newState = [...prevState, ...[{ value: newValue, label: newValue }]];
      return newState;
    }); 
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
        error={error}
        autoComplete="off"
        ref={ref}
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
        onBlur={() => {
          if (selectedValue === null) {
            setError(true);
            if(!ref?.current?.placeholder.includes(" is required")){
              ref?.current?.placeholder = ref?.current?.placeholder + " is required";
            }
          }
        }}
        // maxDropdownHeight={280}
        dropdownComponent="div"
        // rightSection={<ChevronDown size={14} color={theme.colors.gray[7]} />}
        // rightSectionWidth={30}
      />
    </>
  );
}
