import 'package:flutter/material.dart';

import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/order_model.dart';
import 'package:freenest/model/user_model.dart';
import 'package:freenest/service/review_service.dart';
import 'package:freenest/service/shared_service.dart';
import 'package:freenest/widgets/reffera_card_widget.dart';
import 'package:freenest/widgets/service_provider_card_widget.dart';

class WorkOrderDetailsScreen extends StatefulWidget {
  final OrderModel order;
  const WorkOrderDetailsScreen({super.key, required this.order});

  @override
  State<WorkOrderDetailsScreen> createState() => _WorkOrderDetailsScreenState();
}

class _WorkOrderDetailsScreenState extends State<WorkOrderDetailsScreen> {
  bool isLoading = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    getUserDetails();
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

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Work Order Details',
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
                      // Work Order Card
                      ServiceProviderCard(
                        serviceTitle: widget.order.serviceTitle,
                        profileImage: widget.order.imageUrl != null
                            ? "${AppConfig.imageUrl}${widget.order.imageUrl}"
                            : "",
                        viewDetails: false,
                        experience: widget.order.yearsofExperience,
                        rating: widget.order.review?.rating ?? 0.0,
                        workOrders: widget.order.totalhours,
                        price: widget.order.totalPrice,
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

                      // Order Details Card
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
                                'Order Details',
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
                              _buildDetailRow('Order Date:',
                                  _formatDate(widget.order.createdAt)),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Purchased Hours:',
                                  '${widget.order.totalhours} Hours'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Assigned To:',
                                  '${widget.order.assignedUser?.name ?? "Goku"} - ${widget.order.assignedUser?.overallRating ?? 4.6} ⭐'),
                              SizedBox(
                                  height: isDesktop
                                      ? 12
                                      : isTablet
                                          ? 10
                                          : 8),
                              _buildDetailRow('Order Status:',
                                  _formatStatus(widget.order.status)),
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

                      // Payment Receipt and Invoice Buttons
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

                      // Order Rating Section
                      if (widget.order.status == 'completed' ||
                          widget.order.status == 'closed' ||
                          widget.order.status == 'reviewed')
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Check if order has been rated
                                if (widget.order.review != null &&
                                    widget.order.review!.rating > 0)
                                  _buildRatingDisplay(
                                      context, theme, isDesktop, isTablet)
                                else
                                  _buildRatingPrompt(
                                      context, theme, isDesktop, isTablet),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Referral Section
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ReferralCard(
                  onViewDetails: () {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: isTablet ? 4 : 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
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
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary),
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

  Widget _buildRatingDisplay(
      BuildContext context, ThemeData theme, bool isDesktop, bool isTablet) {
    return Column(
      children: [
        // Rating header
        Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            "Order Rating",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: isDesktop
                  ? 24
                  : isTablet
                      ? 22
                      : 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        SizedBox(
            height: isDesktop
                ? 24
                : isTablet
                    ? 20
                    : 16),

        // Stars rating row
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop
                ? 20
                : isTablet
                    ? 16
                    : 12,
            vertical: isDesktop
                ? 14
                : isTablet
                    ? 12
                    : 10,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? 4
                          : isTablet
                              ? 3
                              : 2,
                    ),
                    child: Icon(
                      Icons.star,
                      color: index < widget.order.review!.rating.toInt()
                          ? Colors.amber
                          : theme.colorScheme.onSurface.withOpacity(0.2),
                      size: isDesktop
                          ? 32
                          : isTablet
                              ? 28
                              : 24,
                    ),
                  );
                }),
              ),

              SizedBox(
                  width: isDesktop
                      ? 16
                      : isTablet
                          ? 12
                          : 8),

              // Rating text
              Text(
                'Rated ${widget.order.review!.rating.toStringAsFixed(1)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isDesktop
                      ? 22
                      : isTablet
                          ? 20
                          : 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        SizedBox(
            height: isDesktop
                ? 24
                : isTablet
                    ? 20
                    : 16),

        // Review comment container
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isDesktop
              ? 24
              : isTablet
                  ? 20
                  : 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Comment text
              Text(
                widget.order.review!.comment,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: isDesktop
                      ? 18
                      : isTablet
                          ? 17
                          : 16,
                  height: 1.6,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(
                  height: isDesktop
                      ? 16
                      : isTablet
                          ? 12
                          : 8),

              // Person's name (assuming we have it)
              if (user?.name != null)
                Row(
                  children: [
                    Text(
                      "- ${user?.name}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: isDesktop
                            ? 16
                            : isTablet
                                ? 15
                                : 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingPrompt(
      BuildContext context, ThemeData theme, bool isDesktop, bool isTablet) {
    return Column(
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
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
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
                        'How was your experience with ${user?.name ?? "the service provider"}?',
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
                        constraints: BoxConstraints(
                          minHeight: 120,
                          maxHeight: 200,
                        ),
                        child: TextFormField(
                          controller: commentController,
                          maxLines: null, // Allows dynamic height
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
                            contentPadding: EdgeInsets.all(16),
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

                      // Action Buttons - Fixed with IntrinsicHeight
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
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16 : 15,
                                  ),
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
                                            orderId: widget.order.id,
                                            rating: rating,
                                            comment: comment,
                                          );

                                          // Update the parent widget's order model
                                          // _updateOrderWithReview(response);

                                          Navigator.pop(context);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  "Review submitted successfully!"),
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
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

// Method to update order with new review
// void _updateOrderWithReview(Map<String, dynamic> reviewResponse) {
//   // Create a new OrderReviewModel from the response
//   final newReview = OrderReviewModel.fromMap(reviewResponse);

//   // Update the order model using copyWith
//   widget.order = widget.order.copyWith(
//     review: newReview,
//     reviewId: newReview.id,
//     // If the API returns updated status, update that too
//     status: 'reviewed',
//     statusText: 'reviewed',
//   );

//   // If you're using a state management solution like Provider or Bloc,
//   // you would update the state here. For example with Provider:
//   // context.read<OrderProvider>().updateOrder(widget.order);

//   // If using setState in parent widget, call it
//   if (widget.onReviewSubmitted != null) {
//     widget.onReviewSubmitted!(widget.order);
//   }

//   // Force a rebuild
//   setState(() {});
// }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
