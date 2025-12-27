const Router = require("express");
const {
  createServiceProfile,
  getAllProfiles,
  getProfileById,
  updateProfile,
} = require("../../controllers/admin/serviceProfileController");
const serviceRouter = Router();
const multer = require("multer");
const path = require("path");
const { authenticateToken } = require("../../middleware/auth");

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, "../../../uploads"));
  },
  filename: (req, file, cb) => {
    cb(
      null,
      file.fieldname + "-" + Date.now() + path.extname(file.originalname)
    );
  },
});
const upload = multer({ storage });

// serviceRouter.use(authenticateToken);

serviceRouter.post(
  "/service-profiles",
  upload.single("profileImage"),
  createServiceProfile
);
serviceRouter.get("/service-profiles", getAllProfiles);
serviceRouter.get("/service-profiles/:id", getProfileById);
serviceRouter.put(
  "/service-profiles/:id",
  upload.single("profileImage"),
  updateProfile
);

module.exports = serviceRouter;
