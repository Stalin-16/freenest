const express = require("express");
const { login } = require("../../controllers/admin/adminController");
const adminAuthRouter = express.Router();

adminAuthRouter.post("/login", login);

module.exports = adminAuthRouter;
