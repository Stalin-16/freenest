import 'package:flutter/material.dart';

class ServiceProviderCard extends StatelessWidget {
  final String serviceTitle;
  final String profileImage;
  final int experience;
  final double rating;
  final int workOrders;
  final double price;
  final bool showAddButton;
  final bool viewDetails;
  final VoidCallback? onAddPressed;
  final VoidCallback? onViewDetailsPressed;
  final bool isDark;

  const ServiceProviderCard({
    super.key,
    required this.serviceTitle,
    required this.profileImage,
    required this.experience,
    required this.rating,
    required this.workOrders,
    required this.price,
    this.showAddButton = true,
    this.viewDetails = true,
    this.onAddPressed,
    this.onViewDetailsPressed,
    required this.isDark,
  });

  String _formatWorkOrders(int orders) {
    if (orders >= 1000) {
      return '${(orders / 1000).toStringAsFixed(1)}K';
    }
    return orders.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.cardColor,
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  profileImage.isNotEmpty
                      ? profileImage // You can prepend your AppConfig.imageUrl here
                      : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    size: 30,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle Section - Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    serviceTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Experience
                  Row(
                    children: [
                      Icon(
                        Icons.work,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$experience Years Experience",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Rating and Work Orders
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$rating (${_formatWorkOrders(workOrders)} Work Orders)",
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withOpacity(0.87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // View details - on a separate line below rating
                  if (viewDetails)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: onViewDetailsPressed,
                        child: Text(
                          "View details",
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right Section - Price and Add Button (conditionally shown)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Price
                Text(
                  "Rs. ${price.toStringAsFixed(0)} / hour",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
                const SizedBox(height: 8),

                // Add Button (conditionally shown)
                if (showAddButton)
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      onPressed: onAddPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark ? colorScheme.primary : Colors.grey.shade700,
                        foregroundColor:
                            isDark ? colorScheme.onPrimary : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Add",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? colorScheme.onPrimary : Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
