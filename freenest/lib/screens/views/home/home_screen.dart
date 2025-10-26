import 'package:flutter/material.dart';
import 'package:freenest/config/app_config.dart';
import 'package:freenest/model/profile_mode.dart';
import 'package:freenest/model/profile_name.dart';
import 'package:freenest/screens/views/profile_details_screen.dart';
import 'package:freenest/service/profile_service.dart';
import 'package:freenest/widgets/service_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? userName = '';
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

    print("Profiles Loaded: ${profiles.length}");

    setState(() {
      _profiles = profiles
          .map((p) => {
                'id': p.id.toString(),
                'title': p.serviceTitle,
                'img': p.profileImage != null && p.profileImage!.isNotEmpty
                    ? "${AppConfig.baseUrl}${p.profileImage}"
                    : "https://cdn-icons-png.flaticon.com/512/1946/1946429.png",
              })
          .toList();

      _filteredProfiles = _profiles;
      _isLoading = false;
    });
  } catch (e) {
    print("Error loading profiles: $e");
    setState(() {
      _isLoading = false;
    });
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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 3 : 5;

    return SingleChildScrollView(
      child: Padding(
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
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Popular Services",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
                          builder: (context) => ProfileDetailsPage(
                            profileId: item['id'],
                          ),
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


//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     int crossAxisCount = screenWidth < 600 ? 3 : 5;
//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 10),
//           if (userName != null && userName!.isNotEmpty) ...[
//             Text(
//               "Hi $userName",
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 6),
//             const Text(
//               "What service do you need today?",
//               style: TextStyle(fontSize: 16, color: Colors.black54),
//             ),
//             const SizedBox(height: 16),
//           ],
//           TextField(
//             controller: _searchController,
//             decoration: InputDecoration(
//               hintText: "Search for services...",
//               prefixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(25),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "Popular Services",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 12),
//           if (_filteredServices.isNotEmpty)
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: crossAxisCount,
//                 childAspectRatio: 0.8,
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//               ),
//               itemCount: _filteredServices.length,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ProfileDetailsPage(
//                           title: "${_filteredServices[index]['title']}",
//                           imgUrl: "",
//                           description: "",
//                           price: 0,
//                           // title: service['title']!,
//                           // imgUrl: service['img']!,
//                           // description: service['description'] ??
//                           //     'No description available',
//                           // price: service['price'] ?? 0,
//                         ),
//                       ),
//                     );
//                   },
//                   child: ServiceCard(
//                     title: _filteredServices[index]['title']!,
//                     imgUrl: _filteredServices[index]['img']!,
//                   ),
//                 );
//               },
//             )
//           else
//             const Padding(
//               padding: EdgeInsets.all(12.0),
//               child: Text(
//                 "No matching services found",
//                 style: TextStyle(color: Colors.grey, fontSize: 14),
//               ),
//             ),
//           const SizedBox(height: 20),
//           // CarouselSlider(
//           //   options: CarouselOptions(
//           //     height: 180,
//           //     autoPlay: true,
//           //     enlargeCenterPage: true,
//           //     viewportFraction: 0.9,
//           //     autoPlayInterval: const Duration(seconds: 3),
//           //   ),
//           //   items: promoImages.map((img) {
//           //     return ClipRRect(
//           //       borderRadius: BorderRadius.circular(16),
//           //       child: Stack(
//           //         children: [
//           //           Image.network(img,
//           //               fit: BoxFit.cover, width: double.infinity),
//           //           Container(
//           //             decoration: BoxDecoration(
//           //               gradient: LinearGradient(
//           //                 begin: Alignment.topCenter,
//           //                 end: Alignment.bottomCenter,
//           //                 colors: [
//           //                   Colors.transparent,
//           //                   Colors.black.withOpacity(0.4)
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     );
//           //   }).toList(),
//           // ),
//         ],
//       ),
//     );
//   }
// }
