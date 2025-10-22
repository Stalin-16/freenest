const { Sequelize } = require("sequelize");
require("dotenv").config();

//dbconfig
const dbconfig = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASS,
  {
    host: process.env.DB_HOST,
    dialect: "mysql",
    port: 3306,
    logging: false,
    define: {
      timestamps: true,
      underscored: true,
    },
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000,
    },
  }
);
//DB Authentication and sync
dbconfig
  .authenticate()
  .then(() => {
    console.log("Connection has been established successfully.");
    return dbconfig.sync({ alter: true });
  })
  .then(() => {
    console.log("Tables created successfully if they didn't exist.");
  })
  .catch((err) => {
    console.error("Unable to connect to the database:", err);
  });

module.exports = dbconfig;
