const dbconfig = require("../config/dbconfig");
const ServiceProfile = require("../model/admin/serviceProfile");
const CartDetails = require("../model/cartDetails");
const Order = require("../model/order");
const OrderItem = require("../model/orderItem");

// Add item to cart
exports.addToCart = async (req, res) => {
  try {
    const user_id = req.user?.id;
    const { id, quantity, hourlyRate } = req.body;

    if (!user_id || !id || !hourlyRate) {
      return res.status(400).json({
        status: 400,
        message: "user_id, profile_id, and hourlyRate are required.",
      });
    }

    let cartItem = await CartDetails.findOne({
      where: { user_id, profile_id: id, cart_status: "active" },
    });

    if (cartItem) {
      cartItem.quantity += quantity || 1;
      cartItem.total_price = cartItem.quantity * hourlyRate;
      cartItem.updated_at = new Date();
      await cartItem.save();
    } else {
      cartItem = await CartDetails.create({
        user_id,
        profile_id: id,
        quantity: quantity || 1,
        price_per_unit: hourlyRate,
        total_price: (quantity || 1) * hourlyRate,
      });
    }

    return res.json({
      status: 200,
      message: "Item added to cart successfully",
      data: { item: cartItem },
    });
  } catch (error) {
    console.error("Error in addToCart:", error);
    res.status(500).json({ status: 500, message: "Internal server error" });
  }
};

// Get user's cart
exports.getCart = async (req, res) => {
  try {
    const user_id = req.user?.id;

    if (!user_id)
      return res.status(400).json({ status: 400, message: "user_id required" });

    const cart = await CartDetails.findAll({
      where: { user_id, cart_status: "active" },
      include: [
        {
          model: ServiceProfile,
          as: "profile",
          attributes: ["id", "profileImage", "serviceTitle"],
        },
      ],
    });

    if (!cart || cart.length === 0)
      return res.status(404).json({ status: 404, message: "Cart not found" });

    res.json({
      status: 200,
      message: "Cart fetched successfully",
      data: { cart },
    });
  } catch (error) {
    console.error("Error fetching cart:", error);
    res.status(500).json({ status: 500, message: "Error fetching cart" });
  }
};

// Update quantity
exports.updateQuantity = async (req, res) => {
  try {
    const { user_id, profile_id, quantity } = req.body;

    const item = await CartDetails.findOne({
      where: { user_id, profile_id, cart_status: "active" },
    });

    if (!item)
      return res.status(404).json({ status: 404, message: "Item not found" });

    item.quantity = quantity;
    item.total_price = item.price_per_unit * quantity;
    item.updated_at = new Date();
    await item.save();

    res.json({
      status: 200,
      message: "Quantity updated successfully",
      data: { item },
    });
  } catch (error) {
    res.status(500).json({ status: 500, message: "Error updating quantity" });
  }
};

// Remove item
exports.removeFromCart = async (req, res) => {
  try {
    const { user_id, profile_id } = req.body;

    await CartDetails.destroy({
      where: { user_id, profile_id, cart_status: "active" },
    });

    res.json({
      status: 200,
      message: "Item removed successfully",
    });
  } catch (error) {
    res.status(500).json({ status: 500, message: "Error removing item" });
  }
};
exports.checkout = async (req, res) => {
  const transaction = await dbconfig.transaction();
  try {
    const user_id = req.user?.id;

    
    const cartItems = await CartDetails.findAll({
      where: { user_id, cart_status: "active" },
    });

    if (cartItems.length === 0) {
      return res.status(400).json({ status: 400, message: "Cart is empty" });
    }

    const totalPrice = cartItems.reduce(
      (sum, item) => sum + parseFloat(item.total_price || 0),
      0
    );

    // ✅ Create new order
    const newOrder = await Order.create(
      {
        user_id,
        total_items: cartItems.length,
        total_price: totalPrice,
        status: "completed",
      },
      { transaction }
    );

    // ✅ Create order items
    const orderItemsData = cartItems.map((item) => ({
      order_id: newOrder.id,
      cart_id: item.id,
      product_name: item.product_name,
      quantity: item.quantity,
      price: item.price,
      total_price: item.total_price,
    }));

    await OrderItem.bulkCreate(orderItemsData, { transaction });

    // ✅ Update cart items as checked out
    await CartDetails.update(
      { cart_status: "checked_out", updated_at: new Date() },
      { where: { user_id, cart_status: "active" }, transaction }
    );

    await transaction.commit();

    res.json({
      status: 200,
      message: "Checkout successful",
      data: {
        order: {
          order_id: newOrder.id,
          user_id,
          totalItems: cartItems.length,
          totalPrice,
        },
      },
    });
  } catch (error) {
    await transaction.rollback();
    console.error("Checkout error:", error);
    res.status(500).json({ status: 500, message: "Error during checkout" });
  }
};

exports.syncCart = async (req, res) => {
  try {
    const userId = req.user?.id;
    const cartItems = req.body.cart;

    if (!userId) {
      return res.status(401).json({
        status: 401,
        message: "Unauthorized: Missing or invalid token",
      });
    }

    if (!cartItems || !Array.isArray(cartItems)) {
      return res.status(400).json({
        status: 400,
        message: "Invalid cart data",
      });
    }

    for (const item of cartItems) {
      const { productId, quantity } = item;

      await CartDetails.upsert({
        userId,
        productId,
        quantity,
      });
    }
    return res.status(200).json({
      status: 200,
      message: "Cart synced successfully",
    });
  } catch (error) {
    console.error("Error syncing cart:", error);
    return res.status(500).json({
      status: 500,
      message: "Internal server error",
      error: error.message,
    });
  }
};
