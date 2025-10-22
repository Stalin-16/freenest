import 'package:flutter/material.dart';

class ProfileDetailsPage extends StatelessWidget {
  final String title;
  final String imgUrl;
  final String description;
  final double price;

  const ProfileDetailsPage({
    super.key,
    required this.title,
    required this.imgUrl,
    required this.description,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80), // space for button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  imgUrl,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '₹${price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
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
                  // Add your cart logic here
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
      ),
    );
  }
}
