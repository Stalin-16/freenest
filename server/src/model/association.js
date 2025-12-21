const ServiceProfile = require("./admin/serviceProfile");
const CartDetails = require("./cartDetails");
const Order = require("./order");
const OrderItem = require("./orderItem");
const Review = require("./review");
const User = require("./userModel");

// 🧍 User ↔ CartDetails
User.hasMany(CartDetails, { foreignKey: "user_id", onDelete: "CASCADE" });
CartDetails.belongsTo(User, { foreignKey: "user_id" });

// 🧩 ServiceProfile ↔ CartDetails
ServiceProfile.hasMany(CartDetails, {
  foreignKey: "profile_id",
  onDelete: "CASCADE",
});
CartDetails.belongsTo(ServiceProfile, {
  as: "profile",
  foreignKey: "profile_id",
});

// 🛒 CartDetails ↔ OrderItem
CartDetails.hasOne(OrderItem, { foreignKey: "cart_id" });
OrderItem.belongsTo(CartDetails, { foreignKey: "cart_id" });

// 🧾 Order ↔ User
Order.belongsTo(User, { foreignKey: "user_id" });
User.hasMany(Order, { foreignKey: "user_id" });

// 🧾 Order ↔ OrderItem
Order.hasMany(OrderItem, { foreignKey: "order_id" });
OrderItem.belongsTo(Order, { foreignKey: "order_id" });

Order.hasOne(Review, {
  foreignKey: "orderId",
  as: "review",
});

Review.belongsTo(Order, {
  foreignKey: "orderId",
  as: "order",
});

Order.belongsTo(ServiceProfile, {
  as: "profile",
  targetKey: "id",
  foreignKey: "profile_id",
});
