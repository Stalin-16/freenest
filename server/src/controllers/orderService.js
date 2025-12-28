const ServiceProfile = require("../model/admin/serviceProfile");
const CartDetails = require("../model/cartDetails");
const Order = require("../model/order");
const OrderItem = require("../model/orderItem");
const Review = require("../model/review");
const User = require("../model/userModel");

exports.getOrderDetails = async (req, res) => {
  try {
    const user_id = req.user?.id;

    const orders = await Order.findAll({
      where: { user_id },
      include: [
        {
          model: OrderItem,
          include: [
            {
              model: ServiceProfile,
              as: "profile",
              attributes: [
                "id",
                "serviceTitle",
                "hourlyRate",
                "serviceCategoryId",
                "profileImage",
                "tagline",
                "experienceRange",
                "ratingCount",
                "totalRatings",
                "overallRating",
              ],
            },
            {
              model: User,
              as: "assignedUser",
              attributes: ["id", "name", "email", "overallRating"],
            },
            {
              model: Review,
              as: "reviewDetails",
              attributes: ["id", "rating", "comment"],
            },
          ],
        },
      ],
      order: [["created_at", "DESC"]],
    });

    if (!orders || orders.length === 0) {
      return res.status(404).json({
        status: 404,
        message: "No orders found for this user",
      });
    }

    res.json({
      status: 200,
      message: "Orders fetched successfully",
      data: orders,
    });
  } catch (error) {
    console.error("Error fetching order details:", error);
    res.status(500).json({
      status: 500,
      message: "Failed to fetch order details",
      error: error.message,
    });
  }
};

exports.getAllOrderDetailsForAdmin = async (req, res) => {
  try {
    const orders = await Order.findAll({
      include: [
        {
          model: OrderItem,
          include: [
            {
              model: ServiceProfile,
              as: "profile",
              attributes: [
                "id",
                "serviceTitle",
                "hourlyRate",
                "serviceSubCategoryId",
                "serviceCategoryId",
                "profileImage",
              ],
            },
            {
              model: Review,
              as: "reviewDetails",
              attributes: ["id", "rating", "comment"],
            },
          ],
        },
        {
          model: User,
          as: "user",
          attributes: ["id", "name", "email"],
        },
      ],
      order: [["created_at", "DESC"]],
    });

    if (!orders || orders.length === 0) {
      return res.status(404).json({
        status: 404,
        message: "No orders found for this user",
      });
    }

    res.json({
      status: 200,
      message: "Orders fetched successfully",
      data: orders,
    });
  } catch (error) {
    console.error("Error fetching order details:", error);
    res.status(500).json({
      status: 500,
      message: "Failed to fetch order details",
      error: error.message,
    });
  }
};

exports.getOrderDetailsById = async (req, res) => {
  try {
    const user_id = req.user?.id;

    const orderId = req.params.id;

    const order = await Order.findOne({
      where: { user_id, id: orderId },
      include: [
        {
          model: OrderItem,
          include: [
            {
              model: CartDetails,
              include: [
                {
                  model: ServiceProfile,
                  as: "profile",
                  attributes: [
                    "id",
                    "serviceTitle",
                    "hourlyRate",
                    "serviceCategory",
                    "profileImage",
                  ],
                },
              ],
              attributes: [
                "id",
                "quantity",
                "price_per_unit",
                "total_price",
                "cart_status",
              ],
            },
          ],
        },
        {
          model: User,
          attributes: ["id", "name", "email"],
        },
      ],
    });

    if (!order) {
      return res.status(404).json({
        status: 404,
        message: "Order not found or unauthorized",
      });
    }

    res.json({
      status: 200,
      message: "Order details fetched successfully",
      data: order,
    });
  } catch (error) {
    console.error("Error fetching order details:", error);
    res.status(500).json({
      status: 500,
      message: "Failed to fetch order details",
    });
  }
};

exports.updateOrderStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    console.log(id, status);

    const allowedStatuses = ["Assigned", "Inprogress", "Completed"];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ status: 400, message: "Invalid status" });
    }

    const order = await Order.findByPk(id);
    if (!order) {
      return res.status(404).json({ status: 404, message: "Order not found" });
    }

    order.status = status;
    await order.save();

    return res.json({
      status: 200,
      message: "Order status updated successfully",
    });
  } catch (error) {
    console.error("Error updating order status:", error);
  }
};
