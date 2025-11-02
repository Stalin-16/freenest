const express = require("express");
const cartRouter = express.Router();
const cartController = require("../controllers/cartService");
const { authenticateToken } = require("../middleware/auth");

cartRouter.post("/add",authenticateToken, cartController.addToCart);
cartRouter.get("/get",authenticateToken, cartController.getCart);
cartRouter.post("/update", cartController.updateQuantity);
cartRouter.post("/remove", cartController.removeFromCart);
cartRouter.post("/checkout",authenticateToken, cartController.checkout);
cartRouter.post("/sync",authenticateToken,cartController.syncCart);

module.exports = cartRouter;
