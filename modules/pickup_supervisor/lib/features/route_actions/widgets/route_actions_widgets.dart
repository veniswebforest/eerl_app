import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_selection_rows.dart';
import 'package:pickup_supervisor/core/widgets/module_tag.dart';
import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Asset paths for the planned-trip actions.
abstract final class RouteActionsAssets {
  static const package = 'pickup_supervisor';
  static const _i = 'assets/icons/route_actions';
  static const _n = 'assets/images/route_actions/no_trips';

  static const cancelTrip = '$_i/cancel_trip.svg';
  static const move = '$_i/move.svg';
  static const power = '$_i/power.svg';
  static const chevronDown = '$_i/chevron_down.svg';
  static const dropdown = 'assets/icons/supervisor/add_route/dropdown.svg';
  static const calendar = 'assets/icons/supervisor/home/attention.svg';
  static const changed = 'assets/icons/trips_plan/changed.svg';

  static const noTripsBackground = '$_n/background.svg';
  static const noTripsWindow = '$_n/window.svg';
  static const noTripsWindowBar = '$_n/window_bar.svg';
  static const noTripsDots = '$_n/dots.svg';
  static const noTripsFolder = '$_n/folder.svg';
  static const noTripsPlant = '$_n/plant.svg';
  static const noTripsBubble = '$_n/bubble.svg';
  static const noTripsBubbleCheck = '$_n/bubble_check.svg';
}

Widget routeActionsIcon(String asset, double size) => SvgPicture.asset(
  asset,
  package: RouteActionsAssets.package,
  width: size,
  height: size,
);

/// Screen header: back button, title and a grey subtitle.
class RouteActionsHeader extends StatelessWidget {
  const RouteActionsHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const ModuleBackButton(),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: DriverTextStyles.semibold20.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
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

/// Sheet title (22px semibold) and a grey line under it.
class RouteActionsSheetTitle extends StatelessWidget {
  const RouteActionsSheetTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: DriverTextStyles.semibold20.copyWith(
          fontSize: 22,
          color: DriverColors.neutral950,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        subtitle,
        style: DriverTextStyles.medium12.copyWith(
          color: DriverColors.neutral600,
        ),
      ),
    ],
  );
}

Widget _sheetNote(String text) => Text(
  text,
  style: DriverTextStyles.medium12.copyWith(color: DriverColors.neutral600),
);

/// "Driver / Labour for this trip": free people first, then busy ones.
/// Pops with the chosen [TeamPerson].
class TeamPersonSheet extends StatelessWidget {
  const TeamPersonSheet({
    super.key,
    required this.title,
    required this.freeOn,
    required this.busyNote,
    required this.people,
    required this.selected,
  });

  final String title;
  final String freeOn;
  final String busyNote;
  final List<TeamPerson> people;
  final TeamPerson? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final free = people.where((p) => !p.busy).toList();
    final busy = people.where((p) => p.busy).toList();
    Widget option(TeamPerson p) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ModuleRadioCard(
        key: Key('team-person-${p.phoneTail}'),
        large: true,
        selected: selected?.phoneTail == p.phoneTail,
        dimmed: p.busy,
        title: l10n.ctPerson(p.name, p.phoneTail),
        subtitle: p.busyWith != null
            ? l10n.ctBusy(p.busyWith!.$1, p.busyWith!.$2)
            : p.freeUntil != null
            ? l10n.ctFreeUntil(p.freeUntil!.$1, p.freeUntil!.$2)
            : l10n.ctFreeToday,
        onTap: () => Navigator.of(context).pop(p),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RouteActionsSheetTitle(title: title, subtitle: freeOn),
        const SizedBox(height: 10),
        for (final p in free) option(p),
        if (busy.isNotEmpty) ...[
          const SizedBox(height: 2),
          _sheetNote(l10n.ctBusyAtTime),
          const SizedBox(height: 10),
          for (final p in busy) option(p),
        ],
        const SizedBox(height: 2),
        _sheetNote(busyNote),
      ],
    );
  }
}

