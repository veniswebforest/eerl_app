import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/driver/view/driver_collected_stop_detail_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_gate_team_entry_screen.dart';
import 'package:pickup_supervisor/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _locationIcons = 'assets/icons/driver/location_flow';
const _locationImages = 'assets/images/driver/location_flow';
const _homeIcons = 'assets/icons/driver/home_v2';

enum DriverLocationFlowState {
  locationOff,
  finding,
  detected,
  nearbyStops,
  notAtStop,
}

class DriverLocationFlowScreen extends StatelessWidget {
  const DriverLocationFlowScreen({
    super.key,
    this.initialState = DriverLocationFlowState.locationOff,
    this.autoDetectDuration = const Duration(seconds: 2),
  });

  final DriverLocationFlowState initialState;
  final Duration autoDetectDuration;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _LocationFlowView(
        initialState: initialState,
        autoDetectDuration: autoDetectDuration,
      ),
    );
  }
}

class _LocationFlowView extends StatefulWidget {
  const _LocationFlowView({
    required this.initialState,
    required this.autoDetectDuration,
  });

  final DriverLocationFlowState initialState;
  final Duration autoDetectDuration;

  @override
  State<_LocationFlowView> createState() => _LocationFlowViewState();
}

class _LocationFlowViewState extends State<_LocationFlowView> {
  late DriverLocationFlowState _state = widget.initialState;
  Timer? _detectionTimer;
  int _selectedStop = 0;

  @override
  void initState() {
    super.initState();
    if (_state == DriverLocationFlowState.finding) {
      _scheduleDetection();
    }
  }

  void _showState(DriverLocationFlowState state) {
    _detectionTimer?.cancel();
    setState(() => _state = state);
    if (state == DriverLocationFlowState.finding) {
      _scheduleDetection();
    }
  }

  void _scheduleDetection() {
    _detectionTimer = Timer(widget.autoDetectDuration, () {
      if (mounted && _state == DriverLocationFlowState.finding) {
        setState(() => _state = DriverLocationFlowState.detected);
      }
    });
  }

