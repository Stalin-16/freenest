import 'package:flutter/material.dart';
import 'package:freenest/service/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cart = [];
  bool isLoggedIn = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() => isLoading = true);

    if (isLoggedIn) {
      // TODO: Fetch from your API if user logged in
      // final apiCart = await CartApiService.getCart();
      // cart = apiCart;
    } else {
      cart = await CartService.getCart();
    }

    setState(() => isLoading = false);
  }

  Future<void> _updateQuantity(int index, int newQuantity) async {
    if (newQuantity <= 0) return;

    setState(() {
      cart[index]['quantity'] = newQuantity;
    });

    if (!isLoggedIn) {
      await CartService.updateQuantity(cart[index]['title'], newQuantity);
    } else {
      // TODO: Update quantity in your API
    }
  }

  Future<void> _removeItem(String title) async {
    await CartService.removeFromCart(title);
    _loadCart();
  }

  void _proceedToCheckout() {
    if (!isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to proceed')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, '/checkout');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final total = cart.fold<double>(
      0,
      (sum, item) => sum + (item['hourlyRate'] ?? 0) * (item['quantity'] ?? 1),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item['image'] ?? '',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] ?? 'Untitled',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹${item['hourlyRate']}',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _updateQuantity(
                                  index, (item['quantity'] ?? 1) - 1),
                            ),
                            Text('${item['quantity'] ?? 1}',
                                style: const TextStyle(fontSize: 16)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _updateQuantity(
                                  index, (item['quantity'] ?? 1) + 1),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeItem(item['title']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black12)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("₹${total.toStringAsFixed(2)}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _proceedToCheckout,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Proceed to Checkout',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'cart_service.dart'; // your existing service

// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});

//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }

// class _CartScreenState extends State<CartScreen> {
//   List<Map<String, dynamic>> cart = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadCart();
//   }

//   Future<void> _loadCart() async {
//     final items = await CartService.getCart(); // your existing getCart() logic
//     setState(() {
//       cart = items;
//     });
//   }

//   Future<void> _removeItem(String title) async {
//     await CartService.removeFromCart(title);
//     _loadCart();
//   }

//   void _proceedToCheckout() {
//     // implement checkout navigation or logic here
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Proceeding to checkout...')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Cart')),
//       body: cart.isEmpty
//           ? const Center(child: Text('Your cart is empty'))
//           : ListView.builder(
//               itemCount: cart.length,
//               itemBuilder: (context, index) {
//                 final item = cart[index];
//                 return StatefulBuilder(
//                   builder: (context, setItemState) {
//                     bool isChecked = true; // default all items checked

//                     return CheckboxListTile(
//                       value: isChecked,
//                       onChanged: (bool? value) async {
//                         setItemState(() => isChecked = value ?? false);

//                         // If unchecked, remove the item
//                         if (value == false) {
//                           await _removeItem(item['title']);
//                         }
//                       },
//                       secondary: Image.network(
//                         item['img'],
//                         height: 40,
//                         width: 40,
//                         fit: BoxFit.cover,
//                       ),
//                       title: Text(item['title']),
//                       subtitle: item['price'] != null
//                           ? Text('₹${item['price']}')
//                           : null,
//                       controlAffinity: ListTileControlAffinity.leading,
//                     );
//                   },
//                 );
//               },
//             ),
//       bottomNavigationBar: cart.isEmpty
//           ? const SizedBox.shrink()
//           : Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ElevatedButton(
//                 onPressed: _proceedToCheckout,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text(
//                   'Proceed to Checkout',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               ),
//             ),
//     );
//   }
// }
