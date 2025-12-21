import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/constants/ui_screen_routes.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/shared_service.dart';

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
        loadedCart = await CartApiService.getCart(user.id!);
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

  double get gstAmount => totalAmount * 0.18;

  double get grandTotal => totalAmount + gstAmount;

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
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => isLoading = true);
    try {
      if (isLoggedIn) {
        await CartApiService.checkout();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout failed: $e')),
      );
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
        title: const Text('Your Cart'),
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
                    '3 Years Experience',
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
                        '4.8',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: screenWidth > 600 ? 14 : null,
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

    return TextField(
      decoration: InputDecoration(
        hintText: 'Enter Referral/Promo Code',
        hintStyle: TextStyle(
          color: isDark ? Colors.white70 : Colors.grey[600],
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextButton(
            onPressed: () {},
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
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white : Colors.black,
            width: 1.5,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: screenWidth > 600 ? 20 : 16,
        ),
      ),
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

  Widget _creditDeductionRow() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(width: 40), // Space to align with checkbox
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
