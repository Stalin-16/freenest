const ServiceProfile = require("../model/admin/serviceProfile");
const CartDetails = require("../model/cartDetails");
const Order = require("../model/order");
const OrderItem = require("../model/orderItem");
const User = require("../model/userModel");

exports.getOrderDetails = async (req, res) => {
  try {
    const user_id = req.user?.id;



    const order = await Order.findOne({
      where: {user_id },
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


