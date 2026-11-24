import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetRoot = 'assets/icons/supervisor/flags';
const _assetPackage = 'pickup_supervisor';
const _shadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
];

enum PickupSupervisorFlagDetailType {
  scheduleChanged,
  sourcePaused,
  newSource,
  extraPickup,
  sourceMoved,
}

class PickupSupervisorFlagsScreen extends StatelessWidget {
  const PickupSupervisorFlagsScreen({super.key, this.showEmpty = false});

  final bool showEmpty;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return Scaffold(
            key: Key(
              showEmpty ? 'supervisor-flags-empty' : 'supervisor-flags-list',
            ),
            backgroundColor: DriverColors.background,
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: _FlagsHeader(title: l10n.supervisorFlags),
                  ),
                  if (showEmpty)
                    Expanded(child: _EmptyFlags(l10n: l10n))
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          25,
                          20,
                          MediaQuery.paddingOf(context).bottom + 24,
                        ),
                        child: _FlagsList(l10n: l10n),
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
}

class PickupSupervisorFlagDetailScreen extends StatelessWidget {
  const PickupSupervisorFlagDetailScreen({super.key, required this.type});

  final PickupSupervisorFlagDetailType type;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return Scaffold(
            key: Key('supervisor-flag-detail-${type.name}'),
            backgroundColor: DriverColors.background,
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _FlagsBackButton(),
                    const SizedBox(height: 24),
                    _FlagDetailCard(type: type, l10n: l10n),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: _FlagDetailActions(type: type, l10n: l10n),
          );
        },
      ),
    );
  }
}

class _FlagsHeader extends StatelessWidget {
  const _FlagsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: Row(
        children: [
          const _FlagsBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: DriverTextStyles.semibold20.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
          SvgPicture.asset(
            '$_assetRoot/notification.svg',
            package: _assetPackage,
            width: 45,
            height: 45,
          ),
        ],
      ),
    );
  }
}

