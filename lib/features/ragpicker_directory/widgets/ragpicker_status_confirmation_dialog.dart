import 'package:flutter/material.dart';

import 'package:eerl_app/shared/widgets/app_confirmation_dialog.dart';

class RagpickerStatusConfirmationDialog {
  RagpickerStatusConfirmationDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    required String cancelLabel,
    required String confirmLabel,
    required Color confirmColor,
  }) => AppConfirmationDialog.show(
    context: context,
    title: title,
    message: message,
    cancelLabel: cancelLabel,
    confirmLabel: confirmLabel,
    confirmColor: confirmColor,
    dialogKey: const Key('ragpicker-status-dialog'),
    cancelButtonKey: const Key('ragpicker-dialog-cancel'),
    confirmButtonKey: const Key('ragpicker-dialog-confirm'),
  );
}
