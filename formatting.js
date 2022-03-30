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

const groupBy = (key) => (array) =>
  array.reduce(
    (objectsByKeyValue, obj) => ({
      ...objectsByKeyValue,
      [obj[key]]: (objectsByKeyValue[obj[key]] || []).concat(obj),
    }),
    {}
  );
export { groupBy };
