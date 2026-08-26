import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/notification_item_model.dart';

class NotificationListCard extends StatelessWidget {
  const NotificationListCard({
    super.key,
    required this.items,
    required this.titleFor,
    required this.messageFor,
    required this.timeFor,
  });

  final List<NotificationItemModel> items;
  final String Function(AppNotificationType type) titleFor;
  final String Function(AppNotificationType type) messageFor;
  final String Function(String timeKey) timeFor;

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
            title: titleFor(items[index].type),
            message: messageFor(items[index].type),
            time: timeFor(items[index].timeKey),
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
  const _NotificationTile({
    required this.item,
    required this.title,
    required this.message,
    required this.time,
  });

  final NotificationItemModel item;
  final String title;
  final String message;
  final String time;

  @override
  Widget build(BuildContext context) {
    final colors = _iconColors(item.type);
    return Padding(
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
                  _iconAsset(item.type),
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(colors.$1, BlendMode.srcIn),
                ),
                if (item.type == AppNotificationType.offline)
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
                  title,
                  style: AppTextStyles.semiboldH8_16.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
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
    );
  }

  String _iconAsset(AppNotificationType type) => switch (type) {
    AppNotificationType.offline => 'assets/icons/home/online.svg',
    AppNotificationType.transferRejected =>
      'assets/icons/wallet/status_flagged.svg',
    AppNotificationType.receiptPrinted =>
      'assets/icons/wallet/status_verified.svg',
    AppNotificationType.collectionSubmitted =>
      'assets/icons/wallet/status_verified.svg',
    AppNotificationType.expenseRejected =>
      'assets/icons/wallet/status_verified.svg',
    AppNotificationType.syncCompleted =>
      'assets/icons/wallet/status_verified.svg',
  };

  (Color, Color) _iconColors(AppNotificationType type) => switch (type) {
    AppNotificationType.offline => (AppColors.neutral600, AppColors.neutral100),
    AppNotificationType.transferRejected => (AppColors.red500, AppColors.red50),
    _ => (AppColors.primary500, AppColors.primary50),
  };
}
