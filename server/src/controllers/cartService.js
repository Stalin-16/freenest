const dbconfig = require("../config/dbconfig");
const ServiceProfile = require("../model/admin/serviceProfile");
const CartDetails = require("../model/cartDetails");
const UserCredits = require("../model/creditActivity");
const Order = require("../model/order");
const OrderItem = require("../model/orderItem");
const User = require("../model/userModel");

// Add item to cart
exports.addToCart = async (req, res) => {
  try {
    const user_id = req.user?.id;

    // Accept multiple parameter names for flexibility
    const id = req.body.id || req.body.profile_id;
    const hourlyRate = req.body.hourlyRate || req.body.price_per_unit;
    const quantity = req.body.quantity || 1;

    if (!user_id || !id || !hourlyRate) {
      return res.status(400).json({
        status: 400,
        message: "user_id, profile_id, and price are required.",
      });
    }

    let cartItem = await CartDetails.findOne({
      where: { user_id, profile_id: id, cart_status: "active" },
    });

    if (cartItem) {
      cartItem.quantity += quantity;
      cartItem.total_price = cartItem.quantity * hourlyRate;
      cartItem.updated_at = new Date();
      await cartItem.save();
    } else {
      cartItem = await CartDetails.create({
        user_id,
        profile_id: id,
        quantity: quantity,
        price_per_unit: hourlyRate,
        total_price: quantity * hourlyRate,
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
          attributes: [
            "id",
            "profileImage",
            "serviceTitle",
            "experienceRange",
            "overallRating",
            [
              dbconfig.literal(
                `(SELECT COUNT(*) FROM order_items WHERE order_items.profile_id = profile.id)`
              ),
              "orderCount",
            ],
          ],
          include: [
            {
              model: OrderItem,
              as: "orders",
              attributes: [],
              required: false,
            },
          ],
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
    const { profile_id, quantity } = req.body;
    const user_id = req.user?.id;

    const item = await CartDetails.findOne({
      where: { user_id, id: profile_id, cart_status: "active" },
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
    res
      .status(500)
      .json({ status: 500, message: `Error updating quantity ${error}` });
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

// exports.checkout = async (req, res) => {
//   const transaction = await dbconfig.transaction();
//   try {
//     const user_id = req.user?.id;
//     const { email } = req.body;

//     const cartItems = await CartDetails.findAll({
//       where: { user_id, cart_status: "active" },
//       transaction,
//     });

//     if (cartItems.length === 0) {
//       await transaction.rollback();
//       return res.status(400).json({ status: 400, message: "Cart is empty" });
//     }

//     // Calculate TOTAL checkout amount BEFORE the loop
//     const totalCheckoutAmount = cartItems.reduce(
//       (sum, item) => sum + parseFloat(item.total_price || 0),
//       0
//     );

//     // Calculate 5% credit ONCE based on total checkout
//     const totalCredit = (totalCheckoutAmount * 5) / 100;

//     // Group cart items by profile_id
//     const groupedByProfile = {};

//     cartItems.forEach((item) => {
//       const profileId = item.profile_id;
//       if (!groupedByProfile[profileId]) {
//         groupedByProfile[profileId] = [];
//       }
//       groupedByProfile[profileId].push(item);
//     });

//     // Array to collect all order IDs
//     const orderIds = [];

//     for (const [profileId, profileCartItems] of Object.entries(
//       groupedByProfile
//     )) {
//       // Calculate totals for this profile's items
//       const profileTotal = profileCartItems.reduce(
//         (sum, item) => sum + parseFloat(item.total_price || 0),
//         0
//       );

//       const totalHours = profileCartItems.reduce(
//         (sum, item) => sum + parseFloat(item.quantity || 0),
//         0
//       );

//       const order = await Order.create(
//         {
//           user_id,
//           profile_id: profileId,
//           total_hours: totalHours,
//           price_per_unit: profileTotal / totalHours || 0,
//           total_price: email ? profileTotal - totalCredit : profileTotal,
//           quantity: totalHours,
//           status: "order placed",
//           created_at: new Date(),
//           updated_at: new Date(),
//         },
//         { transaction }
//       );

//       orderIds.push(order.id);

//       // Update cart items for this profile as checked out
//       const cartItemIds = profileCartItems.map((item) => item.id);
//       await CartDetails.update(
//         {
//           cart_status: "checked_out",
//           updated_at: new Date(),
//         },
//         {
//           where: {
//             id: cartItemIds,
//             user_id,
//             cart_status: "active",
//           },
//           transaction,
//         }
//       );
//     }

//     // Create credit ONCE after processing all orders
//     if (email && totalCredit > 0) {
//       await UserCredits.create(
//         {
//           user_id,
//           activity_type: "credit",
//           amount: totalCredit,
//           status: "0",
//           order_id: orderIds.join(","), // Store comma-separated order IDs or pick one
//           description: `5% credit for checkout with email ${email}. Orders: ${orderIds.join(
//             ", "
//           )}`,
//           created_at: new Date(),
//         },
//         { transaction }
//       );
//     }

//     await transaction.commit();

//     res.json({
//       status: 200,
//       message: "Order Placed Successfully",
//       data: {
//         profilesProcessed: Object.keys(groupedByProfile).length,
//         totalItems: cartItems.length,
//         totalCheckoutAmount,
//         creditEarned: totalCredit,
//       },
//     });
//   } catch (error) {
//     await transaction.rollback();
//     console.error("Checkout error:", error);
//     res.status(500).json({
//       status: 500,
//       message: "Error during checkout",
//       error: process.env.NODE_ENV === "development" ? error.message : undefined,
//     });
//   }
// };

exports.checkout = async (req, res) => {
  const transaction = await dbconfig.transaction();
  try {
    const user_id = req.user?.id;
    const { email } = req.body;

    const cartItems = await CartDetails.findAll({
      where: { user_id, cart_status: "active" },
      transaction,
    });

    if (cartItems.length === 0) {
      await transaction.rollback();
      return res.status(400).json({ status: 400, message: "Cart is empty" });
    }

    // Calculate TOTAL checkout amount
    const totalCheckoutAmount = cartItems.reduce(
      (sum, item) => sum + parseFloat(item.total_price || 0),
      0
    );

    // Calculate 5% credit ONCE based on total checkout
    const totalCredit = (totalCheckoutAmount * 5) / 100;

    // Apply credit if email is provided
    const amountAfterCredit = email
      ? totalCheckoutAmount - totalCredit
      : totalCheckoutAmount;

    // Calculate 18% GST on amount after credit
    const gstAmount = (amountAfterCredit * 18) / 100;

    // Calculate final amount (after credit + GST)
    const finalAmount = amountAfterCredit + gstAmount;

    // Calculate total hours/quantity
    const totalHours = cartItems.reduce(
      (sum, item) => sum + parseFloat(item.quantity || 0),
      0
    );

    // Create single order
    const order = await Order.create(
      {
        user_id,
        total_hours: totalHours,
        total_price: finalAmount, // Store final amount including GST
        base_amount: totalCheckoutAmount,
        gst_amount: gstAmount,
        quantity: totalHours,
        created_at: new Date(),
        updated_at: new Date(),
      },
      { transaction }
    );

    // Create order items for each cart item
    for (const cartItem of cartItems) {
      await OrderItem.create(
        {
          order_id: order.id,
          profile_id: cartItem.profile_id,
          cart_id: cartItem.id,
          status: "order placed",
          product_name:
            cartItem.product_name ||
            `Service from Profile ${cartItem.profile_id}`,
          quantity: cartItem.quantity,
          price: cartItem.price_per_unit || 0,
          total_price: cartItem.total_price || 0,
          created_at: new Date(),
        },
        { transaction }
      );
    }

    // Update all cart items as checked out
    const cartItemIds = cartItems.map((item) => item.id);
    await CartDetails.update(
      {
        cart_status: "checked_out",
        updated_at: new Date(),
      },
      {
        where: {
          id: cartItemIds,
          user_id,
          cart_status: "active",
        },
        transaction,
      }
    );

    // Create credit if email is provided and credit amount > 0
    if (email && totalCredit > 0) {
      await UserCredits.create(
        {
          user_id,
          activity_type: "credit",
          amount: totalCredit,
          status: "0",
          order_id: order.id.toString(),
          description: `5% credit for checkout with email ${email}. Order: ${order.id}`,
          created_at: new Date(),
        },
        { transaction }
      );
    }

    await transaction.commit();

    res.json({
      status: 200,
      message: "Order Placed Successfully",
      data: {
        orderId: order.id,
        totalItems: cartItems.length,
        baseAmount: totalCheckoutAmount,
        creditApplied: email ? totalCredit : 0,
        amountAfterCredit: amountAfterCredit,
        gstAmount: gstAmount,
        finalAmount: finalAmount,
        gstPercentage: "18%",
        creditEarned: totalCredit,
        breakdown: {
          subtotal: totalCheckoutAmount,
          discount: email ? totalCredit : 0,
          taxableAmount: amountAfterCredit,
          gst: gstAmount,
          total: finalAmount,
        },
      },
    });
  } catch (error) {
    await transaction.rollback();
    console.error("Checkout error:", error);
    res.status(500).json({
      status: 500,
      message: "Error during checkout",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
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

// Apply referral code
exports.applyReferralCode = async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res
        .status(400)
        .json({ status: 400, message: "Referral code are required." });
    }

    const user = await User.findOne({ where: { email, role: "user" } });
    if (!user) {
      return res
        .status(404)
        .json({ status: 404, message: "Referral code is invalid." });
    }

    return res.status(200).json({
      status: 200,
      message: "Referral code applied successfully",
      data: { referredUser: true },
    });
  } catch (error) {
    console.error("Error applying referral code:", error);
    res.status(500).json({ status: 500, message: "Internal server error" });
  }
};
