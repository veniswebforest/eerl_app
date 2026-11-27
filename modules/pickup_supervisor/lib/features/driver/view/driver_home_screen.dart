import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/driver/model/driver_bottom_nav_item.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:pickup_supervisor/features/driver/view/driver_dashboard_shell.dart';
import 'package:pickup_supervisor/features/profile/view/driver_profile_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_raise_issue_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stop_detail_screen.dart';
import 'package:pickup_supervisor/features/driver/view/driver_stops_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetRoot = 'assets/icons/driver/home_v2';
const _assetPackage = 'pickup_supervisor';

/// Home states. [notStarted] is the app start, before Start trip; Start
/// trip moves it to [morning] (the trip shows On the way).
enum DriverHomeViewMode { notStarted, morning, laterInDay, noTrip }

/// First screen for users whose authenticated role is `DRIVER`.
class DriverHomeScreen extends StatelessWidget {
  const DriverHomeScreen({
    super.key,
    this.viewMode = DriverHomeViewMode.notStarted,
    this.onLogout,
  });

  final DriverHomeViewMode viewMode;

  /// Signs the user out and leaves the driver module (host-provided).
  final Future<void> Function(BuildContext context)? onLogout;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _LocalizedDriverHome(viewMode: viewMode, onLogout: onLogout),
    );
  }
}

class _LocalizedDriverHome extends StatelessWidget {
  const _LocalizedDriverHome({required this.viewMode, this.onLogout});

  final DriverHomeViewMode viewMode;
  final Future<void> Function(BuildContext context)? onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverDashboardShell(
      items: [
        DriverBottomNavItem(
          title: l10n.homeTab,
          selectedIcon: Icons.home_rounded,
          unselectedIcon: Icons.home_outlined,
          page: _DriverHomePage(viewMode: viewMode, onLogout: onLogout),
          pageKey: 'driver-home',
          roles: const {DriverRole.driver},
          permission: 'driver.home.view',
        ),
      ],
    );
  }
}

class _DriverHomePage extends StatefulWidget {
  const _DriverHomePage({required this.viewMode, this.onLogout});

  final DriverHomeViewMode viewMode;
  final Future<void> Function(BuildContext context)? onLogout;

  @override
  State<_DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<_DriverHomePage> {
  late bool _showSummary;
  late DriverHomeViewMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.viewMode;
    _showSummary = _mode != DriverHomeViewMode.laterInDay;
  }

