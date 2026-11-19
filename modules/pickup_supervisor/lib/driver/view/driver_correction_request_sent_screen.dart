import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/view/driver_pickup_success_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_stops_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _homeAssets = 'assets/icons/driver/home_v2';

class DriverCorrectionRequestSentScreen extends StatelessWidget {
  const DriverCorrectionRequestSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _CorrectionRequestSentView());
  }
}

class _CorrectionRequestSentView extends StatelessWidget {
  const _CorrectionRequestSentView();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: Stack(
          children: [
            const Positioned.fill(child: DriverSuccessFormBackground()),
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
                key: const Key('driver-correction-sent-modal'),
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
                      l10n.requestSent,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      l10n.toYourSupervisor,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.correctionRequestSummary,
                      textAlign: TextAlign.center,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DriverColors.cool100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.whatHappensNext,
                            style: DriverTextStyles.semibold12.copyWith(
                              color: DriverColors.primary500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.supervisorChecksPhotos,
                            style: DriverTextStyles.semibold16.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _NextStep(
                            asset: '$_homeAssets/pin.svg',
                            text: l10n.correctionRequestedUntil,
                          ),
                          const SizedBox(height: 8),
                          _NextStep(
                            asset: '$_homeAssets/contact.svg',
                            text: l10n.correctionNotification,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        key: const Key('driver-correction-back-stops'),
                        onPressed: () => Navigator.of(context).popUntil(
                          (route) =>
                              route.settings.name ==
                                  DriverStopsScreen.routeName ||
                              route.isFirst,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: DriverColors.primary500,
                          foregroundColor: DriverColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: DriverTextStyles.bold16,
                        ),
                        child: Text(l10n.backToMyStops),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        key: const Key('driver-correction-back-home'),
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        style: FilledButton.styleFrom(
                          backgroundColor: DriverColors.cool200,
                          foregroundColor: DriverColors.neutral950,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: DriverTextStyles.semibold16,
                        ),
                        child: Text(l10n.backToHome),
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

class _NextStep extends StatelessWidget {
  const _NextStep({required this.asset, required this.text});
  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SvgPicture.asset(asset, package: _package, width: 18, height: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral900,
          ),
        ),
      ),
    ],
  );
}
