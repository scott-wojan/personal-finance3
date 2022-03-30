import React, { useEffect, useState } from "react";
import { createStyles, Select } from "@mantine/core";

export function CategoriesDropdown({
  size = "xs",
  onChange,
  value,
  label = undefined,
}) {
  //TODO: get from URL
  const categories = [
    {
      label: "Auto & Transportation",
      value: "1",
    },
    {
      label: "Bank",
      value: "Bank",
    },
    {
      label: "Cash",
      value: "Cash",
      options: [{ label: "Cash/ATM", value: "Cash/ATM" }],
    },
    {
      label: "Credit Card",
      value: "Credit Card",
      options: [{ label: "Payment", value: "Payment" }],
    },
    {
      label: "Education",
      value: "Education",
      options: [{ label: "Tuition", value: "Tuition" }],
    },
    {
      label: "Entertainment",
      value: "Entertainment",
      options: [
        { label: "Movies", value: "Movies" },
        { label: "Other", value: "Other" },
        { label: "Sports", value: "Sports" },
      ],
    },
    {
      label: "Fitness",
      value: "Fitness",
      options: [{ label: "Gym", value: "Gym" }],
    },
    {
      label: "Food & Dining",
      value: "Food & Dining",
      options: [
        { label: "Dining Out", value: "Dining Out" },
        { label: "Groceries", value: "Groceries" },
      ],
    },
    {
      label: "Gifts & Donations",
      value: "Gifts & Donations",
      options: [{ label: "Gifts", value: "Gifts" }],
    },
    {
      label: "Government",
      value: "Government",
      options: [
        { label: "Federal Tax", value: "Federal Tax" },
        { label: "Legal", value: "Legal" },
        { label: "Property Tax", value: "Property Tax" },
      ],
    },
    {
      label: "Healthcare",
      value: "Healthcare",
      options: [
        { label: "Doctor", value: "Doctor" },
        { label: "Equipment", value: "Equipment" },
        { label: "Pharmacy", value: "Pharmacy" },
        { label: "Reimbursement", value: "Reimbursement" },
      ],
    },
    {
      label: "Hobbies",
      value: "Hobbies",
      options: [
        { label: "Guitar", value: "Guitar" },
        { label: "Software", value: "Software" },
      ],
    },
    {
      label: "Home",
      value: "Home",
      options: [
        { label: "Furnishings & Décor", value: "Furnishings & Décor" },
        { label: "Home Improvement", value: "Home Improvement" },
        { label: "Lawn Care", value: "Lawn Care" },
        { label: "Mortgage", value: "Mortgage" },
        { label: "Property Tax", value: "Property Tax" },
        { label: "Security", value: "Security" },
      ],
    },
    {
      label: "Income",
      value: "Income",
      options: [
        { label: "Credit Card Reward", value: "Credit Card Reward" },
        { label: "Interest", value: "Interest" },
        { label: "Salary", value: "Salary" },
      ],
    },
    {
      label: "Insurance",
      value: "Insurance",
      options: [{ label: "Life Insurance", value: "Life Insurance" }],
    },
    {
      label: "Investment",
      value: "Investment",
      options: [
        { label: "Expense", value: "Expense" },
        { label: "Income", value: "Income" },
      ],
    },
    {
      label: "Other",
      value: "Other",
      options: [
        { label: "General", value: "General" },
        { label: "Shipping", value: "Shipping" },
      ],
    },
    {
      label: "Personal Care",
      value: "Personal Care",
      options: [
        { label: "Hair", value: "Hair" },
        { label: "Spa & Massage", value: "Spa & Massage" },
      ],
    },
    {
      label: "Pets",
      value: "Pets",
      options: [
        { label: "Healthcare", value: "Healthcare" },
        { label: "Pet Food", value: "Pet Food" },
      ],
    },
    {
      label: "Phone",
      value: "Phone",
      options: [{ label: "Cell Phone", value: "Cell Phone" }],
    },
    {
      label: "Pool",
      value: "Pool",
      options: [{ label: "Supplies", value: "Supplies" }],
    },
    {
      label: "Shopping",
      value: "Shopping",
      options: [
        { label: "Clothing", value: "Clothing" },
        { label: "Online Purchase", value: "Online Purchase" },
      ],
    },
    {
      label: "Subscription",
      value: "Subscription",
      options: [
        { label: "Magazine", value: "Magazine" },
        { label: "Music", value: "Music" },
      ],
    },
    {
      label: "Television",
      value: "Television",
      options: [{ label: "Streaming", value: "Streaming" }],
    },
    {
      label: "Travel",
      value: "Travel",
      options: [
        { label: "Activities", value: "Activities" },
        { label: "Airfare", value: "Airfare" },
        { label: "Cash/ATM", value: "Cash/ATM" },
        { label: "Cruise", value: "Cruise" },
        { label: "Hotel", value: "Hotel" },
        { label: "Internet", value: "Internet" },
        { label: "Pet Boarding", value: "Pet Boarding" },
        { label: "Taxi", value: "Taxi" },
      ],
    },
    {
      label: "Utilities",
      value: "Utilities",
      options: [
        { label: "City Services", value: "City Services" },
        { label: "Gas & Electric", value: "Gas & Electric" },
      ],
    },
    {
      label: "Wedding",
      value: "Wedding",
      options: [
        { label: "Ceremony", value: "Ceremony" },
        { label: "Licence", value: "Licence" },
        { label: "Ring", value: "Ring" },
        { label: "Services", value: "Services" },
      ],
    },
  ];

  const [selectedValue, setSelectedValue] = useState(value);

  useEffect(() => {
    setSelectedValue(value);
  }, [value]);

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
      "&.mantine-Select-root  button": {
        color: "black !important",
      },
    },
  }));

  const { classes, cx } = useStyles();

  return (
    <Select
      className={cx(classes.select)}
      // onFocus={(event) => {
      //   event.target.select();
      //   console.log("Focus");
      // }}
      value={selectedValue}
      // @ts-ignore
      size={size}
      data={categories}
      // withinPortal={true}
      label={label}
      placeholder="Category"
      nothingFound="Nothing found"
      getCreateLabel={(query) => `+ Create ${query}`}
      onChange={handleOnChange}
      onCreate={handleCreate}
      searchable
      creatable
      clearable
      // maxDropdownHeight={280}
      dropdownComponent="div"
      // rightSection={<ChevronDown size={14} color={theme.colors.gray[7]} />}
      // rightSectionWidth={30}
    />
  );
}
