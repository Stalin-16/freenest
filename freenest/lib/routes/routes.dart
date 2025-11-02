import 'package:flutter/material.dart';
import 'package:freenest/screens/home_page.dart';
import 'package:freenest/screens/login_screen.dart';
import 'package:freenest/screens/views/order/cart_screen.dart';
import 'package:freenest/screens/views/order/check_out_screen.dart';

final Map<String, WidgetBuilder> routes = {
   LoginScreen.routeName: (context) => const LoginScreen(),
   CheckoutScreen.routeName: (context) => const CheckoutScreen(),
   CartScreen.routeName : (context) => const CartScreen(),
   HomePage.routeName: (context) => const HomePage(),
};
