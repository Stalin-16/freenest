import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/model/user_model.dart';
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

  Future<void> sendOtp() async {
    if (emailCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final auth = AuthService();
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
      final auth = AuthService();
      final data = await auth.verifyOtp(emailCtrl.text, otpCtrl.text);

      if (data['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Success')),
        );
        // Navigate to home
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
      await _googleSignIn.disconnect();

      final googleUser = await _googleSignIn.signIn();
      print( "Google user: $googleUser");
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Sign-in canceled')),
        );
        return;
      }

      // Call backend
      final res = await auth.googleLogin(googleUser.email, googleUser.id,googleUser.displayName);
      print("Google login response: $res");

      // Save token and user
      await SharedService.setToken(res.data['token']);
      final user = UserModel.fromJson(res.data['user']);
      await SharedService.setUser(user);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Login Success')),
      );
    } catch (e) {
      print("Google login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Colors.indigoAccent;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigoAccent.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 60, color: themeColor),
                const SizedBox(height: 20),
                Text(
                  otpSent ? 'Verify OTP' : 'Login / Sign Up',
                  style: TextStyle(
                    color: themeColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Email input
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: themeColor),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: themeColor),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  enabled: !otpSent,
                ),
                const SizedBox(height: 20),
                if (otpSent)
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      prefixIcon: Icon(Icons.pin_outlined, color: themeColor),
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: themeColor),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                const SizedBox(height: 25),

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : otpSent
                            ? verifyOtp
                            : sendOtp,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            otpSent ? 'Verify OTP' : 'Send OTP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text('OR', style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 20),

                // Google sign in
                OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata,
                      size: 28, color: Colors.red),
                  label: const Text('Continue with Google',
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  onPressed: isLoading ? null : handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
