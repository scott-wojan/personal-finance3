import moment from "moment";
import numeral from "numeral";

export function getFormattedCurrency(val) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(val);
}

export function getShortCurrency(val) {
  return numeral(val).format("$0a");
}

export function getFormattedDate(val) {
  return moment(val).format("MMM DD YYYY");
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
