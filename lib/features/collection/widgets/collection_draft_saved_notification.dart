import 'package:flutter/material.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/shared/widgets/app_top_notification.dart';

void showCollectionDraftSavedNotification(BuildContext context) {
  AppTopNotification.show(
    context,
    key: const Key('collection-draft-saved-notification'),
    title: context.l10n.collectionDraftSaved,
    subtitle: context.l10n.collectionDraftSavedSubtitle,
    tone: AppTopNotificationTone.success,
  );
}
