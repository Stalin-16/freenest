import 'package:flutter/material.dart';
import 'package:freenest/screens/home_page.dart';
import 'package:freenest/screens/login_screen.dart';
import 'package:freenest/screens/splash_screen.dart';
import 'package:freenest/screens/views/home/profile_list_screen.dart';
import 'package:freenest/screens/views/order/cart_screen.dart';
import 'package:freenest/screens/views/order/check_out_screen.dart';
import 'package:freenest/screens/views/profile/credit/account_credit_scree.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  CheckoutScreen.routeName: (context) => const CheckoutScreen(),
  CartScreen.routeName: (context) => const CartScreen(),
  HomePage.routeName: (context) => const HomePage(),
  ProfileListScreen.routeName: (context) => const ProfileListScreen(),
  AccountCreditScreen.routeName: (context) => const AccountCreditScreen(),
};