  @override
  void didUpdateWidget(covariant _DriverHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewMode != widget.viewMode) {
      _mode = widget.viewMode;
      _showSummary = _mode != DriverHomeViewMode.laterInDay;
    }
  }

  /// Static: the real app sends the time and GPS (queued offline); here the
  /// trip just switches to On the way.
  void _startTrip() => setState(() => _mode = DriverHomeViewMode.morning);

  /// Start trip: today's Planned trip, queued (outbound doc, Driver writes).
  Future<void> _startLiveTrip(OutboundLiveSession session, String tripId) =>
      session.change(() => session.writes.startTrip(tripId: tripId));

  @override
  Widget build(BuildContext context) {
    return OutboundLiveBuilder<DriverHomeLive>(
      load: DriverHomeLive.load,
      fallback: _page(context, null, null),
      builder: (context, live, session) => _page(context, live, session),
    );
  }

  Widget _page(
    BuildContext context,
    DriverHomeLive? live,
    OutboundLiveSession? session,
  ) {
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: DriverColors.background,
        child: Stack(
          children: [
            const Positioned.fill(child: _PageBackground()),
            LayoutBuilder(
              builder: (context, constraints) {
                final pageWidth = math.min(constraints.maxWidth, 480.0);
                return Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: pageWidth,
                    height: constraints.maxHeight,
                    child: CustomScrollView(
                      key: const Key('driver-home-scroll'),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _DashboardHeader(
                            topInset: topInset,
                            viewMode: _mode,
                            live: live,
                            session: session,
                            onLogout: widget.onLogout,
                            showSummary: _showSummary,
                            onToggleSummary: () =>
                                setState(() => _showSummary = !_showSummary),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            math.max(MediaQuery.paddingOf(context).bottom, 20),
                          ),
                          sliver: SliverList.list(
                            children: [
                              _TripsSection(
                                viewMode: _mode,
                                onStartTrip: _startTrip,
                                live: live,
                                onStartLiveTrip: session == null
                                    ? null
                                    : (id) => _startLiveTrip(session, id),
                              ),
                              const SizedBox(height: 24),
                              DriverSectionTitle(
                                title: DriverLocalizations.of(
                                  context,
                                ).quickAction,
                              ),
                              const SizedBox(height: 16),
                              _IssueCard(tripId: live?.current?.id),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBackground extends StatelessWidget {
  const _PageBackground();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          height: 140,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00FAFAF8), Color(0xFFD2F1D8)],
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.topInset,
    required this.viewMode,
    required this.showSummary,
    required this.onToggleSummary,
    this.onLogout,
    this.live,
    this.session,
  });

  final double topInset;
  final DriverHomeViewMode viewMode;
  final DriverHomeLive? live;
  final OutboundLiveSession? session;
  final Future<void> Function(BuildContext context)? onLogout;
  final bool showSummary;
  final VoidCallback onToggleSummary;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, topInset + 18, 20, 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFC8F2D0), Color(0xFFE3F7E7), Color(0xFFFAFAF8)],
          stops: [0, 0.48, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.welcomeBack,
                      key: const Key('driver-home-title'),
                      style: DriverTextStyles.semibold20.copyWith(
                        color: DriverColors.primary950,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      live != null
                          ? _liveDateLine(context, live!)
                          : viewMode == DriverHomeViewMode.notStarted
                          ? l10n.dhDateAdajan
                          : l10n.homeDateAndZone,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _ProfileButton(
                onLogout: onLogout,
                outline: viewMode == DriverHomeViewMode.notStarted,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _PickupSupervisorCard(
            name: live == null
                ? null
                : (live!.supervisorName ?? l10n.liveNoSupervisor),
          ),
          const SizedBox(height: 12),
          _OnlineCard(
            synced: live != null
                ? live!.unsent == 0
                : viewMode == DriverHomeViewMode.notStarted,
            pending: live?.unsent ?? 3,
            onSync: session?.syncNow,
          ),
          const SizedBox(height: 24),
          _SummarySection(
            live: live,
            viewMode: viewMode,
            expanded: showSummary,
            onToggle: onToggleSummary,
          ),
        ],
      ),
    );
  }
}

/// Top-right profile avatar; opens the driver profile screen.
class _ProfileButton extends StatelessWidget {
  const _ProfileButton({this.onLogout, this.outline = false});

  final Future<void> Function(BuildContext context)? onLogout;

  /// Person icon on a light green circle instead of the photo.
  final bool outline;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('driver-home-profile-button'),
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DriverProfileScreen(onLogout: onLogout),
      ),
    ),
    customBorder: const CircleBorder(),
    child: outline
        ? Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: DriverColors.primary50,
              shape: BoxShape.circle,
            ),
            child: const _ExactSvg(
              asset: '$_assetRoot/profile_outline.svg',
              size: 24,
            ),
          )
        : Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DriverColors.neutral50, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/driver/profile/ramesh_kumar.png',
                package: _assetPackage,
                fit: BoxFit.cover,
              ),
            ),
          ),
  );
}

class _PickupSupervisorCard extends StatelessWidget {
  const _PickupSupervisorCard({this.name});

  /// `me.supervisor.name`; null shows the design sample.
  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/supervisor_user.svg',
                background: DriverColors.primary50,
                iconSize: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name ?? l10n.supervisorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.yourPickupSupervisor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
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
              Expanded(
                child: _ContactButton(
                  label: l10n.call,
                  icon: '$_assetRoot/phone_white.svg',
                  filled: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ContactButton(
                  label: l10n.message,
                  icon: '$_assetRoot/message_green.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.label,
    required this.icon,
    this.filled = false,
  });

  final String label;
  final String icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: _ExactSvg(asset: icon, size: 20),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: filled
              ? DriverColors.primary500
              : DriverColors.surface,
          foregroundColor: filled
              ? DriverColors.surface
              : DriverColors.primary500,
          side: const BorderSide(color: DriverColors.primary500),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: DriverTextStyles.bold16,
        ),
      ),
    );
  }
}

class _OnlineCard extends StatelessWidget {
  const _OnlineCard({this.synced = false, this.pending = 3, this.onSync});

  /// "Everything is synced" instead of the pending count.
  final bool synced;

