import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _homeAssets = 'assets/icons/driver/home_v2';
const _stopAssets = 'assets/icons/driver/stops_v2';
const _stopImages = 'assets/images/driver/stops_v2';

class DriverCollectedStopDetailScreen extends StatelessWidget {
  const DriverCollectedStopDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _CollectedStopDetailView());
  }
}

class _CollectedStopDetailView extends StatelessWidget {
  const _CollectedStopDetailView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 480.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: pageWidth,
                height: constraints.maxHeight,
                child: CustomScrollView(
                  key: const Key('driver-collected-stop-detail'),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topInset + 18,
                        20,
                        math.max(MediaQuery.paddingOf(context).bottom, 20),
                      ),
                      sliver: SliverList.list(
                        children: [
                          DriverStopsPageHeader(
                            title: l10n.stopTwoCollection,
                            backAsset: '$_stopAssets/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          const _CollectionStatusCard(),
                          const SizedBox(height: 16),
                          const _SavedWeightCard(),
                          const SizedBox(height: 16),
                          const _PhotosCard(),
                          const SizedBox(height: 16),
                          DriverPrimaryButton(
                            label: l10n.askSupervisorToCorrect,
                            radius: 12,
                            onPressed: () {},
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.savedCollectionReadonlyMessage,
                            style: DriverTextStyles.medium12.copyWith(
                              color: DriverColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.stopCardTitle(l10n.hotelRajdhani, l10n.sortedMaterial),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: DriverColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      '$_homeAssets/check.svg',
                      package: _package,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.collectedLabel,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset(
                '$_stopAssets/saved_truck.svg',
                package: _package,
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.savedAt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SavedWeightCard extends StatelessWidget {
  const _SavedWeightCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatYouSaved,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.hotelRajdhaniWeight,
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          _MaterialRow(l10n.petBottles, l10n.petBottlesWeight),
          _MaterialRow(l10n.cardboard, l10n.cardboardWeight),
        ],
      ),
    );
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: DriverColors.cool300)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: DriverTextStyles.semibold14.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
      ],
    ),
  );
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.photosMaterialScale,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              _Photo('$_stopImages/material.png'),
              SizedBox(width: 12),
              _Photo('$_stopImages/scale.png'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Image.asset(
      asset,
      package: _package,
      width: 109,
      height: 70,
      fit: BoxFit.cover,
    ),
  );
}
