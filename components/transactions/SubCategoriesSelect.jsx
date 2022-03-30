import React, { useEffect, useState } from "react";
import { createStyles, Select } from "@mantine/core";
import axios from "axios";

const SubCategoriesSelect = React.forwardRef((props, ref) => {
  const {
    // @ts-ignore
    size = "xs",
    // @ts-ignore
    onChange,
    // @ts-ignore
    onCreate,
    // @ts-ignore
    category,
    // @ts-ignore
    value,
    // @ts-ignore
    label = undefined,
  } = props;

  const [selectedValue, setSelectedValue] = useState(value);
  const [error, setError] = useState();
  const [options, setOptions] = useState([{ value: value, label: value }]);

  const onFocus = async () => {
    const res = await axios.post("api/select-options/subcategories", {
      category,
    });
    setOptions(res.data);
  };

  useEffect(() => {
    setSelectedValue(value);
  }, [value]);

  const handleOnChange = (newSelectedValue) => {
    setError(null);
    setSelectedValue(newSelectedValue);
    onChange?.(newSelectedValue);
  };

  const handleCreate = (newValue) => {
    //TODO: save to URL
    setSelectedValue(newValue);
    onCreate?.(newValue);
  };

  const useStyles = createStyles((theme) => ({
    select: {
      "&.mantine-Select-root  button": {
        color: "black !important",
      },
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <>
      <Select
        error={error}
        autoComplete="off"
        ref={ref}
        className={cx(classes.select)}
        onFocus={onFocus}
        value={selectedValue}
        size={size}
        data={options}
        // withinPortal={true}
        label={label}
        placeholder="Subcategory"
        nothingFound="Nothing found"
        getCreateLabel={(query) => `+ Create ${query}`}
        onChange={handleOnChange}
        onCreate={handleCreate}
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
});

SubCategoriesSelect.displayName = "SubCategoriesDropdown";

export { SubCategoriesSelect as SubCategoriesDropdown };
