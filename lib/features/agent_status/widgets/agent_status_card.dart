import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/agent_status/model/agent_status_item.dart';
import 'package:eerl_app/features/home/widgets/home_assets.dart';

class AgentStatusCard extends StatelessWidget {
  const AgentStatusCard({
    super.key,
    required this.item,
    required this.activeLabel,
    required this.offlineLabel,
  });

  final AgentStatusItem item;
  final String activeLabel;
  final String offlineLabel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: Image.asset(
                item.avatarAsset,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral950,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _AgentStatusChip(
              active: item.isActive,
              label: item.isActive ? activeLabel : offlineLabel,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cool100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SvgPicture.asset(HomeAssets.zone, width: 24, height: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AgentStatusChip extends StatelessWidget {
  const _AgentStatusChip({required this.active, required this.label});

  final bool active;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      color: active ? AppColors.primary50 : AppColors.cool200,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.primary500 : AppColors.cool600,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.semiboldH10_12.copyWith(
            color: active ? AppColors.primary500 : AppColors.cool600,
          ),
        ),
      ],
    ),
  );
}
