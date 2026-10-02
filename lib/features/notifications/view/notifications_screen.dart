import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/local_data/presentation/local_query_controller.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/empty_notifications_view.dart';
import '../widgets/notification_list_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, this.hasNotifications = true});

  final bool hasNotifications;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final LocalQueryController<List<NotificationModel>> _controller;
  int _bootstrapRevision = -1;

  @override
  void initState() {
    super.initState();
    _controller = LocalQueryController(
      EerlLocalRepository.instance.getNotifications,
    )..load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final revision = BootstrapSyncService.instance.revision;
    if (_bootstrapRevision >= 0 && revision != _bootstrapRevision) {
      _controller.load();
    }
    _bootstrapRevision = revision;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: context.l10n.notificationTitle,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.isLoading && !_controller.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_controller.error != null) {
                return _LoadError(onRetry: _controller.load);
              }
              final items = widget.hasNotifications
                  ? (_controller.data ?? const <NotificationModel>[])
                  : const <NotificationModel>[];
              return items.isEmpty
                  ? EmptyNotificationsView(
                      title: context.l10n.notificationEmptyTitle,
                      message: context.l10n.notificationEmptyMessage,
                    )
                  : _NotificationList(
                      items: items,
                      onChanged: _controller.load,
                    );
            },
          ),
        ),
      ),
    ),
  );
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.items, required this.onChanged});

  final List<NotificationModel> items;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final today = <NotificationModel>[];
    final earlier = <NotificationModel>[];
    final now = DateTime.now();
    for (final item in items) {
      final created = DateTime.tryParse(item.createdAt)?.toLocal();
      if (created != null &&
          created.year == now.year &&
          created.month == now.month &&
          created.day == now.day) {
        today.add(item);
      } else {
        earlier.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        if (today.isNotEmpty) ...[
          _sectionLabel(context.l10n.notificationToday),
          const SizedBox(height: 10),
          _card(today),
          const SizedBox(height: 24),
        ],
        if (earlier.isNotEmpty) ...[
          _sectionLabel(context.l10n.notificationEarlier),
          const SizedBox(height: 10),
          _card(earlier),
        ],
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: AppTextStyles.semiboldH9_14.copyWith(color: AppColors.neutral950),
  );

  Widget _card(List<NotificationModel> items) => NotificationListCard(
    items: items,
    timeFor: _formatTime,
    onTap: (item) async {
      if (item.readAt == null) {
        await EerlLocalRepository.instance.markNotificationRead(item.id);
        onChanged();
      }
    },
  );

  String _formatTime(String value) {
    final parsed = DateTime.tryParse(value)?.toLocal();
    return parsed == null
        ? value
        : DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(onPressed: onRetry, child: const Text('Retry')),
  );
}
