const express = require("express");
const orderRouter = express.Router();
const orderController = require("../controllers/orderService");
const { authenticateToken } = require("../middleware/auth");

orderRouter.get("/get-all-orders",authenticateToken, orderController.getOrderDetails);

module.exports = orderRouter;