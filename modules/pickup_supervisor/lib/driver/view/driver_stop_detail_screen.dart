import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/driver/view/driver_mixed_waste_form_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_sorted_waste_form_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetPackage = 'pickup_supervisor';

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
                            backAsset: isMixed
                                ? 'assets/icons/driver/pickup/mixed_detail_back.svg'
                                : '$driverStopsAssetRoot/detail_back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          _ContactCard(
                            icon: isMixed
                                ? 'assets/icons/driver/pickup/mixed_detail_route.svg'
                                : '$driverStopsAssetRoot/route.svg',
                            value: isMixed
                                ? l10n.shreeSaiDairy
                                : l10n.abcTextileMills,
                          ),
                          const SizedBox(height: 16),
                          _ContactCard(
                            icon: isMixed
                                ? 'assets/icons/driver/pickup/mixed_detail_phone.svg'
                                : '$driverStopsAssetRoot/phone.svg',
                            value: isMixed
                                ? l10n.mixedDriverPhoneNumber
                                : l10n.driverPhoneNumber,
                            actionLabel: l10n.call,
                          ),
                          const SizedBox(height: 16),
                          _RequestInformationCard(pickupType: pickupType),
                          const SizedBox(height: 16),
                          const _DescriptionCard(),
                          const SizedBox(height: 32),
                          DriverPrimaryButton(
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.value,
    this.actionLabel,
  });

  final String icon;
  final String value;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
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
            child: SvgPicture.asset(icon, package: _assetPackage),
          ),
          SizedBox(width: actionLabel == null ? 10 : 12),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: DriverTextStyles.semibold16.copyWith(
                color: DriverColors.neutral900,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              height: 38,
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: DriverColors.primary500,
                  foregroundColor: DriverColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: DriverTextStyles.bold14,
                ),
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequestInformationCard extends StatelessWidget {
  const _RequestInformationCard({required this.pickupType});

  final DriverPickupType pickupType;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final isMixed = pickupType == DriverPickupType.mixed;
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
          _RequestDivider(isMixed: isMixed),
          const SizedBox(height: 12),
          _RequestTextField(label: l10n.address, value: l10n.pickupAddress),
          const SizedBox(height: 12),
          _RequestDivider(isMixed: isMixed),
          const SizedBox(height: 12),
          _RequestTextField(label: l10n.schedule, value: l10n.pickupSchedule),
          const SizedBox(height: 12),
          _RequestDivider(isMixed: isMixed),
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
          _RequestDivider(isMixed: isMixed),
          const SizedBox(height: 12),
          _RequestTextField(
            label: l10n.expectedWeight,
            value: isMixed
                ? l10n.mixedExpectedWeightValue
                : l10n.expectedWeightValue,
          ),
          const SizedBox(height: 12),
          _RequestDivider(isMixed: isMixed),
          const SizedBox(height: 12),
          Text(
            l10n.requestStatus,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 6),
          DriverStopStatusChip(
            status: DriverStopStatus.pending,
            label: l10n.pendingStatus,
            pendingAsset: isMixed
                ? 'assets/icons/driver/pickup/mixed_detail_pending.svg'
                : '$driverStopsAssetRoot/detail_pending.svg',
          ),
        ],
      ),
    );
  }
}

class _RequestDivider extends StatelessWidget {
  const _RequestDivider({required this.isMixed});

  final bool isMixed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 1,
      child: SvgPicture.asset(
        isMixed
            ? 'assets/icons/driver/pickup/mixed_detail_divider.svg'
            : '$driverStopsAssetRoot/divider.svg',
        package: _assetPackage,
        fit: BoxFit.fill,
      ),
    );
  }
}

class _RequestTextField extends StatelessWidget {
  const _RequestTextField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
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
