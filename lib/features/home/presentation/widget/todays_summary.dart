import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 2×2 grid summary section showing today's collection stats.
class TodaysSummary extends StatelessWidget {
  const TodaysSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Summary",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.65,
          children: const [
            SummaryCard(
              icon: Icons.inventory_2_outlined,
              iconColor: AppColors.orchid,
              iconBg: AppColors.orchidLight,
              label: 'Collected Today',
              value: '320 KG',
              valueColor: AppColors.orchid,
            ),
            SummaryCard(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.primary500,
              iconBg: AppColors.primary100,
              label: 'Verified Entries',
              value: '18',
              valueColor: AppColors.primary500,
            ),
            SummaryCard(
              icon: Icons.swap_horiz_outlined,
              iconColor: AppColors.orange,
              iconBg: AppColors.orangeLight,
              label: 'Transfer Requests',
              value: '04',
              valueColor: AppColors.orange,
            ),
            SummaryCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.purple,
              iconBg: AppColors.purpleLight,
              label: 'Wallet Balance',
              value: '₹50,000',
              valueColor: AppColors.purple,
            ),
          ],
        ),
      ],
    );
  }
}

/// Individual stat card used inside [TodaysSummary].
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6EBEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon bubble
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF92A3B0),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
