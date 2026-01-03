const express = require("express");
const {
  getTransactionSummary,
  getBalance,
} = require("../controllers/creditsService");
const { authenticateToken } = require("../middleware/auth");
const { updateUser } = require("../controllers/authService");
const { saveDeviceToken } = require("../controllers/notificationService");
const creditsRouter = express.Router();

creditsRouter.use(authenticateToken);

creditsRouter.get("/get-transaction-summaries", getTransactionSummary);
creditsRouter.get("/balance", getBalance);
creditsRouter.put("/profile-customer", updateUser);

creditsRouter.post("/save-notification-token", saveDeviceToken);

module.exports = creditsRouter;
