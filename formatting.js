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
