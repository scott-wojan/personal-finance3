import moment from "moment";

export function getFormattedCurrency(val) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(val);
}

export function getFormattedDate(val) {
  return moment(val).format("MMM DD YYYY");
}
