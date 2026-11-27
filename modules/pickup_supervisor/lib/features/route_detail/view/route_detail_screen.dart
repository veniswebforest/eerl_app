import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/route_detail/data/route_detail_live_data.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_confirm_popup.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_segmented_switch.dart';
import 'package:pickup_supervisor/core/widgets/module_toast.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_actions/view/ask_collection_head_screen.dart';
import 'package:pickup_supervisor/features/route_actions/view/change_team_screen.dart';
import 'package:pickup_supervisor/features/route_actions/view/complete_trip_screen.dart';
import 'package:pickup_supervisor/features/route_actions/view/move_stops_screen.dart';
import 'package:pickup_supervisor/features/route_actions/widgets/route_actions_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_assets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_header_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_map_widgets.dart';
import 'package:pickup_supervisor/features/route_detail/widgets/route_detail_stop_widgets.dart';
import 'package:pickup_supervisor/features/stop_detail/view/stop_detail_screen.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M04 Trip details for an on-route, planned or approved trip.
///
/// * On route: This trip | Next 7 Days, List | Map, ⋮ on-route actions.
///   Stops open their detail without Skip (the trip has started).
/// * Planned: ⋮ today actions; a pending stop can be skipped, which removes
///   it from this trip and shows a toast. ⋮ changes the team, moves stops,
///   asks the Collection Head, cancels the trip or switches the route off.
/// * Approved: read only (no ⋮, no Add sources) with the warehouse result.
/// * Switched off ([switchedOff]): no trips, "Switch on this route".
class RouteDetailScreen extends StatelessWidget {
  const RouteDetailScreen({
    super.key,
    this.tripState = TripState.onRoute,
    this.initialPeriod = RouteDetailPeriod.today,
    this.initialView = RouteDetailView.list,
    this.summary,
    this.teamChange,
    this.switchedOff = false,
    this.routeKey = RouteSwitchStore.adajan,
    this.driverNotUsingApp = false,
    this.tripId,
    this.live,
    this.liveRouteId,
  });

  /// A live route opened without a trip (switched off): switching it on
  /// queues the write for this route.
  final String? liveRouteId;

  /// The live trip; null shows the design preview.
  final String? tripId;

  /// The loaded live trip (set by this screen itself).
  final LiveTripDetail? live;

  /// Pal Gam Morning: the shift started 30+ min ago and the driver's app
  /// recorded no stop. Shows the red alert; the stops are all pending.
  final bool driverNotUsingApp;

  final TripState tripState;
  final RouteDetailPeriod initialPeriod;
  final RouteDetailView initialView;

  /// Overrides the trip state's mock summary (another route).
  final RouteSummary? summary;

  /// A driver swap saved before the trip started.
  final TripTeamChange? teamChange;
  final bool switchedOff;

  /// The route on the Routes tab that switching off / on changes.
  final String routeKey;

