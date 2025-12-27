const User = require("../../model/userModel");
const { generateToken } = require("../../utils/jwt");
const bcrypt = require("bcrypt");
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    console.log(email, password);

    // Validate input
    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: "Please provide email and password",
      });
    }

    // Check if user exists
    const user = await User.findOne({
      where: {
        email,
        role: "admin",
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found or unauthorized access",
      });
    }

    // Compare passwords
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: "Invalid email or password",
      });
    }

    // Generate tokens
    const accessToken = generateToken(user);

    // Send response
    return res.status(200).json({
      success: true,
      message: "Login successful",
      data: {
        user: {
          id: user.id,
          email: user.email,
          role: user.role,
        },
        tokens: {
          accessToken,
          expiresIn: process.env.JWT_EXPIRES_IN || "24h",
        },
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
};
