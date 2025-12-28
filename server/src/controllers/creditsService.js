const { Sequelize } = require("sequelize");
const UserCredits = require("../model/creditActivity");

exports.getTransactionSummary = async (req, res) => {
  try {
    const userId = req.user?.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    // Get paginated transactions
    const { count: total, rows: transactions } =
      await UserCredits.findAndCountAll({
        where: {
          user_id: userId,
          // status: "1",
        },
        order: [["created_at", "DESC"]],
        limit: limit,
        offset: offset,
      });

    res.json({
      status: 200,
      data: transactions,
      pagination: {
        page: page,
        limit: limit,
        total: total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error("Error fetching transaction summary:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};
exports.getBalance = async (req, res) => {
  try {
    const userId = req.user?.id || req.query.user_id;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: "User ID is required",
      });
    }

    const currentBalance = await UserCredits.findAll({
      attributes: [
        "activity_type",
        [Sequelize.fn("SUM", Sequelize.col("amount")), "total_amount"],
      ],
      where: {
        user_id: userId,
        status: "1",
      },
      group: ["activity_type"],
      raw: true,
    });

    let balance = 0;
    currentBalance.forEach((item) => {
      if (item.activity_type === "credit") {
        balance += parseFloat(item.total_amount || 0);
      } else {
        balance -= parseFloat(item.total_amount || 0);
      }
    });

    res.json({
      success: true,
      status: 200,
      message: "Balance fetched successfully",
      data: parseFloat(balance.toFixed(2)),
    });
  } catch (error) {
    console.error("Error fetching balance:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};
