import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_tag.dart';
import 'package:pickup_supervisor/features/route_detail/view/route_detail_screen.dart';
import 'package:pickup_supervisor/features/trips_plan/model/trips_plan_models.dart';
import 'package:pickup_supervisor/features/trips_plan/widgets/trips_plan_assets.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _cardShadow = BoxShadow(
  color: Color(0x1F000000),
  blurRadius: 5,
  offset: Offset(0, 2),
);

Widget _icon(String asset, double size) => SvgPicture.asset(
  asset,
  package: TripsPlanAssets.package,
  width: size,
  height: size,
);

/// Back button with the screen title and the areas subtitle.
class TripsPlanHeader extends StatelessWidget {
  const TripsPlanHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ModuleBackButton(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DriverTextStyles.semibold20.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
              const SizedBox(height: 2),
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
    );
  }
}

/// Today / Tomorrow / This week / pick-a-date chips.
class TripsPlanChoices extends StatelessWidget {
  const TripsPlanChoices({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final TripsPlanChoice selected;
  final ValueChanged<TripsPlanChoice> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            key: const Key('trips-plan-choice-today'),
            selected: selected == TripsPlanChoice.today,
            onTap: () => onChanged(TripsPlanChoice.today),
            child: _ChipLabel(
              l10n.tpChoiceToday,
              selected == TripsPlanChoice.today,
            ),
          ),
          const SizedBox(width: 6),
          _Chip(
            key: const Key('trips-plan-choice-tomorrow'),
            selected: selected == TripsPlanChoice.tomorrow,
            onTap: () => onChanged(TripsPlanChoice.tomorrow),
            child: _ChipLabel(
              l10n.tpChoiceTomorrow,
              selected == TripsPlanChoice.tomorrow,
            ),
          ),
          const SizedBox(width: 6),
          _Chip(
            key: const Key('trips-plan-choice-week'),
            selected: selected == TripsPlanChoice.week,
            onTap: () => onChanged(TripsPlanChoice.week),
            child: _ChipLabel(
              l10n.tpChoiceWeek,
              selected == TripsPlanChoice.week,
            ),
          ),
          const SizedBox(width: 6),
          _Chip(
            key: const Key('trips-plan-choice-date'),
            selected: selected == TripsPlanChoice.date,
            onTap: () => onChanged(TripsPlanChoice.date),
            child: _icon(
              selected == TripsPlanChoice.date
                  ? TripsPlanAssets.calendarSelected
                  : TripsPlanAssets.calendar,
              14,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DriverColors.primary500 : DriverColors.neutral50,
      shape: StadiumBorder(
        side: selected
            ? BorderSide.none
            : const BorderSide(color: DriverColors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: child,
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel(this.text, this.selected);

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: DriverTextStyles.semibold12.copyWith(
      color: selected ? DriverColors.neutral50 : DriverColors.neutral900,
    ),
  );
}

/// "Thu 22 Oct 2026" with the trip / stop counts on the right.
class TripsPlanDateRow extends StatelessWidget {
  const TripsPlanDateRow({
    super.key,
    required this.date,
    required this.summary,
  });

  final String date;
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            date,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          summary,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral700,
          ),
        ),
      ],
    );
  }
}

/// White rounded card with the standard Figma shadow.
class TripsPlanCard extends StatelessWidget {
  const TripsPlanCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [_cardShadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(16), child: child),
        ),
      ),
    );
  }
}

/// A single trip: status, vehicle, crew, schedule, progress and Call driver.
class TripsPlanTripCard extends StatelessWidget {
  const TripsPlanTripCard({super.key, required this.trip});

  final TripPlanTrip trip;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final status = switch (trip.status) {
      TripStatus.onRoute => (l10n.tpStatusOnRoute, ModuleTagTone.blue),
      TripStatus.approved => (l10n.tpStatusApproved, ModuleTagTone.green),
      TripStatus.planned => (l10n.tpStatusPlanned, ModuleTagTone.pink),
    };
    final isOwn = trip.vehicleKind == TripVehicleKind.own;
    final vehicleLabel = l10n.tpVehicleTag(
      trip.plate,
      isOwn ? l10n.tpOwnVehicle : l10n.tpContractVehicle,
    );

