const admin = require("firebase-admin");

// Initialize Firebase Admin
const serviceAccount = require("./serviceAccountKey.json");
const User = require("../model/userModel");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Send notification to single device
async function sendToDevice(deviceToken, title, body, data = {}) {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: data,
    token: deviceToken,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
  } catch (error) {
    console.error("Error sending message:", error);
  }
}

async function saveDeviceToken(req, res) {
  try {
    const { token } = req.body;
    const userId = req.user.id;
    console.log(token, userId);
    const user = await User.findByPk(userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    user.deviceToken = token;
    await user.save();
    res
      .status(200)
      .json({ status: 200, message: "Device token saved successfully" });
  } catch (error) {
    console.error("Error saving device token:", error);
    res.status(500).json({ message: "Internal server error" });
  }
}

module.exports = { sendToDevice, saveDeviceToken };
