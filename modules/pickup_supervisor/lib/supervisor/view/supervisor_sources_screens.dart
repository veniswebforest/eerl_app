import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';
import 'package:pickup_supervisor/supervisor/model/supervisor_bottom_nav_item.dart';
import 'package:pickup_supervisor/supervisor/widgets/supervisor_bottom_navigation.dart';

const _iconRoot = 'assets/icons/supervisor/sources';
const _imageRoot = 'assets/images/supervisor/sources';
const _homeIconRoot = 'assets/icons/supervisor/home';
const _assetPackage = 'pickup_supervisor';
const _shadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 8, offset: Offset(0, 2)),
];

class SupervisorSourcesScreen extends StatefulWidget {
  const SupervisorSourcesScreen({
    super.key,
    this.showEmpty = false,
    this.showBottomNavigation = true,
    this.onNavigationSelected,
  });

  final bool showEmpty;
  final bool showBottomNavigation;
  final ValueChanged<int>? onNavigationSelected;

  @override
  State<SupervisorSourcesScreen> createState() =>
      _SupervisorSourcesScreenState();
}

class _SupervisorSourcesScreenState extends State<SupervisorSourcesScreen> {
  var _selectedTab = 0;
  var _query = '';

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final items = _sourceItems(l10n);
          final visibleItems = items
              .where((item) {
                if (_selectedTab != item.tab) return false;
                return _query.isEmpty ||
                    item.title.toLowerCase().contains(_query.toLowerCase());
              })
              .toList(growable: false);
          return Scaffold(
            key: const Key('supervisor-sources-screen'),
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
                  height: 150,
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
                        child: _SourcesHeader(l10n: l10n),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SourceSearch(
                          hint: l10n.sourcesSearchHint,
                          onChanged: (value) => setState(() => _query = value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SourcesTabs(
                          l10n: l10n,
                          selected: _selectedTab,
                          onSelected: (index) =>
                              setState(() => _selectedTab = index),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: widget.showEmpty
                            ? _EmptySources(l10n: l10n)
                            : ListView.separated(
                                key: const Key('supervisor-sources-list'),
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  20,
                                  MediaQuery.paddingOf(context).bottom +
                                      (widget.showBottomNavigation ? 112 : 24),
                                ),
                                itemCount: visibleItems.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (_, index) => _SourceCard(
                                  item: visibleItems[index],
                                  highlighted: index == 0,
                                  onTap: () =>
                                      _openSource(context, visibleItems[index]),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: widget.showBottomNavigation
                ? SupervisorBottomNavigation(
                    items: _standaloneNavigationItems(l10n),
                    selectedIndex: 1,
                    onItemSelected: (index) =>
                        widget.onNavigationSelected?.call(index),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _openSource(BuildContext context, _SourceItem item) {
    if (item.tab == 1) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SupervisorSourceDetailScreen(
          mixed: item.mixed,
          sourceName: item.detailName,
        ),
      ),
    );
  }
}

class SupervisorSourceDetailScreen extends StatelessWidget {
  const SupervisorSourceDetailScreen({
    super.key,
    required this.mixed,
    required this.sourceName,
  });

  final bool mixed;
  final String sourceName;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return Scaffold(
            key: Key('supervisor-source-detail-${mixed ? 'mixed' : 'sorted'}'),
            backgroundColor: DriverColors.background,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: _SourcesBackButton(),
                    ),
                    const SizedBox(height: 24),
                    _SourceDetailCard(
                      l10n: l10n,
                      sourceName: sourceName,
                      mixed: mixed,
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: FilledButton(
                key: const Key('source-add-to-route'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const SupervisorAssignSourceRouteScreen(),
                  ),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: DriverColors.primary500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.sourcesAddToRoute,
                  style: DriverTextStyles.bold16.copyWith(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SupervisorAssignSourceRouteScreen extends StatefulWidget {
  const SupervisorAssignSourceRouteScreen({super.key});

  @override
  State<SupervisorAssignSourceRouteScreen> createState() =>
      _SupervisorAssignSourceRouteScreenState();
}

class _SupervisorAssignSourceRouteScreenState
    extends State<SupervisorAssignSourceRouteScreen> {
  var _selectedRoute = 0;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final routes = [
            _RouteData(
              l10n.sourcesAdajanMorning,
              l10n.sourcesVehicleGj051824,
              l10n.sourcesMorningTime,
              l10n.sourcesAssignedCount,
            ),
            _RouteData(
              l10n.sourcesPalGamMorning,
              l10n.sourcesVehicleGj052564,
              l10n.sourcesPalGamTime,
              l10n.sourcesAssignedCount,
            ),
            _RouteData(
              l10n.sourcesVesuEvening,
              l10n.sourcesVehicleGj051824,
              l10n.sourcesMorningTime,
              l10n.sourcesAssignedCount,
              disabled: true,
            ),
          ];
          return Scaffold(
            key: const Key('supervisor-assign-source-route-screen'),
            backgroundColor: DriverColors.background,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SourcesBackButton(),
                    const SizedBox(height: 24),
                    ...List.generate(routes.length, (index) {
                      final selected = index == _selectedRoute;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          children: [
                            _RouteChoiceCard(
                              data: routes[index],
                              selected: selected,
                              onTap: routes[index].disabled
                                  ? null
                                  : () =>
                                        setState(() => _selectedRoute = index),
                            ),
                            if (index == 0 && selected) ...[
                              const SizedBox(height: 16),
                              _RouteWarning(l10n: l10n),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: DriverColors.primary500,
                        side: const BorderSide(color: DriverColors.primary500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.sourcesAddNew,
                        style: DriverTextStyles.bold16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('source-assign-anyway'),
                      onPressed: () => _showSuccess(context, l10n),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: DriverColors.primary500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.sourcesAssignAnyway,
                        style: DriverTextStyles.bold16.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSuccess(BuildContext context, DriverLocalizations l10n) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) => Dialog(
        key: const Key('source-added-dialog'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          height: 329,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.sourcesAddedToRoute,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.bold24.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.sourcesAddedMessage,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.regular14.copyWith(
                    color: DriverColors.neutral600,
                    height: 19 / 14,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => Navigator.of(
                    dialogContext,
                  ).popUntil((route) => route.isFirst),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: DriverColors.cool200,
                    foregroundColor: DriverColors.neutral950,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.sourcesBackToRequests,
                    style: DriverTextStyles.semibold16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourcesHeader extends StatelessWidget {
  const _SourcesHeader({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sourcesUnassignedTitle,
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.sourcesManageSubtitle,
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
      ),
    );
  }
}

class _SourceSearch extends StatelessWidget {
  const _SourceSearch({required this.hint, required this.onChanged});

  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextField(
        key: const Key('supervisor-source-search'),
        onChanged: onChanged,
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

class _SourcesTabs extends StatelessWidget {
  const _SourcesTabs({
    required this.l10n,
    required this.selected,
    required this.onSelected,
  });

  final DriverLocalizations l10n;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final labels = [l10n.sourcesTabCount, l10n.sourcesExtraTabCount];
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final active = index == selected;
          return Expanded(
            child: Material(
              color: active ? DriverColors.primary500 : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                key: Key('sources-tab-$index'),
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Text(
                    labels[index],
                    style:
                        (active
                                ? DriverTextStyles.bold14
                                : DriverTextStyles.regular14)
                            .copyWith(
                              color: active
                                  ? Colors.white
                                  : DriverColors.neutral900,
                            ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SourceItem {
  const _SourceItem({
    required this.title,
    required this.address,
    required this.schedule,
    required this.detailName,
    this.tab = 0,
    this.mixed = false,
  });

  final String title;
  final String address;
  final String schedule;
  final String detailName;
  final int tab;
  final bool mixed;
}

List<_SourceItem> _sourceItems(DriverLocalizations l10n) => [
  _SourceItem(
    title: l10n.sourcesAdajanTextileSorted,
    address: l10n.sourcesAddressShort,
    schedule: l10n.sourcesMonThuSchedule,
    detailName: l10n.sourcesAbcTextileMills,
  ),
  _SourceItem(
    title: l10n.sourcesShreeSaiMixed,
    address: l10n.sourcesEmbraneAddress,
    schedule: l10n.sourcesExceptSunSchedule,
    detailName: l10n.sourcesShreeSaiDairy,
    mixed: true,
  ),
  _SourceItem(
    title: l10n.sourcesShreeSaiSorted,
    address: l10n.sourcesAddressShort,
    schedule: l10n.sourcesSecondWedSchedule,
    detailName: l10n.sourcesShreeSaiDairy,
  ),
  _SourceItem(
    title: l10n.sourcesMahavirSorted,
    address: l10n.sourcesAddressShort,
    schedule: l10n.sourcesExtraPickupSchedule,
    detailName: l10n.sourcesMahavirPaperMill,
    tab: 1,
  ),
];

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.item,
    required this.highlighted,
    required this.onTap,
  });

  final _SourceItem item;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,

            border: Border.all(
              color: highlighted ? DriverColors.primary500 : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: DriverTextStyles.semibold18.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    highlighted
                        ? '$_iconRoot/arrow_green.svg'
                        : '$_iconRoot/arrow_muted.svg',
                    package: _assetPackage,
                    width: 13,
                    height: 13,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DriverColors.cool100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _SourceInfoRow(
                      asset: '$_iconRoot/location.svg',
                      value: item.address,
                    ),
                    const SizedBox(height: 8),
                    _SourceInfoRow(
                      asset: '$_iconRoot/clock.svg',
                      value: item.schedule,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: DriverColors.yellow50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      '$_iconRoot/unassigned.svg',
                      package: _assetPackage,
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.sourcesUnassignedStatus,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.yellow600,
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

class _SourceInfoRow extends StatelessWidget {
  const _SourceInfoRow({required this.asset, required this.value});

  final String asset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(asset, package: _assetPackage),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
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

class _EmptySources extends StatelessWidget {
  const _EmptySources({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: .4,
              child: Image.asset(
                '$_imageRoot/empty_truck.png',
                package: _assetPackage,
                width: 285,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.sourcesEmptyMessage,
              style: DriverTextStyles.semibold16.copyWith(
                color: DriverColors.neutral400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourcesBackButton extends StatelessWidget {
  const _SourcesBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.primary500,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              '$_iconRoot/back.svg',
              package: _assetPackage,
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceDetailCard extends StatelessWidget {
  const _SourceDetailCard({
    required this.l10n,
    required this.sourceName,
    required this.mixed,
  });

  final DriverLocalizations l10n;
  final String sourceName;
  final bool mixed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sourceName,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const Divider(height: 18, color: DriverColors.cool400),
          _DetailSection(
            label: l10n.sourcesAddress,
            value: l10n.sourcesFullAddress,
            action: Row(
              children: [
                SvgPicture.asset(
                  '$_iconRoot/maps.svg',
                  package: _assetPackage,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.sourcesOpenMaps,
                  style: DriverTextStyles.bold14.copyWith(
                    color: DriverColors.primary500,
                    decoration: TextDecoration.underline,
                    decorationColor: DriverColors.primary500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 18, color: DriverColors.cool400),
          _DetailSection(
            label: l10n.sourcesSchedule,
            value: l10n.sourcesMonThuSchedule,
          ),
          const Divider(height: 18, color: DriverColors.cool400),
          _DetailSection(
            label: l10n.sourcesContactNumber,
            value: l10n.sourcesPhone,
          ),
          const Divider(height: 18, color: DriverColors.cool400),
          Text(l10n.sourcesMaterial, style: DriverTextStyles.semibold14),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: mixed
                      ? DriverColors.orangeLight
                      : DriverColors.purpleLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mixed ? l10n.sourcesMixed : l10n.sourcesSorted,
                  style: DriverTextStyles.bold14.copyWith(
                    color: mixed ? DriverColors.orange : DriverColors.purple,
                  ),
                ),
              ),
              if (!mixed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.sourcesMaterialsList,
                    style: DriverTextStyles.regular14,
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 18, color: DriverColors.cool400),
          Text(l10n.sourcesPickupStatus, style: DriverTextStyles.semibold14),
          const SizedBox(height: 8),
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: DriverColors.yellow50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  '$_iconRoot/detail_unassigned.svg',
                  package: _assetPackage,
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.sourcesUnassignedStatus,
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.label, required this.value, this.action});

  final String label;
  final String value;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DriverTextStyles.semibold14),
        const SizedBox(height: 6),
        Text(
          '  •  $value',
          style: DriverTextStyles.regular14.copyWith(height: 22 / 14),
        ),
        if (action != null) ...[const SizedBox(height: 6), action!],
      ],
    );
  }
}

class _RouteData {
  const _RouteData(
    this.name,
    this.vehicle,
    this.time,
    this.assigned, {
    this.disabled = false,
  });

  final String name;
  final String vehicle;
  final String time;
  final String assigned;
  final bool disabled;
}

class _RouteChoiceCard extends StatelessWidget {
  const _RouteChoiceCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _RouteData data;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: data.disabled ? .5 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected ? DriverColors.primary500 : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: _shadow,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        '$_imageRoot/route_thumbnail.png',
                        package: _assetPackage,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        data.name,
                        style: DriverTextStyles.semibold16.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: DriverColors.neutral400),
                      ),
                      child: selected
                          ? const DecoratedBox(
                              decoration: BoxDecoration(
                                color: DriverColors.primary500,
                                shape: BoxShape.circle,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
                if (selected) ...[
                  const SizedBox(height: 16),
                  _RouteInfoRow(
                    icon: '$_iconRoot/truck.svg',
                    text: data.vehicle,
                  ),
                  const SizedBox(height: 12),
                  _RouteInfoRow(
                    icon: '$_iconRoot/route_clock.svg',
                    text: data.time,
                  ),
                  const SizedBox(height: 12),
                  _RouteInfoRow(
                    icon: '$_iconRoot/store.svg',
                    text: data.assigned,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteInfoRow extends StatelessWidget {
  const _RouteInfoRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: DriverColors.cool100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: DriverColors.primary100,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(icon, package: _assetPackage),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteWarning extends StatelessWidget {
  const _RouteWarning({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E6),
        border: Border.all(color: const Color(0xFFF5D48A)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            '$_iconRoot/info.svg',
            package: _assetPackage,
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.sourcesTimeClashWarning,
              style: DriverTextStyles.medium12.copyWith(
                color: const Color(0xFF795400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

List<SupervisorBottomNavItem> _standaloneNavigationItems(
  DriverLocalizations l10n,
) => [
  SupervisorBottomNavItem(
    title: l10n.supervisorHome,
    selectedIcon: '$_homeIconRoot/nav_home.svg',
    unselectedIcon: '$_homeIconRoot/nav_home.svg',
    page: const SizedBox.shrink(),
    pageKey: 'home',
    roles: const {SupervisorModuleRole.pickupSupervisor},
  ),
  SupervisorBottomNavItem(
    title: l10n.sourcesNavLabel,
    selectedIcon: '$_homeIconRoot/nav_trips.svg',
    unselectedIcon: '$_homeIconRoot/nav_trips.svg',
    page: const SizedBox.shrink(),
    pageKey: 'sources',
    roles: const {SupervisorModuleRole.pickupSupervisor},
  ),
  SupervisorBottomNavItem(
    title: l10n.sourcesRoutesNavLabel,
    selectedIcon: '$_homeIconRoot/nav_sources.svg',
    unselectedIcon: '$_homeIconRoot/nav_sources.svg',
    page: const SizedBox.shrink(),
    pageKey: 'routes',
    roles: const {SupervisorModuleRole.pickupSupervisor},
  ),
  SupervisorBottomNavItem(
    title: l10n.sourcesProfileNavLabel,
    selectedIcon: '$_homeIconRoot/nav_profile.svg',
    unselectedIcon: '$_homeIconRoot/nav_profile.svg',
    page: const SizedBox.shrink(),
    pageKey: 'profile',
    roles: const {SupervisorModuleRole.pickupSupervisor},
  ),
];
