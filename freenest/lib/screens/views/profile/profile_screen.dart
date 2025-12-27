import 'package:flutter/material.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/shared_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await SharedService.isLoggedIn();
    // isLoggedIn = true;
    if (isLoggedIn) {
      await _loadUser();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadUser() async {
    final u = await SharedService.getUser();
    setState(() {
      user = u;
      isLoading = false;
    });
  }

  void _logout() async {
    await SharedService.logggedOutWithOutContext();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _navigateToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Helper method to build list items
  Widget _buildListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onBackground.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isLargeScreen ? 24.0 : 16.0,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== HEADER ==========
              if (isLoggedIn && user != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: isLargeScreen ? 28 : 24,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: isLargeScreen ? 28 : 24,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user!.name ?? 'User',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 18 : 16,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user!.email ?? '',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 14 : 12,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user!.id.toString() ?? '',
                            style: TextStyle(
                              fontSize: isLargeScreen ? 14 : 12,
                              color: theme.colorScheme.onBackground
                                  .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 32),

              // ========== ACTION BUTTON ==========
              if (!isLoggedIn) ...[
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Let's Build Together",
                        style: TextStyle(
                          fontSize: isLargeScreen ? 24 : 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isLargeScreen ? 300 : 200,
                      height: isLargeScreen ? 56 : 50,
                      child: ElevatedButton(
                        onPressed: _navigateToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isDark ? theme.colorScheme.primary : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Sign Up & Start Hiring",
                          style: TextStyle(
                            fontSize: isLargeScreen ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // ========== ACCOUNT INFO CARD ==========
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Account Credit
                      _buildListItem(
                        title: "Account Credit",
                        subtitle: isLoggedIn ? "Rs. 500" : "Rs. 0",
                        icon: Icons.credit_card,
                        context: context,
                        onTap: () {
                          // Navigate to Account Credit Screen
                          Navigator.pushNamed(context, '/account-credit');
                        },
                      ),

                      Divider(
                        height: 0,
                        color: theme.dividerColor.withOpacity(0.2),
                        thickness: 1,
                      ),

                      // Billing
                      _buildListItem(
                        title: "Billing",
                        subtitle: "Refer and Earn 5%",
                        icon: Icons.receipt,
                        context: context,
                        onTap: () {},
                      ),

                      Divider(
                        height: 0,
                        color: theme.dividerColor.withOpacity(0.2),
                        thickness: 1,
                      ),

                      // Settings
                      _buildListItem(
                        title: "Settings",
                        subtitle: "About Chennai Freelancers",
                        icon: Icons.settings,
                        context: context,
                        onTap: () {},
                      ),

                      Divider(
                        height: 0,
                        color: theme.dividerColor.withOpacity(0.2),
                        thickness: 1,
                      ),

                      // Help and Support
                      _buildListItem(
                        title: "Help and Support",
                        subtitle: "",
                        icon: Icons.help_outline,
                        context: context,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // // ========== LOGOUT BUTTON ==========
              // if (isLoggedIn) ...[
              //   SizedBox(
              //     width: double.infinity,
              //     height: isLargeScreen ? 56 : 50,
              //     child: OutlinedButton.icon(
              //       onPressed: _logout,
              //       icon: Icon(
              //         Icons.logout,
              //         size: isLargeScreen ? 22 : 20,
              //         color: theme.colorScheme.error,
              //       ),
              //       label: Text(
              //         'Logout',
              //         style: TextStyle(
              //           fontSize: isLargeScreen ? 16 : 14,
              //           fontWeight: FontWeight.w500,
              //           color: theme.colorScheme.error,
              //         ),
              //       ),
              //       style: OutlinedButton.styleFrom(
              //         foregroundColor: theme.colorScheme.error,
              //         side: BorderSide(color: theme.colorScheme.error),
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(12),
              //         ),
              //       ),
              //     ),
              //   ),
              //   SizedBox(height: isLargeScreen ? 32 : 24),
              // ] else ...[
              //   SizedBox(height: isLargeScreen ? 32 : 24),
              // ],
            ],
          ),
        ),
      ),
    );
  }
}
