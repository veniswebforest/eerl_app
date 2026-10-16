import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/auth/presentation/auth_provider.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

import '../model/logout_data_status.dart';
import 'profile_assets.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({
    super.key,
    this.dataStatus,
    this.pendingCount,
    this.onNo,
    this.onYes,
    this.loadSyncStatus,
    this.syncPendingEntries,
  });

  final LogoutDataStatus? dataStatus;
  final int? pendingCount;
  final VoidCallback? onNo;
  final FutureOr<void> Function()? onYes;
  final Future<SyncStatusModel> Function()? loadSyncStatus;
  final Future<void> Function()? syncPendingEntries;

  @override
  State<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  LogoutDataStatus? _dataStatus;
  int _pendingCount = 0;
  bool _loading = false;
  bool _syncing = false;
  bool _syncFailed = false;

  @override
  void initState() {
    super.initState();
    _dataStatus = widget.dataStatus;
    _pendingCount = widget.pendingCount ?? 0;
    if (_dataStatus == null) unawaited(_refreshStatus(showLoader: true));
  }

  Future<SyncStatusModel> _getSyncStatus() =>
      (widget.loadSyncStatus ?? EerlLocalRepository.instance.getSyncStatus)();

  Future<void> _refreshStatus({bool showLoader = false}) async {
    if (showLoader && mounted) setState(() => _loading = true);
    try {
      final status = await _getSyncStatus();
      if (!mounted) return;
      setState(() {
        _pendingCount = status.outboxCount;
        _dataStatus = status.hasOutboxEntries
            ? LogoutDataStatus.pending
            : LogoutDataStatus.synced;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // If the queue cannot be inspected, fail closed and do not allow
        // logout to discard data whose sync state is unknown.
        _dataStatus = LogoutDataStatus.pending;
        _syncFailed = true;
      });
    } finally {
      if (mounted && showLoader) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPendingData = _dataStatus == LogoutDataStatus.pending;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: AppColors.neutral50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                ProfileAssets.logoutDialog,
                width: 57.8123,
                height: 55.5,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  context.l10n.logoutConfirmationTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.boldH6_20.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.logoutConfirmationMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.cool950,
                ),
              ),
              if (hasPendingData) ...[
                const SizedBox(height: 16),
                Container(
                  key: const Key('logout-pending-warning'),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.red50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        ProfileAssets.logoutWarning,
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          context.l10n.syncPendingItems(_pendingCount),
                          key: const Key('logout-pending-count'),
                          style: AppTextStyles.boldH8_14.copyWith(
                            color: AppColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_syncFailed) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.logoutSyncRequired,
                  key: const Key('logout-sync-error'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mediumSH9_12.copyWith(
                    color: AppColors.red600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _LogoutButton(
                      key: const Key('logout-no-button'),
                      label: context.l10n.logoutNo,
                      backgroundColor: AppColors.cool200,
                      foregroundColor: AppColors.cool950,
                      onPressed: _syncing || _loading
                          ? null
                          : widget.onNo ?? () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LogoutButton(
                      key: const Key('logout-yes-button'),
                      label: context.l10n.logoutYes,
                      backgroundColor: AppColors.red500,
                      foregroundColor: AppColors.neutral50,
                      isLoading: _syncing || _loading,
                      onPressed: _syncing || _loading
                          ? null
                          : () => _confirmLogout(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    if (_syncing || _loading) return;
    setState(() {
      _syncing = true;
      _syncFailed = false;
    });
    try {
      final beforeSync = await _getSyncStatus();
      if (beforeSync.hasOutboxEntries) {
        await (widget.syncPendingEntries ??
            OutgoingSyncService.instance.retryAllAndDrain)();
      }
      final afterSync = await _getSyncStatus();
      if (!mounted) return;
      setState(() {
        _pendingCount = afterSync.outboxCount;
        _dataStatus = afterSync.hasOutboxEntries
            ? LogoutDataStatus.pending
            : LogoutDataStatus.synced;
        _syncFailed = afterSync.hasOutboxEntries;
      });
      if (afterSync.hasOutboxEntries) return;

      final override = widget.onYes;
      if (override != null) {
        await override();
        return;
      }
      if (!context.mounted) return;
      await _logout(context);
    } catch (_) {
      if (mounted) setState(() => _syncFailed = true);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final router = GoRouter.of(context);
    await authProvider.logout();
    if (!context.mounted) return;
    Navigator.pop(context);
    router.go(AppRoutes.login);
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.neutral50,
              ),
            )
          : Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.boldH7_16,
            ),
    ),
  );
}
