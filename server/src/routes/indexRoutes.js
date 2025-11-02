const serviceRouter = require("./admin/serviceProfileRoutes");
const authRouter = require("./authRouter");
const cartRouter = require("./cartRouter");
const orderRouter = require("./orderRouter");
const profileRouter = require("./profileRouter");

const registerRoutes = (app) => {
  app.use("/api/v1/auth", authRouter);
  app.use("/api/v1/admin", serviceRouter);
  app.use("/api/v1/customer", profileRouter);
  app.use("/api/v1/customer/cart", cartRouter);
  app.use("/api/v1/customer/order", orderRouter);
};

module.exports = registerRoutes;
