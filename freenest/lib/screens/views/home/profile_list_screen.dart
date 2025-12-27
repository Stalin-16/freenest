import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/screens/views/home/draggable_pop.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/profile_service.dart';
import 'package:freenest/widgets/reffera_card_widget.dart';
import 'package:freenest/widgets/shimmer_efferct.dart';
import 'package:freenest/widgets/snackbar_utils.dart';

class ProfileListScreen extends StatefulWidget {
  static const routeName = "/profile-list";
  final int? profileId;

  const ProfileListScreen({Key? key, this.profileId}) : super(key: key);

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final ProfileService _profileService = ProfileService();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 8;
  bool _hasMoreData = true;
  int _totalProfiles = 0;
  List<ProfileList> _profiles = [];
  final CartApiService _cartApiService = CartApiService();
  @override
  void initState() {
    super.initState();
    _loadInitialProfiles();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_scrollController.position.outOfRange) {
      if (_hasMoreData && !_isLoadingMore && !_isLoading) {
        _loadMoreProfiles();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialProfiles() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _profiles = [];
    });

    try {
      final response = await _profileService.getProfilesPaginated(
        serviceSubCategoryId: widget.profileId ?? 0,
        page: 1,
        limit: _pageSize,
      );
      setState(() {
        _profiles = response.data;
        _totalProfiles = response.total;
        _hasMoreData = response.hasNext;
        _currentPage = response.page;
      });
    } catch (e) {
      _showErrorSnackbar("Failed to load profiles");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _loadMoreProfiles() async {
    if (_isLoadingMore || !_hasMoreData || _isLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await _profileService.getProfilesPaginated(
        serviceSubCategoryId: widget.profileId ?? 0,
        page: nextPage,
        limit: _pageSize,
      );

      setState(() {
        _profiles.addAll(response.data);
        _totalProfiles = response.total;
        _hasMoreData = response.hasNext;
        _currentPage = response.page;
      });
    } catch (e) {
      print("Load more profiles failed: $e");
      _showErrorSnackbar("Failed to load more profiles");
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshProfiles() async {
    await _loadInitialProfiles();
  }

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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: 16, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profiles",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading && _profiles.isEmpty
                ? buildShimmerSkeletonEffect()
                : _profiles.isEmpty
                    ? Center(
                        child: Text(
                          "No profiles available",
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                                  scrollInfo.metrics.maxScrollExtent - 100 &&
                              !_isLoadingMore &&
                              _hasMoreData &&
                              !_isLoading) {
                            _loadMoreProfiles();
                          }
                          return false;
                        },
                        child: RefreshIndicator(
                          onRefresh: _refreshProfiles,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount:
                                _profiles.length + (_hasMoreData ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Show loading indicator at the bottom
                              if (index >= _profiles.length) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: _isLoadingMore
                                        ? CircularProgressIndicator(
                                            color: colorScheme.primary,
                                          )
                                        : _hasMoreData
                                            ? const SizedBox.shrink()
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Text(
                                                  "No more profiles",
                                                  style: TextStyle(
                                                      color:
                                                          theme.disabledColor),
                                                ),
                                              ),
                                  ),
                                );
                              }

                              final p = _profiles[index];

                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.cardColor,
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade300,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
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
                                            p.profileImage.isNotEmpty
                                                ? "${AppConfig.imageUrl}${p.profileImage}"
                                                : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                              Icons.person,
                                              size: 30,
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Middle Section - Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Title
                                            Text(
                                              p.serviceTitle,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    theme.colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),

                                            // Experience
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.work,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade700,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${p.experience} Years Experience",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.grey.shade400
                                                        : Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),

                                            // Rating and Work Orders
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber.shade700,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  "${p.rating} (${_formatWorkOrders(p.workOrders)} Work Orders)",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: theme
                                                        .colorScheme.onSurface
                                                        .withOpacity(0.87),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),

                                            // View details - on a separate line below rating
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: GestureDetector(
                                                onTap: () =>
                                                    showProfileDetailsBottomSheet(
                                                        context, p),
                                                child: Text(
                                                  "View details",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Right Section - Price and Add Button
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Price
                                          Text(
                                            "Rs. ${p.price.toStringAsFixed(0)} / hour",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                            textAlign: TextAlign.end,
                                          ),
                                          const SizedBox(height: 8),

                                          // Add Button
                                          SizedBox(
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final cartItem = {
                                                  'profile_id': p.id,
                                                  'user_id': p.serviceTitle,
                                                  'quantity': 1,
                                                  'price_per_unit': p.price,
                                                  'total_price': p.price * 1,
                                                  'cart_status': 'active'
                                                };
                                                _addToCart(cartItem)
                                                    .then((value) {
                                                  CustomSnackBar.showSuccess(
                                                    context: context,
                                                    message:
                                                        'Added to cart successfully!',
                                                  );
                                                }).catchError((error) {
                                                  CustomSnackBar.showError(
                                                    context: context,
                                                    message:
                                                        'Failed to add to cart.',
                                                  );
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isDark
                                                    ? colorScheme.primary
                                                    : Colors.grey.shade700,
                                                foregroundColor: isDark
                                                    ? colorScheme.onPrimary
                                                    : Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                "Add",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDark
                                                      ? colorScheme.onPrimary
                                                      : Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
          ),
          if (!_isLoading && _profiles.isNotEmpty)
            ReferralCard(
              onViewDetails: () {
                print("Reffera view details tapped");
              },
            ),
        ],
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
