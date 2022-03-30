import { Checkbox, createStyles } from "@mantine/core";
import React, { useEffect, useState } from "react";
import { Check } from "tabler-icons-react";

export function EditableCheckbox({
  value = false,
  onChange = undefined,
  disabled = false,
  isEditing = false,
}) {
  const [isChecked, setIsChecked] = useState(value);

  const onInputChange = (e) => {
    const newValue = e.currentTarget.checked;
    onChange?.(newValue, isChecked);
    setIsChecked(newValue);
  };

  useEffect(() => {
    setIsChecked(value);
  }, [value]);

  const useStyles = createStyles((theme) => ({
    checkBox: {
      textAlign: "center",
      div: {
        display: "flex",
        justifyContent: "center",
      },
    },
  }));

  const { classes, cx } = useStyles();

  if (!isEditing) {
    return isChecked === true ? (
      <div className={cx(classes.checkBox)}>
        <Check />
      </div>
    ) : (
      <></>
    );
  }

  return (
    <div className={cx(classes.checkBox)}>
      <Checkbox
        checked={isChecked}
        // size="xs"
        // style={{ width: "100%" }}
        onChange={onInputChange}
        disabled={disabled}
      />
    </div>
  );
}
