const authRouter = require("./authRouter");

const registerRoutes = (app)=>{
    app.use("/api/v1/auth", authRouter);
}

module.exports = registerRoutes