const bcrypt = require("bcrypt");
const User = require("../../model/userModel");
const { Op } = require("sequelize");

const freelancerController = {
  // Get all freelancers with pagination, search, and filtering
  async getFreelancers(req, res) {
    try {
      const {
        page = 1,
        limit = 10,
        search = "",
        status,
        role = "freelancer",
        sortBy = "createdAt",
        sortOrder = "DESC",
      } = req.body;

      const pageNum = parseInt(page);
      const limitNum = parseInt(limit);
      const offset = (pageNum - 1) * limitNum;

      // Build where clause
      const where = {
        role: role,
      };

      // Add status filter if provided
      if (status && status !== "all") {
        where.status = status;
      }

      // Add search filter
      if (search) {
        where[Op.or] = [
          { name: { [Op.like]: `%${search}%` } },
          { email: { [Op.like]: `%${search}%` } },
          { mobile: { [Op.like]: `%${search}%` } },
        ];
      }

      // Get total count
      const total = await User.count({ where });

      // Get paginated data
      const freelancers = await User.findAll({
        where,
        attributes: {
          exclude: ["password", "otp", "otpExpires"],
        },
        order: [[sortBy, sortOrder]],
        limit: limitNum,
        offset: offset,
      });

      res.json({
        success: true,
        data: freelancers,
        pagination: {
          total,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum),
          hasNextPage: pageNum < Math.ceil(total / limitNum),
          hasPrevPage: pageNum > 1,
        },
      });
    } catch (error) {
      console.error("Error fetching freelancers:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching freelancers",
        error: error.message,
      });
    }
  },

  // Get single freelancer by ID
  async getFreelancerById(req, res) {
    try {
      const { id } = req.params;

      const freelancer = await User.findOne({
        where: {
          id,
          role: "freelancer",
        },
        attributes: { exclude: ["password", "otp", "otpExpires"] },
      });

      if (!freelancer) {
        return res.status(404).json({
          success: false,
          message: "Freelancer not found",
        });
      }

      res.json({
        success: true,
        data: freelancer,
      });
    } catch (error) {
      console.error("Error fetching freelancer:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching freelancer",
        error: error.message,
      });
    }
  },

  // Create new freelancer
  async createFreelancer(req, res) {
    try {
      const { name, email, mobile, password, hourlyRate, experience } =
        req.body;

      // Check if user already exists
      const existingUser = await User.findOne({ where: { email } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: "User with this email already exists",
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(
        password || "defaultPassword123",
        10
      );

      // Create freelancer
      const freelancer = await User.create({
        name,
        email,
        mobile,
        password: hashedPassword,
        role: "freelancer",
        status: "pending", // Default to pending approval
        isActive: true,
        hourlyRate: hourlyRate || 0,
        experience: experience || 0,
      });

      // Remove sensitive data from response
      const {
        password: _,
        otp,
        otpExpires,
        ...freelancerData
      } = freelancer.toJSON();

      res.status(201).json({
        success: true,
        message: "Freelancer created successfully. Status: Pending Approval",
        data: freelancerData,
      });
    } catch (error) {
      console.error("Error creating freelancer:", error);
      res.status(500).json({
        success: false,
        message: "Error creating freelancer",
        error: error.message,
      });
    }
  },

  // Update freelancer status (approve/reject)
  async updateFreelancerStatus(req, res) {
    try {
      const { id } = req.params;
      const { status } = req.body;

      // Validate status
      if (!["approved", "pending", "rejected"].includes(status)) {
        return res.status(400).json({
          success: false,
          message:
            'Invalid status. Must be "approved", "pending", or "rejected"',
        });
      }

      const freelancer = await User.findOne({
        where: {
          id,
          role: "freelancer",
        },
      });

      if (!freelancer) {
        return res.status(404).json({
          success: false,
          message: "Freelancer not found",
        });
      }

      // Update status
      await freelancer.update({ status });

      // Remove sensitive data from response
      const { password, otp, otpExpires, ...updatedFreelancer } =
        freelancer.toJSON();

      res.json({
        success: true,
        message: `Freelancer ${
          status === "approved"
            ? "approved"
            : status === "rejected"
            ? "rejected"
            : "set to pending"
        } successfully`,
        data: updatedFreelancer,
      });
    } catch (error) {
      console.error("Error updating freelancer status:", error);
      res.status(500).json({
        success: false,
        message: "Error updating freelancer status",
        error: error.message,
      });
    }
  },

  // Update freelancer details
  async updateFreelancer(req, res) {
    try {
      const { id } = req.params;
      const updates = req.body;

      // Remove fields that shouldn't be updated directly
      delete updates.password;
      delete updates.role;
      delete updates.id;

      const freelancer = await User.findOne({
        where: {
          id,
          role: "freelancer",
        },
      });

      if (!freelancer) {
        return res.status(404).json({
          success: false,
          message: "Freelancer not found",
        });
      }

      // Update freelancer
      await freelancer.update(updates);

      // Remove sensitive data from response
      const { password, otp, otpExpires, ...updatedFreelancer } =
        freelancer.toJSON();

      res.json({
        success: true,
        message: "Freelancer updated successfully",
        data: updatedFreelancer,
      });
    } catch (error) {
      console.error("Error updating freelancer:", error);
      res.status(500).json({
        success: false,
        message: "Error updating freelancer",
        error: error.message,
      });
    }
  },

  // Delete freelancer
  async deleteFreelancer(req, res) {
    try {
      const { id } = req.params;

      const freelancer = await User.findOne({
        where: {
          id,
          role: "freelancer",
        },
      });

      if (!freelancer) {
        return res.status(404).json({
          success: false,
          message: "Freelancer not found",
        });
      }

      await freelancer.destroy();

      res.json({
        success: true,
        message: "Freelancer deleted successfully",
      });
    } catch (error) {
      console.error("Error deleting freelancer:", error);
      res.status(500).json({
        success: false,
        message: "Error deleting freelancer",
        error: error.message,
      });
    }
  },

  // Get freelancer statistics
  async getFreelancerStats(req, res) {
    try {
      const total = await User.count({ where: { role: "freelancer" } });
      const approved = await User.count({
        where: { role: "freelancer", status: "approved" },
      });
      const pending = await User.count({
        where: { role: "freelancer", status: "pending" },
      });
      const active = await User.count({
        where: { role: "freelancer", isActive: true },
      });
      const inactive = await User.count({
        where: { role: "freelancer", isActive: false },
      });

      res.json({
        success: true,
        data: {
          total,
          approved,
          pending,
          active,
          inactive,
          approvedPercentage:
            total > 0 ? Math.round((approved / total) * 100) : 0,
        },
      });
    } catch (error) {
      console.error("Error fetching freelancer stats:", error);
      res.status(500).json({
        success: false,
        message: "Error fetching freelancer statistics",
        error: error.message,
      });
    }
  },
};

module.exports = freelancerController;
