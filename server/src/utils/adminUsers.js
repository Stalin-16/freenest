const bcrypt = require("bcrypt");
const User = require("../model/userModel");

async function seedAdminUser() {
  try {
    // Check if admin already exists
    const existingAdmin = await User.findOne({
      where: { email: "adminchennaifl@gmail.com" },
    });

    if (existingAdmin) {
      console.log(
        "⚠️  Admin user already exists with email: adminchennaifl@gmail.com"
      );
      console.log("User details:", {
        id: existingAdmin.id,
        name: existingAdmin.name,
        role: existingAdmin.role,
      });
      return;
    }

    // Hash the password
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash("admin@123", saltRounds);

    console.log("Password hashed successfully");

    // Create admin user
    const adminUser = await User.create({
      name: "Admin",
      email: "adminchennaifl@gmail.com",
      password: hashedPassword,
      role: "admin",
      isActive: true,
      overallRating: 0,
      totalRatings: 0,
      ratingCount: 0,
    });

    console.log("✅ Admin user created successfully!");
    console.log("==================================");
    console.log("Admin Credentials:");
    console.log("Email: adminchennaifl@gmail.com");
    console.log("Password: admin@123");
    console.log("User ID:", adminUser.id);
    console.log("Name:", adminUser.name);
    console.log("Role:", adminUser.role);
    console.log("==================================");
  } catch (error) {
    console.error("❌ Error seeding admin user:", error.message);
    if (error.errors) {
      error.errors.forEach((err) => {
        console.error(`  - ${err.message}`);
      });
    }
  } finally {
  }
}

module.exports = seedAdminUser;
