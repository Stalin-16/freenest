// routes/reviewRoutes.js
const express = require("express");
const reviewRouter = express.Router();
const reviewController = require("../controllers/reviewService");

// Create a new review
reviewRouter.post("/", reviewController.createReview);

// Get all reviews with pagination
reviewRouter.get("/", reviewController.getAllReviews);

// Get review by ID
reviewRouter.get("/:reviewId", reviewController.getReviewById);

// Get review by order ID
reviewRouter.get("/order/:orderId", reviewController.getReviewByOrderId);

// Update review
reviewRouter.put("/:reviewId", reviewController.updateReview);

// Delete review (soft delete)
reviewRouter.delete("/:reviewId", reviewController.deleteReview);

module.exports = reviewRouter;
