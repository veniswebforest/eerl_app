import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/features/driver/view/driver_mixed_waste_form_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_nothing_to_collect_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_sorted_waste_form_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _assets = 'assets/icons/driver/stop_detail_v2';

class DriverStopDetailScreen extends StatelessWidget {
  const DriverStopDetailScreen({
    super.key,
    this.pickupType = DriverPickupType.sorted,
  });

  final DriverPickupType pickupType;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _DriverStopDetailView(pickupType: pickupType),
    );
  }
}

class _DriverStopDetailView extends StatelessWidget {
  const _DriverStopDetailView({required this.pickupType});
  final DriverPickupType pickupType;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final isMixed = pickupType == DriverPickupType.mixed;
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
                  key: const Key('driver-stop-detail'),
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
                            title: l10n.stopDetail,
                            gap: 16,
                            backAsset: '$_assets/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          _SourceCard(isMixed: isMixed),
                          const SizedBox(height: 16),
                          _PickupPersonCard(isMixed: isMixed),
                          const SizedBox(height: 16),
                          _RequestInformationCard(isMixed: isMixed),
                          const SizedBox(height: 16),
                          const _DescriptionCard(),
                          const SizedBox(height: 32),
                          DriverPrimaryButton(
                            key: const Key('driver-start-pickup'),
                            label: l10n.startPickup,
                            radius: 12,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => isMixed
                                    ? const DriverMixedWasteFormScreen()
                                    : const DriverSortedWasteFormScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              key: const Key('driver-nothing-to-collect'),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const DriverNothingToCollectScreen(),
                                ),
                              ),
                              icon: SvgPicture.asset(
                                '$_assets/scale_button.svg',
                                package: _package,
                                width: 20,
                                height: 20,
                              ),
                              label: Text(l10n.nothingToCollectWeight),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: DriverColors.neutral900,
                                side: const BorderSide(
                                  color: Color(0xFF9AA3AD),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: DriverTextStyles.bold16,
                              ),
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

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.isMixed});
  final bool isMixed;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      padding: const EdgeInsets.all(8),
      radius: 12,
      shadowBlurRadius: 4,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DriverColors.primary100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset('$_assets/source.svg', package: _package),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMixed ? l10n.shreeSaiDairy : l10n.abcTextileMills,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.stopTripPosition,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupPersonCard extends StatelessWidget {
  const _PickupPersonCard({required this.isMixed});
  final bool isMixed;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personAtPickupPoint,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6EB),
                  shape: BoxShape.circle,
                ),
                child: SvgPicture.asset('$_assets/user.svg', package: _package),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMixed
                          ? l10n.maheshOwner.split(' · ').first
                          : l10n.rakeshShah,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      isMixed
                          ? l10n.maheshOwner.split(' · ').last
                          : l10n.storeManager,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                    Text(
                      isMixed
                          ? l10n.mixedDriverPhoneNumber
                          : l10n.pickupContactPhone,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 38,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    '$_assets/phone.svg',
                    package: _package,
                    width: 18,
                    height: 18,
                  ),
                  label: Text(l10n.call),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    backgroundColor: DriverColors.primary500,
                    foregroundColor: DriverColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: DriverTextStyles.bold14,
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

class _RequestInformationCard extends StatelessWidget {
  const _RequestInformationCard({required this.isMixed});
  final bool isMixed;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      shadowBlurRadius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.requestInformation,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          _BulletInfo(label: l10n.address, value: l10n.pickupAddress),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          _BulletInfo(label: l10n.schedule, value: l10n.pickupSchedule),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          Text(
            l10n.material,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMixed
                      ? DriverColors.orangeLight
                      : DriverColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMixed ? l10n.mixedMaterial : l10n.sortedMaterial,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: isMixed ? DriverColors.orange : DriverColors.purple,
                  ),
                ),
              ),
              if (!isMixed)
                Text(
                  l10n.materialItems,
                  style: DriverTextStyles.regular14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          _BulletInfo(
            label: l10n.expectedWeight,
            value: isMixed
                ? l10n.mixedExpectedWeightValue
                : l10n.expectedWeightValue,
          ),
          const SizedBox(height: 12),
          const _Divider(),
          const SizedBox(height: 12),
          Text(
            l10n.requestStatus,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 32,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DriverColors.yellow50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  '$_assets/pending.svg',
                  package: _package,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.pendingStatus,
                  style: DriverTextStyles.semibold12.copyWith(
                    color: DriverColors.yellow600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 1,
    child: SvgPicture.asset(
      '$_assets/divider.svg',
      package: _package,
      fit: BoxFit.fill,
    ),
  );
}

class _BulletInfo extends StatelessWidget {
  const _BulletInfo({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: DriverTextStyles.semibold14.copyWith(
          color: DriverColors.neutral950,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '•',
              textAlign: TextAlign.center,
              style: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      shadowBlurRadius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.description,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.pickupDescription,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}
