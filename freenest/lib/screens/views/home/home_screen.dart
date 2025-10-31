import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/screens/views/home/profile_details_screen.dart';
import 'package:freenest/service/profile_service.dart';
import 'package:freenest/widgets/service_card.dart';
// import 'package:carousel_slider/carousel_slider.dart'

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? userName = "Stalin"; // Example name (replace dynamically later)
  final ProfileService _profileService = ProfileService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _profiles = [];
  List<Map<String, dynamic>> _filteredProfiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    try {
      final List<ProfileList> profiles = await _profileService.getAllProfiles();
      setState(() {
        _profiles = profiles
            .map((p) => {
                  'id': p.id.toString(),
                  'title': p.serviceTitle,
                  'img': p.profileImage != null && p.profileImage!.isNotEmpty
                      ? "${AppConfig.imageUrl}${p.profileImage}"
                      : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
                })
            .toList();
        _filteredProfiles = _profiles;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading profiles: $e");
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProfiles = _profiles
          .where((p) => p['title'].toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 3 : 5;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // appBar: AppBar(
        // backgroundColor: Colors.white,
        // title: Row(
        //   children: [
        //     const Icon(Icons.person, color: Colors.white),
        //     const SizedBox(width: 10),
        //     Text(
        //       "Welcome, ${userName ?? 'User'} ",
        //       style:  TextStyle(color:  theme.brightness == Brightness.dark ? Colors.black : Colors.black),
        //     ),
        //   ],
        // ),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         theme.brightness == Brightness.dark
      //             ? Icons.light_mode
      //             : Icons.dark_mode,
      //         color: Colors.white,
      //       ),
      //       onPressed: () {
      //         // Optional: Implement theme toggle using provider or Bloc later
      //       },
      //     ),
      //   ],
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search for services...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: theme.inputDecorationTheme.fillColor ??
                    (theme.brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.white),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Popular Services",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_filteredProfiles.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _filteredProfiles.length,
                itemBuilder: (context, index) {
                  final item = _filteredProfiles[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfileDetailsPage(profileId: item['id']),
                        ),
                      );
                    },
                    child: ServiceCard(
                      title: item['title'],
                      imgUrl: item['img'],
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "No matching services found",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}