import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/review_service.dart';
import 'package:freenest/service/shared_service.dart';
import 'package:freenest/widgets/reffera_card_widget.dart';
import 'package:freenest/widgets/service_provider_card_widget.dart';
import 'package:freenest/widgets/snackbar_utils.dart';

class WorkOrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  final OrderItem?
      selectedItem; // Optional: if you want to highlight a specific item
  const WorkOrderDetailsScreen({
    super.key,
    required this.order,
    this.selectedItem,
  });

  @override
  State<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends State<WorkOrderDetailsScreen> {
  bool isLoading = false;
  UserModel? user;
  OrderItem? currentItem; // The currently displayed order item

  @override
  void initState() {
    super.initState();
    getUserDetails();
    // If no specific item is selected, show the first one
    currentItem = widget.selectedItem ??
        (widget.order.orderItems.isNotEmpty
            ? widget.order.orderItems[0]
            : null);
  }

  Future<void> getUserDetails() async {
    user = await SharedService.getUser();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDesktop = screenSize.width >= 1024;

    // If no items in the order, show empty state
    if (widget.order.orderItems.isEmpty || currentItem == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Work Order Details'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 80,
                color: theme.disabledColor,
              ),
              const SizedBox(height: 16),
              Text(
                'No order items found',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    final profile = currentItem!.profile;
    final assignedUser = currentItem!.assignedUser;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 40
                      : isTablet
                          ? 24
                          : 16,
                  vertical: isDesktop ? 24 : 16,
                ),
                constraints: BoxConstraints(
                  minHeight: screenSize.height,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop
                        ? 800
                        : isTablet
                            ? 600
                            : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header with Multiple Items
                      if (widget.order.orderItems.length > 1) ...[
                        _buildOrderItemsSelector(theme, isDark),
                        SizedBox(
                            height: isDesktop
                                ? 24
                                : isTablet
                                    ? 20
                                    : 16),
                      ],

                      // Order Information Card
                      Card(
                        elevation: isDark ? 0 : 2,
                        surfaceTintColor: theme.colorScheme.surface,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isDark
                              ? BorderSide(
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.1))
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop
                              ? 24
                              : isTablet
                                  ? 20
                                  : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service Provider Card
                              ServiceProviderCard(
                                serviceTitle: profile.serviceTitle,
                                profileImage: profile.profileImage != null
                                    ? "${AppConfig.imageUrl}${profile.profileImage}"
                                    : "",
                                viewDetails: false,
                                experience: profile.experienceRange,
                                rating: profile.overallRating ?? 0.0,
                                workOrders:
                                    0, // You might want to pass actual work orders count
                                price: currentItem!.price,
                                showAddButton: false,
                                onAddPressed: () {},
                                isDark: isDark,
                              ),

                              SizedBox(
                                  height: isDesktop
                                      ? 24
                                      : isTablet
                                          ? 20
                                          : 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Order #${widget.order.id}',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          _getStatusColor(currentItem!.status)
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            _getStatusColor(currentItem!.status)
                                                .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _formatStatus(currentItem!.status),
                                      style:
                                          theme.textTheme.labelMedium?.copyWith(
                                        color: _getStatusColor(
                                            currentItem!.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: isDesktop
                                      ? 16
                                      : isTablet
                                          ? 14
                                          : 12),
                              _buildDetailRow(
                                  'Order Date:', widget.order.formattedDate),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow(
                                  'Order Time:', widget.order.formattedTime),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 24
                              : isTablet
                                  ? 20
                                  : 16),

                      // Service Details Card
                      Card(
                        elevation: isDark ? 0 : 2,
                        surfaceTintColor: theme.colorScheme.surface,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isDark
                              ? BorderSide(
                                  color: theme.colorScheme.outline
                                      .withOpacity(0.1))
                              : BorderSide.none,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isDesktop
                              ? 24
                              : isTablet
                                  ? 20
                                  : 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Details',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(
                                  height: isDesktop
                                      ? 16
                                      : isTablet
                                          ? 14
                                          : 12),
                              _buildDetailRow('Service:', profile.serviceTitle),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Experience:',
                                  '${profile.experienceRange} Years'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Hourly Rate:',
                                  '₹${profile.hourlyRate.toStringAsFixed(2)}'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Purchased Hours:',
                                  '${currentItem!.quantity} Hours'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Total Price:',
                                  '₹${currentItem!.totalPrice.toStringAsFixed(2)}'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              if (assignedUser != null)
                                _buildDetailRow('Assigned To:',
                                    '${assignedUser.name} - ${assignedUser.overallRating} ⭐'),
                              if (assignedUser == null)
                                _buildDetailRow(
                                    'Assigned To:', 'Not assigned yet'),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 24
                              : isTablet
                                  ? 20
                                  : 16),

                      // Payment Information
                      // Card(
                      //   elevation: isDark ? 0 : 2,
                      //   surfaceTintColor: theme.colorScheme.surface,
                      //   color: theme.colorScheme.surface,
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(12),
                      //     side: isDark
                      //         ? BorderSide(
                      //             color: theme.colorScheme.outline
                      //                 .withOpacity(0.1))
                      //         : BorderSide.none,
                      //   ),
                      //   child: Padding(
                      //     padding: EdgeInsets.all(isDesktop
                      //         ? 24
                      //         : isTablet
                      //             ? 20
                      //             : 16),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Payment Information',
                      //           style: theme.textTheme.titleMedium?.copyWith(
                      //             fontWeight: FontWeight.bold,
                      //             color: theme.colorScheme.onSurface,
                      //           ),
                      //         ),
                      //         SizedBox(
                      //             height: isDesktop
                      //                 ? 16
                      //                 : isTablet
                      //                     ? 14
                      //                     : 12),
                      //         _buildDetailRow('Base Amount:',
                      //             '₹${widget.order.baseAmount.toStringAsFixed(2)}'),
                      //         SizedBox(
                      //             height: isDesktop
                      //                 ? 12
                      //                 : isTablet
                      //                     ? 10
                      //                     : 8),
                      //         _buildDetailRow('GST Amount:',
                      //             '₹${widget.order.gstAmount.toStringAsFixed(2)}'),
                      //         SizedBox(
                      //             height: isDesktop
                      //                 ? 12
                      //                 : isTablet
                      //                     ? 10
                      //                     : 8),
                      //         const Divider(),
                      //         SizedBox(
                      //             height: isDesktop
                      //                 ? 12
                      //                 : isTablet
                      //                     ? 10
                      //                     : 8),
                      //         _buildDetailRow('Total Amount:',
                      //             '₹${widget.order.totalAmount.toStringAsFixed(2)}',
                      //             isTotal: true),
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      SizedBox(
                          height: isDesktop
                              ? 24
                              : isTablet
                                  ? 20
                                  : 16),

                      // Action Buttons
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 400) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.receipt,
                                    label: 'Payment Receipt',
                                    onPressed: () {},
                                    theme: theme,
                                  ),
                                ),
                                SizedBox(
                                    width: isDesktop
                                        ? 16
                                        : isTablet
                                            ? 14
                                            : 12),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.description,
                                    label: 'Invoice',
                                    onPressed: () {},
                                    theme: theme,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.receipt,
                                  label: 'Payment Receipt',
                                  onPressed: () {},
                                  theme: theme,
                                ),
                                SizedBox(width: isTablet ? 14 : 12),
                                _buildActionButton(
                                  icon: Icons.description,
                                  label: 'Invoice',
                                  onPressed: () {},
                                  theme: theme,
                                ),
                              ],
                            );
                          }
                        },
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 40
                              : isTablet
                                  ? 32
                                  : 32),

                      // Order Rating Section (only for completed orders)
                      if (currentItem!.status.toLowerCase() == 'completed' &&
                          !currentItem!.hasReview)
                        _buildRatingSection(theme, isDesktop, isTablet, isDark),

                      // Show existing review if item has been rated
                      if (currentItem!.hasReview &&
                          currentItem!.reviewDetails != null)
                        _buildReviewDisplay(theme, isDesktop, isTablet, isDark),

                      SizedBox(
                          height: isDesktop
                              ? 40
                              : isTablet
                                  ? 32
                                  : 32),
                      ReferralCard(
                        onViewDetails: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Referral Section
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsSelector(ThemeData theme, bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      surfaceTintColor: theme.colorScheme.surface,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items (${widget.order.orderItems.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.order.orderItems.map((item) {
                final isSelected = currentItem?.id == item.id;
                return ChoiceChip(
                  label: Text(
                    item.profile.serviceTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      currentItem = item;
                    });
                  },
                  selectedColor: theme.colorScheme.primary,
                  backgroundColor: isDark
                      ? theme.colorScheme.surfaceVariant
                      : Colors.grey.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isTablet ? 3 : 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
              color:
                  theme.colorScheme.onSurface.withOpacity(isTotal ? 1.0 : 0.7),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: isTablet ? 4 : 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontSize: isTotal ? 16 : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.black12),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildRatingSection(
      ThemeData theme, bool isDesktop, bool isTablet, bool isDark) {
    return Card(
      elevation: isDark ? 0 : 2,
      surfaceTintColor: Colors.white,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop
            ? 24
            : isTablet
                ? 20
                : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: isDesktop
                    ? 12
                    : isTablet
                        ? 10
                        : 8),
            Text(
              'Help us improve by rating your experience',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(
                height: isDesktop
                    ? 28
                    : isTablet
                        ? 24
                        : 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showRatingDialog(context, user, theme);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isDesktop
                        ? 18
                        : isTablet
                            ? 16
                            : 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Rate Now',
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewDisplay(
      ThemeData theme, bool isDesktop, bool isTablet, bool isDark) {
    final review = currentItem!.reviewDetails!;

    return Card(
      elevation: isDark ? 0 : 2,
      surfaceTintColor: theme.colorScheme.surface,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))
            : BorderSide.none,
      ),
      child: Padding(
        padding: EdgeInsets.all(isDesktop
            ? 24
            : isTablet
                ? 20
                : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Review',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(
                height: isDesktop
                    ? 16
                    : isTablet
                        ? 14
                        : 12),

            // Rating Stars
            Row(
              children: [
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      color: index < review.rating.toInt()
                          ? Colors.amber
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      size: 20,
                    );
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  '${review.rating.toStringAsFixed(1)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(
                height: isDesktop
                    ? 12
                    : isTablet
                        ? 10
                        : 8),

            // Review Comment
            Container(
              padding: EdgeInsets.all(isDesktop
                  ? 16
                  : isTablet
                      ? 14
                      : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                review.comment,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(
      BuildContext context, UserModel? user, ThemeData theme) {
    double rating = 0;
    String comment = '';
    final TextEditingController commentController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;
    final isDesktop = screenSize.width >= 1024;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isDesktop
                      ? 500
                      : isTablet
                          ? 400
                          : 340,
                ),
                child: Container(
                  padding: EdgeInsets.all(
                    isDesktop
                        ? 32
                        : isTablet
                            ? 24
                            : 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      Text(
                        'Rate Your Experience',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 16
                              : isTablet
                                  ? 14
                                  : 12),

                      // Subtitle
                      Text(
                        'How was your experience with ${currentItem?.profile.serviceTitle ?? "the service"}?',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 28
                              : isTablet
                                  ? 24
                                  : 24),

                      // Star Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                rating = index + 1.0;
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: isDesktop
                                    ? 48
                                    : isTablet
                                        ? 44
                                        : 40,
                              ),
                            ),
                          );
                        }),
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 16
                              : isTablet
                                  ? 14
                                  : 12),

                      // Rating Text
                      Text(
                        rating == 0
                            ? 'Tap to rate'
                            : '${rating.toInt()} Star${rating > 1 ? 's' : ''}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 28
                              : isTablet
                                  ? 24
                                  : 24),

                      // Comment Section
                      Text(
                        'Share your feedback (optional)',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 16
                              : isTablet
                                  ? 14
                                  : 12),

                      // Text field with constrained height
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 120,
                          maxHeight: 200,
                        ),
                        child: TextFormField(
                          controller: commentController,
                          maxLines: null,
                          style: theme.textTheme.bodyLarge,
                          decoration: InputDecoration(
                            hintText: 'Tell us about your experience...',
                            hintStyle: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            comment = value;
                          },
                        ),
                      ),

                      SizedBox(
                          height: isDesktop
                              ? 32
                              : isTablet
                                  ? 28
                                  : 24),

                      // Action Buttons
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isDesktop
                                        ? 16
                                        : isTablet
                                            ? 14
                                            : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style:
                                      TextStyle(fontSize: isDesktop ? 16 : 15),
                                ),
                              ),
                            ),
                            SizedBox(
                                width: isDesktop
                                    ? 16
                                    : isTablet
                                        ? 14
                                        : 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: rating == 0 || isLoading
                                    ? null
                                    : () async {
                                        try {
                                          setState(() => isLoading = true);

                                          // Call the API
                                          final response =
                                              await ReviewApiService
                                                  .submitReview(
                                            orderItemId: currentItem!
                                                .id, // Changed from orderId to orderItemId
                                            rating: rating,
                                            comment: comment,
                                          );
                                          print(response);
                                          // Update the current item with the review
                                          setState(() {
                                            currentItem = OrderItem(
                                              id: currentItem!.id,
                                              profileId: currentItem!.profileId,
                                              assignedTo:
                                                  currentItem!.assignedTo,
                                              orderId: currentItem!.orderId,
                                              cartId: currentItem!.cartId,
                                              quantity: currentItem!.quantity,
                                              price: currentItem!.price,
                                              totalPrice:
                                                  currentItem!.totalPrice,
                                              reviewId: response.data[
                                                  'id'], // Assuming API returns review ID
                                              status: currentItem!.status,
                                              createdAt: currentItem!.createdAt,
                                              profile: currentItem!.profile,
                                              assignedUser:
                                                  currentItem!.assignedUser,
                                              reviewDetails: OrderReview(
                                                id: response.data['id'],
                                                rating: response.data['rating'],
                                                comment:
                                                    response.data['comment'],
                                              ),
                                            );
                                          });

                                          Navigator.pop(context);

                                          CustomSnackBar.showSuccess(
                                            context: context,
                                            message:
                                                'Review submitted successfully!',
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Failed to submit review: $e'),
                                              backgroundColor:
                                                  theme.colorScheme.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          );
                                        } finally {
                                          setState(() => isLoading = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  disabledBackgroundColor: theme
                                      .colorScheme.primary
                                      .withOpacity(0.5),
                                  padding: EdgeInsets.symmetric(
                                    vertical: isDesktop
                                        ? 16
                                        : isTablet
                                            ? 14
                                            : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: isLoading
                                    ? SizedBox(
                                        height: isDesktop ? 24 : 20,
                                        width: isDesktop ? 24 : 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        'Submit Review',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isDesktop ? 16 : 15,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'order placed':
        return Colors.blue;
      case 'getting ready':
        return Colors.indigo;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatStatus(String status) {
    return status.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