  /// Changes not sent yet (the outbox).
  final int pending;
  final Future<void> Function()? onSync;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const _IconTile(
            asset: '$_assetRoot/online.svg',
            background: DriverColors.primary50,
            radius: 20,
            iconSize: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.onlineStatus,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.primary500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  synced
                      ? l10n.dhEverythingSynced
                      : l10n.pendingCollections(pending),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: onSync ?? () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                backgroundColor: DriverColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: DriverTextStyles.bold12,
              ),
              child: Text(l10n.syncNow),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    this.live,
    required this.viewMode,
    required this.expanded,
    required this.onToggle,
  });

  final DriverHomeLive? live;
  final DriverHomeViewMode viewMode;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final noTrip = viewMode == DriverHomeViewMode.noTrip;
    final notStarted = viewMode == DriverHomeViewMode.notStarted;
    final day = live;
    String two(int n) => n.toString().padLeft(2, '0');
    final metrics = day != null
        ? [
            _SummaryMetricData(
              '$_assetRoot/scale.svg',
              l10n.zeroKg,
              two(day.zeroKg),
              DriverColors.cool300,
              DriverColors.neutral800,
            ),
            _SummaryMetricData(
              '$_assetRoot/cancelled.svg',
              l10n.cancelled,
              two(day.cancelled),
              DriverColors.purple50,
              DriverColors.purple600,
            ),
            _SummaryMetricData(
              '$_assetRoot/check.svg',
              l10n.collected,
              two(day.collected),
              DriverColors.primary50,
              DriverColors.primary500,
            ),
            _SummaryMetricData(
              '$_assetRoot/pending_clock.svg',
              l10n.pendingStatus,
              two(day.pending),
              DriverColors.yellow50,
              DriverColors.yellow700,
            ),
          ]
        : noTrip
        ? [
            _SummaryMetricData(
              '$_assetRoot/check.svg',
              l10n.collected,
              '00',
              DriverColors.primary50,
              DriverColors.primary500,
            ),
            _SummaryMetricData(
              '$_assetRoot/pending_clock.svg',
              l10n.pendingStatus,
              '00',
              DriverColors.yellow50,
              DriverColors.yellow700,
            ),
            _SummaryMetricData(
              '$_assetRoot/scale.svg',
              l10n.zeroKg,
              '00',
              DriverColors.cool300,
              DriverColors.neutral800,
            ),
            _SummaryMetricData(
              '$_assetRoot/cancelled.svg',
              l10n.cancelled,
              '00',
              DriverColors.purple50,
              DriverColors.purple600,
            ),
          ]
        : [
            _SummaryMetricData(
              '$_assetRoot/scale.svg',
              l10n.zeroKg,
              notStarted ? '00' : '01',
              DriverColors.cool300,
              DriverColors.neutral800,
            ),
            _SummaryMetricData(
              '$_assetRoot/cancelled.svg',
              l10n.cancelled,
              notStarted ? '00' : '01',
              DriverColors.purple50,
              DriverColors.purple600,
            ),
            _SummaryMetricData(
              '$_assetRoot/check.svg',
              l10n.collected,
              notStarted ? '00' : '03',
              DriverColors.primary50,
              DriverColors.primary500,
            ),
            _SummaryMetricData(
              '$_assetRoot/pending_clock.svg',
              l10n.pendingStatus,
              notStarted ? '13' : '08',
              DriverColors.yellow50,
              DriverColors.yellow700,
            ),
          ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverSectionTitle(
          title: l10n.todaysSummary,
          trailing: IconButton(
            key: const Key('driver-summary-toggle'),
            onPressed: onToggle,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            icon: const _ExactSvg(
              asset: '$_assetRoot/summary_eye.svg',
              size: 28,
            ),
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: DriverColors.primary50,
              border: Border.all(color: DriverColors.summaryBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const _IconTile(
                  asset: '$_assetRoot/package.svg',
                  background: DriverColors.surface,
                  iconSize: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.collectedToday,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: DriverTextStyles.medium14.copyWith(
                          color: DriverColors.neutral900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        day != null
                            ? l10n.liveKgSoFar(formatKg(day.collectedKg))
                            : noTrip
                            ? l10n.collectedWeightZero
                            : notStarted
                            ? l10n.dhZeroSoFar
                            : l10n.collectedWeight420,
                        style: DriverTextStyles.bold20.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _SummaryMetric(data: metrics[0])),
              const SizedBox(width: 8),
              Expanded(child: _SummaryMetric(data: metrics[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _SummaryMetric(data: metrics[2])),
              const SizedBox(width: 8),
              Expanded(child: _SummaryMetric(data: metrics[3])),
            ],
          ),
        ],
      ],
    );
  }
}

