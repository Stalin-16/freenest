import 'package:flutter/material.dart';
import 'package:freenest/screens/views/home/profile_list_screen.dart';
import 'dart:async';
import 'dart:math';
import 'package:shimmer/shimmer.dart';

/// Lightweight ServiceCard used in grids. Replace with your own widget if needed.
class ServiceCard extends StatelessWidget {
  final String title;
  final String imgUrl;

  const ServiceCard({Key? key, required this.title, required this.imgUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade400,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imgUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined, size: 40),
                )),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Skeleton ServiceCard for loading state
class ServiceCardSkeleton extends StatelessWidget {
  const ServiceCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skeleton Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade700 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Skeleton Title
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for category header
class CategoryHeaderSkeleton extends StatelessWidget {
  const CategoryHeaderSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 120,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home screen with animated expand/collapse, skeleton loading, dynamic search.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true; // show skeleton on first load only
  bool _initialLoadDone = false;

  // Hard-coded categories & items (each item has unique id)
  final List<Map<String, dynamic>> serviceCategories = [
    {
      "category": "Analyst",
      "items": [
        {
          "id": 101,
          "title": "Business Analyst",
          "img": "images/home/bussines.png",
        },
        {
          "id": 102,
          "title": "Salesforce Business Analyst",
          "img": "images/home/salesforce.png",
        },
        {
          "id": 103,
          "title": "Quality Analyst",
          "img": "images/home/QA.png",
        },
      ]
    },
    {
      "category": "Web Developer",
      "items": [
        {
          "id": 201,
          "title": "PHP Developer",
          "img": "images/home/php.png",
        },
        {
          "id": 202,
          "title": "Node JS Developer",
          "img": "images/home/nodejs.png",
        },
        {
          "id": 203,
          "title": "Java Developer",
          "img": "images/home/java.png",
        },
      ]
    },
    {
      "category": "Mobile Developer",
      "items": [
        {
          "id": 301,
          "title": "Flutter Developer",
          "img": "images/home/flutter.jpg",
        },
        {
          "id": 302,
          "title": "React Native Developer",
          "img": "images/home/reactnative.png",
        },
        {
          "id": 303,
          "title": "iOS Developer",
          "img": "images/home/ios.png",
        },
        {
          "id": 304,
          "title": "Kotlin Developer",
          "img": "images/home/kotlin.webp",
        },
      ]
    },
  ];

  // Expanded state stored by category index
  final Map<int, bool> _expanded = {};

  // For filtering results
  Map<int, List<Map<String, dynamic>>> _filteredByCategory = {};

  // Random placeholder text
  late String _randomPlaceholder;

  @override
  void initState() {
    super.initState();
    _prepareInitialData();
    _searchController.addListener(_applyFilter);
  }

  void _prepareInitialData() {
    // initialize expanded state and filtered map
    for (int i = 0; i < serviceCategories.length; i++) {
      _expanded[i] = true;
      _filteredByCategory[i] =
          List<Map<String, dynamic>>.from(serviceCategories[i]['items']);
    }

    // pick random placeholder from all titles
    final allTitles = <String>[];
    for (final c in serviceCategories) {
      for (final it in c['items']) {
        allTitles.add(it['title'] as String);
      }
    }
    final rng = Random();
    _randomPlaceholder = allTitles.isNotEmpty
        ? allTitles[rng.nextInt(allTitles.length)]
        : 'Search';

    // Simulate skeleton loading on first load only (2.5s)
    _isLoading = true;
    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        _isLoading = false;
        _initialLoadDone = true;
      });
    });
  }

  void _applyFilter() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      // restore original lists
      for (int i = 0; i < serviceCategories.length; i++) {
        _filteredByCategory[i] =
            List<Map<String, dynamic>>.from(serviceCategories[i]['items']);
      }
    } else {
      for (int i = 0; i < serviceCategories.length; i++) {
        final items = serviceCategories[i]['items'] as List;
        _filteredByCategory[i] = items
            .where((it) =>
                (it['title'] as String).toLowerCase().contains(q) ||
                (serviceCategories[i]['category'] as String)
                    .toLowerCase()
                    .contains(q))
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildSkeletonLoading() {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 3 : 5;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton search bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 18),

          // Skeleton "Explore all service profiles" text
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade700 : Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 12),

          // Skeleton categories with grids
          Column(
            children: List.generate(3, (catIndex) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton category header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade700 : Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey.shade700 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Skeleton grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        catIndex == 2 ? 4 : 3, // Different counts for variety
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, i) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width < 600 ? 3 : 5;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar - Always visible
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Search for \"$_randomPlaceholder\"",
                    hintStyle: _isLoading && !_initialLoadDone
                        ? TextStyle(color: Colors.transparent)
                        : null,
                    prefixIcon: Icon(Icons.search,
                        color: _isLoading && !_initialLoadDone
                            ? Colors.transparent
                            : theme.iconTheme.color),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: _isLoading && !_initialLoadDone
                      ? const TextStyle(color: Colors.transparent)
                      : null,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                "Explore all service profiles",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange[700],
                ),
              ),

              const SizedBox(height: 12),

              // Show skeleton loading or actual content
              if (_isLoading && !_initialLoadDone)
                _buildSkeletonLoading()
              else
                // Actual categories content
                Column(
                  children: List.generate(serviceCategories.length, (catIndex) {
                    final categoryData = serviceCategories[catIndex];
                    final categoryName = categoryData['category'] as String;
                    final items = List<Map<String, dynamic>>.from(
                        _filteredByCategory[catIndex] ?? []);

                    // ensure expanded default
                    _expanded.putIfAbsent(catIndex, () => true);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // header with animated arrow
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _expanded[catIndex] = !_expanded[catIndex]!;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(categoryName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                AnimatedRotation(
                                  // subtle rotation for arrow
                                  turns: _expanded[catIndex]! ? 0.0 : 0.5,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    Icons.keyboard_arrow_up,
                                    size: 26,
                                    color: theme.iconTheme.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Animated size for smooth collapse/expand
                        AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOut,
                          child: ConstrainedBox(
                            constraints: _expanded[catIndex]!
                                ? const BoxConstraints()
                                : const BoxConstraints(maxHeight: 0),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: items.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Text(
                                        "No matches found",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    )
                                  : GridView.builder(
                                      key: ValueKey(
                                          "grid_${catIndex}_${items.length}_${_searchController.text}"),
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: items.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        mainAxisSpacing: 12,
                                        crossAxisSpacing: 12,
                                        childAspectRatio: 0.85,
                                      ),
                                      itemBuilder: (context, i) {
                                        final item = items[i];
                                        return GestureDetector(
                                          onTap: () {
                                            // handle navigation to profile details with item['id']
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        ProfileListScreen(
                                                            profileId:
                                                                item['id'])));
                                          },
                                          child: ServiceCard(
                                            title: item['title'] as String,
                                            imgUrl: item['img'] as String,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                      ],
                    );
                  }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
