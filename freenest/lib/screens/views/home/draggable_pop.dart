import 'package:flutter/material.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/widgets/shimmer_efferct.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/profile_mode.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/service/profile_service.dart';

void showProfileDetailsBottomSheet(BuildContext context, ProfileList p) {
  final ProfileService profileService = ProfileService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) {
      return _ProfileDetailsSheet(
        profileId: p.id,
        initialProfile: p,
        profileService: profileService,
      );
    },
  );
}

class _ProfileDetailsSheet extends StatefulWidget {
  final int profileId;
  final ProfileList initialProfile;
  final ProfileService profileService;

  const _ProfileDetailsSheet({
    required this.profileId,
    required this.initialProfile,
    required this.profileService,
  });

  @override
  __ProfileDetailsSheetState createState() => __ProfileDetailsSheetState();
}

class __ProfileDetailsSheetState extends State<_ProfileDetailsSheet> {
  late ProfileList _profile;
  Profile? _detailedProfile;
  bool _isLoading = true;
  bool _hasError = false;
  final ScrollController _scrollController = ScrollController();

  final CartApiService _cartApiService = CartApiService();

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile;
    _loadProfileDetails();
  }

  Future<void> _loadProfileDetails() async {
    try {
      final response = await widget.profileService
          .getProfileById(widget.profileId.toString());
      if (response.status == 200) {
        setState(() {
          _detailedProfile = Profile.fromMap(response.data);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load profile");
      }
    } catch (e) {
      print("Error loading profile details: $e");
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  int _selectedHours = 1;
  final List<int> _hourOptions = [1, 5, 10, 15, 20, 25, 30, 40, 50];

  Future<CartItemModel> _addToCart(Map<String, dynamic> product) async {
    try {
      final cartItem = await _cartApiService.addToCart(product);
      if (cartItem != null) {
        return cartItem;
      } else {
        throw Exception("Failed to add item to cart - API returned null");
      }
    } catch (e) {
      print('Error in _addToCart: $e');
      throw Exception("Failed to add item to cart: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isLoading
                ? buildShimmerEffect()
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 16),
                            Text(
                              "Failed to load details",
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadProfileDetails,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          // Scrollable content
                          SingleChildScrollView(
                            controller: scrollController,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 160, // Space for sticky header
                                bottom: 80, // Space for sticky footer
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 20),
                                    // Tagline
                                    if (_detailedProfile?.tagline != null &&
                                        _detailedProfile!.tagline.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          _detailedProfile!.tagline,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            height: 1.4,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),

                                    // Service Deliverables Section
                                    if (_detailedProfile
                                            ?.deliverables?.isNotEmpty ==
                                        true) ...[
                                      Text(
                                        "Service Deliverables",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._detailedProfile!.deliverables!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key + 1;
                                        final deliverable = entry.value;
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: "$index. ",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: theme.colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text:
                                                          "${deliverable.title}",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: theme.colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                deliverable.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade700,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 24),
                                    ],

                                    // Process Steps Section
                                    if (_detailedProfile
                                            ?.processSteps?.isNotEmpty ==
                                        true) ...[
                                      Text(
                                        "How It Works (Process Steps)",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._detailedProfile!.processSteps!
                                          .map((step) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 12),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(Icons.check_circle,
                                                        size: 16,
                                                        color: isDark
                                                            ? Colors
                                                                .green.shade400
                                                            : Colors.green),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        step.title,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: isDark
                                                              ? Colors
                                                                  .grey.shade400
                                                              : Colors.grey
                                                                  .shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                      const SizedBox(height: 24),
                                    ],

                                    // Promises Section
                                    if (_detailedProfile
                                            ?.promises?.isNotEmpty ==
                                        true) ...[
                                      Text(
                                        "Our Promises",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._detailedProfile!.promises!
                                          .map((promise) => Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      promise.checked
                                                          ? Icons.check_circle
                                                          : Icons
                                                              .radio_button_unchecked,
                                                      size: 16,
                                                      color: promise.checked
                                                          ? (isDark
                                                              ? Colors.green
                                                                  .shade400
                                                              : Colors.green)
                                                          : (isDark
                                                              ? Colors
                                                                  .grey.shade600
                                                              : Colors.grey),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        promise.text,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: isDark
                                                              ? Colors
                                                                  .grey.shade400
                                                              : Colors.grey
                                                                  .shade700,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                      const SizedBox(height: 24),
                                    ],

                                    // FAQs Section
                                    if (_detailedProfile?.faqs?.isNotEmpty ==
                                        true) ...[
                                      Text(
                                        "Frequently Asked Questions",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ..._detailedProfile!.faqs!.map((faq) =>
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Q: ${faq.question}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: theme
                                                        .colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "A: ${faq.answer}",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const SizedBox(height: 24),
                                    ],

                                    // Review Comments
                                    if (_detailedProfile?.reviewComments !=
                                            null &&
                                        _detailedProfile!
                                            .reviewComments.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Client Review",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _detailedProfile!.reviewComments,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    const SizedBox(height: 80),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Sticky Header - FIXED OVERFLOW ISSUE
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Header with close button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const SizedBox(width: 40),
                                        Text(
                                          "Service Details",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color:
                                                  theme.colorScheme.onSurface),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Main Profile Header Card
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxHeight: 80),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Profile Image
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: isDark
                                                  ? Colors.grey.shade800
                                                  : Colors.grey.shade200,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                _profile.profileImage.isNotEmpty
                                                    ? "${AppConfig.imageUrl}${_profile.profileImage}"
                                                    : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Icon(
                                                  Icons.person,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Middle section
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    _profile.serviceTitle,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: theme.colorScheme
                                                          .onSurface,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.calendar_today,
                                                      size: 14,
                                                      color: isDark
                                                          ? Colors.grey.shade500
                                                          : Colors.grey,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        "${_profile.experience} Years Experience",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? Colors
                                                                  .grey.shade400
                                                              : Colors.grey
                                                                  .shade700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      size: 14,
                                                      color: isDark
                                                          ? Colors
                                                              .orange.shade400
                                                          : Colors.orange,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        "★ ${_profile.rating} (${_formatWorkOrders(_profile.workOrders)} Work Orders)",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: isDark
                                                              ? Colors
                                                                  .grey.shade400
                                                              : Colors.grey
                                                                  .shade700,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),

                                          // Right side - Price and dropdown (FIXED)
                                          Container(
                                            constraints: const BoxConstraints(
                                                maxWidth: 90),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Price text
                                                Text(
                                                  "Rs. ${_profile.price.toStringAsFixed(0)} / hour",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: isDark
                                                        ? Colors.green.shade400
                                                        : Colors.green.shade700,
                                                  ),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                ),
                                                const SizedBox(height: 4),

                                                // Hours dropdown
                                                Container(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 60),
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 4),
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? Colors.orange.shade900
                                                            .withOpacity(0.3)
                                                        : Colors.orange.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton<int>(
                                                      value: _selectedHours,
                                                      isDense: true,
                                                      icon: Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 14,
                                                        color: isDark
                                                            ? Colors
                                                                .orange.shade300
                                                            : Colors.orange
                                                                .shade800,
                                                      ),
                                                      iconSize: 14,
                                                      elevation: 0,
                                                      dropdownColor: isDark
                                                          ? Colors.grey.shade900
                                                          : Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? Colors
                                                                .orange.shade300
                                                            : Colors.orange
                                                                .shade800,
                                                      ),
                                                      items: _hourOptions
                                                          .map((int value) {
                                                        return DropdownMenuItem<
                                                            int>(
                                                          value: value,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        2),
                                                            child: Text(
                                                              value.toString(),
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: isDark
                                                                    ? Colors
                                                                        .orange
                                                                        .shade300
                                                                    : Colors
                                                                        .orange
                                                                        .shade800,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                      onChanged:
                                                          (int? newValue) {
                                                        if (newValue != null) {
                                                          setState(() {
                                                            _selectedHours =
                                                                newValue;
                                                          });
                                                        }
                                                      },
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

                                  const Divider(height: 1),
                                ],
                              ),
                            ),
                          ),

                          // Sticky Footer
                          // Sticky Footer
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, -2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Rs. ${(_profile.price * _selectedHours).toStringAsFixed(0)}",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        Text(
                                          "Rs. ${_profile.price.toStringAsFixed(0)} × $_selectedHours Hours",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDark
                                            ? Colors.orange.shade800
                                            : Colors.orange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () async {
                                        final cartItem = {
                                          'profile_id': _profile.id,
                                          'user_id': _profile.serviceTitle,
                                          'quantity': _selectedHours,
                                          'price_per_unit': _profile.price,
                                          'total_price':
                                              _profile.price * _selectedHours,
                                          'cart_status': 'active'
                                        };

                                        await _addToCart(cartItem);

                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Add to cart",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  String _formatWorkOrders(int workOrders) {
    if (workOrders >= 1000) {
      return "${(workOrders / 1000).toStringAsFixed(2)}K";
    }
    return workOrders.toString();
  }
}
