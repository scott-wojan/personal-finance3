export function toJsonEscaped(obj) {
  return JSON.stringify(obj).replace(/[\/\(\)\']/g, "''");
}

export function toOrderBy(arr) {
  if (!arr || arr.length === 0) {
    return null;
  }

  const sortBy = arr.map((column) => {
    return `${column.name} ${column.direction}`;
  });

  if (sortBy == []) {
    return null;
  }

  return sortBy.join(", ");
}

export function toWhere(arr) {
  if (!arr || arr.length === 0) {
    return null;
  }

  const formatValue = (value) => {
    //Dates
    if (value instanceof Date) {
      return `'${value.toLocaleDateString("en-US")}'`;
    }
    //Numbers
    if (typeof value === "number") {
      return value;
    }
    //TEXT
    return `'${value}'`;
  };

  const getValues = (column) => {
    //Single value specified
    if (column.value) {
      return `${formatValue(column.value)}`;
    }

    if (!column.values || !Array.isArray(column.values) || !column.values[0]) {
      return `ERROR:toWhere`;
    }

    //Numbers and dates use between
    if (
      column.values[0] instanceof Date ||
      typeof column.values[0] === "number"
    ) {
      const between = column.values.map((val, index) => {
        return `${index > 0 ? "and" : ""} ${formatValue(val)}`;
      });

      return between.join(" ").trim();
    }

    return `(${column.values.map((val) => {
      return formatValue(val);
    })})`;
  };

  const getOperator = (column) => {
    // console.log("getOperator", column);
    if (column.values && Array.isArray(column.values) && column.values[0]) {
      if (
        column.values[0] instanceof Date ||
        typeof column.values[0] === "number"
      ) {
        return "between";
      }
      return "in";
    } else {
      return "=";
    }
  };

  return (
    " and " +
    arr
      .map((column) => {
        return `${column.name} ${getOperator(column)} ${getValues(column)}`;
      })
      .join(" and ")
  );
}
