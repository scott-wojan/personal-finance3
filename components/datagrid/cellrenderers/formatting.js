import dayjs from "dayjs";

function formatCurrency(val, { currencyCode }) {
  if (!navigator) {
    throw new Error("Unable to access window.navigator to determine language");
  }

  const formattedAmount = new Intl.NumberFormat(navigator.language, {
    style: "currency",
    currency: currencyCode,
  }).format(val);

  return formattedAmount;
}

function formatDate(val, settings) {
  if (settings) {
    return dayjs(val).format(settings.format);
  }
  if (!navigator) {
    throw new Error("Unable to access window.navigator to determine language");
  }

  try {
    const date = new Date(val);
    return date?.toLocaleString(navigator.language, {
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
    });
  } catch (error) {
    throw new Error("Unable to convert to date value");
  }
}

const formatters = new Map([
  ["currency", formatCurrency],
  ["date", formatDate],
  // ["select", EditableSelect],
  // ["date", EditableDate],
]);

function format(type, value, settings) {
  const formatter = formatters.get(type);
  if (!formatter) {
    console.log(`No formatter for ${type}`, value);
    return value;
  }
  return formatter(value, settings);
}

const formattingHandler = {
  get: function (target, prop, receiver) {
    if (prop === "settings") {
      const settings = Object.keys(target.settings).map((propertyName) => {
        const propertyValue = target.settings[propertyName];
        if (typeof propertyValue === "function") {
          return {
            [propertyName]: propertyValue(target.data),
          };
        }
        return {
          [propertyName]: propertyValue,
        };
      })?.[0];

      return settings;
    }
    1;
    // @ts-ignore
    return Reflect.get(...arguments);
  },
};

export { formatCurrency, formatDate, format, formattingHandler, formatters };
