import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// List of available collection types: D2D, MRF Station, Ramp.
class CollectionTypes extends StatelessWidget {
  const CollectionTypes({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Collection types',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 10),
        CollectionTypeItem(
          icon: Icons.local_shipping_outlined,
          iconColor: AppColors.primary500,
          iconBg: AppColors.primary100,
          title: 'D2D',
          subtitle: 'SMC Vehicle',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        CollectionTypeItem(
          icon: Icons.recycling_outlined,
          iconColor: AppColors.orchid,
          iconBg: AppColors.orchidLight,
          title: 'MRF Station',
          subtitle: 'Material Recovery Facility',
          onTap: () {},
        ),
        const SizedBox(height: 8),
        CollectionTypeItem(
          icon: Icons.person_outline,
          iconColor: AppColors.purple,
          iconBg: AppColors.purpleLight,
          title: 'Ramp',
          subtitle: 'Retail Dealer',
          onTap: () {},
        ),
      ],
    );
  }
}

/// Single tappable row inside [CollectionTypes].
class CollectionTypeItem extends StatelessWidget {
  const CollectionTypeItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6EBEE), width: 1),
          ),
          child: Row(
            children: [
              // Icon bubble
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 12),

              // Title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF92A3B0),
                      ),
                    ),
                  ],
                ),
              ),

              // Green chevron button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
