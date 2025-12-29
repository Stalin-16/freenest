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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate total number of order items across all orders
    int totalItems = 0;
    for (final order in orders) {
      totalItems += order.orderItems.length;
    }

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : totalItems == 0
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: totalItems,
                    itemBuilder: (context, index) {
                      // Find which order and order item this index corresponds to
                      final (order, orderItem) = _findOrderItemByIndex(index);

                      return _buildOrderItemCard(
                          order, orderItem, theme, isDark);
                    },
                  ),
                ),
    );
  }

  /// Helper function to find order and orderItem by global index
  (OrderModel order, OrderItem orderItem) _findOrderItemByIndex(int index) {
    int currentIndex = 0;
    for (final order in orders) {
      if (index < currentIndex + order.orderItems.length) {
        final itemIndex = index - currentIndex;
        return (order, order.orderItems[itemIndex]);
      }
      currentIndex += order.orderItems.length;
    }
    throw Exception('Index out of bounds');
  }

  Widget _buildOrderItemCard(
    OrderModel order,
    OrderItem orderItem,
    ThemeData theme,
    bool isDark,
  ) {
    final profile = orderItem.profile;

    return InkWell(
      onTap: () {
        // Create a temporary order with just this item for details screen
        final tempOrder = OrderModel(
          id: order.id,
          userId: order.userId,
          baseAmount: orderItem.totalPrice,
          gstAmount: 0, // You might want to calculate this per item
          totalAmount: orderItem.totalPrice,
          createdAt: order.createdAt,
          updatedAt: order.updatedAt,
          orderItems: [orderItem],
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkOrderDetailsScreen(order: tempOrder),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                  child: profile.profileImage != null
                      ? Image.network(
                          "${AppConfig.imageUrl}${profile.profileImage!}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.serviceTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${profile.experienceRange} Years Experience',
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '${orderItem.quantity} Hrs',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '×',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '₹${orderItem.price.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '=',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                '₹${orderItem.totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              /// RIGHT SIDE - Compact version
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(orderItem.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: 6),
                  _itemStatusWidget(orderItem, theme, isDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ---------------- COMPACT STATUS WIDGET ----------------
  Widget _itemStatusWidget(OrderItem orderItem, ThemeData theme, bool isDark) {
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
      "order placed": "Placed",
      "getting ready": "Getting Ready",
      "in progress": "In Progress",
      "completed": "Completed",
      "cancelled": "Cancelled",
    };

    String statusKey = orderItem.status.toLowerCase();
    String label = statusLabels[statusKey] ?? orderItem.status;

    // Special case for completed with review
    if (statusKey == "completed" && orderItem.hasReview) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.withOpacity(0.3), width: 0.5),
        ),
        child: Text(
          "Rated⭐",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    // Special case for completed without review
    if (statusKey == "completed" && !orderItem.hasReview) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.orange.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rate",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              "⭐",
              style: TextStyle(fontSize: 8),
            ),
          ],
        ),
      );
    }

    // Get the text color for this status
    Color textColor = statusColors[statusKey] ?? Colors.grey;

    // Create background color from text color with opacity
    Color bgColor = textColor.withOpacity(isDark ? 0.15 : 0.08);

    // For default/grey status
    if (!statusColors.containsKey(statusKey)) {
      bgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
    }

    // Make label shorter for mobile
    String compactLabel = label;
    if (label.length > 10) {
      // Shorten long status labels
      if (label.toLowerCase().contains("getting ready")) compactLabel = "Ready";
      if (label.toLowerCase().contains("in progress"))
        compactLabel = "Progress";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        compactLabel,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}
