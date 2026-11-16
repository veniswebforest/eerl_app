import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

class DriverPickupSuccessScreen extends StatelessWidget {
  const DriverPickupSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _PickupSuccessView());
  }
}

class _PickupSuccessView extends StatelessWidget {
  const _PickupSuccessView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: _SuccessFormBackground()),
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
                ),
              ),
            ),
            Center(
              child: Container(
                width: math.min(MediaQuery.sizeOf(context).width - 40, 335),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DriverColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      '$driverPickupImageRoot/success_illustration.png',
                      package: driverAssetPackage,
                      width: 135,
                      height: 135,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.pickupRecorded,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      l10n.successfully,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pickupSuccessMessage,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        key: const Key('driver-back-to-list'),
                        onPressed: () => Navigator.of(context).popUntil(
                          (route) =>
                              route.settings.name == 'driver-stops' ||
                              route.isFirst,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: DriverColors.cool200,
                          foregroundColor: DriverColors.neutral950,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: DriverTextStyles.semibold16,
                        ),
                        child: Text(l10n.backToList),
                      ),
                    ),
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

class _SuccessFormBackground extends StatelessWidget {
  const _SuccessFormBackground();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        padding.top + 18,
        20,
        padding.bottom + 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverStopsPageHeader(
            title: l10n.sortedPickupForm,
            gap: 16,
            backAsset: '$driverPickupIconRoot/success_back.svg',
            onBack: () {},
          ),
          const SizedBox(height: 32),
          DriverRequiredLabel(label: l10n.enterWeightKg),
          const SizedBox(height: 8),
          DriverValueField(
            prefix: l10n.kgUnit,
            value: l10n.successWeightValue,
            height: 55,
          ),
          const SizedBox(height: 24),
          DriverRequiredLabel(label: l10n.materialAndWeighbridgePhoto),
          const SizedBox(height: 8),
          DriverCaptureArea(
            label: l10n.capturePhoto,
            icon: '$driverPickupIconRoot/success_camera.svg',
            active: false,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DriverPhotoThumbnail(
                  image: '$driverPickupImageRoot/success_photo_base.png',
                  overlayImage:
                      '$driverPickupImageRoot/success_photo_overlay.png',
                  removeIcon: '$driverPickupIconRoot/success_photo_remove.svg',
                  width: double.infinity,
                  height: 92,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DriverPhotoThumbnail(
                  image: '$driverPickupImageRoot/success_scale_photo.png',
                  removeIcon: '$driverPickupIconRoot/success_photo_remove.svg',
                  width: double.infinity,
                  height: 92,
                ),
              ),
            ],
          ),
          const Spacer(),
          DriverFormButton(
            label: l10n.savePickup,
            enabled: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