class _SummaryMetricData {
  const _SummaryMetricData(
    this.asset,
    this.label,
    this.value,
    this.iconBackground,
    this.valueColor,
  );
  final String asset;
  final String label;
  final String value;
  final Color iconBackground;
  final Color valueColor;
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.data});
  final _SummaryMetricData data;

  @override
  Widget build(BuildContext context) {
    return DriverSurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _IconTile(
            asset: data.asset,
            background: data.iconBackground,
            size: 36,
            iconSize: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: DriverTextStyles.semibold18.copyWith(
                    color: data.valueColor,
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

class _TripsSection extends StatelessWidget {
  const _TripsSection({
    required this.viewMode,
    this.onStartTrip,
    this.live,
    this.onStartLiveTrip,
  });
  final DriverHomeViewMode viewMode;
  final VoidCallback? onStartTrip;
  final DriverHomeLive? live;
  final Future<void> Function(String tripId)? onStartLiveTrip;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final day = live;
    if (day != null) return _buildLive(context, day);
    if (viewMode == DriverHomeViewMode.noTrip) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverSectionTitle(title: l10n.todaysTrips),
          const SizedBox(height: 16),
          const _NoTripCard(),
        ],
      );
    }
    if (viewMode == DriverHomeViewMode.notStarted) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverSectionTitle(title: l10n.todaysTripsCount(2)),
          const SizedBox(height: 16),
          _ExpandedTripCard(
            data: _TripData(
              title: l10n.tripMorning,
              time: l10n.dhMorningTripTime(7),
              crew: l10n.dhVehicleCrew,
              drop: l10n.dhDropAdajan,
              collected: 0,
              pending: 7,
              zeroKg: 0,
              cancelled: 0,
              collectedWeight: l10n.collectedWeightZero,
              completedStops: 0,
              totalStops: 7,
              progress: 0,
              started: false,
            ),
            onStartTrip: onStartTrip,
          ),
          const SizedBox(height: 16),
          _SubsectionTitle(l10n.laterToday),
          const SizedBox(height: 12),
          const _CollapsedTripCard(later: false),
        ],
      );
    }
    final later = viewMode == DriverHomeViewMode.laterInDay;
    final trip = _TripData(
      title: later ? l10n.tripAfternoon : l10n.tripMorning,
      time: later ? l10n.afternoonTripTime : l10n.morningTripTime,
      crew: l10n.vehicleCrew,
      drop: later ? l10n.dropSachin : l10n.dropMagdalla,
      collected: later ? 2 : 3,
      pending: later ? 4 : 2,
      zeroKg: later ? 0 : 1,
      cancelled: later ? 0 : 1,
      collectedWeight: later ? l10n.weight180Kg : l10n.weight420Kg,
      completedStops: later ? 2 : 5,
      totalStops: later ? 6 : 7,
      progress: later ? .33 : .71,
    );
    final nextStop = later
        ? _StopData(
            l10n.royalResidency,
            l10n.mixedMaterial,
            3,
            6,
            l10n.ghodDodRoadSurat,
            l10n.pickupSchedule3to330,
            l10n.priyaSecretary,
            DriverPickupType.mixed,
          )
        : _StopData(
            l10n.abcTextileMills,
            l10n.sortedMaterial,
            6,
            7,
            l10n.industrialAreaSurat,
            l10n.pickupSchedule,
            l10n.rakeshStoreManager,
            DriverPickupType.sorted,
          );
    final afterStop = later
        ? _StopData(
            l10n.shantiNagar,
            l10n.mixedMaterial,
            4,
            6,
            l10n.citylightRoadSurat,
            l10n.pickupSchedule330to4,
            l10n.meenaSecretary,
            DriverPickupType.mixed,
            lockedAfterStop: 3,
          )
        : _StopData(
            l10n.shreeSaiDairy,
            l10n.mixedMaterial,
            7,
            7,
            l10n.lpSavaniRoadSurat,
            l10n.pickupSchedule9to11,
            l10n.maheshOwner,
            DriverPickupType.mixed,
            lockedAfterStop: 6,
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverSectionTitle(title: l10n.todaysTripsCount(2)),
        const SizedBox(height: 16),
        _ExpandedTripCard(data: trip),
        const SizedBox(height: 16),
        _SubsectionTitle(l10n.nextStopOnTrip(later ? 2 : 1)),
        const SizedBox(height: 12),
        _StopCard(data: nextStop, isNext: true),
        const SizedBox(height: 16),
        _SubsectionTitle(l10n.afterThat(later ? 3 : 1)),
        const SizedBox(height: 12),
        _StopCard(data: afterStop),
        const SizedBox(height: 16),
        _SubsectionTitle(later ? l10n.earlierToday : l10n.laterToday),
        const SizedBox(height: 12),
        _CollapsedTripCard(later: later),
      ],
    );
  }
}

