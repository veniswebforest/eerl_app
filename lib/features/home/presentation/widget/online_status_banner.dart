import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Green banner showing connectivity status and pending sync count.
class OnlineStatusBanner extends StatelessWidget {
  const OnlineStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF9EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC3EFCB), width: 1),
      ),
      child: Row(
        children: [
          // Wifi icon
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.wifi, size: 18, color: AppColors.primary500),
          ),
          const SizedBox(width: 10),

          // Status text
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're Online",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4A28),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '3 collection Pending',
                  style: TextStyle(fontSize: 12, color: Color(0xFF247134)),
                ),
              ],
            ),
          ),

          // Sync Now button
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }
}
