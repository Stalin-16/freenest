const { DataTypes } = require("sequelize");
const sequelize = require("../config/dbconfig");

const User = sequelize.define(
  "User",
  {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },

    // User’s name
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },

    // Email (unique identifier)
    email: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },

    // Google ID (used for OAuth login)
    googleId: {
      type: DataTypes.STRING,
      allowNull: true,
      unique: true,
    },

    // Optional password (for non-Google users)
    password: {
      type: DataTypes.STRING,
      allowNull: true,
    },

    // Role-based access (default user)
    role: {
      type: DataTypes.ENUM("user", "admin"),
      allowNull: false,
      defaultValue: "user",
    },

    // Whether the account is active
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    //Otp code
    otp: { type: DataTypes.STRING, allowNull: true },
    //Otp Expires
    otpExpires: { type: DataTypes.DATE, allowNull: true },
  },
  {
    tableName: "users",
  }
);

module.exports = User;
