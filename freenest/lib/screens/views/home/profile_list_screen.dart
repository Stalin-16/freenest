import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/screens/views/home/draggable_pop.dart';
import 'package:freenest/service/profile_service.dart';
import 'package:freenest/widgets/reffera_card_widget.dart';

class ProfileListScreen extends StatefulWidget {
  static const routeName = "/profile-list";
  final int? profileId;

  const ProfileListScreen({Key? key, this.profileId}) : super(key: key);

  @override
  State<ProfileListScreen> createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = false;
  List<ProfileList> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500)); // Fake delay

    // DUMMY DATA (Test Purposes Only)
    _profiles = [
      ProfileList(
        id: 1,
        serviceTitle: "Flutter Developer L3",
        experience: "3 Years",
        rating: 4.9,
        workOrders: 3500,
        price: 500,
        profileImage: "https://cdn-icons-png.flaticon.com/512/5968/5968885.png",
      ),
      ProfileList(
        id: 2,
        serviceTitle: "Node.js Backend Engineer",
        experience: "2 Years",
        rating: 4.7,
        workOrders: 2100,
        price: 450,
        profileImage: "https://cdn-icons-png.flaticon.com/512/919/919825.png",
      ),
      ProfileList(
        id: 3,
        serviceTitle: "Java Spring Boot Developer",
        experience: "2.5 Years",
        rating: 4.8,
        workOrders: 2600,
        price: 550,
        profileImage: "https://cdn-icons-png.flaticon.com/512/226/226777.png",
      ),
    ];

    setState(() => _isLoading = false);
  }

  Future<void> _loadProfilesss() async {
    setState(() => _isLoading = true);

    try {
      final List<ProfileList> data = await _profileService.getAllProfiles();
      setState(() {
        _profiles = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Profile loading failed: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.of(context).size.width;

    final bool isWide = w > 600;
    final double avatarSize = isWide ? 56 : 48;

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
        title: const Text("Profiles"),
      ),
      body: Column(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _profiles.isEmpty
                  ? const Center(child: Text("No profiles available"))
                  : Expanded(
                      child: ListView.separated(
                        itemCount: _profiles.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final p = _profiles[index];

                          return Card(
                            elevation: 1.2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Left: Avatar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[200],
                                      child: Image.network(
                                        p.profileImage.isNotEmpty
                                            ? "${AppConfig.imageUrl}${p.profileImage}"
                                            : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image,
                                                size: 32),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Middle: Title, Experience, Rating
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.serviceTitle,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.work_outline,
                                                size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                p.experience,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                color: Colors.amber, size: 14),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                "${p.rating} • ${p.workOrders} Work Orders",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.green),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  showProfileDetailsBottomSheet(
                                                      context, p),
                                              child: const Text(
                                                "View details",
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right: Price + Add button
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "Rs. ${p.price.toStringAsFixed(0)} / hour",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.indigo),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        height: 32,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            print("Add pressed for ${p.id}");
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            backgroundColor: Colors.grey[800],
                                          ),
                                          child: const Text(
                                            "Add",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          const Spacer(),
          ReferralCard(
            onViewDetails: () {
              print("Reffera view details tapped");
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileHorizontalCard extends StatelessWidget {
  final int id;
  final String title;
  final String experience;
  final double rating;
  final int workOrders;
  final String price;
  final String imageUrl;
  final double avatarSize;
  final VoidCallback onAdd;
  final VoidCallback onViewDetails;

  const _ProfileHorizontalCard({
    Key? key,
    required this.id,
    required this.title,
    required this.experience,
    required this.rating,
    required this.workOrders,
    required this.price,
    required this.imageUrl,
    required this.avatarSize,
    required this.onAdd,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: avatarSize + 10,
                height: avatarSize + 10,
                color: theme.cardColor,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Middle content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.work_outline,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(experience,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700])),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "$rating • $workOrders Work Orders",
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.green[700]),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onViewDetails,
                        child: Text(
                          "View details",
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // Price + Add button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onAdd,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Add"),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
