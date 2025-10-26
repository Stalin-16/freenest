const Router = require("express");
const {
  getAllProfilesForUsers,
  getProfileByIdForUsers,
} = require("../controllers/profileService");
const profileRouter = Router();

profileRouter.get("/profile-customer", getAllProfilesForUsers);
profileRouter.get("/profile-customer/:id", getProfileByIdForUsers);

module.exports = profileRouter;
