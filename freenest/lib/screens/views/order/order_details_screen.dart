import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/service/review_service.dart';
import 'package:freenest/widgets/reffera_card_widget.dart';
import 'package:freenest/widgets/service_provider_card_widget.dart';

class WorkOrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const WorkOrderDetailsScreen({super.key, required this.order});

  @override
  State<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends State<WorkOrderDetailsScreen> {
  bool isDarkMode = false;
  bool isLoading = false;
  final Map<int, double> ratings = {};
  final Map<int, String> comments = {};

  @override
  void initState() {
    super.initState();
    // _fetchOrder();
  }

  Future<void> _submitReview(int orderId) async {
    final rating = ratings[orderId] ?? 0;
    final comment = comments[orderId] ?? '';

    try {
      setState(() => isLoading = true);

      await ReviewApiService.submitReview(
        orderId: orderId,
        rating: rating,
        comment: comment,
      );

      // Refresh order to get updated data with review
      // await _fetchOrder();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Work Order Details'),
        ),
        body: const Center(
          child: Text('Order not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Work Order Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Fixed padding value
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Work Order Card - Updated with actual order data
                ServiceProviderCard(
                  serviceTitle: widget.order.serviceTitle,
                  profileImage: widget.order.imageUrl != null
                      ? "${AppConfig.imageUrl}${widget.order.imageUrl}"
                      : "",
                  viewDetails: false,
                  experience: widget.order.yearsofExperience ?? 0,
                  rating: widget.order?.review?.rating ?? 0.0,
                  workOrders: widget.order.totalhours ?? 0,
                  price: widget.order?.totalPrice ?? 0.0,
                  showAddButton: false,
                  onAddPressed: () {},
                  isDark: isDark,
                ),

                const SizedBox(height: 16),

                // Payment Receipt and Invoice Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.receipt),
                        label: const Text('Payment Receipt'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement invoice view
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.description),
                        label: const Text('Invoice'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Order Rating Section - Updated to use actual order ID
                Card(
                  elevation: 2,
                  color: theme.colorScheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Order Rating',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Help us improve by rating your experience',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Show rating input if not rated, or show existing rating
                        // if (order?.rating != null && order!.rating! > 0)
                        //   Column(
                        //     children: [
                        //       Text(
                        //         'Your Rating: ${order!.rating!.toStringAsFixed(1)}/5',
                        //         style: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: theme.colorScheme.primary,
                        //         ),
                        //       ),
                        //       if (order?.review != null && order!.review!.isNotEmpty)
                        //         Padding(
                        //           padding: const EdgeInsets.only(top: 8.0),
                        //           child: Text(
                        //             '"${order!.review!}"',
                        //             textAlign: TextAlign.center,
                        //             fontStyle: FontStyle.italic,
                        //           ),
                        //         ),
                        //     ],
                        //   )
                        // else
                        //   SizedBox(
                        //     width: double.infinity,
                        //     child: ElevatedButton(
                        //       onPressed: () {
                        //         // TODO: Show rating dialog
                        //         _showRatingDialog(context);
                        //       },
                        //       style: ElevatedButton.styleFrom(
                        //         backgroundColor: theme.colorScheme.primary,
                        //         foregroundColor: Colors.white,
                        //         padding: const EdgeInsets.symmetric(vertical: 12),
                        //       ),
                        //       child: const Text(
                        //         'Rate Now',
                        //         style: TextStyle(fontSize: 16),
                        //       ),
                        //     ),
                        //   ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Referral Section
                ReferralCard(
                  onViewDetails: () {
                    print("Referral view details tapped");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Your Experience'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add rating widgets here (stars, text field)
            const Text('How was your experience?'),
            const SizedBox(height: 16),
            // Add your rating input widgets
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _submitReview(widget.order.id);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