extension on _TripsSection {
  /// Home from SQLite: today's trips, the current one in full with its next
  /// stop and the one after; the others as one line (outbound doc, Driver
  /// screens · Home).
  Widget _buildLive(BuildContext context, DriverHomeLive day) {
    final l10n = DriverLocalizations.of(context);
    if (day.trips.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DriverSectionTitle(title: l10n.todaysTrips),
          const SizedBox(height: 16),
          const _NoTripCard(),
        ],
      );
    }
    final current = day.current;
    final index = current == null ? -1 : day.trips.indexOf(current);
    final earlier = index < 0 ? day.trips : day.trips.sublist(0, index);
    final later = index < 0
        ? const <DriverTripLive>[]
        : day.trips.sublist(index + 1);
    final next = day.nextStop;
    final after = day.afterStop;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DriverSectionTitle(title: l10n.todaysTripsCount(day.trips.length)),
        const SizedBox(height: 16),
        if (current != null) ...[
          _ExpandedTripCard(
            data: _liveTripData(l10n, current, index + 1),
            tripId: current.id,
            onStartTrip: current.started || onStartLiveTrip == null
                ? null
                : () => onStartLiveTrip!(current.id),
          ),
          if (next != null) ...[
            const SizedBox(height: 16),
            _SubsectionTitle(l10n.nextStopOnTrip(index + 1)),
            const SizedBox(height: 12),
            _StopCard(data: _liveStopData(l10n, next), isNext: true),
          ],
          if (after != null) ...[
            const SizedBox(height: 16),
            _SubsectionTitle(l10n.afterThat(1)),
            const SizedBox(height: 12),
            _StopCard(
              data: _liveStopData(l10n, after, lockedAfter: next?.stopOrder),
            ),
          ],
        ],
        if (later.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SubsectionTitle(l10n.laterToday),
          for (final trip in later) ...[
            const SizedBox(height: 12),
            _CollapsedTripCard(
              later: false,
              live: trip,
              index: day.trips.indexOf(trip) + 1,
            ),
          ],
        ],
        if (earlier.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SubsectionTitle(l10n.earlierToday),
          for (final trip in earlier) ...[
            const SizedBox(height: 12),
            _CollapsedTripCard(
              later: true,
              live: trip,
              index: day.trips.indexOf(trip) + 1,
            ),
          ],
        ],
      ],
    );
  }
}

_TripData _liveTripData(
  DriverLocalizations l10n,
  DriverTripLive trip,
  int index,
) => _TripData(
  title: l10n.liveTripTitle(index, trip.shiftName),
  time: l10n.liveTripTime(
    formatClock(trip.shiftStart),
    formatClock(trip.shiftEnd),
    trip.stops,
  ),
  crew: trip.crew,
  drop: l10n.liveDropAt(trip.warehouseName),
  collected: trip.collected,
  pending: trip.pending,
  zeroKg: trip.zeroKg,
  cancelled: trip.cancelled,
  collectedWeight: l10n.liveKg(formatKg(trip.collectedKg)),
  completedStops: trip.done,
  totalStops: trip.stops,
  progress: trip.progress,
  started: trip.started,
);

_StopData _liveStopData(
  DriverLocalizations l10n,
  DriverStopLive stop, {
  int? lockedAfter,
}) => _StopData(
  stop.sourceName,
  stop.pickupType == DriverPickupType.sorted
      ? l10n.sortedMaterial
      : l10n.mixedMaterial,
  stop.stopOrder,
  stop.totalStops,
  stop.address,
  stop.window ?? l10n.liveAnyTime,
  stop.contact,
  stop.pickupType,
  lockedAfterStop: lockedAfter,
  stopId: stop.id,
  tripId: stop.tripId,
);

