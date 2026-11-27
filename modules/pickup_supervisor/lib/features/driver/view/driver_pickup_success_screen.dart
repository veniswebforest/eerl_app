import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/view/driver_location_flow_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stops_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_trip_summary_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _successIcons = 'assets/icons/driver/pickup_success_v2';
const _successImages = 'assets/images/driver/pickup_success_v2';

class DriverPickupSuccessScreen extends StatelessWidget {
  const DriverPickupSuccessScreen({
    super.key,
    this.isLastStop = false,
    this.tripId,
  });

  final bool isLastStop;

  /// The live trip; null shows the design preview.
  final String? tripId;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: tripId == null
          ? _PickupSuccessView(isLastStop: isLastStop)
          : OutboundLiveBuilder<_LiveAfterStop>(
              load: (session) => _LiveAfterStop.load(session, tripId!),
              fallback: _PickupSuccessView(isLastStop: isLastStop),
              builder: (context, data, _) =>
                  _PickupSuccessView(isLastStop: data.next == null, live: data),
            ),
    );
  }
}

class _LiveAfterStop {
  const _LiveAfterStop(this.trip, this.next);

  final DriverTripLive? trip;
  final DriverStopLive? next;

  static Future<_LiveAfterStop> load(
    OutboundLiveSession session,
    String tripId,
  ) async {
    final tripRow = await session.queries.driverTrip(tripId);
    final trip = tripRow == null ? null : DriverTripLive.fromRow(tripRow);
    final nextRow = await session.queries.nextStop(tripId);
    return _LiveAfterStop(
      trip,
      nextRow == null
          ? null
          : DriverStopLive.fromRow(nextRow, totalStops: trip?.stops ?? 0),
    );
  }
}

class _PickupSuccessView extends StatelessWidget {
  const _PickupSuccessView({required this.isLastStop, this.live});

  final bool isLastStop;
  final _LiveAfterStop? live;

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
                width: math.min(MediaQuery.sizeOf(context).width - 40, 335),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DriverColors.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _AnimatedSuccessIllustration(),
                    const SizedBox(height: 24),
                    Text(
                      l10n.pickupRecorded,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      l10n.successfully,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.bold24.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isLastStop
                          ? l10n.lastPickupSavedMessage
                          : l10n.nextPickupSavedMessage,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    isLastStop
                        ? _TripDoneCard(trip: live?.trip)
                        : _NextStopCard(stop: live?.next),
                    const SizedBox(height: 16),
                    _SuccessActionButton(
                      key: Key(
                        isLastStop
                            ? 'driver-view-trip-summary'
                            : 'driver-go-next-stop',
                      ),
                      label: isLastStop
                          ? l10n.viewTripSummary
                          : l10n.goToNextStop,
                      icon: '$_successIcons/arrow.svg',
                      primary: true,
                      onPressed: isLastStop
                          ? () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DriverTripSummaryScreen(
                                  tripId: live?.trip?.id,
                                ),
                              ),
                            )
                          : () => _goToNextStop(context),
                    ),
                    const SizedBox(height: 16),
                    _SuccessActionButton(
                      key: const Key('driver-back-to-list'),
                      label: l10n.backToList,
                      onPressed: () => _backToStops(context),
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

  void _goToNextStop(BuildContext context) {
    final next = live?.next;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => next == null
            ? const DriverLocationFlowScreen()
            : DriverStopDetailScreen(
                pickupType: next.pickupType,
                stopId: next.id,
                tripId: next.tripId,
              ),
      ),
      (route) =>
          route.settings.name == DriverStopsScreen.routeName || route.isFirst,
    );
  }

  void _backToStops(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) =>
          route.settings.name == DriverStopsScreen.routeName || route.isFirst,
    );
  }
}

class _NextStopCard extends StatelessWidget {
  const _NextStopCard({this.stop});

