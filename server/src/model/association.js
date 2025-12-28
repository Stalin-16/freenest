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

// 🧾 Order ↔ User
Order.belongsTo(User, { as: "user", foreignKey: "user_id" });
User.hasMany(Order, { as: "orders", foreignKey: "user_id" });

// 🧾 Order ↔ OrderItem
Order.hasMany(OrderItem, { foreignKey: "order_id" });
OrderItem.belongsTo(Order, { foreignKey: "order_id" });

OrderItem.hasOne(Review, { foreignKey: "orderItemId", as: "reviewDetails" });
Review.belongsTo(OrderItem, { foreignKey: "orderItemId" });

// 🧩 ServiceProfile ↔ Order
ServiceProfile.hasMany(OrderItem, { foreignKey: "profile_id", as: "orders" });

OrderItem.belongsTo(ServiceProfile, {
  as: "profile",
  targetKey: "id",
  foreignKey: "profile_id",
});

OrderItem.belongsTo(User, {
  as: "assignedUser",
  targetKey: "id",
  foreignKey: "assigned_to",
});
