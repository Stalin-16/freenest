import 'package:flutter/material.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/account_service.dart';
import 'package:freenest/service/shared_service.dart';
import 'package:freenest/widgets/snackbar_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  UserModel? editedUser; // To hold edited values
  bool isLoading = true;
  bool isLoggedIn = false;
  bool isEditing = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final AccountService _accountService = AccountService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await SharedService.isLoggedIn();
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
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phoneNo?.toString() ?? '';
      isLoading = false;
    });
  }

  void _startEditing() {
    setState(() {
      isEditing = true;
      editedUser = UserModel(
        name: user?.name,
        email: user?.email,
        phoneNo: user?.phoneNo,
        // Add other fields as needed
      );
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phoneNo?.toString() ?? '';
    });
  }

  void _cancelEditing() {
    setState(() {
      isEditing = false;
      editedUser = null;
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phoneNo?.toString() ?? '';
    });
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      try {
        // Update the user object
        user = user?.copyWith(
          name: _nameController.text.trim(),
          phoneNo: int.tryParse(_phoneController.text.trim()),
        );

        final Map<String, dynamic> data = {
          "id": user?.id,
          "name": _nameController.text.trim(),
          "phoneNo": int.tryParse(_phoneController.text.trim()),
        };

        final response = await _accountService.updateUser(data);
        print("Response: $response");
        if (response.status == 200) {
          await SharedService.setUser(user!);
        }

        // Update UI
        setState(() {
          isEditing = false;
          editedUser = null;
          isLoading = false;
        });

        // Show success message
        if (mounted) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Profile updated successfully!',
          );
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
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

  Widget _buildEditableHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Name',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your name',
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: theme.colorScheme.onBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Email field (read-only)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    user?.email ?? 'No email',
                    style: TextStyle(
                      fontSize: isLargeScreen ? 16 : 14,
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Phone number field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter your phone number',
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 16 : 14,
                    color: theme.colorScheme.onBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (!RegExp(r'^[0-9]{10}$').hasMatch(value.trim())) {
                      return 'Please enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          // Save/Cancel buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelEditing,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: theme.colorScheme.onBackground,
                      side: BorderSide(
                        color: theme.dividerColor.withOpacity(0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.onPrimary,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalHeader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return Row(
      children: [
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
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user!.phoneNo?.toString() ?? '',
                style: TextStyle(
                  fontSize: isLargeScreen ? 14 : 12,
                  color: theme.colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.edit,
            color: theme.colorScheme.primary,
            size: 18,
          ),
          onPressed: _startEditing,
        ),
      ],
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
      appBar: isEditing
          ? AppBar(
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onBackground,
                ),
                onPressed: _cancelEditing,
              ),
              title: Text(
                'Edit Profile',
                style: TextStyle(
                  color: theme.colorScheme.onBackground,
                ),
              ),
            )
          : null,
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
                if (isEditing) _buildEditableHeader() else _buildNormalHeader(),
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
              // Only show when not editing
              if (!isEditing) ...[
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
              ],
            ],
          ),
        ),
      ),
    );
  }
}
