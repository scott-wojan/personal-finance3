import { format } from "../cellrenderers/formatting";

const { useState, useEffect } = require("react");

export default function useFormattedValueState({ value, formatting }) {
  const [unFormattedValue, setUnFormattedValue] = useState(value);
  const [formattedValue, setFormattedValue] = useState(value);

  useEffect(() => {
    setUnFormattedValue(value);
  }, [value]);

  useEffect(() => {
    if (formatting) {
      setFormattedValue(format(formatting.type, value, formatting.settings));
    } else {
      setFormattedValue(unFormattedValue);
    }
  }, [formatting, value, unFormattedValue]);

  return [
    formattedValue,
    setFormattedValue,
    unFormattedValue,
    setUnFormattedValue,
  ];
}
