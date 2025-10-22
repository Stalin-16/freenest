const { DataTypes } = require("sequelize");
const sequelize = require("../config/dbconfig");


  const CartDetails = sequelize.define('CartDetails', {
   id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    user_id: {
      type:  DataTypes.INTEGER,
      allowNull: false,
      comment: 'ID of the user who owns the cart',
    },

    profile_id: {
      type:  DataTypes.INTEGER,
      allowNull: false,
      comment: 'ID of the product added to cart',
    },

    quantity: {
      type: DataTypes.INTEGER,
      allowNull: false,
      defaultValue: 1,
      validate: { min: 1 },
      comment: 'Number of items for this product',
    },

    price_per_unit: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      comment: 'Price of one unit at the time of adding to cart',
    },

    total_price: {
      type: DataTypes.DECIMAL(10, 2),
      allowNull: false,
      comment: 'Computed total (quantity * price_per_unit)',
    },

    added_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      comment: 'When the product was added to cart',
    },

    updated_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
      comment: 'Last time this cart item was updated',
    },

    cart_status: {
      type: DataTypes.ENUM('active', 'checked_out', 'abandoned'),
      defaultValue: 'active',
      comment: 'Status of this cart entry',
    },
  }, {
    tableName: 'cart_details',
    timestamps: false,
  });

  CartDetails.associate = (models) => {
    CartDetails.belongsTo(models.User, { foreignKey: 'user_id' });
    CartDetails.belongsTo(models.Product, { foreignKey: 'profile_id' });
  };

  module.exports =CartDetails;