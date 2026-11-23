import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/features/collection/model/collection_entry_state.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'home_assets.dart';
import 'home_styles.dart';

/// List of available collection types: D2D, MRF Station, Ramp.
class CollectionTypes extends StatefulWidget {
  const CollectionTypes({super.key, this.onTypeTap});

  final ValueChanged<CollectionType>? onTypeTap;

  @override
  State<CollectionTypes> createState() => _CollectionTypesState();
}

class _CollectionTypesState extends State<CollectionTypes> {
  List<CollectionType>? _types;
  int _bootstrapRevision = -1;

  @override
  void initState() {
    super.initState();
    _bootstrapRevision = BootstrapSyncService.instance.revision;
    BootstrapSyncService.instance.addListener(_reloadAfterBootstrap);
    EerlLocalRepository.instance.activeCenterNotifier.addListener(_load);
    unawaited(_load());
  }

  @override
  void dispose() {
    BootstrapSyncService.instance.removeListener(_reloadAfterBootstrap);
    EerlLocalRepository.instance.activeCenterNotifier.removeListener(_load);
    super.dispose();
  }

  void _reloadAfterBootstrap() {
    final revision = BootstrapSyncService.instance.revision;
    if (revision == _bootstrapRevision) return;
    _bootstrapRevision = revision;
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final channels = await EerlLocalRepository.instance.getChannels();
      if (!mounted) return;
      final types = channels
          .map((channel) => _typeFromChannel(channel.channel))
          .whereType<CollectionType>()
          .toList(growable: false);
      setState(() => _types = types.isEmpty ? CollectionType.values : types);
    } catch (_) {
      if (mounted) setState(() => _types = CollectionType.values);
    }
  }

  CollectionType? _typeFromChannel(String channel) =>
      switch (channel.trim().toUpperCase()) {
        'D2D' => CollectionType.d2d,
        'MRF' => CollectionType.mrfStation,
        'RAMP' => CollectionType.ramp,
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final types = _types;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.collectionTypes, style: HomeStyles.sectionTitle),
        const SizedBox(height: 16),
        if (types == null)
          const Center(child: CircularProgressIndicator())
        else
          for (var index = 0; index < types.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _item(context, types[index]),
          ],
      ],
    );
  }

  Widget _item(BuildContext context, CollectionType type) => switch (type) {
    CollectionType.d2d => CollectionTypeItem(
      key: const Key('home-collection-type-d2d'),
      iconAsset: HomeAssets.collectionD2d,
      iconColor: AppColors.secondary500,
      iconBg: AppColors.primary100,
      title: context.l10n.d2d,
      subtitle: context.l10n.smcVehicle,
      onTap: () => widget.onTypeTap?.call(type),
    ),
    CollectionType.mrfStation => CollectionTypeItem(
      key: const Key('home-collection-type-mrf'),
      iconAsset: HomeAssets.collectionMrf,
      iconColor: AppColors.orchid,
      iconBg: AppColors.orchidLight,
      title: context.l10n.mrfStation,
      subtitle: context.l10n.materialRecoveryFacility,
      onTap: () => widget.onTypeTap?.call(type),
    ),
    CollectionType.ramp => CollectionTypeItem(
      key: const Key('home-collection-type-ramp'),
      iconAsset: HomeAssets.collectionRamp,
      iconColor: AppColors.purple,
      iconBg: AppColors.purpleLight,
      title: context.l10n.ramp,
      subtitle: context.l10n.retailDealer,
      onTap: () => widget.onTypeTap?.call(type),
    ),
  };
}

/// Single tappable row inside [CollectionTypes].
class CollectionTypeItem extends StatelessWidget {
  const CollectionTypeItem({
    super.key,
    required this.iconAsset,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String iconAsset;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 82),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [HomeStyles.cardShadow],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon bubble
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(iconAsset, width: 24, height: 24),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.semiboldH7_18.copyWith(
                                  color: iconColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.mediumSH8_14.copyWith(
                            color: AppColors.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Green chevron button
                  Container(
                    width: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary500,
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        HomeAssets.chevronRight,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
