import 'package:flutter/material.dart';
import 'package:freenest/model/profile_mode.dart';
import 'package:freenest/service/profile_service.dart';

class ProfileDetailsPage extends StatefulWidget {
  final String profileId;

  const ProfileDetailsPage({super.key, required this.profileId});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  late Future<Profile> _profileFuture;
  final ProfileService _profileService = ProfileService();
  @override
  void initState() {
    super.initState();
    _profileFuture = fetchProfile();
  }

Future<Profile> fetchProfile() async {
  final response = await _profileService.getProfileById(widget.profileId);
  print(response);
  if (response.status == 200) {
    return Profile.fromMap(response.data);
  } else {
    throw Exception("Failed to load profile");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Details")),
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
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (profile.profileImage != null)
                      Image.network(
                        profile.profileImage!,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        profile.serviceTitle,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Category: ${profile.serviceCategory}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Experience: ${profile.experienceRange}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Hourly Rate: ₹${profile.hourlyRate}",
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        profile.tagline,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Rating: ${profile.rating}/5",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Reviews: ${profile.reviewComments}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deliverables
                    if (profile.deliverables.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Deliverables:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ...profile.deliverables.map(
                                (d) => Text("- ${d.title} (${d.description})")),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Process Steps
                    if (profile.processSteps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Process Steps:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ...profile.processSteps.map(
                                (p) => Text("- ${p.title}: ${p.description}")),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Promises
                    if (profile.promises.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Promises:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ...profile.promises.map((p) => Row(
                                  children: [
                                    Icon(
                                      p.checked
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: p.checked
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text(p.text)),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),

                    // FAQs
                    if (profile.faqs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("FAQs:",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            ...profile.faqs.map((f) =>
                                Text("- Q: ${f.question}\n  A: ${f.answer}")),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),

              // Fixed bottom button
              Positioned(
                bottom: 10,
                left: 16,
                right: 16,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to Cart")),
                      );
                    },
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
