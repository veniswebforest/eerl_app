import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_toast.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_mock_data.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_mock_data.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';
import 'package:pickup_supervisor/features/trips_plan/view/trips_plan_screen.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_bottom_nav_item.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_add_route_flow.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_bottom_navigation.dart';

const _iconRoot = 'assets/icons/supervisor/routes';
const _imageRoot = 'assets/images/supervisor/routes';
const _homeIconRoot = 'assets/icons/supervisor/home';
const _assetPackage = 'pickup_supervisor';

class PickupSupervisorRoutesScreen extends StatefulWidget {
  const PickupSupervisorRoutesScreen({
    super.key,
    this.showEmpty = false,
    this.showBottomNavigation = true,
    this.onNavigationSelected,
  });

  final bool showEmpty;
  final bool showBottomNavigation;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<PickupSupervisorRoutesScreen> createState() =>
      _PickupSupervisorRoutesScreenState();
}

class _PickupSupervisorRoutesScreenState
    extends State<PickupSupervisorRoutesScreen> {
  var _selectedFilter = 0;
  var _query = '';
  var _showSavedBanner = false;

  /// A context inside [DriverLocalizationScope], for the switch toast.
  BuildContext? _scopedContext;
  final _listController = ScrollController();

  @override
  void initState() {
    super.initState();
    RouteSwitchStore.off.addListener(_refresh);
    RouteSwitchStore.event.addListener(_showSwitchToast);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showSwitchToast());
  }

  @override
  void dispose() {
    RouteSwitchStore.off.removeListener(_refresh);
    RouteSwitchStore.event.removeListener(_showSwitchToast);
    _listController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  /// "Route Switched Off / On!" once, after a trip screen changed a route.
  void _showSwitchToast() {
    final event = RouteSwitchStore.event.value;
    if (event == null || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scoped = _scopedContext;
      if (!mounted || scoped == null || !scoped.mounted) return;
      if (RouteSwitchStore.event.value == null) return;
      RouteSwitchStore.event.value = null;
      final l10n = DriverLocalizations.of(scoped);
      final name = _routeName(l10n, event.$1);
      final on = event.$2 == RouteSwitchEvent.switchedOn;
      // A route switched on moves to the top: show it.
      if (on && _listController.hasClients) _listController.jumpTo(0);
      ModuleToast.show(
        scoped,
        kind: on ? ModuleToastKind.success : ModuleToastKind.error,
        title: on ? l10n.onDoneTitle : l10n.soDoneTitle,
        message: on ? l10n.onDoneBody(name) : l10n.soDoneBody(name),
      );
    });
  }

  void _openRoute(_RouteItem route) {
    if (route.status != _RouteStatus.switchedOff) {
      Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const TripsPlanScreen()),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => RouteDetailScreen(
          tripState: TripState.planned,
          switchedOff: true,
          routeKey: route.keyName,
          summary: route.keyName == RouteSwitchStore.rander
              ? RouteActionsMockData.randerSummary
              : RouteDetailMockData.plannedSummary,
        ),
      ),
    );
  }

  Future<void> _openAddRoute() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => const PickupSupervisorAddRouteScreen(),
      ),
    );
    if (saved == true && mounted) {
      setState(() => _showSavedBanner = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          _scopedContext = context;
          final l10n = DriverLocalizations.of(context);
          final routes = _routes(l10n)
              .where((route) {
                final matchesFilter =
                    _selectedFilter == 0 ||
                    (_selectedFilter == 1 && !route.isContract) ||
                    (_selectedFilter == 2 && route.isContract);
                final matchesQuery =
                    _query.isEmpty ||
                    route.title.toLowerCase().contains(_query.toLowerCase());
                return matchesFilter && matchesQuery;
              })
              .toList(growable: false);

          return Scaffold(
            key: const Key('supervisor-routes-screen'),
            extendBody: true,
            backgroundColor: DriverColors.background,
            body: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: DriverColors.background),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 160,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFFB9F0C4), DriverColors.background],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                        child: _RoutesHeader(l10n: l10n),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _RoutesSearch(
                          hint: l10n.routesSearchHint,
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                      if (widget.showEmpty)
                        Expanded(child: _EmptyRoutes(l10n: l10n))
                      else ...[
                        const SizedBox(height: 16),
                        _RouteFilters(
                          l10n: l10n,
                          selected: _selectedFilter,
                          onSelected: (value) =>
                              setState(() => _selectedFilter = value),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            key: const Key('supervisor-routes-list'),
                            controller: _listController,
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              MediaQuery.paddingOf(context).bottom + 132,
                            ),
                            itemCount: routes.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (_, index) => _RouteCard(
                              route: routes[index],
                              highlighted: routes[index].highlighted,
                              onTap: () => _openRoute(routes[index]),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 92,
                  child: _AddRouteButton(onTap: _openAddRoute),
                ),
                if (_showSavedBanner)
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 8,
                    left: 15,
                    right: 15,
                    child: _SavedRouteBanner(
                      l10n: l10n,
                      onClose: () => setState(() => _showSavedBanner = false),
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: widget.showBottomNavigation
                ? PickupSupervisorBottomNavigation(
                    items: _standaloneNavigationItems(l10n),
                    selectedIndex: 2,
                    onItemSelected: (index) =>
                        widget.onNavigationSelected?.call(index),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class _RoutesHeader extends StatelessWidget {
  const _RoutesHeader({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.routesTitle,
                style: DriverTextStyles.semibold20.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.routesSubtitle,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        SvgPicture.asset(
          '$_iconRoot/notification.svg',
          package: _assetPackage,
          width: 45,
          height: 45,
        ),
      ],
    );
  }
}

class _RoutesSearch extends StatelessWidget {
  const _RoutesSearch({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextField(
        key: const Key('supervisor-route-search'),
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: DriverTextStyles.regular14,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: DriverTextStyles.regular14.copyWith(
            color: DriverColors.neutral500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(15),
            child: SvgPicture.asset(
              '$_iconRoot/search.svg',
              package: _assetPackage,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DriverColors.cool400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: DriverColors.primary500),
          ),
        ),
      ),
    );
  }
}

class _RouteFilters extends StatelessWidget {
  const _RouteFilters({
    required this.l10n,
    required this.selected,
    required this.onSelected,
  });

  final DriverLocalizations l10n;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = [
      l10n.routesFilterAll,
      l10n.routesFilterOwn,
      l10n.routesFilterContract,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 36,
        child: Row(
          children: List.generate(labels.length * 2 - 1, (itemIndex) {
            if (itemIndex.isOdd) return const SizedBox(width: 6);
            final index = itemIndex ~/ 2;
            final active = index == selected;
            return Expanded(
              flex: index == 0 ? 7 : 15,
              child: Material(
                color: active ? DriverColors.primary500 : Colors.white,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  key: Key('route-filter-$index'),
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: active
                          ? null
                          : Border.all(color: DriverColors.cool400),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      labels[index],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: active ? Colors.white : DriverColors.neutral700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _EmptyRoutes extends StatelessWidget {
  const _EmptyRoutes({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                '$_imageRoot/empty_routes.png',
                package: _assetPackage,
                width: 243,
                height: 147,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.routesEmptyMessage,
                textAlign: TextAlign.center,
                style: DriverTextStyles.semibold16.copyWith(
                  color: DriverColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({
    required this.route,
    required this.highlighted,
    required this.onTap,
  });

  final _RouteItem route;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = route.status == _RouteStatus.switchedOff;
    return Opacity(
      opacity: disabled ? .58 : 1,
      child: Container(
        key: Key('route-card-${route.keyName}'),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: DriverColors.primary500, width: 1.5)
              : null,
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          route.title,
                          style: DriverTextStyles.semibold16.copyWith(
                            color: DriverColors.neutral950,
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        highlighted
                            ? '$_iconRoot/arrow_green.svg'
                            : '$_iconRoot/arrow_muted.svg',
                        package: _assetPackage,
                        width: 14,
                        height: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _RouteTag(
                        text: route.vehicleType,
                        icon: route.isContract
                            ? '$_iconRoot/contract_vehicle.svg'
                            : '$_iconRoot/own_vehicle.svg',
                        background: route.isContract
                            ? DriverColors.pink100
                            : DriverColors.secondary100,
                        foreground: route.isContract
                            ? DriverColors.pink600
                            : DriverColors.blue600,
                      ),
                      if (route.secondaryTag != null)
                        _RouteTag(
                          text: route.secondaryTag!,
                          icon: route.driverNotUsingApp
                              ? '$_iconRoot/driver_app.svg'
                              : null,
                          background: route.driverNotUsingApp
                              ? DriverColors.red100
                              : DriverColors.cool100,
                          foreground: route.driverNotUsingApp
                              ? DriverColors.red600
                              : DriverColors.neutral700,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _DashedDivider(),
                  const SizedBox(height: 12),
                  _RouteInfoRow(
                    icon: disabled
                        ? '$_iconRoot/truck_disabled.svg'
                        : '$_iconRoot/truck.svg',
                    text: route.vehicleNumber,
                  ),
                  const SizedBox(height: 9),
                  _RouteInfoRow(
                    icon: disabled
                        ? '$_iconRoot/time_disabled.svg'
                        : '$_iconRoot/time.svg',
                    text: route.time,
                  ),
                  const SizedBox(height: 9),
                  _RouteInfoRow(
                    icon: disabled
                        ? '$_iconRoot/status_disabled.svg'
                        : '$_iconRoot/status.svg',
                    child: _StatusChip(
                      status: route.status,
                      text: route.statusText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: route.progress,
                      backgroundColor: DriverColors.cool200,
                      color: DriverColors.primary500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    route.progressText,
                    style: DriverTextStyles.medium12.copyWith(
                      color: DriverColors.neutral500,
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

class _RouteTag extends StatelessWidget {
  const _RouteTag({
    required this.text,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String text;
  final String? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon!,
              package: _assetPackage,
              width: 16,
              height: 16,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: DriverTextStyles.semibold12.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _RouteInfoRow extends StatelessWidget {
  const _RouteInfoRow({required this.icon, this.text, this.child});

  final String icon;
  final String? text;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: DriverColors.cool100,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(icon, package: _assetPackage),
        ),
        const SizedBox(width: 8),
        Expanded(
          child:
              child ??
              Text(
                text!,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.text});

  final _RouteStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      _RouteStatus.onRoute => (DriverColors.secondary100, DriverColors.blue600),
      _RouteStatus.planned => (DriverColors.purple50, DriverColors.purple600),
      _RouteStatus.approved => (
        DriverColors.primary100,
        DriverColors.primary800,
      ),
      _RouteStatus.switchedOff => (
        DriverColors.cool200,
        DriverColors.neutral700,
      ),
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: DriverTextStyles.semibold12.copyWith(color: foreground),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const gap = 4.0;
        final count = (constraints.maxWidth / (dashWidth + gap)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => const SizedBox(
              width: dashWidth,
              height: 1,
              child: ColoredBox(color: DriverColors.cool400),
            ),
          ),
        );
      },
    );
  }
}

class _AddRouteButton extends StatelessWidget {
  const _AddRouteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
        color: DriverColors.primary200,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 68,
        height: 68,
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: DriverColors.primary300,
          shape: BoxShape.circle,
        ),
        child: Material(
          color: DriverColors.primary500,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            key: const Key('add-route-button'),
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/help_support/add.svg',
                width: 34,
                height: 34,
                colorFilter: const ColorFilter.mode(
                  DriverColors.neutral50,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedRouteBanner extends StatelessWidget {
  const _SavedRouteBanner({required this.l10n, required this.onClose});

  final DriverLocalizations l10n;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('add-route-saved-banner'),
      color: DriverColors.primary50,
      elevation: 3,
      shadowColor: DriverColors.shadow,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
        decoration: BoxDecoration(
          border: Border.all(color: DriverColors.primary200),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/supervisor/add_route/success_tick.svg',
              package: _assetPackage,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.addRouteSavedTitle,
                    style: DriverTextStyles.semibold14.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.addRouteSavedSubtitle,
                    style: DriverTextStyles.regular12.copyWith(
                      color: DriverColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              key: const Key('close-add-route-saved-banner'),
              onPressed: onClose,
              visualDensity: VisualDensity.compact,
              icon: SvgPicture.asset(
                'assets/icons/supervisor/add_route/close.svg',
                package: _assetPackage,
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _RouteStatus { onRoute, planned, approved, switchedOff }

class _RouteItem {
  const _RouteItem({
    required this.keyName,
    required this.title,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.time,
    required this.status,
    required this.statusText,
    required this.progressText,
    required this.isContract,
    this.secondaryTag,
    this.driverNotUsingApp = false,
    this.highlighted = false,
    this.progress = 0,
  });

  final String keyName;
  final String title;
  final String vehicleType;
  final String? secondaryTag;
  final String vehicleNumber;
  final String time;
  final _RouteStatus status;
  final String statusText;
  final String progressText;
  final bool isContract;
  final bool driverNotUsingApp;
  final bool highlighted;
  final double progress;

  _RouteItem copyWith({
    _RouteStatus? status,
    String? statusText,
    String? progressText,
    bool? highlighted,
    double? progress,
  }) => _RouteItem(
    keyName: keyName,
    title: title,
    vehicleType: vehicleType,
    secondaryTag: secondaryTag,
    vehicleNumber: vehicleNumber,
    time: time,
    status: status ?? this.status,
    statusText: statusText ?? this.statusText,
    progressText: progressText ?? this.progressText,
    isContract: isContract,
    driverNotUsingApp: driverNotUsingApp,
    highlighted: highlighted ?? this.highlighted,
    progress: progress ?? this.progress,
  );
}

String _routeName(DriverLocalizations l10n, String key) =>
    _baseRoutes(l10n).firstWhere((r) => r.keyName == key).title;

/// The mock routes with the switched off / on state applied. A route
/// switched on in this session moves to the top as Planned.
List<_RouteItem> _routes(DriverLocalizations l10n) {
  final off = RouteSwitchStore.off.value;
  final items = [
    for (final r in _baseRoutes(l10n))
      if (off.contains(r.keyName))
        r.copyWith(
          status: _RouteStatus.switchedOff,
          statusText: l10n.routesSwitchedOff,
          progressText: l10n.routesNoTripsUntilOn,
          progress: 0,
        )
      else if (r.status == _RouteStatus.switchedOff)
        r.copyWith(
          status: _RouteStatus.planned,
          statusText: l10n.routesPlanned,
          progressText: l10n.routesCollectedZero,
          highlighted: true,
        )
      else
        r,
  ];
  final first = items
      .where((r) => RouteSwitchStore.switchedOnNow.contains(r.keyName))
      .toList();
  return [...first, ...items.where((r) => !first.contains(r))];
}

List<_RouteItem> _baseRoutes(DriverLocalizations l10n) => [
  _RouteItem(
    keyName: 'pal-gam',
    title: l10n.routesPalGamMorning,
    vehicleType: l10n.routesOwnVehicle,
    secondaryTag: l10n.routesDriverNotUsingApp,
    vehicleNumber: l10n.routesVehicle5678,
    time: l10n.routesPalGamTime,
    status: _RouteStatus.onRoute,
    statusText: l10n.routesOnRoute,
    progressText: l10n.routesRecordedZero,
    isContract: false,
    driverNotUsingApp: true,
  ),
  _RouteItem(
    keyName: 'adajan',
    title: l10n.routesAdajanMorning,
    vehicleType: l10n.routesOwnVehicle,
    secondaryTag: l10n.routesDailyWeekly,
    vehicleNumber: l10n.routesVehicle1234,
    time: l10n.routesAdajanTime,
    status: _RouteStatus.planned,
    statusText: l10n.routesPlanned,
    progressText: l10n.routesCollectedZero,
    isContract: false,
    highlighted: true,
  ),
  _RouteItem(
    keyName: 'punagam',
    title: l10n.routesPunagamFullDay,
    vehicleType: l10n.routesContractVehicle,
    secondaryTag: l10n.routesDailyMonthly,
    vehicleNumber: l10n.routesVehicle5678,
    time: l10n.routesFullDayTime,
    status: _RouteStatus.approved,
    statusText: l10n.routesApproved,
    progressText: l10n.routesCollectedEight,
    isContract: true,
    progress: 1,
  ),
  _RouteItem(
    keyName: 'rander',
    title: l10n.routesRanderEvening,
    vehicleType: l10n.routesContractVehicle,
    secondaryTag: l10n.routesWeeklyBiWeekly,
    vehicleNumber: l10n.routesVehicle9012,
    time: l10n.routesEveningTime,
    status: _RouteStatus.switchedOff,
    statusText: l10n.routesSwitchedOff,
    progressText: l10n.routesCollectedZero,
    isContract: true,
  ),
];

List<PickupSupervisorBottomNavItem> _standaloneNavigationItems(
  DriverLocalizations l10n,
) => [
  PickupSupervisorBottomNavItem(
    title: l10n.supervisorHome,
    selectedIcon: '$_homeIconRoot/nav_home.svg',
    unselectedIcon: '$_homeIconRoot/nav_home.svg',
    page: const SizedBox.shrink(),
    pageKey: 'home',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesNavLabel,
    selectedIcon: '$_homeIconRoot/nav_trips.svg',
    unselectedIcon: '$_homeIconRoot/nav_trips.svg',
    page: const SizedBox.shrink(),
    pageKey: 'sources',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesRoutesNavLabel,
    selectedIcon: '$_homeIconRoot/nav_sources.svg',
    unselectedIcon: '$_homeIconRoot/nav_sources.svg',
    page: const SizedBox.shrink(),
    pageKey: 'routes',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
  PickupSupervisorBottomNavItem(
    title: l10n.sourcesProfileNavLabel,
    selectedIcon: '$_homeIconRoot/nav_profile.svg',
    unselectedIcon: '$_homeIconRoot/nav_profile.svg',
    page: const SizedBox.shrink(),
    pageKey: 'profile',
    roles: const {PickupSupervisorModuleRole.pickupSupervisor},
  ),
];
