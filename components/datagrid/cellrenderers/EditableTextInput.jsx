import { TextInput } from "@mantine/core";
import React, { useEffect, useState } from "react";

export function EditableTextInput({
  value,
  formatting = undefined,
  onChange = undefined,
  disabled = false,
}) {
  const [textValue, setTextValue] = useState(value);

  const onInputChange = (e) => {
    const newValue = e.target.value;
    onChange?.(newValue, textValue);
    setTextValue(newValue);
  };

  useEffect(() => {
    setTextValue(value);
  }, [value]);

  return (
    <TextInput
      value={textValue}
      size="xs"
      onChange={onInputChange}
      disabled={disabled}
    />
  );
}
