const express = require("express");
const cors = require("cors");
const errorHandler = require("./middleware/errorHandler");
const registerRoutes = require("./routes/indexRoutes");
const path = require("path");
const {
  User,
  ServiceProfile,
  CartDetails,  
} = require("./model/association");

const app = express();

app.use(express.json());
app.use(cors());

//  Correct static route
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Register API routes
registerRoutes(app);

// Error handler
// app.use(errorHandler);

// Start server
app.listen(5000, () =>
  console.log(" Server running at 5000")
);


