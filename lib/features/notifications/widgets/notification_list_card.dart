import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

class NotificationListCard extends StatelessWidget {
  const NotificationListCard({
    super.key,
    required this.items,
    required this.timeFor,
    this.onTap,
  });

  final List<NotificationModel> items;
  final String Function(String createdAt) timeFor;
  final ValueChanged<NotificationModel>? onTap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        for (var index = 0; index < items.length; index++) ...[
          _NotificationTile(
            item: items[index],
            time: timeFor(items[index].createdAt),
            onTap: onTap == null ? null : () => onTap!(items[index]),
          ),
          if (index != items.length - 1)
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.cool200,
            ),
        ],
      ],
    ),
  );
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.time, this.onTap});

  final NotificationModel item;
  final String time;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = item.type.toUpperCase();
    final colors = _iconColors(type);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.$2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    _iconAsset(type),
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(colors.$1, BlendMode.srcIn),
                  ),
                  if (type == 'OFFLINE')
                    Transform.rotate(
                      angle: -.72,
                      child: Container(
                        width: 29,
                        height: 2,
                        decoration: BoxDecoration(
                          color: colors.$1,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.body ?? '',
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    time,
                    style: AppTextStyles.mediumSH9_12.copyWith(
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _iconAsset(String type) => switch (type) {
    'OFFLINE' => 'assets/icons/home/online.svg',
    'TRANSFER_REJECTED' => 'assets/icons/wallet/status_flagged.svg',
    _ => 'assets/icons/wallet/status_verified.svg',
  };

  (Color, Color) _iconColors(String type) => switch (type) {
    'OFFLINE' => (AppColors.neutral600, AppColors.neutral100),
    'TRANSFER_REJECTED' => (AppColors.red500, AppColors.red50),
    _ => (AppColors.primary500, AppColors.primary50),
  };
}
