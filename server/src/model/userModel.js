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
    },
    // Optional password (for non-Google users)
    password: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    phoneNo: {
      type: DataTypes.BIGINT,
      allowNull: true,
    },

    // Role-based access (default user)
    role: {
      type: DataTypes.ENUM("user", "admin", "guest", "freelancer"),
      allowNull: false,
      defaultValue: "user",
    },

    status: {
      type: DataTypes.ENUM("approved", "pending"),
      allowNull: true,
      defaultValue: "pending",
    },

    // Whether the account is active
    isActive: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
    //Otp code
    otp: { type: DataTypes.STRING, allowNull: true },
    experience: { type: DataTypes.STRING, allowNull: true },
    hourlyRate: { type: DataTypes.FLOAT, allowNull: true },
    //Otp Expires
    otpExpires: { type: DataTypes.DATE, allowNull: true },
    overallRating: { type: DataTypes.INTEGER, default: 0 },
    totalRatings: { type: DataTypes.INTEGER, default: 0 },
    ratingCount: { type: DataTypes.INTEGER, default: 0 },
  },
  {
    tableName: "users",
  }
);

module.exports = User;
