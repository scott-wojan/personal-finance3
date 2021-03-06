import dayjs from "dayjs";
import numeral from "numeral";

export function getFormattedCurrency(val) {
  const value = val === -0 ? 0 : val;

  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(value);
}

export function getShortCurrency(val) {
  return numeral(val).format("$0a");
}

export function getFormattedDate(val) {
  return dayjs(val).format("MMM DD YYYY");
}

export function groupBy(objectArray, property) {
  if (!objectArray || !Array.isArray(objectArray)) {
    return [];
  }
  return objectArray.reduce((acc, obj) => {
    const key = obj[property];
    if (!acc[key]) {
      acc[key] = [];
    }
    // Add object to list for given key's value
    acc[key].push(obj);
    return acc;
  }, {});
}
