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
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    cart = await CartService.getCart();
    setState(() {});
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
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  leading: Image.network(item['img'], height: 40),
                  title: Text(item['title']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await CartService.removeFromCart(item['title']);
                      _loadCart();
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          onPressed: _proceedToCheckout,
          child: const Text('Proceed to Checkout'),
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