class _FlagsBackButton extends StatelessWidget {
  const _FlagsBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.primary500,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: const Key('supervisor-flags-back'),
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: SvgPicture.asset(
              '$_assetRoot/back.svg',
              package: _assetPackage,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlagsList extends StatelessWidget {
  const _FlagsList({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final flags = [
      _FlagData(l10n.flagTimeClash, l10n.flagHotelRajdhaniTime),
      _FlagData(l10n.flagOffRoute, l10n.flagSunriseOffRoute),
      _FlagData(
        l10n.flagScheduleChanged,
        l10n.flagAdajanTextileSorted,
        type: PickupSupervisorFlagDetailType.scheduleChanged,
        highlighted: true,
      ),
      _FlagData(
        l10n.flagSourcePaused,
        l10n.flagClosedForDiwali,
        type: PickupSupervisorFlagDetailType.sourcePaused,
      ),
      _FlagData(
        l10n.flagNewSourceNoRoute,
        l10n.flagAbcTextileMills,
        type: PickupSupervisorFlagDetailType.newSource,
      ),
      _FlagData(
        l10n.flagExtraPickupNoRoute,
        l10n.flagShreeSaiSorted,
        type: PickupSupervisorFlagDetailType.extraPickup,
      ),
      _FlagData(
        l10n.flagSourceMovedToYou,
        l10n.flagRkTrading,
        type: PickupSupervisorFlagDetailType.sourceMoved,
      ),
    ];
    return Column(
      children: List.generate(
        flags.length,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index == flags.length - 1 ? 0 : 16),
          child: _FlagTile(data: flags[index]),
        ),
      ),
    );
  }
}

class _FlagData {
  const _FlagData(
    this.title,
    this.subtitle, {
    this.type,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final PickupSupervisorFlagDetailType? type;
  final bool highlighted;
}

class _FlagTile extends StatelessWidget {
  const _FlagTile({required this.data});

  final _FlagData data;

  @override
  Widget build(BuildContext context) {
    final borderColor = data.highlighted
        ? DriverColors.primary500
        : Colors.transparent;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key('supervisor-flag-${data.title}'),
        onTap: data.type == null
            ? null
            : () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PickupSupervisorFlagDetailScreen(type: data.type!),
                ),
              ),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 75),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _shadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  '$_assetRoot/flag_issue.svg',
                  package: _assetPackage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.subtitle,
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
              SvgPicture.asset(
                data.highlighted
                    ? '$_assetRoot/arrow_green.svg'
                    : '$_assetRoot/arrow_muted.svg',
                package: _assetPackage,
                width: 13,
                height: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFlags extends StatelessWidget {
  const _EmptyFlags({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.translate(
        offset: const Offset(0, -4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EmptyFlagsIllustration(month: l10n.flagOctober),
              const SizedBox(height: 32),
              Text(
                l10n.flagNothingToCheck,
                textAlign: TextAlign.center,
                style: DriverTextStyles.bold24.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.flagNothingToCheckSubtitle,
                textAlign: TextAlign.center,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFlagsIllustration extends StatelessWidget {
  const _EmptyFlagsIllustration({required this.month});

  final String month;

  Widget _asset(String name, double width, double height) => SvgPicture.asset(
    '$_assetRoot/$name.svg',
    package: _assetPackage,
    width: width,
    height: height,
  );

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .5,
      child: SizedBox(
        width: 217,
        height: 205.1,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: _asset('empty_clouds', 217, 60.1),
            ),
            Positioned(
              left: 55.7,
              top: 9.6,
              child: _asset('empty_phone', 104.6, 205.1),
            ),
            Positioned(
              left: 68,
              top: 139.6,
              child: _asset('empty_note', 61.7, 52.9),
            ),
            Positioned(
              left: 18.9,
              top: 45.3,
              child: _asset('empty_check', 30.1, 30.1),
            ),
            Positioned(
              left: 38.2,
              top: 93.4,
              child: _asset('empty_location', 47.3, 34.6),
            ),
            Positioned(
              left: 67.8,
              top: 35,
              child: _asset('empty_calendar', 80.5, 52.9),
            ),
            Positioned(
              left: 74.4,
              top: 53.1,
              child: _asset('empty_calendar_rows_1', 65.9, 13.7),
            ),
            Positioned(
              left: 74.4,
              top: 35,
              child: Text(
                month,
                style: DriverTextStyles.regular12.copyWith(
                  color: DriverColors.primary800,
                ),
              ),
            ),
            Positioned(
              left: 74.4,
              top: 71.5,
              child: _asset('empty_calendar_rows_2', 65.9, 13.7),
            ),
            Positioned(
              left: 95.6,
              top: 93.4,
              child: _asset('empty_list', 52.7, 34.6),
            ),
            Positioned(
              left: 140.2,
              top: 150.6,
              child: _asset('empty_settings', 34, 30.4),
            ),
            Positioned(
              left: .6,
              bottom: 0,
              child: _asset('empty_baseline', 215.8, .5),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagDetailCard extends StatelessWidget {
  const _FlagDetailCard({required this.type, required this.l10n});

  final PickupSupervisorFlagDetailType type;
  final DriverLocalizations l10n;

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
            l10n.flagShreeSaiDairy,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset(
                '$_assetRoot/location.svg',
                package: _assetPackage,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.flagShreeSaiAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (type == PickupSupervisorFlagDetailType.scheduleChanged)
            _ScheduleChangedPanel(l10n: l10n)
          else
            _FlagStatusPanel(type: type, l10n: l10n),
          if (type == PickupSupervisorFlagDetailType.scheduleChanged) ...[
            const SizedBox(height: 8),
            Text(
              l10n.flagFromMon2Nov,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.primary500,
              ),
            ),
          ] else if (type == PickupSupervisorFlagDetailType.sourcePaused) ...[
            const SizedBox(height: 8),
            Text(
              l10n.flagReasonClosedForDiwali,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.primary500,
              ),
            ),
          ] else if (type == PickupSupervisorFlagDetailType.sourceMoved) ...[
            const SizedBox(height: 8),
            Text(
              l10n.flagMovedFromVesu,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.primary500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleChangedPanel extends StatelessWidget {
  const _ScheduleChangedPanel({required this.l10n});

  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 116,
      decoration: BoxDecoration(
        color: DriverColors.cool100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.flagWas,
            style: DriverTextStyles.semibold12.copyWith(
              color: DriverColors.neutral400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.flagOldSchedule,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 4),
          SvgPicture.asset(
            '$_assetRoot/down_arrow.svg',
            package: _assetPackage,
            width: 16,
            height: 20,
          ),
          const SizedBox(height: 2),
          Text(
            l10n.flagNow,
            style: DriverTextStyles.semibold12.copyWith(
              color: DriverColors.neutral400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            l10n.flagNewSchedule,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagStatusPanel extends StatelessWidget {
  const _FlagStatusPanel({required this.type, required this.l10n});

  final PickupSupervisorFlagDetailType type;
  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (type) {
      PickupSupervisorFlagDetailType.sourcePaused => (
        l10n.flagPausedDates,
        'paused',
      ),
      PickupSupervisorFlagDetailType.newSource => (
        l10n.flagNewSourceNoRoute,
        'no_route',
      ),
      PickupSupervisorFlagDetailType.extraPickup => (
        l10n.flagExtraPickupNoRouteDetail,
        'no_route',
      ),
      PickupSupervisorFlagDetailType.sourceMoved => (
        l10n.flagSourceMovedToYou,
        'moved',
      ),
      PickupSupervisorFlagDetailType.scheduleChanged => ('', 'no_route'),
    };
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: DriverColors.cool100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              '$_assetRoot/$icon.svg',
              package: _assetPackage,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.neutral700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagDetailActions extends StatelessWidget {
  const _FlagDetailActions({required this.type, required this.l10n});

  final PickupSupervisorFlagDetailType type;
  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final single = type == PickupSupervisorFlagDetailType.sourcePaused;
    final secondary = type == PickupSupervisorFlagDetailType.scheduleChanged
        ? l10n.flagCheckRoute
        : l10n.flagAddToRoute;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          if (!single) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: DriverColors.primary500,
                  side: const BorderSide(color: DriverColors.primary500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(secondary, style: DriverTextStyles.bold16),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              onPressed: () => Navigator.maybePop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: DriverColors.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                single ? l10n.flagDone : l10n.flagMarkDone,
                style: DriverTextStyles.bold16.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