  final DriverStopLive? stop;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _SuccessInfoCard(
      background: DriverColors.cool100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stop != null
                ? '${l10n.nextStop} · '
                      '${l10n.stopPosition(stop!.stopOrder, stop!.totalStops)}'
                : l10n.nextStopSevenOfSeven,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.semibold12.copyWith(
              color: DriverColors.primary500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            stop != null
                ? l10n.stopCardTitle(
                    stop!.sourceName,
                    stop!.pickupType == DriverPickupType.sorted
                        ? l10n.sortedMaterial
                        : l10n.mixedMaterial,
                  )
                : l10n.stopCardTitle(l10n.shreeSaiDairy, l10n.mixedMaterial),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          _SuccessInfoRow(
            asset: '$_successIcons/pin.svg',
            text: stop?.address ?? l10n.nextStopDistance,
          ),
          const SizedBox(height: 8),
          _SuccessInfoRow(
            asset: '$_successIcons/user.svg',
            text: stop?.contact ?? l10n.maheshOwner,
          ),
        ],
      ),
    );
  }
}

class _TripDoneCard extends StatelessWidget {
  const _TripDoneCard({this.trip});

  final DriverTripLive? trip;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _SuccessInfoCard(
      background: DriverColors.primary50,
      border: DriverColors.summaryBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.allTripStopsDone,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.semibold12.copyWith(
              color: DriverColors.primary500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.takeLoadToWarehouse,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          _SuccessInfoRow(
            asset: '$_successIcons/package.svg',
            text: trip != null
                ? l10n.liveKg(formatKg(trip!.collectedKg))
                : l10n.vehicleLoadTotal,
          ),
          const SizedBox(height: 8),
          _SuccessInfoRow(
            asset: '$_successIcons/warehouse.svg',
            text: trip != null
                ? l10n.liveDropAt(trip!.warehouseName)
                : l10n.warehouseDistance,
          ),
        ],
      ),
    );
  }
}

class _SuccessInfoCard extends StatelessWidget {
  const _SuccessInfoCard({
    required this.background,
    required this.child,
    this.border,
  });

  final Color background;
  final Color? border;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: border == null ? null : Border.all(color: border!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

class _SuccessInfoRow extends StatelessWidget {
  const _SuccessInfoRow({required this.asset, required this.text});

  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(asset, package: _package),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessActionButton extends StatelessWidget {
  const _SuccessActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final String? icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primary
              ? DriverColors.primary500
              : DriverColors.cool200,
          foregroundColor: primary
              ? DriverColors.surface
              : DriverColors.neutral950,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: primary
              ? DriverTextStyles.bold16
              : DriverTextStyles.semibold16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(icon!, package: _package),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedSuccessIllustration extends StatefulWidget {
  const _AnimatedSuccessIllustration();

  @override
  State<_AnimatedSuccessIllustration> createState() =>
      _AnimatedSuccessIllustrationState();
}

class _AnimatedSuccessIllustrationState
    extends State<_AnimatedSuccessIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  late final Animation<double> _scale = TweenSequence<double>([
    _segment(0, .009, 3.333),
    _segment(.009, .046, 3.334),
    _segment(.046, .135, 3.333),
    _segment(.135, .431, 3.333),
    _segment(.431, 1.511, 3.334),
    _segment(1.511, 1.633, 3.333),
    _segment(1.633, 1.682, 3.333),
    _segment(1.682, 1.699, 3.334),
    _segment(1.699, 1.7, 1.111),
    _segment(1.7, 1.7, 50),
    _segment(1.7, 1.693, 2.222),
    _segment(1.693, 1.643, 3.333),
    _segment(1.643, 1.472, 3.334),
    _segment(1.472, .228, 3.333),
    _segment(.228, .057, 3.333),
    _segment(.057, .007, 3.334),
    _segment(.007, 0, 2.222),
    _segment(0, 0, 1.111),
  ]).animate(_controller);

  static TweenSequenceItem<double> _segment(
    double begin,
    double end,
    double weight,
  ) {
    return TweenSequenceItem<double>(
      tween: Tween<double>(begin: begin, end: end),
      weight: weight,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: 135,
      height: 135,
      child: ClipRect(
        child: Center(
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, child) => Transform.scale(
              scale: reduceMotion ? 1 : _scale.value,
              child: child,
            ),
            child: Image.asset(
              '$_successImages/success.gif',
              package: _package,
              width: 122,
              height: 122,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class DriverSuccessFormBackground extends StatelessWidget {
  const DriverSuccessFormBackground({super.key});

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
