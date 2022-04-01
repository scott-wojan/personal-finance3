import React, {
  createContext,
  useCallback,
  useEffect,
  useReducer,
} from "react";
import { useState, useRef, useMemo, useContext } from "react";

const DataGridContext = createContext({
  selectedRow: undefined,
  setSelectedRow: undefined,
  rows: undefined,
  columns: undefined,
  getSubRow: undefined,
  onCellChange: undefined,
  onRowChange: undefined,
  pagination: undefined,
  setSort: undefined,
  setFilter: undefined,
  updateRow: undefined,
  // selectedColumnIndex: null,
  // setSelectedColumnIndex: null,
  // tableRef: null,
  tbodyRef: undefined,
  // expandedRowIndex: null,
  // setExpandedRowIndex: null,
});

export function DataGridProvider({
  rows,
  columns,
  getSubRow,
  pagination = paginationSettingsDefaults,
  onCellChange,
  onRowChange,
  onFilterAndSort,
  children,
}) {
  const [selectedRow, setSelectedRow] = useState(null);
  // const [selectedColumnIndex, setSelectedColumnIndex] = useState(0);
  // const [expandedRowIndex, setExpandedRowIndex] = useState(0);
  // const tableRef = useRef();
  const [filtersAndSorting, dispatch] = useReducer(gridReducer, gridDefaults);
  const tbodyRef = useRef(null);

  const updateRow = ({ rowIndex, propertyName, newValue }) => {
    rows[rowIndex][propertyName] = newValue;
  };

  const updateSelectedRow = useCallback(
    async (newRow) => {
      if (selectedRow?.index == newRow?.index) {
        return; //row didn't change
      }

      if (selectedRow && selectedRow.isDirty) {
        onRowChange?.({ row: selectedRow });
      }

      await setSelectedRow(newRow);
    },
    [onRowChange, selectedRow]
  );
  useEffect(() => {
    if (filtersAndSorting != gridDefaults) {
      onFilterAndSort?.(filtersAndSorting);
    }
  }, [filtersAndSorting, onFilterAndSort]);

  const updateSort = useCallback((name, direction) => {
    // @ts-ignore
    dispatch({ type: ON_SORT, payload: { name, direction } });
  }, []);

  const updateFilter = useCallback((name, values) => {
    const payload = formatPayload(name, values);
    if (name && !values) {
      // @ts-ignore
      dispatch({ type: ON_REMOVE_FILTER, payload });
      return;
    }
    // @ts-ignore
    dispatch({ type: ON_FILTER, payload });
  }, []);

  const memoedValue = useMemo(
    () => ({
      selectedRow,
      setSelectedRow: updateSelectedRow,
      rows,
      columns,
      getSubRow,
      onCellChange,
      onRowChange,
      pagination,
      setSort: updateSort,
      setFilter: updateFilter,
      updateRow,
      tbodyRef,
      // selectedColumnIndex,
      // setSelectedColumnIndex,
      // tableRef,
      // expandedRowIndex,
      // setExpandedRowIndex,
    }),
    [
      selectedRow,
      updateSelectedRow,
      rows,
      columns,
      getSubRow,
      onCellChange,
      onRowChange,
      pagination,
      updateSort,
      updateFilter,
    ]
  );

  return (
    <DataGridContext.Provider value={memoedValue}>
      {children}
    </DataGridContext.Provider>
  );
}

export function useDataGrid() {
  return useContext(DataGridContext);
}

function formatPayload(name, values) {
  if (!values) {
    return { name };
  }
  if (values?.length === 1) {
    return { name, value: values[0] };
  }
  return { name, values: [...values] };
}

const paginationSettingsDefaults = {
  pageSize: 10,
  page: 1,
};

function merge(a, b, prop) {
  var reduced = a.filter(function (aitem) {
    return !b.find(function (bitem) {
      return aitem[prop] === bitem[prop];
    });
  });
  return reduced.concat(b);
}

const gridDefaults = {
  filter: [],
  sort: [],
};

const ON_FILTER = "ON_FILTER";
const ON_SORT = "ON_SORT";
const ON_REMOVE_FILTER = "REMOVE_FILTER";

function gridReducer(state, { type, payload }) {
  switch (type) {
    case ON_FILTER:
      const newFilterValue = merge(state.filter, [payload], "name");
      // console.log("newFilterValue", newFilterValue);
      return {
        ...state,
        filter: newFilterValue,
      };
    case ON_REMOVE_FILTER:
      return {
        ...state,
        filter: state.filter.filter((o) => {
          return o.name !== payload.name;
        }),
      };
    case ON_SORT:
      const newSortValue = merge(state.sort, [payload], "name");
      // console.log("newSortValue", newSortValue);
      return {
        ...state,
        sort: newSortValue,
      };
    default:
      throw new Error(`Unhandled action type: ${type}`);
  }
}
