const { DataTypes } = require("sequelize");
const sequelize = require("../config/dbconfig");

const CartDetails = sequelize.define("CartDetails", {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
  },
  profile_id: {
    type: DataTypes.BIGINT,
    allowNull: false,
  },
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  price_per_unit: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  total_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false,
  },
  added_at: DataTypes.DATE,
  updated_at: DataTypes.DATE,
  cart_status: {
    type: DataTypes.ENUM("active", "checked_out", "abandoned"),
    defaultValue: "active",
  },
});
module.exports = CartDetails;
