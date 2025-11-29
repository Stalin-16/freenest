import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = UiScreenRoutes.splash;
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(
          context, '/home'); // Replace with your next screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Change background color as needed
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your Logo
            Image.asset(
              'assets/images/logo.png', // Update with your actual logo path
              height: 120,
              width: 120,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 40),

            // "Chenai" Text
            Text(
              'Chennai',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900], // Adjust color to match your design
              ),
            ),

            const SizedBox(height: 20),

            // "Freelancers" Text
            Text(
              'Freelancers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 40),

            // "Let's Build Together" Text
            Text(
              "Let's Build Together",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 60),

            // Powered By Text
            Text(
              'Powered By Inaivorks.com',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
