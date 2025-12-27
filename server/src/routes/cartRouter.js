const express = require("express");
const cartRouter = express.Router();
const cartController = require("../controllers/cartService");
const { authenticateToken } = require("../middleware/auth");

cartRouter.post("/add", authenticateToken, cartController.addToCart);
cartRouter.get("/get", authenticateToken, cartController.getCart);
cartRouter.post("/update", authenticateToken, cartController.updateQuantity);
cartRouter.post("/remove", authenticateToken, cartController.removeFromCart);
cartRouter.post("/checkout", authenticateToken, cartController.checkout);
cartRouter.post("/sync", authenticateToken, cartController.syncCart);
cartRouter.post(
  "/apply-referral",
  authenticateToken,
  cartController.applyReferralCode
);

module.exports = cartRouter;