    return TripsPlanCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => const RouteDetailScreen()),
      ),
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
                      trip.name,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      trip.time,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ModuleTag(label: status.$1, tone: status.$2),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ModuleTag(
                label: vehicleLabel,
                tone: isOwn ? ModuleTagTone.blue : ModuleTagTone.pink,
                iconAsset: isOwn
                    ? TripsPlanAssets.ownVehicle
                    : TripsPlanAssets.contractVehicle,
              ),
              if (trip.alert == TripAlert.changedForToday)
                ModuleTag(
                  label: l10n.tpChangedForToday,
                  tone: ModuleTagTone.yellow,
                  iconAsset: TripsPlanAssets.changed,
                ),
              if (trip.alert == TripAlert.driverNotUsingApp)
                ModuleTag(
                  label: l10n.tpDriverNotUsingApp,
                  tone: ModuleTagTone.red,
                  iconAsset: TripsPlanAssets.driverNotUsingApp,
                ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoBox(crew: _crewLine(l10n), schedule: _scheduleLine(l10n)),
          if (trip.progress != null) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    _progressLine(l10n),
                    style: DriverTextStyles.medium13.copyWith(
                      color: DriverColors.neutral700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.tpWeightKg(trip.weightKg ?? '0'),
                  style: DriverTextStyles.bold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          const _CallDriverButton(),
        ],
      ),
    );
  }

  String _crewLine(DriverLocalizations l10n) {
    final crew = trip.crew;
    if (crew.transporter != null) {
      return l10n.tpTransporterDriver(crew.transporter!, crew.driver);
    }
    final driver = crew.coveringFor == null
        ? crew.driver
        : l10n.tpCoverFor(crew.driver, crew.coveringFor!);
    return crew.helper == null ? driver : '$driver · ${crew.helper}';
  }

  String _scheduleLine(DriverLocalizations l10n) {
    final s = trip.schedule;
    return [
      l10n.tpStops(s.stops),
      if (s.daily > 0) l10n.tpDaily(s.daily),
      if (s.weekly > 0) l10n.tpWeekly(s.weekly),
      if (s.monthly > 0) l10n.tpMonthly(s.monthly),
      if (s.biWeekly > 0) l10n.tpBiWeekly(s.biWeekly),
      if (s.onCall > 0) l10n.tpOnCall(s.onCall),
      if (s.paused > 0) l10n.tpPaused(s.paused),
    ].join(' · ');
  }

  String _progressLine(DriverLocalizations l10n) {
    final p = trip.progress!;
    return switch (p.kind) {
      TripProgressKind.collectedOf => l10n.tpCollectedOf(p.first, p.second),
      TripProgressKind.recordedOf => l10n.tpRecordedOf(p.first, p.second),
      TripProgressKind.collectedMissed => l10n.tpCollectedMissed(
        p.first,
        p.second,
      ),
    };
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.crew, required this.schedule});

  final String crew;
  final String schedule;

  @override
  Widget build(BuildContext context) {
    Widget row(String asset, String text) => Row(
      children: [
        _icon(asset, 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: DriverTextStyles.medium13.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DriverColors.cool100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          row(TripsPlanAssets.person, crew),
          const SizedBox(height: 6),
          row(TripsPlanAssets.clock, schedule),
        ],
      ),
    );
  }
}

class _CallDriverButton extends StatelessWidget {
  const _CallDriverButton();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const Key('trips-plan-call-driver'),
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: DriverColors.neutral50,
          foregroundColor: DriverColors.primary500,
          side: const BorderSide(color: DriverColors.primary500),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: _icon(TripsPlanAssets.phone, 20),
        label: Text(l10n.tpCallDriver, style: DriverTextStyles.bold16),
      ),
    );
  }
}

/// A day in the "This week" list.
class TripsPlanDayCard extends StatelessWidget {
  const TripsPlanDayCard({
    super.key,
    required this.title,
    required this.summary,
    required this.ownVehicles,
    required this.contractVehicles,
    this.onTap,
  });

  final String title;
  final String summary;
  final int ownVehicles;
  final int contractVehicles;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return TripsPlanCard(
      onTap: onTap,
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
                      title,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      summary,
                      style: DriverTextStyles.medium12.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                  ],
                ),
              ),
              _icon(TripsPlanAssets.chevronRight, 20),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ModuleTag(
                label: l10n.tpOwnVehicleCount(ownVehicles),
                tone: ModuleTagTone.blue,
                iconAsset: TripsPlanAssets.ownVehicle,
              ),
              ModuleTag(
                label: l10n.tpContractCount(contractVehicles),
                tone: ModuleTagTone.pink,
                iconAsset: TripsPlanAssets.contractVehicle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "No trips on this day" empty state.
class TripsPlanEmptyState extends StatelessWidget {
  const TripsPlanEmptyState({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 40),
      child: Column(
        children: [
          _icon(TripsPlanAssets.emptyCircle, 120),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: DriverTextStyles.semibold18.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
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
