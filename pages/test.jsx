import React from "react";
import { RuleEditor } from "components/transactions/RuleEditor";

// const sampleData = {
//   set: [
//     {
//       name: "name",
//       value: "Amazon",
//     },
//     {
//       name: "category",
//       value: "Food and Drink",
//     },
//     {
//       name: "subcategory",
//       value: "Restaurants",
//     },
//   ],
//   where: [
//     {
//       name: "name",
//       value: "AMAZON.COM",
//       condition: "starts with",
//     },
//   ],
// };

const sampleData = {
  id: "AMRqdnzoPDh6YN4NJYDKTgLz7RXYXOHB5xRV3",
  account: "VentureOne",
  date: "2022-04-14",
  name: "NTTA AUTOCHARGE",
  amount: 40,
  category: "Travel",
  subcategory: "Tolls and Fees",
  iso_currency_code: "USD",
  is_pending: false,
  index: 0,
};

export default function Test() {
  return (
    <RuleEditor
      data={sampleData}
      onCancel={() => {
        console.log("CANCELED");
      }}
      onSave={(rule) => {
        console.log(rule);
      }}
    />
  );
}