String _liveDateLine(BuildContext context, DriverHomeLive live) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  final day = DateTime.tryParse(live.today) ?? DateTime.now();
  String date;
  try {
    date = DateFormat('EEE, d MMM', locale).format(day);
  } on Object {
    date = DateFormat('EEE, d MMM').format(day);
  }
  final place = live.warehouseName;
  return place == null || place.isEmpty
      ? date
      : DriverLocalizations.of(context).liveDateAndPlace(date, place);
}

class _SubsectionTitle extends StatelessWidget {
  const _SubsectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: DriverTextStyles.semibold16.copyWith(color: DriverColors.neutral950),
  );
}

class _TripData {
  const _TripData({
    required this.title,
    required this.time,
    required this.drop,
    required this.collected,
    required this.pending,
    required this.zeroKg,
    required this.cancelled,
    required this.collectedWeight,
    required this.completedStops,
    required this.totalStops,
    required this.progress,
    required this.crew,
    this.started = true,
  });
  final String title;
  final String time;
  final String crew;

  /// False before Start trip: "Not started" and the Start trip button.
  final bool started;
  final String drop;
  final int collected;
  final int pending;
  final int zeroKg;
  final int cancelled;
  final String collectedWeight;
  final int completedStops;
  final int totalStops;
  final double progress;
}

class _ExpandedTripCard extends StatelessWidget {
  const _ExpandedTripCard({required this.data, this.onStartTrip, this.tripId});
  final _TripData data;
  final VoidCallback? onStartTrip;

  /// The live trip; null in the design preview.
  final String? tripId;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/trip.svg',
                background: DriverColors.secondary100,
                iconSize: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.time,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              data.started
                  ? _TripBadge(label: l10n.onTheWay, active: true)
                  : _TripBadge(label: l10n.dhNotStarted, idle: true),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: DriverColors.tripDetails,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _TripInfoRow(
                  asset: '$_assetRoot/vehicle.svg',
                  value: data.crew,
                ),
                const SizedBox(height: 8),
                _TripInfoRow(
                  asset: '$_assetRoot/warehouse.svg',
                  value: data.drop,
                  semibold: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TripCount(
                  data.collected,
                  l10n.collected,
                  DriverColors.primary50,
                  DriverColors.primary500,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _TripCount(
                  data.pending,
                  l10n.pendingStatus,
                  DriverColors.yellow50,
                  DriverColors.yellow700,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _TripCount(
                  data.zeroKg,
                  l10n.zeroKg,
                  DriverColors.cool300,
                  DriverColors.neutral800,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _TripCount(
                  data.cancelled,
                  l10n.cancelled,
                  DriverColors.purple50,
                  DriverColors.purple600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ValueRow(
            l10n.collectedOnTrip,
            data.collectedWeight,
            boldValue: true,
          ),
          const SizedBox(height: 12),
          _ValueRow(
            l10n.stopsDone(data.completedStops, data.totalStops),
            '${(data.progress * 100).round()}%',
            greenValue: true,
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(48),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: data.progress,
              backgroundColor: DriverColors.cool200,
              color: DriverColors.primary500,
            ),
          ),
          const SizedBox(height: 12),
          if (!data.started) ...[
            SizedBox(
              width: double.infinity,
              height: 44,
              child: FilledButton.icon(
                key: const Key('driver-start-trip'),
                onPressed: onStartTrip ?? () {},
                icon: const _ExactSvg(
                  asset: '$_assetRoot/play_white.svg',
                  size: 20,
                ),
                label: Text(l10n.dhStartTrip),
                style: FilledButton.styleFrom(
                  backgroundColor: DriverColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: DriverTextStyles.bold16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.dhStartTripHint,
              style: DriverTextStyles.medium12.copyWith(
                color: DriverColors.slate600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () => _openStops(context, tripId: tripId),
              style: OutlinedButton.styleFrom(
                foregroundColor: DriverColors.primary500,
                side: const BorderSide(color: DriverColors.primary500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: DriverTextStyles.bold16,
              ),
              child: Text(l10n.seeAllStops(data.totalStops)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(
    this.label,
    this.value, {
    this.boldValue = false,
    this.greenValue = false,
  });
  final String label;
  final String value;
  final bool boldValue;
  final bool greenValue;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral700,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        value,
        style:
            (boldValue ? DriverTextStyles.bold16 : DriverTextStyles.semibold14)
                .copyWith(
                  color: greenValue
                      ? DriverColors.primary500
                      : DriverColors.neutral950,
                ),
      ),
    ],
  );
}

class _TripCount extends StatelessWidget {
  const _TripCount(this.value, this.label, this.background, this.color);
  final int value;
  final String label;
  final Color background;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text('$value', style: DriverTextStyles.bold16.copyWith(color: color)),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral700,
          ),
        ),
      ],
    ),
  );
}

class _TripInfoRow extends StatelessWidget {
  const _TripInfoRow({
    required this.asset,
    required this.value,
    this.semibold = false,
  });
  final String asset;
  final String value;
  final bool semibold;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _ExactSvg(asset: asset, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style:
              (semibold
                      ? DriverTextStyles.semibold14
                      : DriverTextStyles.medium14)
                  .copyWith(color: DriverColors.neutral900),
        ),
      ),
    ],
  );
}

