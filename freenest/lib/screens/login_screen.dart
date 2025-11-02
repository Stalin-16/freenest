import 'package:flutter/material.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/model/cart_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final padding = size.width < 600 ? 20.0 : 40.0; // responsive padding
    final boxWidth =
        size.width < 600 ? double.infinity : 400.0; // responsive box

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 40),
          child: Container(
            width: boxWidth,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline, size: 60, color: colorScheme.primary),
                const SizedBox(height: 20),
                Text(
                  otpSent ? 'Verify OTP' : 'Login / Sign Up',
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Email field
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !otpSent,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon:
                        Icon(Icons.email_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: isDark
                        ? colorScheme.surfaceVariant
                        : colorScheme.surface,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // OTP field
                if (otpSent)
                  TextField(
                    controller: otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      prefixIcon:
                          Icon(Icons.pin_outlined, color: colorScheme.primary),
                      counterText: '',
                      filled: true,
                      fillColor: isDark
                          ? colorScheme.surfaceVariant
                          : colorScheme.surface,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.primary),
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
                      backgroundColor: colorScheme.primary,
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
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),
                Text('OR',
                    style: textTheme.bodyMedium
                        ?.copyWith(color: colorScheme.outline)),

                const SizedBox(height: 20),

                // Google Sign In
                OutlinedButton.icon(
                  icon: const Icon(Icons.g_mobiledata,
                      size: 30, color: Colors.red),
                  label: Text(
                    'Continue with Google',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  onPressed: isLoading ? null : handleGoogleLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: colorScheme.outlineVariant),
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