  @override
  Widget build(BuildContext context) {
    final id = tripId;
    if (id == null || live != null) {
      return DriverLocalizationScope(child: _RouteDetailView(screen: this));
    }
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return OutboundLiveBuilder<LiveTripDetail?>(
            load: (session) => LiveTripDetail.load(session, id, l10n),
            fallback: _RouteDetailView(screen: this),
            builder: (context, data, _) => data == null
                ? _RouteDetailView(screen: this)
                : _RouteDetailView(
                    key: ValueKey(data),
                    screen: RouteDetailScreen(
                      tripState: data.state,
                      summary: data.summary,
                      switchedOff: !data.routeActive,
                      routeKey: data.routeId,
                      driverNotUsingApp: data.driverNotUsingApp,
                      tripId: id,
                      live: data,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

class _RouteDetailView extends StatefulWidget {
  const _RouteDetailView({super.key, required this.screen});

  final RouteDetailScreen screen;

  @override
  State<_RouteDetailView> createState() => _RouteDetailViewState();
}

class _RouteDetailViewState extends State<_RouteDetailView> {
  late RouteDetailPeriod _period = widget.screen.initialPeriod;
  late RouteDetailView _view = widget.screen.initialView;
  StopFilter _filter = StopFilter.all;
  late TripTeamChange? _change = widget.screen.teamChange;

  /// Set once the trip is cancelled (the reason typed in the popup).
  late String? _cancelReason = widget.screen.live?.cancelReason;

  LiveTripDetail? get _live => widget.screen.live;
  OutboundLiveSession? get _session => OutboundLiveSession.of(context);

  /// Runs a queued trip write; false (message shown) when refused.
  Future<bool> _write(
    Future<void> Function(OutboundLiveSession s) write,
  ) async {
    final session = _session;
    if (session == null || _live == null) return true;
    try {
      await session.change(() => write(session));
      return true;
    } on LocalWriteValidationException catch (error) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(
          context,
        )?.showSnackBar(SnackBar(content: Text(error.message)));
      }
      return false;
    }
  }

  /// Planned stops can be skipped, so they live in state.
  late final List<RouteStop> _stops = [
    ...?widget.screen.live?.stops,
    if (widget.screen.live == null)
      ...widget.screen.driverNotUsingApp
          ? RouteDetailMockData.palGamStops
          : switch (widget.screen.tripState) {
              TripState.onRoute => RouteDetailMockData.todayStops,
              TripState.planned => RouteDetailMockData.plannedStops,
              TripState.approved => RouteDetailMockData.approvedStops,
            },
  ];

  TripState get _state => widget.screen.tripState;
  bool get _isThisTrip => _period == RouteDetailPeriod.today;
  bool get _cancelled => _cancelReason != null;
  bool get _switchedOff => widget.screen.switchedOff;
  bool get _notUsingApp => widget.screen.driverNotUsingApp;

  /// A not-started trip lists a few stops, then "and 4 more stops …".
  static const _notStartedShown = 4;
  String get _tripDate =>
      _live?.tripDateLabel ?? RouteDetailMockData.plannedTripDate;

  RouteSummary get _summary =>
      widget.screen.summary ??
      (_notUsingApp ? RouteDetailMockData.palGamSummary : null) ??
      switch (_state) {
        TripState.onRoute => RouteDetailMockData.todaySummary,
        TripState.planned => RouteDetailMockData.plannedSummary,
        TripState.approved => RouteDetailMockData.approvedSummary,
      };

  Future<void> _openStop(RouteStop stop) async {
    final l10n = DriverLocalizations.of(context);
    final summary = _summary;
    final skipped = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => StopDetailScreen(
          stop: stop,
          tripState: _state,
          summary: summary,
          stopNumber: _stops.indexOf(stop) + 1,
          totalStops: _stops.length,
          tripDate: _tripDate,
        ),
      ),
    );
    if (skipped != true || !mounted) return;
    setState(() => _stops.remove(stop));
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.skPickupSkippedTitle,
      message: l10n.skPickupSkippedBody(
        stop.name,
        _tripDate,
        _live != null ? '—' : RouteDetailMockData.nextVisitAfterSkip,
      ),
    );
  }

