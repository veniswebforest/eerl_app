import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Dropdown card showing the currently selected EERL zone.
class ZoneSelector extends StatelessWidget {
  const ZoneSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Location icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: AppColors.primary500,
            ),
          ),
          const SizedBox(width: 10),

          // Zone label
          const Expanded(
            child: Text(
              'EERL · Surat Zone',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A202C),
              ),
            ),
          ),

          // Dropdown arrow
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF92A3B0),
          ),
        ],
      ),
    );
  }
}
