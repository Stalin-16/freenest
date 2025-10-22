const server = require("express");
const cors = require("cors");
const errorHandler = require("./middleware/errorHandler");
const registerRoutes = require("./routes/indexRoutes");
const db = require("./config/dbconfig");

// initialize server
const app = server();
app.use(server.json());
//cors middleware
app.use(cors());

//Register routes
registerRoutes(app);

//Error handler
app.use(errorHandler);

// Start server
app.listen(5000, () => console.log("Server running on port 5000"));