  Future<void> _changeTeam() async {
    final l10n = DriverLocalizations.of(context);
    final change = await Navigator.of(context).push<TripTeamChange>(
      MaterialPageRoute(
        builder: (_) => ChangeTeamScreen(
          routeName: _summary.name,
          tripDate: _live?.tripDateLabel ?? RouteActionsMockData.tripDate,
          tripId: _live?.tripId,
        ),
      ),
    );
    if (change == null || !mounted) return;
    setState(() => _change = change);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.ctSavedTitle,
      message: l10n.ctSavedBody(change.driver, _tripDate),
    );
  }

  Future<void> _moveStops() async {
    final moved = await Navigator.of(context).push<Set<String>>(
      MaterialPageRoute(
        builder: (_) => MoveStopsScreen(
          routeName: _summary.name,
          tripDate: _live?.tripDateLabel ?? RouteActionsMockData.tripDate,
          tripId: _live?.tripId,
          // Live: only the trip's own open stops can move.
          stops: _live == null
              ? List.of(_stops)
              : [
                  for (final s in _stops)
                    if (s.id != null &&
                        (s.status == StopStatus.pending ||
                            s.status == StopStatus.nextStop))
                      s,
                ],
        ),
      ),
    );
    if (moved == null || moved.isEmpty || !mounted) return;
    setState(() => _stops.removeWhere((s) => moved.contains(s.name)));
  }

  void _completeTrip() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => CompleteTripScreen(
        routeName: _summary.name,
        tripDate: _live?.tripDateLabel ?? RouteActionsMockData.todayDate,
        tripId: _live?.tripId,
        openStops: [
          for (final s in _stops)
            if (s.status == StopStatus.pending ||
                s.status == StopStatus.nextStop ||
                s.status == StopStatus.missed)
              s,
        ],
      ),
    ),
  );

  void _askHead() => Navigator.of(context).push<void>(
    MaterialPageRoute(
      builder: (_) => AskCollectionHeadScreen(routeName: _summary.name),
    ),
  );

  Future<void> _cancelTrip() async {
    final l10n = DriverLocalizations.of(context);
    final reason = await showModulePopup<String>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: CancelTripPopup(
          route: _summary.name,
          date: _tripDate,
          stops: _stops.length,
        ),
      ),
    );
    if (reason == null || !mounted) return;
    final live = _live;
    if (live != null &&
        !await _write(
          (s) => s.writes.cancelTrip(tripId: live.tripId, reason: reason),
        )) {
      return;
    }
    if (!mounted) return;
    setState(() => _cancelReason = reason);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.cxDoneTitle,
      message: l10n.cxDoneBody(
        _summary.name,
        _tripDate,
        _change?.driver ?? _summary.driverName,
      ),
    );
  }

  Future<void> _confirmSwitch({required bool on}) async {
    final l10n = DriverLocalizations.of(context);
    final name = _summary.name;
    final ok = await showModulePopup<bool>(
      context,
      builder: (popupContext) => DriverLocalizationScope(
        child: ModuleConfirmPopup(
          key: Key(on ? 'switch-on-popup' : 'switch-off-popup'),
          title: on ? l10n.onTitle : l10n.soTitle,
          message: on
              ? l10n.onBody(name)
              : l10n.soBody(name, _summary.assignedSources),
          cancelLabel: l10n.apCancel,
          confirmLabel: on ? l10n.onConfirm : l10n.soConfirm,
          danger: !on,
          onConfirm: () => Navigator.of(popupContext).pop(true),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final routeId = _live?.routeId ?? widget.screen.liveRouteId;
    final session = _session;
    if (routeId != null && session != null) {
      try {
        await session.change(
          () => session.writes.setRouteActive(routeId: routeId, active: on),
        );
      } on LocalWriteValidationException catch (error) {
        if (mounted) {
          ScaffoldMessenger.maybeOf(
            context,
          )?.showSnackBar(SnackBar(content: Text(error.message)));
        }
        return;
      }
    }
    if (!mounted) return;
    final key = widget.screen.routeKey;
    on ? RouteSwitchStore.switchOn(key) : RouteSwitchStore.switchOff(key);
    // Lands on Routes, which shows the toast once.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showActions() {
    final l10n = DriverLocalizations.of(context);
    final name = _summary.name;
    final onRoute = _state == TripState.onRoute;
    showModuleSheet<void>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: RouteActionsSheet(
          title: onRoute
              ? l10n.raOnRouteTitle(name)
              : l10n.taSheetTitle(name, _tripDate),
          message: onRoute ? l10n.raOnRouteBody : l10n.taSheetBody,
          cancelLabel: l10n.apCancel,
          actions: onRoute
              ? [
                  RouteAction(
                    keyName: 'complete-trip',
                    icon: RouteDetailAssets.actionTeam,
                    iconBackground: DriverColors.secondary100,
                    title: l10n.raCompleteTrip,
                    subtitle: l10n.raCompleteTripBody,
                    onTap: _completeTrip,
                  ),
                  RouteAction(
                    keyName: 'ask-head',
                    icon: RouteDetailAssets.actionMessage,
                    iconBackground: DriverColors.primary100,
                    title: l10n.supervisorAskCollectionHead,
                    subtitle: l10n.raAskHeadBody,
                    onTap: _askHead,
                  ),
                ]
              : [
                  RouteAction(
                    keyName: 'change-team',
                    icon: RouteDetailAssets.actionTeam,
                    iconBackground: DriverColors.secondary100,
                    title: l10n.raChangeTeam,
                    subtitle: l10n.taChangeTeamBody,
                    onTap: _changeTeam,
                  ),
                  RouteAction(
                    keyName: 'move-stops',
                    icon: RouteActionsAssets.move,
                    iconBackground: DriverColors.escalatedBg,
                    title: l10n.taMoveStops,
                    subtitle: l10n.taMoveStopsBody,
                    onTap: _moveStops,
                  ),
                  RouteAction(
                    keyName: 'ask-head',
                    icon: RouteDetailAssets.actionMessage,
                    iconBackground: DriverColors.primary100,
                    title: l10n.supervisorAskCollectionHead,
                    subtitle: l10n.raAskHeadBody,
                    onTap: _askHead,
                  ),
                  RouteAction(
                    keyName: 'cancel-trip',
                    icon: RouteActionsAssets.cancelTrip,
                    iconBackground: DriverColors.red100,
                    title: l10n.taCancelTrip,
                    subtitle: l10n.taCancelTripBody(_tripDate),
                    danger: true,
                    onTap: _cancelTrip,
                  ),
                  RouteAction(
                    keyName: 'switch-off',
                    icon: RouteActionsAssets.power,
                    iconBackground: DriverColors.red100,
                    title: l10n.taSwitchOffRoute,
                    subtitle: l10n.taSwitchOffRouteBody,
                    danger: true,
                    onTap: () => _confirmSwitch(on: false),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    // Live trips show the list: the design's map has no real pin layout yet.
    final showMap =
        _live == null &&
        _state == TripState.onRoute &&
        _isThisTrip &&
        _view == RouteDetailView.map;
    final showAdd =
        _state != TripState.approved &&
        !showMap &&
        !_cancelled &&
        !_switchedOff &&
        !_notUsingApp;
    return ModulePage(
      bottom: _switchedOff
          ? DriverPrimaryButton(
              key: const Key('route-detail-switch-on'),
              radius: 12,
              label: l10n.soSwitchOn,
              onPressed: () => _confirmSwitch(on: true),
            )
          : showAdd
          ? DriverPrimaryButton(
              key: const Key('route-detail-add-sources'),
              radius: 12,
              label: l10n.rdAddSources,
              onPressed: () {},
            )
          : null,
      child: ListView(
        clipBehavior: Clip.none,
        key: const Key('route-detail-scroll'),
        padding: EdgeInsets.zero,
        children: [
          RouteDetailTopBar(
            title: l10n.rdTripDetails,
            onMore: _switchedOff
                ? () {}
                : _state == TripState.approved || _cancelled
                ? null
                : _showActions,
          ),
          const SizedBox(height: 24),
          RouteDetailHeaderCard(
            summary: _summary,
            state: _state,
            showStarted:
                _state == TripState.onRoute && _isThisTrip && !_notUsingApp,
            change: _change,
            badge: _switchedOff
                ? TripBadge.switchedOff
                : _cancelled
                ? TripBadge.cancelled
                : _notUsingApp
                ? TripBadge.notStarted
                : null,
            alert: _notUsingApp
                ? DriverNotUsingAppAlert(
                    driver: _summary.driverName,
                    shiftStart: _live != null
                        ? _summary.shiftTime.split(' – ').first
                        : RouteDetailMockData.palGamShiftStart,
                    onComplete: _completeTrip,
                  )
                : null,
          ),
          if (_switchedOff)
            ..._switchedOffContent(l10n)
          else ...[
            if (_state == TripState.approved) ...[
              const SizedBox(height: 24),
              RouteDetailWarehouseCard(
                result:
                    _live?.warehouseResult ??
                    RouteDetailMockData.warehouseResult,
              ),
            ],
            const SizedBox(height: 24),
            ModuleSegmentedSwitch(
              keyPrefix: 'route-detail-period',
              labels: [l10n.rdThisTrip, l10n.rdNext7Days],
              selectedIndex: _isThisTrip ? 0 : 1,
              onChanged: (index) => setState(
                () => _period = index == 0
                    ? RouteDetailPeriod.today
                    : RouteDetailPeriod.next7Days,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              !_isThisTrip
                  ? l10n.rdDateRange
                  : _state == TripState.planned
                  ? l10n.rdDateTomorrow
                  : l10n.rdDateToday,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
            const SizedBox(height: 24),
            ..._isThisTrip
                ? _cancelled
                      ? [_cancelledNote(l10n)]
                      : _thisTripContent(l10n)
                : _upcomingContent(l10n),
          ],
        ],
      ),
    );
  }

  List<Widget> _thisTripContent(DriverLocalizations l10n) {
    final counts = {
      for (final filter in StopFilter.values)
        filter: _stops.where((s) => s.matches(filter)).length,
    };
    final matching = _stops.where((s) => s.matches(_filter)).toList();
    final visible = _notUsingApp
        ? matching.take(_notStartedShown).toList()
        : matching;
    final hidden = matching.length - visible.length;
    // Nothing recorded yet, so no live map for a trip that hasn't started.
    final onRoute = _state == TripState.onRoute && !_notUsingApp;
    return [
      if (onRoute) ...[
        ModuleSegmentedSwitch(
          keyPrefix: 'route-detail-view',
          labels: [l10n.rdList, l10n.rdMap],
          selectedIndex: _view == RouteDetailView.list ? 0 : 1,
          onChanged: (index) => setState(
            () =>
                _view = index == 0 ? RouteDetailView.list : RouteDetailView.map,
          ),
        ),
        const SizedBox(height: 16),
      ],
      if (onRoute && _view == RouteDetailView.map)
        const RouteDetailMapCard(
          points: RouteDetailMockData.mapStops,
          warehouseName: 'Adajan Central Warehouse',
          nextNumber: 6,
          nextName: 'Om Sweets',
          nextTime: '10–12 am',
          nextDistance: '1.2 km',
        )
      else ...[
        RouteDetailFilterChips(
          selected: _filter,
          counts: counts,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < visible.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          RouteDetailStopCard(
            key: Key('route-detail-stop-${visible[i].name}-$i'),
            stop: visible[i],
            onTap: () => _openStop(visible[i]),
          ),
        ],
        if (_state == TripState.planned) ...[
          const SizedBox(height: 16),
          _hint(l10n),
        ],
        if (hidden > 0) ...[
          const SizedBox(height: 16),
          Text(
            l10n.rdMoreStopsPending(hidden),
            key: const Key('route-detail-more-stops'),
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium12.copyWith(
              color: DriverColors.cool600,
            ),
          ),
        ],
      ],
    ];
  }

  List<Widget> _upcomingContent(DriverLocalizations l10n) {
    // Live: later days are the online trips plan; nothing is made up here.
    final stops = _live != null
        ? const <RouteStop>[]
        : RouteDetailMockData.nextSevenDaysStops;
    return [
      for (var i = 0; i < stops.length; i++) ...[
        if (i > 0) const SizedBox(height: 16),
        RouteDetailStopCard(
          key: Key('route-detail-upcoming-$i'),
          stop: stops[i],
          upcoming: true,
          onTap: () {},
        ),
      ],
      if (_state != TripState.approved) ...[
        const SizedBox(height: 16),
        _hint(l10n),
      ],
    ];
  }

  List<Widget> _switchedOffContent(DriverLocalizations l10n) => [
    const SizedBox(height: 34),
    Center(child: NoTripsIllustration(label: l10n.soNoTrips)),
    const SizedBox(height: 24),
    Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 285),
        child: Text(
          l10n.soEmpty(_summary.assignedSources),
          key: const Key('route-detail-switched-off'),
          textAlign: TextAlign.center,
          style: DriverTextStyles.semibold16.copyWith(
            color: DriverColors.neutral400,
          ),
        ),
      ),
    ),
  ];

  Widget _cancelledNote(DriverLocalizations l10n) {
    var reason = _cancelReason!.trim();
    if (reason.endsWith('.')) reason = reason.substring(0, reason.length - 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        l10n.cxNote(reason, _stops.length, _tripDate),
        key: const Key('route-detail-cancelled'),
        textAlign: TextAlign.center,
        style: DriverTextStyles.medium12.copyWith(color: DriverColors.cool600),
      ),
    );
  }

  Widget _hint(DriverLocalizations l10n) => Center(
    child: SizedBox(
      width: 296,
      child: Text(
        l10n.rdAddedLastHint,
        textAlign: TextAlign.center,
        style: DriverTextStyles.medium12.copyWith(color: DriverColors.cool600),
      ),
    ),
  );
}

/// "Cancel this trip?" with a required reason. Pops with the reason.
class CancelTripPopup extends StatefulWidget {
  const CancelTripPopup({
    super.key,
    required this.route,
    required this.date,
    required this.stops,
  });

  final String route;
  final String date;
  final int stops;

  @override
  State<CancelTripPopup> createState() => _CancelTripPopupState();
}

class _CancelTripPopupState extends State<CancelTripPopup> {
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final text = _reason.text.trim();
    return ModuleConfirmPopup(
      key: const Key('cancel-trip-popup'),
      title: l10n.cxTitle,
      message: l10n.cxBody(widget.route, widget.date, widget.stops),
      cancelLabel: l10n.cxKeep,
      confirmLabel: l10n.cxConfirm,
      danger: true,
      onConfirm: text.isEmpty ? null : () => Navigator.of(context).pop(text),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModuleFieldLabel(l10n.ctReason, required: true),
          const SizedBox(height: 8),
          ModuleTextArea(
            controller: _reason,
            fieldKey: const Key('cancel-trip-reason'),
            minHeight: 88,
          ),
        ],
      ),
    );
  }
}
