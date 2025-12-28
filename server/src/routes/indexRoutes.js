const serviceRouter = require("./admin/serviceProfileRoutes");
const authRouter = require("./authRouter");
const cartRouter = require("./cartRouter");
const orderRouter = require("./orderRouter");
const profileRouter = require("./profileRouter");
const reviewRouter = require("./reviewRouter");
const freelanceRouter = require("./admin/freelancerRoutes");
const adminAuthRouter = require("./admin/adminAuthRouter");
const creditsRouter = require("./creditsRouter");
const registerRoutes = (app) => {
  app.use("/api/v1/auth", authRouter);
  app.use("/api/v1/admin", serviceRouter);
  app.use("/api/v1/admin/auth", adminAuthRouter);
  app.use("/api/v1/admin/freelancers", freelanceRouter);

  app.use("/api/v1/admin/order", orderRouter);
  app.use("/api/v1/customer", profileRouter);
  app.use("/api/v1/customer/credits", creditsRouter);
  app.use("/api/v1/customer/reviews", reviewRouter);
  app.use("/api/v1/customer/cart", cartRouter);
  app.use("/api/v1/customer/order", orderRouter);
};

module.exports = registerRoutes;
