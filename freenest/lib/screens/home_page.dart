import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/screens/views/order/cart_screen.dart';
import 'package:freenest/screens/views/home/home_screen.dart';
import 'package:freenest/screens/views/order/order_screen.dart';
import 'package:freenest/screens/views/profile/profile_screen.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/cart_service.dart';
import 'package:freenest/service/shared_service.dart';

class HomePage extends StatefulWidget {
  static String routeName = UiScreenRoutes.home;
  const HomePage({super.key});
  static final GlobalKey<_HomePageState> homePageKey =
      GlobalKey<_HomePageState>();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  int _cartCount = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _screens.addAll([
      const HomeScreen(),
      const OrderScreen(),
      const ProfileScreen(),
    ]);
    _loadCartCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This will trigger when the app state changes (comes to foreground)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCartCount();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Reload cart count when switching to home tab
    if (index == 0) {
      _loadCartCount();
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final cart = await CartApiService.getCart();
      if (mounted) {
        setState(() => _cartCount = cart.length);
      }
    } catch (e) {
      print('Error loading cart count: $e');
    }
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
                                // Use await to wait for cart screen to close
                                await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const CartScreen()))
                                    .then((_) {
                                  _loadCartCount();
                                });
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
            : _selectedIndex == 1
                ? []
                : [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: _logout,
                      ),
                    )
                  ], // No actions for other screens
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
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
