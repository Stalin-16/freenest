const serviceRouter = require("./admin/serviceProfileRoutes");
const authRouter = require("./authRouter");

const registerRoutes = (app) => {
  app.use("/api/v1/auth", authRouter);
  app.use("/api/v1/admin", serviceRouter);
};

module.exports = registerRoutes;