/// "Which trip or route?" (or pickup point). Pops with the chosen target.
class AskTargetSheet extends StatelessWidget {
  const AskTargetSheet({
    super.key,
    required this.forTrip,
    required this.targets,
    required this.selected,
  });

  final bool forTrip;
  final List<AskTarget> targets;
  final AskTarget? selected;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RouteActionsSheetTitle(
          title: forTrip ? l10n.ahWhich : l10n.ahWhichPoint,
          subtitle: forTrip ? l10n.ahYourRoutes : l10n.ahYourPoints,
        ),
        const SizedBox(height: 10),
        for (final (i, t) in targets.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ModuleRadioCard(
              key: Key('ask-target-$i'),
              large: true,
              selected: selected?.name == t.name,
              title: t.name,
              subtitle: t.isRoute
                  ? l10n.ahRouteOption(
                      t.plate!,
                      t.contract ? l10n.msContract : l10n.tpOwnVehicle,
                      t.time ?? '',
                    )
                  : t.detail,
              onTap: () => Navigator.of(context).pop(t),
            ),
          ),
        const SizedBox(height: 2),
        _sheetNote(forTrip ? l10n.ahSheetNote : l10n.ahSheetNotePoint),
      ],
    );
  }
}

/// "Own vehicle" (blue) or "Contract" (pink) tag on a move target.
class MoveTargetTag extends StatelessWidget {
  const MoveTargetTag({super.key, required this.contract});

  final bool contract;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModuleTag(
      label: contract ? l10n.msContract : l10n.tpOwnVehicle,
      tone: contract ? ModuleTagTone.pink : ModuleTagTone.blue,
    );
  }
}

/// "No trips" illustration on a switched-off route, built from the Figma
/// layers so its label can be translated.
class NoTripsIllustration extends StatelessWidget {
  const NoTripsIllustration({super.key, required this.label});

  final String label;

  static const _w = 161.682;
  static const _h = 170.0;

  /// Figma insets (top, right, bottom, left) as fractions of the box.
  static Positioned _layer(
    String asset,
    double t,
    double r,
    double b,
    double l,
  ) => Positioned(
    left: l * _w,
    top: t * _h,
    width: (1 - l - r) * _w,
    height: (1 - t - b) * _h,
    child: SvgPicture.asset(
      asset,
      package: RouteActionsAssets.package,
      fit: BoxFit.fill,
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const Key('no-trips-illustration'),
    width: _w,
    height: _h,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        _layer(
          RouteActionsAssets.noTripsBackground,
          -.0608,
          .0645,
          -.0049,
          -.1216,
        ),
        _layer(RouteActionsAssets.noTripsWindow, .2173, .3344, .3399, -.041),
        _layer(RouteActionsAssets.noTripsWindowBar, .2173, .3344, .7283, -.041),
        _layer(RouteActionsAssets.noTripsDots, .2344, .3637, .7438, .5369),
        _layer(RouteActionsAssets.noTripsFolder, .3313, .5189, .4202, .1285),
        _layer(RouteActionsAssets.noTripsPlant, .6465, -.0011, -.0608, .7125),
        _layer(RouteActionsAssets.noTripsBubble, -.0543, .0948, .8451, .6651),
        _layer(RouteActionsAssets.noTripsBubbleCheck, 0, .1588, .9138, .7505),
        Positioned(
          left: .1815 * _w,
          top: .4412 * _h,
          width: (1 - .1815 - .5649) * _w + 20,
          child: Text(
            label,
            maxLines: 1,
            style: DriverTextStyles.medium12.copyWith(
              fontSize: 9.774,
              height: 12.217 / 9.774,
              color: DriverColors.neutral950,
            ),
          ),
        ),
      ],
    ),
  );
}
