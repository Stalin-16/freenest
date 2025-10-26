const serviceRouter = require("./admin/serviceProfileRoutes");
const authRouter = require("./authRouter");
const profileRouter = require("./profileRouter");

const registerRoutes = (app) => {
  app.use("/api/v1/auth", authRouter);
  app.use("/api/v1/admin", serviceRouter);
  app.use("/api/v1/customer", profileRouter);
};

module.exports = registerRoutes;
