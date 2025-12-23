const dbconfig = require("../config/dbconfig");
const ServiceProfile = require("../model/admin/serviceProfile");
const Order = require("../model/order");
const Review = require("../model/review");
const User = require("../model/userModel");

function calculateNewAverage(currentAverage, currentCount, newRating) {
  const totalSum = currentAverage * currentCount + newRating;
  const newCount = currentCount + 1;
  const newAverage = totalSum / newCount;

  return {
    newAverage: parseFloat(newAverage.toFixed(2)),
    newCount,
  };
}

// Update service rating
const updateServiceRating = async (serviceId, newRating, transaction) => {
  try {
    // Find the service
    const service = await ServiceProfile.findOne({
      where: { id: serviceId },
      transaction,
    });

    if (!service) {
      throw new Error("Service not found");
    }

    // Calculate new average
    const { newAverage, newCount } = calculateNewAverage(
      service.overallRating || 0,
      service.ratingCount || 0,
      newRating
    );

    // Update service
    await ServiceProfile.update(
      {
        overallRating: newAverage,
        ratingCount: newCount,
        totalRatings: (service.totalRatings || 0) + newRating,
      },
      {
        where: { id: serviceId },
        transaction,
      }
    );

    return newAverage;
  } catch (error) {
    console.error("Error updating service rating:", error);
    throw error;
  }
};

// Update user/provider rating
const updateUserRating = async (userId, newRating, transaction) => {
  try {
    // Find the user (provider)
    const user = await User.findOne({
      where: { id: userId },
      transaction,
    });

    if (!user) {
      throw new Error("User not found");
    }

    // Calculate new average
    const { newAverage, newCount } = calculateNewAverage(
      user.overallRating || 0,
      user.ratingCount || 0,
      newRating
    );

    // Update user
    await User.update(
      {
        overallRating: newAverage,
        ratingCount: newCount,
        totalRatings: (user.totalRatings || 0) + newRating,
      },
      {
        where: { id: userId },
        transaction,
      }
    );

    return newAverage;
  } catch (error) {
    console.error("Error updating user rating:", error);
    throw error;
  }
};

// Create review and update order, user, and service ratings
exports.createReview = async (req, res) => {
  const transaction = await dbconfig.transaction();

  try {
    console.log("Create review request body:", req.body);
    const userId = req.user.id;
    const { orderId, rating, comment } = req.body;

    // Validate input
    if (!orderId || !rating || !comment) {
      await transaction.rollback();
      return res.status(400).json({
        success: false,
        message: "Order ID, rating, and comment are required",
      });
    }

    if (rating < 1 || rating > 5) {
      await transaction.rollback();
      return res.status(400).json({
        success: false,
        message: "Rating must be between 1 and 5",
      });
    }

    // Check if order exists and is completed
    const order = await Order.findOne({
      where: {
        id: orderId,
        status: "completed",
      },
      transaction,
    });

    if (!order) {
      await transaction.rollback();
      return res.status(404).json({
        success: false,
        message: "Order not found or not completed",
      });
    }

    // Check if review already exists
    const existingReview = await Review.findOne({
      where: { orderId },
      transaction,
    });

    if (existingReview) {
      await transaction.rollback();
      return res.status(409).json({
        success: false,
        message: "Review already exists for this order",
      });
    }

    // Create review
    const review = await Review.create(
      {
        orderId,
        rating,
        comment,
        userId,
        providerId: order.assigned_to,
        serviceId: order.profile_id,
      },
      { transaction }
    );

    // Update order with reviewId and status
    await Order.update(
      {
        reviewId: review.id,
        status: "reviewed",
      },
      {
        where: { id: orderId },
        transaction,
      }
    );

    // Update Service Rating
    if (order.profile_id) {
      await updateServiceRating(order.profile_id, rating, transaction);
    }
    // Update User/Provider Rating
    if (order.assigned_to) {
      await updateUserRating(order.assigned_to, rating, transaction);
    }

    await transaction.commit();

    res.status(200).json({
      status: 200,
      message: "Review submitted successfully",
    });
  } catch (error) {
    await transaction.rollback();
    console.error("Create review error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get review by order ID
exports.getReviewByOrderId = async (req, res) => {
  try {
    const { orderId } = req.params;

    if (!orderId) {
      return res.status(400).json({
        success: false,
        message: "Order ID is required",
      });
    }

    const review = await Review.findOne({
      where: { orderId },
      include: [
        {
          model: Order,
          as: "order",
          attributes: ["id", "status", "totalPrice", "totalItems"],
        },
      ],
    });

    if (!review) {
      return res.status(404).json({
        success: false,
        message: "Review not found for this order",
      });
    }

    res.status(200).json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error("Get review by order ID error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get all reviews with pagination
exports.getAllReviews = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const { count, rows: reviews } = await Review.findAndCountAll({
      include: [
        {
          model: Order,
          as: "order",
          attributes: ["id", "status", "totalPrice"],
        },
      ],
      limit,
      offset,
      order: [["createdAt", "DESC"]],
    });

    const totalPages = Math.ceil(count / limit);

    res.status(200).json({
      success: true,
      data: {
        reviews,
        pagination: {
          currentPage: page,
          totalPages,
          totalReviews: count,
          hasNext: page < totalPages,
          hasPrev: page > 1,
        },
      },
    });
  } catch (error) {
    console.error("Get all reviews error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Update review
exports.updateReview = async (req, res) => {
  try {
    const { reviewId } = req.params;
    const { rating, comment } = req.body;

    if (!reviewId) {
      return res.status(400).json({
        success: false,
        message: "Review ID is required",
      });
    }

    if (!rating && !comment) {
      return res.status(400).json({
        success: false,
        message: "Rating or comment is required for update",
      });
    }

    if (rating && (rating < 1 || rating > 5)) {
      return res.status(400).json({
        success: false,
        message: "Rating must be between 1 and 5",
      });
    }

    const updateData = {};
    if (rating) updateData.rating = rating;
    if (comment) updateData.comment = comment;

    const [affectedRows] = await Review.update(updateData, {
      where: { id: reviewId },
    });

    if (affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Review not found",
      });
    }

    // Fetch updated review
    const updatedReview = await Review.findByPk(reviewId);

    res.status(200).json({
      success: true,
      message: "Review updated successfully",
      data: updatedReview,
    });
  } catch (error) {
    console.error("Update review error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Delete review (soft delete)
exports.deleteReview = async (req, res) => {
  try {
    const { reviewId } = req.params;

    if (!reviewId) {
      return res.status(400).json({
        success: false,
        message: "Review ID is required",
      });
    }

    const [affectedRows] = await Review.update(
      { status: "inactive" },
      { where: { id: reviewId } }
    );

    if (affectedRows === 0) {
      return res.status(404).json({
        success: false,
        message: "Review not found",
      });
    }

    res.status(200).json({
      success: true,
      message: "Review deleted successfully",
    });
  } catch (error) {
    console.error("Delete review error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get review by ID
exports.getReviewById = async (req, res) => {
  try {
    const { reviewId } = req.params;

    if (!reviewId) {
      return res.status(400).json({
        success: false,
        message: "Review ID is required",
      });
    }

    const review = await Review.findByPk(reviewId, {
      include: [
        {
          model: Order,
          as: "order",
          attributes: ["id", "status", "totalPrice", "totalItems"],
        },
      ],
    });

    if (!review) {
      return res.status(404).json({
        success: false,
        message: "Review not found",
      });
    }

    res.status(200).json({
      success: true,
      data: review,
    });
  } catch (error) {
    console.error("Get review by ID error:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
      error: error.message,
    });
  }
};
