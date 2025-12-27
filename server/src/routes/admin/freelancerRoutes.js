const express = require("express");
const router = express.Router();
const { authenticateToken, authorize } = require("../../middleware/auth");
const freelancerController = require("../../controllers/admin/freelancerController");

// All routes require authentication
router.use(authenticateToken);

// Get freelancers with pagination, search, and filtering
router.post(
  "/get-all-freelancers",
  authorize(["admin"]),
  freelancerController.getFreelancers
);

// Get single freelancer
router.get(
  "/:id",
  authorize(["admin"]),
  freelancerController.getFreelancerById
);

// Create freelancer
router.post(
  "/create-freelancers",
  authorize(["admin"]),
  freelancerController.createFreelancer
);

// Update freelancer status (approve/reject)
router.put(
  "/:id/status",
  authorize(["admin"]),
  freelancerController.updateFreelancerStatus
);

// Update freelancer details
router.put("/:id", authorize(["admin"]), freelancerController.updateFreelancer);

// Delete freelancer
router.delete(
  "/:id",
  authorize(["admin"]),
  freelancerController.deleteFreelancer
);

// Get freelancer statistics
router.get(
  "/stats/summary",
  authorize(["admin"]),
  freelancerController.getFreelancerStats
);

module.exports = router;
