import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/home/widgets/collection_types.dart';
import 'package:eerl_app/shared/widgets/app_screen_header.dart';
import '../model/recent_collection_item_model.dart';
import '../widgets/collection_assets.dart';
import '../widgets/start_collection_card.dart';

class CollectionsTabScreen extends StatelessWidget {
  const CollectionsTabScreen({
    super.key,
    this.onAddCollection,
    this.onCollectionTap,
    this.onViewAllTap,
    this.onNotificationTap,
    this.onCollectionTypeTap,
  });
  final VoidCallback? onAddCollection;
  final ValueChanged<RecentCollectionStatus>? onCollectionTap;
  final VoidCallback? onViewAllTap;
  final VoidCallback? onNotificationTap;
  final ValueChanged<CollectionType>? onCollectionTypeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            AppScreenHeaderMetrics.topInset,
            20,
            120,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppScreenHeader(
                      title: l10n.collections,
                      subtitle: l10n.startYourCollections,
                      actions: [
                        InkWell(
                          key: const Key('collections-notification-button'),
                          onTap: onNotificationTap,
                          borderRadius: BorderRadius.circular(24),
                          child: SvgPicture.asset(
                            CollectionAssets.notification,
                            width: 45,
                            height: 45,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    StartCollectionCard(
                      title: l10n.startCollection,
                      description: l10n.recordWeightProof,
                    ),
                    const SizedBox(height: 24),
                    CollectionTypes(onTypeTap: onCollectionTypeTap),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
