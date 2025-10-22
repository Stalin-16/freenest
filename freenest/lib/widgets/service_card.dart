import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String imgUrl;

  const ServiceCard({super.key, required this.title, required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.25;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const[ BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(imgUrl, height: cardWidth * 0.4, width: cardWidth * 0.4),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          
        ],
      ),
    );
  }
}