import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/cart_model.dart';
import 'package:freenest/model/profile_mode.dart';
import 'package:freenest/service/cart_api_service.dart';
import 'package:freenest/service/cart_service.dart';
import 'package:freenest/service/profile_service.dart';
import 'package:freenest/service/shared_service.dart';
import '../../../widgets/custom_button.dart';

class ProfileDetailsPage extends StatefulWidget {
  final String profileId;
  const ProfileDetailsPage({super.key, required this.profileId});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late Future<Profile> _profileFuture;
  final ProfileService _profileService = ProfileService();
  final CartApiService _cartApiService = CartApiService();

  bool isLoggedIn = false;
  @override
  void initState() {
    super.initState();
    _profileFuture = fetchProfile();
  }

  Future<Profile> fetchProfile() async {
    final loggedIn = await SharedService.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
    });
    final response = await _profileService.getProfileById(widget.profileId);
    if (response.status == 200) {
      return Profile.fromMap(response.data);
    } else {
      throw Exception("Failed to load profile");
    }
  }

  Future<CartItemModel> addToCart(Map<String, dynamic> product) async {
    final cartItem = await _cartApiService.addToCart(product);

    if (cartItem != null) {
      return cartItem;
    } else {
      throw Exception("Failed to add item to cart");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text("Profile Details", style: TextStyle(fontSize: 18)),
      ),
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No profile data found"));
          }

          final profile = snapshot.data!;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---- HEADER ----
                    Stack(
                      children: [
                        if (profile.profileImage != null)
                          Container(
                            height: 250,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                  AppConfig.imageUrl + profile.profileImage!,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.4),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.serviceTitle,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.tagline,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ---- ABOUT SECTION ----
                    _sectionCard(
                      context,
                      title: "About",
                      children: [
                        _infoRow(context, Icons.work_outline, "Category",
                            profile.serviceCategory),
                        _infoRow(context, Icons.timeline, "Experience",
                            "${profile.experienceRange} years"),
                        _infoRow(context, Icons.attach_money, "Hourly Rate",
                            "₹${profile.hourlyRate}"),
                        _infoRow(context, Icons.star, "Rating",
                            "${profile.rating}/5 ⭐️"),
                      ],
                    ),

                    // ---- DELIVERABLES ----
                    if (profile.deliverables.isNotEmpty)
                      _sectionCard(
                        context,
                        title: "Deliverables",
                        children: profile.deliverables
                            .map((d) => _bullet(
                                context, "${d.title} — ${d.description}"))
                            .toList(),
                      ),

                    // ---- PROCESS ----
                    if (profile.processSteps.isNotEmpty)
                      _sectionCard(
                        context,
                        title: "Work Process",
                        children: profile.processSteps
                            .asMap()
                            .entries
                            .map((e) => _stepItem(context, e.key + 1,
                                e.value.title, e.value.description))
                            .toList(),
                      ),

                    // ---- PROMISES ----
                    if (profile.promises
                        .where((p) => p.checked == true)
                        .isNotEmpty)
                      _sectionCard(
                        context,
                        title: "My Promises",
                        children: profile.promises
                            .where((p) => p.checked == true)
                            .map((p) => _promiseItem(context, p.text))
                            .toList(),
                      ),

                    // ---- FAQ ----
                    if (profile.faqs.isNotEmpty)
                      _sectionCard(
                        context,
                        title: "FAQs",
                        children: profile.faqs
                            .map((f) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Q: ${f.question}",
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            )),
                                        const SizedBox(height: 4),
                                        Text("A: ${f.answer}",
                                            style: theme.textTheme.bodyMedium),
                                      ],
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // ---- BOTTOM BUTTONS ----
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Add to Cart",
                        icon: Icons.add_shopping_cart,
                        color: colorScheme.primaryContainer,
                        onPressed: () async {
                          final profile = snapshot.data!;

                          // prepare cart item
                          final item = {
                            "id": profile.id,
                            "title": profile.serviceTitle,
                            "quantity": 1,
                            "hourlyRate": profile.hourlyRate,
                            "image": profile.profileImage,
                            "category": profile.serviceCategory,
                          };

                          if (isLoggedIn) {
                            await addToCart(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Added to online cart")),
                            );
                          } else {
                            final cartItem = CartItemModel.fromMap(item);
                            await CartService.addToCart(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Added to local cart")),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ---- Reusable UI Components ----
  Widget _infoRow(
      BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
          ),
          Text(value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
        ],
      ),
    );
  }

  Widget _sectionCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Card(
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: colorScheme.shadow.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.circle,
                size: 8, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      );

  Widget _stepItem(BuildContext context, int step, String title, String desc) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(step.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 13)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(desc, style: Theme.of(context).textTheme.bodyMedium),
                  ]),
            )
          ],
        ),
      );

  Widget _promiseItem(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      );
}
