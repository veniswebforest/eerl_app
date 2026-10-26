import 'package:flutter/material.dart';

import 'package:eerl_app/shared/widgets/app_top_notification.dart';

/// Helper for showing consistently themed snackbars.
class AppSnackbar {
  AppSnackbar._();

  /// Show an informational snackbar.
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    AppTopNotification.show(
      context,
      title: message,
      duration: duration,
      tone: AppTopNotificationTone.info,
    );
  }

  /// Show a success snackbar.
  static void success(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    AppTopNotification.show(
      context,
      title: message,
      duration: duration,
      tone: AppTopNotificationTone.success,
    );
  }

  /// Show an error snackbar.
  static void error(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
  }) {
    AppTopNotification.show(
      context,
      title: message,
      duration: duration,
      tone: AppTopNotificationTone.error,
    );
  }
}
