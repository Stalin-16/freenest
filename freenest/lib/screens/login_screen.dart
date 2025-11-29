import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/model/token_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/cart_service.dart';
import 'package:freenest/service/shared_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:freenest/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = UiScreenRoutes.login;
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final otpCtrl = TextEditingController();
  final _googleSignIn = GoogleSignIn();
  bool otpSent = false;
  bool isLoading = false;
  final AuthService auth = AuthService();

  Future<void> syncCart() async {
    try {
      final localCart = await CartService.getCart();
      if (localCart.isEmpty) return;

      // Send local cart to backend
      final response = await CartApiService.syncCart(
          localCart.map((e) => e.toMap()).toList());

      if (response.status == 200) {
        await CartService.clearCart();
      } else {
        print(" Cart sync failed: ${response.message}");
      }
    } catch (e) {
      print(" Error syncing cart: $e");
    }
  }

  Future<void> sendOtp() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final response = await auth.sendOtp(emailCtrl.text);

      if (response['success'] == true) {
        setState(() => otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to send OTP')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifyOtp() async {
    if (otpCtrl.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 6-digit OTP')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final data = await auth.verifyOtp(emailCtrl.text, otpCtrl.text);

      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Success')),
        );
        await syncCart();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Invalid OTP')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> handleGoogleLogin() async {
    setState(() => isLoading = true);

    try {
      // _googleSignIn.disconnect();
      final googleUser =
          await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-in canceled')),
        );
        return;
      }

      final res = await auth.googleLogin(
        googleUser.email,
        googleUser.id,
        googleUser.displayName,
      );
      TokenModel tokenModel = TokenModel.fromMap(res.data);
      await SharedService.setToken(tokenModel);
      final user = UserModel.fromMap(res.data['user']);
      await SharedService.setUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Login Success')),
      );
      await syncCart();

      if (Navigator.canPop(context)) Navigator.pop(context);
    } catch (e) {
      _googleSignIn.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void continueAsGuest() {
    // Navigate to home screen as guest
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;
    final buttonColor =
        isDark ? Colors.blueGrey.shade700 : const Color(0xFF4A4A4A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // ---------------- LOGO ----------------
                    Image.asset(
                      'assets/images/logo.png',
                      height: size.height * 0.12,
                    ),

                    const SizedBox(height: 20),

                    // ---------------- TITLE ----------------
                    Text(
                      'Chennai Freelancers',
                      style: TextStyle(
                        fontSize: size.width * 0.065,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),

                    SizedBox(height: size.height * 0.05),

                    // ---------------- EMAIL FIELD ----------------
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !otpSent,
                      decoration: InputDecoration(
                        hintText: "Enter Email Address",
                        hintStyle: TextStyle(
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[700]),
                        filled: true,
                        fillColor: theme.cardColor,
                        suffixIcon: !otpSent
                            ? TextButton(
                                onPressed: isLoading ? null : sendOtp,
                                child: Text(
                                  "Get OTP",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: borderColor),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ---------------- OTP FIELD ----------------
                    if (otpSent)
                      TextField(
                        controller: otpCtrl,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter OTP",
                          counterText: "",
                          filled: true,
                          fillColor: theme.cardColor,
                          hintStyle: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[700]),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: borderColor),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // ---------------- SIGN UP BUTTON ----------------
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: otpSent ? verifyOtp : sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "Sign Up & Start Hiring",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // ---------------- OR DIVIDER ----------------
                    Row(
                      children: [
                        Expanded(child: Divider(color: borderColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            "(OR)",
                            style: TextStyle(color: primaryTextColor),
                          ),
                        ),
                        Expanded(child: Divider(color: borderColor)),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // ---------------- CONTINUE AS GUEST ----------------
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: continueAsGuest,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: buttonColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Continue as Guest",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.10),
                  ],
                ),
              ),
            ),

            // ---------------- FIXED BOTTOM FOOTER ----------------
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Powered By Inaiworks.com",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
