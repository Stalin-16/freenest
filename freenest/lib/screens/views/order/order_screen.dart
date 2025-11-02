// lib/screens/views/order/order_screen.dart
import 'package:flutter/material.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/service/oerder_service.dart';

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
      final fetchedOrders = await OrderApiService.getOrders();
      print(fetchedOrders);
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? const Center(
                  child:
                      Text('No orders found', style: TextStyle(fontSize: 16)),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 2 : 1,
                    childAspectRatio: isTablet ? 2.5 : 2.0,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                                "Items: ${order.totalItems} | ₹${order.totalPrice.toStringAsFixed(2)}"),
                            Text("Status: ${order.status}"),
                            Text(
                                "Date: ${order.createdAt.toLocal().toString().split(' ')[0]}"),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: order.orderItems.length,
                                itemBuilder: (context, i) {
                                  final item = order.orderItems[i];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(item.productName ?? "Unknown"),
                                    subtitle: Text(
                                        "${item.quantity} × ₹${item.price.toStringAsFixed(2)}"),
                                    trailing: Text(
                                      "₹${item.totalPrice.toStringAsFixed(2)}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                },
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