class _StopData {
  const _StopData(
    this.name,
    this.material,
    this.current,
    this.total,
    this.location,
    this.schedule,
    this.contact,
    this.pickupType, {
    this.lockedAfterStop,
    this.stopId,
    this.tripId,
  });
  final String? stopId;
  final String? tripId;
  final String name;
  final String material;
  final int current;
  final int total;
  final String location;
  final String schedule;
  final String contact;
  final DriverPickupType pickupType;
  final int? lockedAfterStop;
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.data, this.isNext = false});
  final _StopData data;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final locked = data.lockedAfterStop != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: isNext ? Border.all(color: DriverColors.primary500) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            offset: Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.stopCardTitle(data.name, data.material),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.semibold18.copyWith(
                      color: DriverColors.neutral900,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.stopPosition(data.current, data.total),
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DriverColors.cool100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StopInfoLine('$_assetRoot/pin.svg', data.location),
                  const SizedBox(height: 8),
                  _StopInfoLine(
                    '$_assetRoot/schedule.svg',
                    data.schedule,
                    regular: true,
                  ),
                  const SizedBox(height: 8),
                  _StopInfoLine(
                    '$_assetRoot/contact.svg',
                    data.contact,
                    semibold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isNext)
                  _StatusChip(
                    l10n.nextStop,
                    DriverColors.primary500,
                    DriverColors.surface,
                  ),
                _StatusChip(
                  l10n.pendingStatus,
                  DriverColors.yellow50,
                  DriverColors.yellow700,
                  asset: '$_assetRoot/chip_clock.svg',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 100,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const _ExactSvg(
                      asset: '$_assetRoot/phone_green.svg',
                      size: 20,
                    ),
                    label: Text(l10n.call),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: DriverColors.primary500,
                      side: const BorderSide(color: DriverColors.primary500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: DriverTextStyles.bold16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: locked
                        ? FilledButton(
                            onPressed: null,
                            style: FilledButton.styleFrom(
                              disabledBackgroundColor: DriverColors.cool300,
                              disabledForegroundColor: DriverColors.neutral800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: DriverTextStyles.bold16,
                            ),
                            child: Text(
                              l10n.opensAfterStop(data.lockedAfterStop!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : FilledButton.icon(
                            onPressed: () => _openStop(
                              context,
                              data.pickupType,
                              stopId: data.stopId,
                              tripId: data.tripId,
                            ),
                            icon: const _ExactSvg(
                              asset: '$_assetRoot/pencil.svg',
                              size: 20,
                            ),
                            label: Text(l10n.enterCollection),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              backgroundColor: DriverColors.primary500,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: DriverTextStyles.bold16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (locked) ...[
              const SizedBox(height: 8),
              Text(
                l10n.unlockAfterStop(data.lockedAfterStop!),
                style: DriverTextStyles.medium12.copyWith(
                  color: DriverColors.neutral800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StopInfoLine extends StatelessWidget {
  const _StopInfoLine(
    this.asset,
    this.value, {
    this.regular = false,
    this.semibold = false,
  });
  final String asset;
  final String value;
  final bool regular;
  final bool semibold;
  @override
  Widget build(BuildContext context) {
    final style = semibold
        ? DriverTextStyles.semibold14
        : (regular ? DriverTextStyles.regular14 : DriverTextStyles.medium14);
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: DriverColors.surface,
            shape: BoxShape.circle,
          ),
          child: _ExactSvg(asset: asset, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style.copyWith(
              color: regular || semibold
                  ? DriverColors.neutral950
                  : DriverColors.neutral700,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.label, this.background, this.foreground, {this.asset});
  final String label;
  final Color background;
  final Color foreground;
  final String? asset;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (asset != null) ...[
          _ExactSvg(asset: asset!, size: 16),
          const SizedBox(width: 6),
        ],
        Text(
          label,
          style: DriverTextStyles.semibold12.copyWith(color: foreground),
        ),
      ],
    ),
  );
}

class _CollapsedTripCard extends StatelessWidget {
  const _CollapsedTripCard({required this.later, this.live, this.index = 1});
  final bool later;

  /// A live trip; null shows the design sample.
  final DriverTripLive? live;
  final int index;
  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Row(
        children: [
          const _IconTile(
            asset: '$_assetRoot/trip.svg',
            background: DriverColors.secondary100,
            iconSize: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  live != null
                      ? l10n.liveTripTitle(index, live!.shiftName)
                      : later
                      ? l10n.tripMorning
                      : l10n.tripAfternoon,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  live != null
                      ? (later
                            ? (live!.netKg == null
                                  ? l10n.liveHandedOver
                                  : l10n.liveHandedOverNet(
                                      formatKg(live!.netKg!),
                                    ))
                            : l10n.liveTripTime(
                                formatClock(live!.shiftStart),
                                formatClock(live!.shiftEnd),
                                live!.stops,
                              ))
                      : later
                      ? l10n.handedOverWeight
                      : l10n.afternoonTripTime,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Capped so a long translation can't push the title out.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: _TripBadge(
              label: later
                  ? l10n.delivered
                  : l10n.startsAt(
                      live != null
                          ? formatClock(live!.shiftStart)
                          : l10n.afternoonStartTime,
                    ),
              delivered: later,
            ),
          ),
        ],
      ),
    );
  }
}

class _TripBadge extends StatelessWidget {
  const _TripBadge({
    required this.label,
    this.active = false,
    this.delivered = false,
    this.idle = false,
  });
  final String label;
  final bool active;
  final bool delivered;

  /// Grey "Not started".
  final bool idle;
  @override
  Widget build(BuildContext context) {
    final background = idle
        ? DriverColors.tagGrey
        : delivered
        ? DriverColors.primary50
        : (active ? DriverColors.secondary100 : DriverColors.cool300);
    final foreground = idle
        ? DriverColors.slate600
        : delivered
        ? DriverColors.primary500
        : (active ? DriverColors.blue600 : DriverColors.neutral800);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: DriverTextStyles.semibold12.copyWith(color: foreground),
      ),
    );
  }
}

class _NoTripCard extends StatelessWidget {
  const _NoTripCard();
  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          const _ExactSvg(asset: '$_assetRoot/no_trip.svg', size: 72),
          const SizedBox(height: 8),
          Text(
            l10n.noTripToday,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noTripMessage,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({this.tripId});

  /// The trip the issue is about (the current one), if any.
  final String? tripId;
  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconTile(
                asset: '$_assetRoot/issue.svg',
                background: DriverColors.red100,
                iconSize: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.raiseAnIssue,
                  style: DriverTextStyles.semibold18.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.issueDescription,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 16),
          DriverPrimaryButton(
            label: l10n.reportIssue,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => DriverRaiseIssueScreen(tripId: tripId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.asset,
    required this.background,
    required this.iconSize,
    this.size = 40,
    this.radius = 8,
  });
  final String asset;
  final Color background;
  final double iconSize;
  final double size;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: _ExactSvg(asset: asset, size: iconSize),
  );
}

class _ExactSvg extends StatelessWidget {
  const _ExactSvg({required this.asset, required this.size});
  final String asset;
  final double size;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: SvgPicture.asset(asset, package: _assetPackage),
  );
}

void _openStops(BuildContext context, {String? tripId}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: DriverStopsScreen.routeName),
      builder: (_) => DriverStopsScreen(tripId: tripId),
    ),
  );
}

void _openStop(
  BuildContext context,
  DriverPickupType pickupType, {
  String? stopId,
  String? tripId,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DriverStopDetailScreen(
        pickupType: pickupType,
        stopId: stopId,
        tripId: tripId,
      ),
    ),
  );
}
