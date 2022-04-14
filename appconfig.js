const application = {
  name: process.env.APP_NAME,
};

const database = {
  port: parseInt(process.env.DB_PORT),
  host: process.env.DB_HOST_NAME,
  username: process.env.POSTGRES_USER,
  password: process.env.POSTGRES_PASSWORD,
  name: process.env.DB_NAME,
};

const environment = {
  name: process.env.NODE_ENV,
  isDevelopment: process.env.NODE_ENV === "development",
  isProduction: process.env.NODE_ENV === "production",
};

const plaid = {
  clientId: process.env.CLIENT_ID,
  secret: process.env.SECRET,
  environment: process.env.PLAID_ENV,
  // sandboxRedirectUri: process.env.PLAID_SANDBOX_REDIRECT_URI,
  // developmentRedirectUri: process.env.PLAID_DEVELOPMENT_REDIRECT_URI,
  // productionRedirectUri: process.env.PLAID_PRODUCTION_REDIRECT_URI,
};

export { database, environment, plaid, application };
