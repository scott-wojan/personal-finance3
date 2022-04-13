import { TextInput } from "@mantine/core";
import React, { useEffect, useState } from "react";

// @ts-ignore
const EditableTextInput = React.forwardRef((props, ref) => {
  const {
    // @ts-ignore
    value,
    // @ts-ignore
    formatting = undefined,
    // @ts-ignore
    onChange = undefined,
    // @ts-ignore
    disabled = false,
    // @ts-ignore
    autoComplete = false,
  } = props;
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
      autoComplete={!autoComplete ? "off" : "on"}
      ref={ref}
      value={textValue}
      size="xs"
      onChange={onInputChange}
      disabled={disabled}
    />
  );
});

EditableTextInput.displayName = "EditableTextInput";

export { EditableTextInput };
