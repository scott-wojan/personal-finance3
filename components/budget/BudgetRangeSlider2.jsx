import React from "react";
import Nouislider from "nouislider-react";
import "nouislider/distribute/nouislider.css";
import { getShortCurrency } from "formatting";
//https://refreshless.com/nouislider

const currencyFormater = {
  to: function (value) {
    return getShortCurrency(value);
  },
  // 'from' the formatted value.
  // Receives a string, should return a number.
  from: function (value) {
    return value;
  },
};

export default function BudgetRangeSlider2({ onChange }) {
  const onUpdate = (val) => {
    onChange?.(val?.[0], val?.[1]);
  };

  return (
    // @ts-ignore
    <Nouislider
      style={
        {
          // backgroundColor: "red",
        }
      }
      // clickablePips
      // pips={{
      //   mode: "steps",
      //   density: 10,
      //   format: currencyFormater,
      // }}
      pips={{
        mode: "values",
        density: 12,
        values: [0, 25, 75, 100],
        format: currencyFormater,
      }}
      tooltips={true}
      //tooltips={[currencyFormater, currencyFormater]}
      behaviour="tap-drag"
      range={{ min: 0, max: 100 }}
      // Handles start at ...
      start={[20, 80]}
      // Display colored bars between handles
      connect
      //force the slider to jump between the specified values
      //snap={true}
      //The amount the slider changes on movement
      // step={5}
      onUpdate={onUpdate}
      format={currencyFormater}
    />
  );
}
