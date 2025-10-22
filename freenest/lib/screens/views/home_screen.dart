import 'package:flutter/material.dart';
import 'package:freenest/screens/views/profile_details_screen.dart';
import 'package:freenest/widgets/service_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String? userName = '';

  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> services = [
    {
      'title': 'Web Development',
      'img': 'https://cdn-icons-png.flaticon.com/512/2738/2738854.png'
    },
    {
      'title': 'Software Development',
      'img': 'https://cdn-icons-png.flaticon.com/512/810/810207.png'
    },
    {
      'title': 'Block Chain',
      'img': 'https://cdn-icons-png.flaticon.com/512/3050/3050525.png'
    },
    {
      'title': 'Plumber',
      'img': 'https://cdn-icons-png.flaticon.com/512/1903/1903482.png'
    },
    {
      'title': 'Cleaning',
      'img': 'https://cdn-icons-png.flaticon.com/512/2920/2920058.png'
    },
    {
      'title': 'AC Repair',
      'img': 'https://cdn-icons-png.flaticon.com/512/1684/1684375.png'
    },
  ];

  final List<String> promoImages = [
    'https://images.unsplash.com/photo-1556740714-a8395b3bf30f?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1556742044-3c52d6e88c62?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_vector-1682309080127-19d3a6214a17?q=80&w=1170&auto=format&fit=crop',
  ];

  List<Map<String, String>> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _filteredServices = List.from(services);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredServices = services
          .where((service) => service['title']!.toLowerCase().contains(query))
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          if (userName != null && userName!.isNotEmpty) ...[
            Text(
              "Hi $userName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "What service do you need today?",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),
          ],
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
          if (_filteredServices.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.8,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileDetailsPage(
                          title: "${_filteredServices[index]['title']}",
                          imgUrl: "",
                          description: "",
                          price: 0,
                          // title: service['title']!,
                          // imgUrl: service['img']!,
                          // description: service['description'] ??
                          //     'No description available',
                          // price: service['price'] ?? 0,
                        ),
                      ),
                    );
                  },
                  child: ServiceCard(
                    title: _filteredServices[index]['title']!,
                    imgUrl: _filteredServices[index]['img']!,
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
          const SizedBox(height: 20),
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: promoImages.map((img) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(img,
                        fit: BoxFit.cover, width: double.infinity),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
