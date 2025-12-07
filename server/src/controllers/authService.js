const User = require("../model/userModel");
const { generateToken, generateOTP } = require("../utils/jwt");
const nodemailer = require("nodemailer");
require("dotenv").config();

const transporter = nodemailer.createTransport({
  service: "Gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

const sendOtp = async (req, res) => {
  const { email, name } = req.body;

  if (!email && !name) {
    return res.status(400).json({
      status: 400,
      message: "Either email or name is required",
    });
  }

  const otp = generateOTP();
  const otpExpires = new Date(Date.now() + 5 * 60 * 1000);

  let user = null;

  // Search priority: email first, then name
  if (email) {
    user = await User.findOne({ where: { email } });
  }

  let foundByName = false;
  if (!user && name) {
    foundByName = true;
    user = await User.findOne({ where: { name } });
  }

  if (!user) {
    // Create new user - require email for new registrations
    if (!email) {
      return res.status(400).json({
        status: 400,
        message: "Email is required for new user registration",
      });
    }

    user = await User.create({
      email,
      name: name || email.split("@")[0], // Use provided name if available
      otp,
      otpExpires,
    });
  } else {
    // Update user
    user.otp = otp;
    user.otpExpires = otpExpires;

    // If user was found by name and email was provided in request, update the email
    if (foundByName && email) {
      user.email = email;
    }

    // Also update name if email is provided and user doesn't have a name
    if (foundByName && email) {
      user.name = email.split("@")[0];
    }

    await user.save();
  }

  // Send OTP email
  if (user.email) {
    await transporter.sendMail({
      from: process.env.EMAIL_USER,
      to: user.email,
      subject: "Your OTP Code",
      text: `Your OTP is ${otp}. It expires in 5 minutes.`,
    });

    return res.status(200).json({
      status: 200,
      message: "OTP sent to email",
    });
  } else {
    return res.status(200).json({
      status: 200,
      message: "OTP updated but no email available to send",
    });
  }
};

verifyOtp = async (req, res) => {
  const { email, otp } = req.body;
  const user = await User.findOne({ where: { email } });

  if (!user) return res.status(404).json({ message: "User not found" });
  if (user.otp !== otp) return res.status(400).json({ message: "Invalid OTP" });
  if (user.otp_expires < new Date())
    return res.status(400).json({ message: "OTP expired" });

  user.otp = null;
  user.otpExpires = null;
  await user.save();

  const token = generateToken(user);
  return res.status(200).json({
    status: 200,
    message: "OTP verified",

    data: {
      token: {
        access_token: token,
        expires_in: 3600,
        scope: "user",
        token_type: "Bearer",
      },
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        isGuest: false,
      },
    },
  });
};

googleLogin = async (req, res) => {
  const { email, googleId, user_name } = req.body;

  let user = await User.findOne({ where: { email } });

  if (!user) {
    user = await User.create({ email, googleId: googleId, name: user_name });
  }

  const token = generateToken(user);

  res.json({
    status: 200,
    message: "Login successful",
    data: {
      access_token: token,
      user: user,
    },
  });
};

const generateGuestToken = async (req, res) => {
  try {
    const guestId = `guest_${Date.now()}_${Math.floor(Math.random() * 1000)}`;

    const guestUser = await User.create({
      name: `Guest_${guestId}`,
      email: `${guestId}@temporary.guest`,
      role: "guest",
      isTemporary: true,
      createdAt: new Date(),
      // deleteAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
    });

    // Generate token for guest
    const token = generateToken({
      id: guestUser._id,
      role: "guest",
    });

    return res.status(200).json({
      status: 200,
      message: "Guest session created",
      data: {
        token: {
          access_token: token,
          expires_in: 3600,
          scope: "user",
          token_type: "Bearer",
        },
        user: {
          id: guestUser.id,
          name: guestUser.name,
          email: guestUser.email,
          role: guestUser.role,
          isGuest: true,
        },
      },
    });
  } catch (error) {
    console.error("Guest token generation error:", error);
    return res.status(500).json({
      status: 500,
      message: "Failed to create guest session",
    });
  }
};

module.exports = { sendOtp, verifyOtp, googleLogin, generateGuestToken };
