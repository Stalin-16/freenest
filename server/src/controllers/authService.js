const User = require("../model/userModel");
const { generateToken, generateOTP } = require("../utils/jwt");
const nodemailer = require("nodemailer");
require("dotenv").config();


const transporter = nodemailer.createTransport({
  service: "Gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS
  }
});

const sendOtp = async (req, res) => {
  const { email } = req.body;
  const otp = generateOTP();
  const otpExpires = new Date(Date.now() + 5 * 60 * 1000); // 5 min

  let user = await User.findOne({ where: { email } });
  if (!user) {
    user = await User.create({ email, user_name: email.split("@")[0], otp, otp_expires });
  } else {
    user.otp = otp;
    user.otp_expires = otpExpires;
    await user.save();
  }

  await transporter.sendMail({
    from: process.env.EMAIL_USER,
    to: email,
    subject: "Your OTP Code",
    text: `Your OTP is ${otp}. It expires in 5 minutes.`
  });

  res.json({ message: "OTP sent to email" });
};

verifyOtp = async (req, res) => {
  const { email, otp } = req.body;
  const user = await User.findOne({ where: { email } });

  if (!user) return res.status(404).json({ message: "User not found" });
  if (user.otp !== otp) return res.status(400).json({ message: "Invalid OTP" });
  if (user.otp_expires < new Date()) return res.status(400).json({ message: "OTP expired" });

  user.otp = null;
  user.otp_expires = null;
  await user.save();

  const token = generateToken(user);
  res.json({ message: "OTP verified", token });
};

googleLogin = async (req, res) => {
  const { email, id, user_name } = req.body;

  console.log(email, id, user_name);

  let user = await User.findOne({ where: { email } });

  if (!user) {
    user = await User.create({ email, googleId:id, name: user_name });
  } else if (!user.id) {
    user.id = id;
    await user.save();
  }

  const token = generateToken(user);

  res.json({ message: "Login successful", token });
};

module.exports = { sendOtp, verifyOtp, googleLogin };