import 'package:flutter/material.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/service/oerder_service.dart';
import 'package:freenest/service/review_service.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool isLoading = true;
  List<OrderModel> orders = [];
  final Map<int, double> ratings = {};
  final Map<int, String> comments = {};
  final Map<int, bool> showRatingSection = {};

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
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

      // Refresh orders to get updated data with review
      await _fetchOrders();
      
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

  Color _getStatusColor(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case "order placed":
        return Colors.orange;
      case "assigned":
        return Colors.blue;
      case "in progress":
        return Colors.amber;
      case "completed":
        return Colors.green;
      case "reviewed":
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    }
  }

  Widget _buildRatingSection(int orderId) {
    final rating = ratings[orderId] ?? 0;
    final comment = comments[orderId] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const Text(
          "Rate this service:",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return IconButton(
              icon: Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  ratings[orderId] = index + 1.0;
                });
              },
            );
          }),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLength: 300,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Write your feedback (max 300 chars)",
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          onChanged: (val) {
            comments[orderId] = val;
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    showRatingSection[orderId] = false;
                    ratings.remove(orderId);
                    comments.remove(orderId);
                  });
                },
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: rating > 0 && comment.isNotEmpty
                    ? () => _submitReview(orderId)
                    : null,
                icon: const Icon(Icons.send, size: 18),
                label: const Text("Submit Review"),
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child: Text(
                    'No orders found',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final statusColor = _getStatusColor(order.status, context);
                    final isCompleted = order.status.toLowerCase() == "completed";
                    final isReviewed = order.status.toLowerCase() == "reviewed";
                    final hasReview = order.review != null;

                    return Card(
                      color: isDark
                          ? Colors.grey[900]
                          : Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Order #${order.id}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Order summary
                            Text(
                              "Items: ${order.totalItems} | ₹${order.totalPrice.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            
                            Text(
                              "Date: ${order.createdAt.toLocal().toString().split(' ')[0]}",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                            
                            // Show review rating if exists
                            if (hasReview) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Rated: ${order.review!.rating}/5",
                                    style: TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            
                            const SizedBox(height: 12),
                            const Divider(),
                            
                            // Order items
                            ...order.orderItems.map((item) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                item.productName,
                                style: const TextStyle(fontSize: 14),
                              ),
                              subtitle: Text(
                                "${item.quantity} × ₹${item.price.toStringAsFixed(2)}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Text(
                                "₹${item.totalPrice.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            )).toList(),
                            
                            const SizedBox(height: 12),
                            
                            // Review section for completed orders
                            if (isCompleted && !isReviewed && !hasReview) ...[
                              if (showRatingSection[order.id] ?? false) 
                                _buildRatingSection(order.id)
                              else
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        showRatingSection[order.id] = true;
                                      });
                                    },
                                    icon: const Icon(Icons.rate_review),
                                    label: const Text("Add Review"),
                                  ),
                                ),
                            ],
                            
                            // Show thank you message for reviewed orders
                            if (isReviewed || hasReview) 
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Thank you for your review!",
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}