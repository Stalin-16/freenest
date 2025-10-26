const express = require("express");
const cors = require("cors");
const errorHandler = require("./middleware/errorHandler");
const registerRoutes = require("./routes/indexRoutes");
const path = require("path");

// initialize server
const app = express();

app.use(express.json());
app.use(cors());

// ✅ Correct static route
app.use("/uploads", express.static(path.join(__dirname, "uploads")));

// Register routes
registerRoutes(app);

// Error handler
app.use(errorHandler);

// Start server
app.listen(5000, () => console.log("✅ Server running on port 5000"));
