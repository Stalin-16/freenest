import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/shared_service.dart';
import 'package:freenest/widgets/snackbar_utils.dart';

class CheckoutScreen extends StatefulWidget {
  static String routeName = UiScreenRoutes.checkout;
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool isLoading = false;
  bool isLoggedIn = false;
  List<Map<String, dynamic>> cart = [];
  bool useCredits = false; // Moved to state level
  double creditsAmount = 500.0; // Can be made dynamic from API
  bool _isErrorVisible = false;
  // Add these state variables for referral
  bool _isReferralApplied = false;
  double _referralDiscountPercentage =
      0.0; // Store discount percentage from API
  final TextEditingController _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  String _appliedPromoCode = "";

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    isLoggedIn = await SharedService.isLoggedIn();
    if (isLoggedIn) {
      await _loadCart();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadCart() async {
    UserModel? user = await SharedService.getUser();
    setState(() => isLoading = true);

    try {
      List<CartItemModel> loadedCart = [];
      if (user != null) {
        loadedCart = await CartApiService.getCart();
      }
      setState(() {
        cart = loadedCart.map((e) => e.toMap()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  double get totalAmount {
    return cart.fold(
      0,
      (sum, item) => sum + (item['hourlyRate'] * item['quantity']),
    );
  }

  double get reffralDiscount {
    // Apply discount only if referral is applied
    return _isReferralApplied
        ? totalAmount * (_referralDiscountPercentage / 100)
        : 0.0;
  }

  double get subtotalAfterDiscount {
    return totalAmount - reffralDiscount;
  }

  double get gstAmount {
    // Calculate GST on discounted amount
    return subtotalAfterDiscount * 0.18;
  }

  double get grandTotal {
    return subtotalAfterDiscount + gstAmount;
  }

  double get amountToPay {
    double amount = grandTotal;
    if (useCredits) {
      amount -= creditsAmount;
    }
    // Ensure amount is not negative
    return amount < 0 ? 0.0 : amount;
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => isLoading = true);
    try {
      if (isLoggedIn) {
        // Use the stored applied promo code
        final response = await CartApiService.checkout(_appliedPromoCode);
        if (response.status == 200) {
          CustomSnackBar.showSuccess(
            context: context,
            message: 'Order placed successfully!',
          );
          Navigator.pop(context);
        } else {
          setState(() => isLoading = false);
          CustomSnackBar.showError(
            context: context,
            message: response.message!,
          );
        }
      }
    } catch (e) {
      CustomSnackBar.showError(context: context, message: e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text('Your Cart',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart.isEmpty
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: textTheme.titleMedium,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth > 600 ? 24 : 16,
                          vertical: 16,
                        ),
                        children: [
                          /// CART ITEMS
                          ...cart.map(_cartItemCard).toList(),

                          const SizedBox(height: 16),

                          /// PROMO CODE
                          _promoCodeField(),

                          const SizedBox(height: 20),

                          /// PAYMENT SUMMARY
                          _paymentSummary(),
                        ],
                      ),
                    ),

                    /// PAY BUTTON
                    _bottomPayButton(),
                  ],
                ),
    );
  }

  /// ---------------- CART ITEM ----------------

  Widget _cartItemCard(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      surfaceTintColor: isDark ? Colors.grey[900] : Colors.grey[500],
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 16 : 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: screenWidth > 600 ? 28 : 24,
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(screenWidth > 600 ? 28 : 24),
                child: Image.network(
                  "${AppConfig.imageUrl}${item['imageUrl']}",
                  width: screenWidth > 600 ? 36 : 32,
                  height: screenWidth > 600 ? 36 : 32,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.person,
                    size: screenWidth > 600 ? 20 : 18,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ),
            ),
            SizedBox(width: screenWidth > 600 ? 16 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth > 600 ? 18 : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item['experience']} Years Experience',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: screenWidth > 600 ? 14 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        item['rating'] != null
                            ? item['rating'].toString()
                            : 'N/A',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: screenWidth > 600 ? 14 : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${item['workOrderCount'] ?? '0'} Work Orders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: screenWidth > 600 ? 14 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${item['hourlyRate']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 600 ? 18 : null,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth > 600 ? 12 : 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : theme.dividerColor,
                    ),
                  ),
                  child: Text(
                    item['quantity'].toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: screenWidth > 600 ? 15 : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- PROMO CODE ----------------
  Widget _promoCodeField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    Future<void> handleApplyPromoCode() async {
      String code = _promoController.text.trim();
      if (code.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a promo code')),
        );
        return;
      }

      setState(() {
        _isApplyingPromo = true;
        _isErrorVisible = false;
      });

      try {
        final response = await CartApiService.applyReferral(code);
        if (response.status == 200) {
          double discountPercentage = 5.0; // This should come from API response
          setState(() {
            _isReferralApplied = true;
            _referralDiscountPercentage = discountPercentage;
            _appliedPromoCode = code; // Store the applied code
            _isErrorVisible = false;
          });

          CustomSnackBar.showSuccess(
            context: context,
            message:
                'Referral code applied! You got $discountPercentage% discount.',
          );
        } else {
          setState(() {
            _isErrorVisible = true;
          });
          CustomSnackBar.showWarning(
            context: context,
            message: 'Invalid promo code. Please try again.',
          );
        }
      } catch (e) {
        setState(() {
          _isErrorVisible = true;
        });
        CustomSnackBar.showError(
          context: context,
          message: 'Error applying promo code. Please try again.',
        );
      } finally {
        setState(() => _isApplyingPromo = false);
      }
    }

    void removeReferral() {
      setState(() {
        _isReferralApplied = false;
        _referralDiscountPercentage = 0.0;
        _appliedPromoCode = ""; // Clear the applied code
        _promoController.clear();
        _isErrorVisible = false;
      });
      CustomSnackBar.showInfo(
        context: context,
        message: 'Referral code removed.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _promoController,
          enabled: !_isReferralApplied,
          decoration: InputDecoration(
            hintText: 'Enter Referral Code',
            hintStyle: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _isReferralApplied
                  ? IconButton(
                      onPressed: removeReferral,
                      icon:
                          const Icon(Icons.close, color: Colors.red, size: 20),
                      tooltip: 'Remove referral code',
                    )
                  : _isApplyingPromo
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: handleApplyPromoCode,
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: screenWidth > 600 ? 16 : null,
                            ),
                          ),
                        ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isErrorVisible
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isErrorVisible
                    ? Colors.red
                    : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isErrorVisible
                    ? Colors.red
                    : (isDark ? Colors.white : Colors.black),
                width: 1.5,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: screenWidth > 600 ? 20 : 16,
            ),
          ),
        ),
        // Optional: Show error message below the field
        if (_isErrorVisible)
          const Padding(
            padding: EdgeInsets.only(top: 4.0, left: 16),
            child: Text(
              'Invalid referral code. Please try again.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        if (_isReferralApplied)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Referral applied: $_referralDiscountPercentage% discount',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }

  /// ---------------- PAYMENT SUMMARY ----------------

  Widget _paymentSummary() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey[900] : Colors.white,
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(screenWidth > 600 ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: screenWidth > 600 ? 18 : null,
              ),
            ),
            const SizedBox(height: 12),
            _summaryRow('Item total', totalAmount),

            // Show referral discount if applied
            if (_isReferralApplied)
              _discountRow('Referral Discount', reffralDiscount),

            _summaryRow('Subtotal', subtotalAfterDiscount),
            _summaryRow('Tax GST @ 18%', gstAmount),
            const Divider(height: 24),
            _summaryRow(
              'Total amount',
              grandTotal,
              isBold: true,
            ),

            // Credits Section
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: useCredits,
                  onChanged: (bool? value) {
                    setState(() {
                      useCredits = value ?? false;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: Text(
                    useCredits
                        ? 'Using Credits ($creditsAmount)'
                        : 'Use Credits ($creditsAmount)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: screenWidth > 600 ? 16 : null,
                    ),
                  ),
                ),
              ],
            ),

            // Show credit deduction line when checked
            if (useCredits) _creditDeductionRow(),

            const Divider(height: 24),

            // Amount to Pay
            _summaryRow(
              'Amount to Pay',
              amountToPay,
              isBold: true,
              isLarge: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _discountRow(String label, double value) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: screenWidth > 600 ? 16 : null,
              color: Colors.green,
            ),
          ),
          Text(
            '-₹${value.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: screenWidth > 600 ? 16 : null,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _creditDeductionRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 40), // Space to align with checkbox
          Expanded(
            child: Text(
              'Credit Deduction',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth > 600 ? 16 : null,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
          ),
          Text(
            '-₹${creditsAmount.toStringAsFixed(0)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: screenWidth > 600 ? 16 : null,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double value,
      {bool isBold = false, bool isLarge = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth > 600 ? 8 : 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth > 600 ? 18 : null,
                    color: isDark ? Colors.white : Colors.black,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontSize: screenWidth > 600 ? 16 : null,
                    color: isDark ? Colors.white70 : Colors.grey[700],
                  ),
          ),
          Text(
            '₹${value.toStringAsFixed(0)}',
            style: isLarge
                ? TextStyle(
                    fontSize: screenWidth > 600 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  )
                : isBold
                    ? theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth > 600 ? 18 : null,
                        color: isDark ? Colors.white : Colors.black,
                      )
                    : theme.textTheme.bodyMedium?.copyWith(
                        fontSize: screenWidth > 600 ? 16 : null,
                        color: isDark ? Colors.white70 : Colors.grey[700],
                      ),
          ),
        ],
      ),
    );
  }

  /// ---------------- BOTTOM PAY BUTTON ----------------

  Widget _bottomPayButton() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth > 600 ? 20 : 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: isDark
            ? Border.all(color: Colors.grey[800]!)
            : Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Right align the button
        children: [
          ElevatedButton(
            onPressed: isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : Colors.black45,
              foregroundColor: isDark ? Colors.black : Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 48 : 40,
                vertical: screenWidth > 600 ? 20 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Pay ₹${amountToPay.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: screenWidth > 600 ? 18 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
