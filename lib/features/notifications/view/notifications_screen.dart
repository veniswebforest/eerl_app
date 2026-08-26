import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/notification_item_model.dart';
import '../widgets/empty_notifications_view.dart';
import '../widgets/notification_list_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    required this.onBack,
    this.hasNotifications = true,
  });

  final VoidCallback onBack;
  final bool hasNotifications;

  static const _items = [
    NotificationItemModel(
      type: AppNotificationType.offline,
      group: NotificationGroup.today,
      timeKey: 'justNow',
    ),
    NotificationItemModel(
      type: AppNotificationType.transferRejected,
      group: NotificationGroup.today,
      timeKey: 'tenMinutes',
    ),
    NotificationItemModel(
      type: AppNotificationType.receiptPrinted,
      group: NotificationGroup.today,
      timeKey: 'fiveHours',
    ),
    NotificationItemModel(
      type: AppNotificationType.collectionSubmitted,
      group: NotificationGroup.today,
      timeKey: 'sevenHours',
    ),
    NotificationItemModel(
      type: AppNotificationType.expenseRejected,
      group: NotificationGroup.earlier,
      timeKey: 'yesterday',
    ),
    NotificationItemModel(
      type: AppNotificationType.syncCompleted,
      group: NotificationGroup.earlier,
      timeKey: 'previousDate',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.notificationTitle,
      onBackTap: onBack,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: hasNotifications
              ? _NotificationList(items: _items)
              : EmptyNotificationsView(
                  title: context.l10n.notificationEmptyTitle,
                  message: context.l10n.notificationEmptyMessage,
                ),
        ),
      ),
    ),
  );
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items});

  final List<NotificationItemModel> items;

  @override
  Widget build(BuildContext context) {
    final today = items
        .where((item) => item.group == NotificationGroup.today)
        .toList(growable: false);
    final earlier = items
        .where((item) => item.group == NotificationGroup.earlier)
        .toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        _sectionLabel(context.l10n.notificationToday),
        const SizedBox(height: 10),
        _card(context, today),
        const SizedBox(height: 24),
        _sectionLabel(context.l10n.notificationEarlier),
        const SizedBox(height: 10),
        _card(context, earlier),
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppTextStyles.semiboldH9_14.copyWith(color: AppColors.neutral950),
  );

  Widget _card(BuildContext context, List<NotificationItemModel> items) =>
      NotificationListCard(
        items: items,
        titleFor: (type) => _title(context, type),
        messageFor: (type) => _message(context, type),
        timeFor: (key) => _time(context, key),
      );

  String _title(BuildContext context, AppNotificationType type) =>
      switch (type) {
        AppNotificationType.offline => context.l10n.notificationOfflineTitle,
        AppNotificationType.transferRejected =>
          context.l10n.notificationTransferRejectedTitle,
        AppNotificationType.receiptPrinted =>
          context.l10n.notificationReceiptTitle,
        AppNotificationType.collectionSubmitted =>
          context.l10n.notificationCollectionTitle,
        AppNotificationType.expenseRejected =>
          context.l10n.notificationExpenseTitle,
        AppNotificationType.syncCompleted => context.l10n.notificationSyncTitle,
      };

  String _message(BuildContext context, AppNotificationType type) =>
      switch (type) {
        AppNotificationType.offline => context.l10n.notificationOfflineMessage,
        AppNotificationType.transferRejected =>
          context.l10n.notificationTransferRejectedMessage,
        AppNotificationType.receiptPrinted =>
          context.l10n.notificationReceiptMessage,
        AppNotificationType.collectionSubmitted =>
          context.l10n.notificationCollectionMessage,
        AppNotificationType.expenseRejected =>
          context.l10n.notificationExpenseMessage,
        AppNotificationType.syncCompleted =>
          context.l10n.notificationSyncMessage,
      };

  String _time(BuildContext context, String key) => switch (key) {
    'justNow' => context.l10n.notificationJustNow,
    'tenMinutes' => context.l10n.notificationTenMinutes,
    'fiveHours' => context.l10n.notificationFiveHours,
    'sevenHours' => context.l10n.notificationSevenHours,
    'yesterday' => context.l10n.notificationYesterday,
    'previousDate' => context.l10n.notificationPreviousDate,
    _ => key,
  };
}
