const Router = require("express");
const authRouter = Router();
const authService = require("../controllers/authService");

authRouter.post("/send-otp", authService.sendOtp);
authRouter.post("/verify-otp", authService.verifyOtp);
authRouter.post("/google-login", authService.googleLogin);

module.exports = authRouter;
