import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/service/shared_service.dart';

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
    _navigateToNextScreen();
  }

  bool isLoggedIn = false;

  void _navigateToNextScreen() async {
    isLoggedIn = await SharedService.isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, "/home");
      return;
    }
    Navigator.pushReplacementNamed(context, "/login");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content Centered
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Your Logo
                    Image.asset(
                      'assets/images/loginL.png',
                      height: isSmallScreen
                          ? size.height * 0.25
                          : size.height * 0.3,
                      width:
                          isSmallScreen ? size.width * 0.6 : size.width * 0.4,
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: isSmallScreen ? 30 : 40),

                    // "Let's Build Together" Text - Made Bolder
                    Text(
                      "Let's Build Together",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Powered By Text at Bottom
            Positioned(
              bottom: isSmallScreen ? 20 : 30,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Powered By Inaivorks.com',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
