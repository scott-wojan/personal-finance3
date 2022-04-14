export function preventSqlInjection(handler) {
  return async (req, res) => {
    const method = req.method.toLowerCase();

    // check handler supports HTTP method
    if (!handler[method]) {
      return res.status(405).end(`Method ${req.method} Not Allowed`);
    }

    try {
      // global middleware
      //await jwtMiddleware(req, res);
      if (hasSql(JSON.stringify(req.body))) {
        return res.status(400).end();
      }

      // route handler
      await handler[method](req, res);
    } catch (err) {
      // global error handler
      res.status(500).json(err);
    }
  };
}

function hasSql(value) {
  if (value === null || value === undefined) {
    return false;
  }
  value = value.toLowerCase();

  if (
    (value.includes("select") || value.includes("drop")) &&
    (value.includes("from") ||
      value.includes("table") ||
      value.includes("view") ||
      value.includes("function"))
  ) {
    return true; //TODO: Need to make stronger!!!
  }

  // sql regex reference: http://www.symantec.com/connect/articles/detection-sql-injection-and-cross-site-scripting-attacks
  var sql_meta = new RegExp("(%27)|(')|(--)|(%23)|(#)", "i");
  if (sql_meta.test(value)) {
    return true;
  }

  var sql_meta2 = new RegExp(
    "((%3D)|(=))[^\n]*((%27)|(')|(--)|(%3B)|(;))",
    "i"
  );
  if (sql_meta2.test(value)) {
    return true;
  }

  var sql_typical = new RegExp(
    "w*((%27)|('))((%6F)|o|(%4F))((%72)|r|(%52))",
    "i"
  );
  if (sql_typical.test(value)) {
    return true;
  }

  var sql_union = new RegExp("((%27)|('))union", "i");
  if (sql_union.test(value)) {
    return true;
  }

  return false;
}
