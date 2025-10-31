import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String imgUrl;

  const ServiceCard({
    super.key,
    required this.title,
    required this.imgUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    double cardWidth = MediaQuery.of(context).size.width * 0.25;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
        ],
        border: isDark
            ? Border.all(color: Colors.grey.withOpacity(0.3))
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imgUrl,
            height: cardWidth * 0.4,
            width: cardWidth * 0.4,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  