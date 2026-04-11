module.exports = {
  projectConfig: {
    jwtSecret: process.env.JWT_SECRET || "zerodast-ci-jwt-secret",
    cookieSecret: process.env.COOKIE_SECRET || "zerodast-ci-cookie-secret",
    database_url: process.env.DATABASE_URL || "postgres://medusa:medusa@postgres:5432/medusa",
    redis_url: process.env.REDIS_URL || "redis://redis:6379",
    store_cors: "http://localhost:8000",
    admin_cors: "http://localhost:7001",
  },
  plugins: [],
};
