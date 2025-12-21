// ignore_for_file: unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/screens/views/order/order_details_screen.dart';
import 'package:freenest/service/order_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  List<OrderModel> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() => isLoading = true);
      final fetchedOrders = await OrderApiService.getOrders();
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day}-${months[date.month - 1]}-${date.year}';
  }

  /// ---------------- STATUS WIDGET ---------------- ///
  /// Returns a widget representing the status of the order.
  Map<String, Color> statusColors = {
    "getting ready": Colors.blue,
    "in progress": Colors.yellow,
    "completed": Colors.green,
    "cancelled": Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final totalPrice = order.totalhours * order.priceperhour;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => WorkOrderDetailsScreen(
                                  order: order,
                                )));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// LEFT ICON
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: order.imageUrl != null
                                  ? Image.network(
                                      "${AppConfig.imageUrl}${order.imageUrl!}",
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.work,
                                          color: theme.colorScheme.primary,
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.work,
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// CENTER CONTENT
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${order.serviceTitle}",
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${order.yearsofExperience} Years Experience",
                                  style: theme.textTheme.bodySmall,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${order.totalhours} Hrs x Rs. ${order.priceperhour} = Rs. $totalPrice",
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),

                          /// RIGHT SIDE
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(order.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              _statusWidget(order),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// ---------------- STATUS WIDGET ----------------

  Widget _statusWidget(OrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Define your status colors map
    Map<String, Color> statusColors = {
      "getting ready": Colors.blue,
      "order placed": Colors.indigo,
      "in progress": Colors.orange,
      "completed": Colors.green,
      "cancelled": Colors.red,
    };

    // Define status labels (optional - for display text)
    Map<String, String> statusLabels = {
      "order placed": "Order Placed",
      "getting ready": "Getting Ready",
      "in progress": "In Progress",
      "completed": "Completed",
      "cancelled": "Cancelled",
    };

    String statusKey = order.status.toLowerCase();
    String label = statusLabels[statusKey] ?? order.status;

    // Special case for completed with review
    if (statusKey == "completed" && order.review != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          "Rated⭐",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Special case for completed without review
    if (statusKey == "completed" && order.review == null) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => WorkOrderDetailsScreen(
                        order: order,
                      )));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Rate Now ⭐",
          style: TextStyle(
              fontSize: 12, color: !isDark ? Colors.white : Colors.black),
        ),
      );
    }

    // Get the text color for this status
    Color textColor = statusColors[statusKey] ?? Colors.grey;

    // Create background color from text color with opacity
    Color bgColor = textColor.withOpacity(isDark ? 0.2 : 0.1);

    // For default/grey status
    if (!statusColors.containsKey(statusKey)) {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    }

    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
