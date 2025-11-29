import 'package:flutter/material.dart';

class ReferralCard extends StatelessWidget {
  final VoidCallback? onViewDetails;

  const ReferralCard({super.key, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        // borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Icon
          Column(
            children: [
              Icon(Icons.compare_arrows,
                  size: 28, color: theme.iconTheme.color),
              const SizedBox(height: 8),
              Icon(Icons.person_add, size: 28, color: theme.iconTheme.color),
            ],
          ),

          const SizedBox(width: 16),

          // Middle Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Refer and get free services",
                  style: theme.textTheme.titleMedium!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Invite and get 5% Credit",
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ),

          // Right "View details"
          GestureDetector(
            onTap: onViewDetails,
            child: Text(
              "View details",
              style: theme.textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
