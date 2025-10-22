const jwt = require('jsonwebtoken');
require('dotenv').config();


const JWT_SECRET = process.env.JWT_SECRET;

exports.generateToken = (user) => {
  return jwt.sign(
    { id: user.id, role: user.role },
    JWT_SECRET,
    { expiresIn: '7d' }
  );
};
exports.generateOTP=()=> {
  return Math.floor(100000 + Math.random() * 900000).toString(); // 6-digit
}


import express from "express";
const app = express();

// Middleware to detect subdomain
app.use((req, res, next) => {
  const host = req.hostname; // e.g. admin.example.com
  const parts = host.split('.');
  req.subdomain = parts.length > 2 ? parts[0] : null; // get 'admin' or 'partner'
  next();
});

// Subdomain routing
app.use((req, res, next) => {
  if (req.subdomain === 'admin') {
    // handle admin requests
    return adminRoutes(req, res, next);
  } else if (req.subdomain === 'partner') {
    // handle partner requests
    return partnerRoutes(req, res, next);
  } else {
    // default or main site
    return next();
  }
});

function adminRoutes(req, res) {
  res.send('Welcome to Admin Portal');
}

function partnerRoutes(req, res) {
  res.send('Welcome to Partner Portal');
}

// Default domain route
app.get('/', (req, res) => {
  res.send('Main site');
});

app.listen(3000, () => console.log("Server running on port 3000"));
