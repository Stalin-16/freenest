// profile_details_popup.dart
import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/profile_name.dart';

void showProfileDetailsBottomSheet(BuildContext context, ProfileList p) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
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
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with close button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          Text(
                            "Service Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Theme.of(context).colorScheme.onSurface),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Main Profile Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: Image.network(
                              p.profileImage.isNotEmpty
                                  ? "${AppConfig.imageUrl}${p.profileImage}"
                                  : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.serviceTitle,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${p.experience} Experience",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 14, color: Colors.orange),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "★ ${p.rating} (${p.workOrders} Work Orders)",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 100,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Rs. ${p.price.toStringAsFixed(0)} / hour",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "15",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1),
                      const SizedBox(height: 20),

                      const Text(
                        "Hire skilled Flutter developers for scalable apps",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _ExpandableSection(
                        title: "Service Deliverables",
                        initiallyExpanded: true,
                        children: [
                          _buildDeliverableItem(
                            "1. Flutter Mobile App Development",
                            "Build a complete mobile app for Android and iOS with clean design, smooth performance, and modern features.",
                          ),
                          _buildDeliverableItem(
                            "2. Feature Development & Enhancement",
                            "Add new features, improve existing modules, and fix issues to make the app faster and more user-friendly.",
                          ),
                          _buildDeliverableItem(
                            "3. UI Screen Design to Flutter Implementation",
                            "Convert your design (Figma/XD) into high-quality Flutter screens with proper layout, animations, and responsiveness.",
                          ),
                          _buildDeliverableItem(
                            "4. API Integration & Data Handling",
                            "Connect the app with your backend to fetch and update data securely, including login, forms, and real-time updates.",
                          ),
                          _buildDeliverableItem(
                            "5. App Testing & Store Deployment",
                            "Test the app thoroughly, resolve bugs, and publish it to the Google Play Store and Apple App Store.",
                          ),
                          _buildDeliverableItem(
                            "6. Code Reviews & Refactoring",
                            "Review your existing code, improve the structure, remove unnecessary parts, and boost performance.",
                          ),
                          _buildDeliverableItem(
                            "7. App Maintenance & Support",
                            "Provide ongoing updates, bug fixes, and improvements to keep the app stable and compatible with the latest OS versions.",
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      _ExpandableSection(
                        title: "How It Works (Process Steps)",
                        initiallyExpanded: false,
                        children: [
                          const SizedBox(height: 16),
                          _buildProcessStep("1. Initial Consultation"),
                          _buildProcessStep("2. Requirement Analysis"),
                          _buildProcessStep("3. Development & Testing"),
                          _buildProcessStep("4. Deployment & Support"),
                        ],
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Rs. ${(p.price * 15).toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  "Rs. ${p.price.toStringAsFixed(0)} x 15 Hours",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                print("Add to cart pressed for ${p.id}");
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
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

class _ExpandableSection extends StatefulWidget {
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.grey,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              ...widget.children,
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}

Widget _buildDeliverableItem(String title, String description) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

Widget _buildProcessStep(String step) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.check_circle, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    ),
  );
}
