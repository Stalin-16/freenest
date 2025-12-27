const { Sequelize, DataTypes } = require("sequelize");

const UserCredits = Sequelize.define(
  "UserCredits",
  {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    activity_type: {
      type: DataTypes.ENUM("credit", "debit"),
      allowNull: false,
    },
    order_id: {
      type: DataTypes.INTEGER,
      allowNull: true,
    },

    // amount: {
    //   type: DataTypes.DECIMAL(10, 2),
    //   allowNull: false,
    // },
    description: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: Sequelize.NOW,
    },
  },
  {
    tableName: "user_credits",
    timestamps: false,
  }
);

module.exports = UserCredits;