  void _openPickup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            const DriverStopDetailScreen(pickupType: DriverPickupType.mixed),
      ),
    );
  }

  void _openSelectedStop() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _selectedStop == 0
            ? const DriverStopDetailScreen(pickupType: DriverPickupType.mixed)
            : const DriverCollectedStopDetailScreen(),
      ),
    );
  }

  void _openGateTeamEntry() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DriverGateTeamEntryScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _OrderedStopsBackdrop(),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: .60),
                      ),
                    ),
                    SafeArea(
                      minimum: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: _buildPopup(context),
                        ),
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

  Widget _buildPopup(BuildContext context) {
    return switch (_state) {
      DriverLocationFlowState.locationOff => _LocationStatusPopup(
        key: const Key('driver-location-off-popup'),
        status: DriverLocalizations.of(context).locationIsOff,
        statusKind: _StatusKind.error,
        title: DriverLocalizations.of(context).turnOnLocation,
        message: DriverLocalizations.of(context).locationOffMessage,
        actions: [
          _PopupAction(
            key: const Key('driver-turn-on-location'),
            label: DriverLocalizations.of(context).turnOnLocation,
            primary: true,
            onTap: () => _showState(DriverLocationFlowState.finding),
          ),
          _PopupAction(
            key: const Key('driver-location-off-gate-team'),
            label: DriverLocalizations.of(context).gateTeamWillEnter,
            onTap: _openGateTeamEntry,
          ),
        ],
      ),
      DriverLocationFlowState.finding => _LocationStatusPopup(
        key: const Key('driver-finding-location-popup'),
        status: DriverLocalizations.of(context).findingYourLocationStatus,
        statusKind: _StatusKind.info,
        title: DriverLocalizations.of(context).findingYourLocation,
        message: DriverLocalizations.of(context).findingLocationMessage,
        actions: [
          _PopupAction(
            key: const Key('driver-cancel-location'),
            label: DriverLocalizations.of(context).cancelAction,
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      DriverLocationFlowState.detected => _LocationStatusPopup(
        key: const Key('driver-location-detected-popup'),
        status: DriverLocalizations.of(context).locationDetected,
        statusKind: _StatusKind.info,
        title: DriverLocalizations.of(context).shreeSaiDairy,
        message: DriverLocalizations.of(context).lpSavaniRoadSurat,
        horizontalActions: true,
        actions: [
          _PopupAction(
            key: const Key('driver-location-not-here'),
            label: DriverLocalizations.of(context).notHere,
            onTap: () => _showState(DriverLocationFlowState.notAtStop),
          ),
          _PopupAction(
            key: const Key('driver-start-collection'),
            label: DriverLocalizations.of(context).startCollection,
            primary: true,
            onTap: _openPickup,
          ),
        ],
      ),
      DriverLocationFlowState.nearbyStops => _NearbyStopsPopup(
        selectedStop: _selectedStop,
        onSelected: (index) => setState(() => _selectedStop = index),
        onNotHere: () => _showState(DriverLocationFlowState.notAtStop),
        onContinue: _openSelectedStop,
      ),
      DriverLocationFlowState.notAtStop => _LocationStatusPopup(
        key: const Key('driver-no-stop-popup'),
        status: DriverLocalizations.of(context).noStopFoundHere,
        statusKind: _StatusKind.warning,
        title: DriverLocalizations.of(context).notAtTripStop,
        message: DriverLocalizations.of(context).notAtStopMessage,
        actions: [
          _PopupAction(
            key: const Key('driver-location-try-again'),
            label: DriverLocalizations.of(context).tryAgain,
            primary: true,
            onTap: () => _showState(DriverLocationFlowState.finding),
          ),
          _PopupAction(
            key: const Key('driver-choose-stop'),
            label: DriverLocalizations.of(context).chooseStopMyself,
            onTap: () => _showState(DriverLocationFlowState.nearbyStops),
          ),
          _PopupAction(
            key: const Key('driver-no-stop-gate-team'),
            label: DriverLocalizations.of(context).gateTeamWillEnter,
            onTap: _openGateTeamEntry,
          ),
        ],
      ),
    };
  }
}

enum _StatusKind { info, warning, error }

class _PopupAction {
  const _PopupAction({
    required this.key,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final Key key;
  final String label;
  final VoidCallback onTap;
  final bool primary;
}

class _LocationStatusPopup extends StatelessWidget {
  const _LocationStatusPopup({
    super.key,
    required this.status,
    required this.statusKind,
    required this.title,
    required this.message,
    required this.actions,
    this.horizontalActions = false,
  });

  final String status;
  final _StatusKind statusKind;
  final String title;
  final String message;
  final List<_PopupAction> actions;
  final bool horizontalActions;

  @override
  Widget build(BuildContext context) {
    final statusColors = switch (statusKind) {
      _StatusKind.info => (DriverColors.secondary100, DriverColors.blue600),
      _StatusKind.warning => (const Color(0xFFFFF4E0), const Color(0xFFB26A00)),
      _StatusKind.error => (DriverColors.red100, DriverColors.red600),
    };
    return _PopupShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRect(
            child: SizedBox(
              width: 212,
              height: 164,
              child: Image.asset(
                '$_locationImages/location_target.gif',
                package: _package,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: statusColors.$1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: DriverTextStyles.semibold12.copyWith(
                color: statusColors.$2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          if (horizontalActions)
            Row(
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(child: _PopupButton(action: actions[index])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var index = 0; index < actions.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _PopupButton(action: actions[index]),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _NearbyStopsPopup extends StatelessWidget {
  const _NearbyStopsPopup({
    required this.selectedStop,
    required this.onSelected,
    required this.onNotHere,
    required this.onContinue,
  });

  final int selectedStop;
  final ValueChanged<int> onSelected;
  final VoidCallback onNotHere;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return _PopupShell(
      key: const Key('driver-nearby-stops-popup'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: DriverColors.secondary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.stopsNearby(2),
              style: DriverTextStyles.semibold12.copyWith(
                color: DriverColors.blue600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.whichStopAreYouAt,
            textAlign: TextAlign.center,
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.twoStopsCloseMessage,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 16),
          _StopOption(
            key: const Key('driver-nearby-stop-0'),
            selected: selectedStop == 0,
            title: l10n.stopCardTitle(l10n.shreeSaiDairy, l10n.mixedMaterial),
            subtitle: l10n.distanceStopSeven,
            onTap: () => onSelected(0),
          ),
          const SizedBox(height: 8),
          _StopOption(
            key: const Key('driver-nearby-stop-1'),
            selected: selectedStop == 1,
            title: l10n.stopCardTitle(
              l10n.greenParkSociety,
              l10n.mixedMaterial,
            ),
            subtitle: l10n.distanceAlreadyCollected,
            onTap: () => onSelected(1),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _PopupButton(
                  action: _PopupAction(
                    key: const Key('driver-nearby-not-here'),
                    label: l10n.notHere,
                    onTap: onNotHere,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PopupButton(
                  action: _PopupAction(
                    key: const Key('driver-nearby-continue'),
                    label: l10n.continueAction,
                    primary: true,
                    onTap: onContinue,
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

class _PopupShell extends StatelessWidget {
  const _PopupShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: math.min(MediaQuery.sizeOf(context).width - 40, 335),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _PopupButton extends StatelessWidget {
  const _PopupButton({required this.action});

  final _PopupAction action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        key: action.key,
        onPressed: action.onTap,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: action.primary
              ? DriverColors.primary500
              : DriverColors.cool200,
          foregroundColor: action.primary
              ? DriverColors.surface
              : DriverColors.cool950,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
        child: Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _StopOption extends StatelessWidget {
  const _StopOption({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DriverColors.primary50 : DriverColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? DriverColors.primary500 : const Color(0xFFDDE2E6),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SvgPicture.asset(
                selected
                    ? '$_locationIcons/radio_selected.svg'
                    : '$_locationIcons/radio.svg',
                package: _package,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderedStopsBackdrop extends StatelessWidget {
  const _OrderedStopsBackdrop();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final top = MediaQuery.paddingOf(context).top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.orderedPickupStops,
                      style: DriverTextStyles.semibold20.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.startYourCollections,
                      style: DriverTextStyles.medium14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: DriverColors.cool100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: DriverColors.neutral700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: DriverColors.surface,
              border: Border.all(color: DriverColors.cool400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: DriverColors.cool500, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.searchHere,
                  style: DriverTextStyles.regular14.copyWith(
                    color: const Color(0xFF6D6D6D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 52,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: DriverColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  offset: Offset(0, 2),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.pendingCount(3),
                      style: DriverTextStyles.medium14.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: DriverColors.primary500,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.collectedCount(1),
                      style: DriverTextStyles.bold14.copyWith(
                        color: DriverColors.surface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _CollectedBackdropCard(l10n: l10n),
          const Spacer(),
          const _BackdropBottomNav(),
        ],
      ),
    );
  }
}

class _CollectedBackdropCard extends StatelessWidget {
  const _CollectedBackdropCard({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.primary500),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. ${l10n.yashTextileHub}',
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DriverColors.cool100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _BackdropInfo(
                  asset: '$_homeIcons/pin.svg',
                  text: l10n.anjanaFarmAreaSurat,
                ),
                const SizedBox(height: 8),
                _BackdropInfo(
                  asset: '$_homeIcons/schedule.svg',
                  text: l10n.collectionWindowNineToTen,
                ),
                const SizedBox(height: 8),
                _BackdropInfo(
                  asset: '$_homeIcons/package.svg',
                  text: l10n.materialSortedLabel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: DriverColors.primary100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: DriverColors.primary500,
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
    );
  }
}

class _BackdropInfo extends StatelessWidget {
  const _BackdropInfo({required this.asset, required this.text});

  final String asset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: DriverColors.surface,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(asset, package: _package),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BackdropBottomNav extends StatelessWidget {
  const _BackdropBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1D4A28),
        borderRadius: BorderRadius.circular(32),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(Icons.home_outlined, color: DriverColors.surface, size: 28),
          Icon(Icons.route_outlined, color: DriverColors.primary400, size: 28),
          Icon(
            Icons.description_outlined,
            color: DriverColors.surface,
            size: 28,
          ),
          Icon(Icons.person_outline, color: DriverColors.surface, size: 28),
        ],
      ),
    );
  }
}
