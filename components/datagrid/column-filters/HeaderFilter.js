import React, { useEffect, useState } from "react";
import { ActionIcon, Menu, useMantineTheme } from "@mantine/core";
import { ChevronDown, ChevronUp, Filter } from "tabler-icons-react";
import TextFilter from "./TextFilter";
import NumericRangeFilter from "./NumericRangeFilter";
import { DateRangeFilter } from "./DateRangeFilter";
import { SelectFilter } from "./SelectFilter";
import { Sort } from "./Sort";
import { useClickOutside } from "@mantine/hooks";

export function HeaderFilter({
  column,
  onSort = undefined,
  onFilter = undefined,
  isOpen: initialOpen = false,
}) {
  const [isOpen, setIsOpen] = useState(initialOpen);
  const [sortDirection, setSortDirection] = useState(undefined);
  const [filterValues, setFilterValues] = useState(undefined);
  const [backgroundColor, setBackgroundColor] = useState(undefined);
  const [filterComponentRef, setFilterComponentRef] = useState(null);
  const [isInUse, setIsInUse] = useState(false);
  const theme = useMantineTheme();

  const FilterComponent = filterComponents.get(column.dataType) ?? TextFilter;

  const ref = useClickOutside(() => setIsOpen(false), null, [
    filterComponentRef,
  ]);

  useEffect(() => {
    const inUse = filterValues || sortDirection != undefined;
    setBackgroundColor(inUse ? theme.colors.gray[3] : "");
    setIsInUse(inUse);
  }, [filterValues, sortDirection, theme.colors.gray]);

  const toggleShowMenu = () => {
    const showMenu = !isOpen;
    setIsOpen(showMenu);
    // showMenu ? onShow?.() : onHide?.();
  };

  const handleSort = (direction) => {
    setSortDirection(direction === sortDirection ? "" : direction);
    onSort?.(direction);
    setIsOpen(false);
  };

  function handleFilter() {
    setIsOpen(false);
    if (arguments && arguments[0] !== undefined) {
      onFilter?.(arguments);
      setFilterValues(arguments);
      return;
    }
    onFilter?.(undefined);
    setFilterValues(undefined);
    setSortDirection(undefined);
    onSort?.(undefined);
  }

  return (
    <>
      <Menu
        placement="end"
        closeOnItemClick={false}
        opened={isOpen}
        control={
          <ActionIcon style={{ backgroundColor }} onClick={toggleShowMenu}>
            {isInUse ? (
              <Filter size={18} />
            ) : isOpen ? (
              <ChevronUp size={18} />
            ) : (
              <ChevronDown size={18} />
            )}
          </ActionIcon>
        }
      >
        <Sort
          onSort={handleSort}
          sortDirection={sortDirection}
          column={column}
        />

        <FilterComponent
          // @ts-ignore
          column={column}
          setRef={setFilterComponentRef}
          onFilter={handleFilter}
          values={filterValues}
        />
      </Menu>
    </>
  );
}

const filterComponents = new Map([
  ["text", TextFilter],
  ["numeric", NumericRangeFilter],
  ["select", SelectFilter],
  ["date", DateRangeFilter],
]);
