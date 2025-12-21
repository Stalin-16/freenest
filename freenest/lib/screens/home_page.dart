import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/screens/views/order/cart_screen.dart';
import 'package:freenest/screens/views/home/home_screen.dart';
import 'package:freenest/screens/views/order/order_screen.dart';
import 'package:freenest/screens/views/profile/profile_screen.dart';
import 'package:freenest/service/cart_service.dart';
import 'package:freenest/service/shared_service.dart';

class HomePage extends StatefulWidget {
  static String routeName = UiScreenRoutes.home;
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _cartCount = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _loadCartCount();
    _screens.addAll([
      const HomeScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadCartCount() async {
    final cart = await CartService.getCart();
    setState(() => _cartCount = cart.length);
  }

  void _logout() async {
    await SharedService.logggedOutWithOutContext();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? ""
              : _selectedIndex == 1
                  ? "Work Orders"
                  : "Account",
        ),
        actions: _selectedIndex == 0 // Show actions only for Home screen
            ? [
                // Use Expanded to take available width and separate left/right content
                Expanded(
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: SizedBox(width: 8),
                      ),
                      DropdownButton<String>(
                        value: "India",
                        underline: const SizedBox(),
                        items: ["India", "USA", "UK", "UAE"]
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (v) {},
                      ),

                      // Spacer to push cart to the right end
                      const Spacer(),

                      // Right side - Cart icon with badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),
                              onPressed: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const CartScreen()),
                                ).then((_) => _loadCartCount());
                              },
                            ),
                          ),
                          if (_cartCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$_cartCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ]
            : null, // No actions for other screens
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Orders"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}
