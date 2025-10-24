const { DataTypes } = require("sequelize");
const sequelize = require("../../config/dbconfig");
const ServiceProfile = sequelize.define(
  "ServiceProfile",
  {
    id: {
      type: DataTypes.BIGINT,
      primaryKey: true,
      autoIncrement: true,
    },
    // 1. Basic Info
    serviceTitle: { type: DataTypes.STRING, allowNull: false },
    serviceCategory: { type: DataTypes.STRING, allowNull: false },
    experienceRange: { type: DataTypes.STRING, allowNull: false },
    hourlyRate: { type: DataTypes.FLOAT, allowNull: false },
    tagline: { type: DataTypes.STRING, allowNull: false },
    profileImage: { type: DataTypes.STRING },

    // 2–5 Complex Fields (stored as JSON)
    deliverables: { type: DataTypes.JSON, allowNull: true },
    processSteps: { type: DataTypes.JSON, allowNull: true },
    promises: { type: DataTypes.JSON, allowNull: true },
    faqs: { type: DataTypes.JSON, allowNull: true },

    // 6. Review & Rating
    rating: { type: DataTypes.INTEGER, defaultValue: 5 },
    reviewComments: { type: DataTypes.TEXT },

    // 7. Freelance Partners Reference
    jobDescriptionLink: { type: DataTypes.STRING },
    learningResourceLink: { type: DataTypes.STRING },

    // 8. SEO
    metaTitle: { type: DataTypes.STRING },
    metaDescription: { type: DataTypes.TEXT },
    keywords: { type: DataTypes.STRING },
  },
  {
    tableName: "service_profiles",
    timestamps: false,
  }
);

module.exports = ServiceProfile;
