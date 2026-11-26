import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_toast.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_flags.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/view/pickup_supervisor_routes_screen.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

export 'package:pickup_supervisor/features/pickup_supervisor/model/pickup_supervisor_flags.dart'
    show PickupSupervisorFlagDetailType;

const _assetRoot = 'assets/icons/supervisor/flags';
const _assetPackage = 'pickup_supervisor';
const _shadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
];

/// PS-M06 Flags (Home › Flags tile). Each card opens its flag; Mark done
/// takes it off the list with a toast. With no open flag it shows
/// "Nothing to check".
class PickupSupervisorFlagsScreen extends StatelessWidget {
  const PickupSupervisorFlagsScreen({super.key, this.showEmpty = false});

  final bool showEmpty;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _FlagsView(showEmpty: showEmpty));
}

class _FlagsView extends StatefulWidget {
  const _FlagsView({required this.showEmpty});

  final bool showEmpty;

  @override
  State<_FlagsView> createState() => _FlagsViewState();
}

class _FlagsViewState extends State<_FlagsView> {
  /// Flags marked done in this visit.
  final _done = <PickupSupervisorFlagDetailType>{};

  Future<void> _open(PickupFlag flag) async {
    final done = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PickupSupervisorFlagDetailScreen(type: flag.type),
      ),
    );
    if (done != true || !mounted) return;
    final l10n = DriverLocalizations.of(context);
    setState(() => _done.add(flag.type));
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.fgDoneTitle,
      message: l10n.fgDoneBody(flag.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final flags = widget.showEmpty
        ? const <PickupFlag>[]
        : PickupFlagsMockData.all(
            l10n,
          ).where((f) => !_done.contains(f.type)).toList();
    return Scaffold(
      key: Key(
        flags.isEmpty ? 'supervisor-flags-empty' : 'supervisor-flags-list',
      ),
      backgroundColor: DriverColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: _FlagsHeader(title: l10n.supervisorFlags),
                ),
                if (flags.isEmpty)
                  Expanded(child: _EmptyFlags(l10n: l10n))
                else
                  Expanded(
                    child: ListView.separated(
                      key: const Key('supervisor-flags-scroll'),
                      padding: EdgeInsets.fromLTRB(
                        20,
                        24,
                        20,
                        MediaQuery.paddingOf(context).bottom + 24,
                      ),
                      itemCount: flags.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 16),
                      itemBuilder: (_, i) => _FlagTile(
                        flag: flags[i],
                        onTap: () => _open(flags[i]),
                      ),
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

/// One flag: its "what happened" box, what to do, and Mark done. Pops with
/// `true` when the flag is marked done.
class PickupSupervisorFlagDetailScreen extends StatelessWidget {
  const PickupSupervisorFlagDetailScreen({super.key, required this.type});

  final PickupSupervisorFlagDetailType type;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: Builder(
      builder: (context) {
        final l10n = DriverLocalizations.of(context);
        final flag = PickupFlagsMockData.of(l10n, type);
        final actionLabel = switch (flag.action) {
          FlagAction.openRoutes => l10n.fgOpenRoutes,
          FlagAction.checkRoute => l10n.fgCheckRoute,
          FlagAction.addToRoute => l10n.fgAddToRoute,
        };
        return ModulePage(
          key: Key('supervisor-flag-detail-${type.name}'),
          bottom: Row(
            children: [
              Expanded(
                child: ModuleButton(
                  key: const Key('supervisor-flag-action'),
                  label: actionLabel,
                  variant: ModuleButtonVariant.outline,
                  height: 52,
                  // Static: every follow-up opens Routes.
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const PickupSupervisorRoutesScreen(
                        showBottomNavigation: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ModuleButton(
                  key: const Key('supervisor-flag-mark-done'),
                  label: l10n.flagMarkDone,
                  height: 52,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
          child: ListView(
            clipBehavior: Clip.none,
            padding: EdgeInsets.zero,
            children: [
              Row(
                children: [
                  const _FlagsBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      flag.title,
                      style: DriverTextStyles.semibold20.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _FlagPointCard(flag: flag),
              const SizedBox(height: 16),
              _WhatToDoCard(label: l10n.fgWhatToDo, text: flag.whatToDo),
              if (flag.closesByItself) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.fgClosesByItself,
                  style: DriverTextStyles.medium12.copyWith(
                    fontSize: 13,
                    color: DriverColors.slate600,
                  ),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    ),
  );
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

class _FlagTile extends StatelessWidget {
  const _FlagTile({required this.flag, required this.onTap});

  final PickupFlag flag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, tile) = flag.icon;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('supervisor-flag-${flag.type.name}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: tile,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SvgPicture.asset(
                        '$_assetRoot/$icon.svg',
                        package: _assetPackage,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flag.name,
                              style: DriverTextStyles.semibold16.copyWith(
                                color: DriverColors.neutral900,
                                height: 20 / 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              flag.summary,
                              style: DriverTextStyles.medium14.copyWith(
                                color: DriverColors.neutral700,
                                height: 20 / 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 15,
                right: 15,
                child: SvgPicture.asset(
                  '$_assetRoot/arrow_muted.svg',
                  package: _assetPackage,
                  width: 12,
                  height: 12,
                ),
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

/// White card: pickup point name, address and the grey "what happened" box.
class _FlagPointCard extends StatelessWidget {
  const _FlagPointCard({required this.flag});

  final PickupFlag flag;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          flag.name,
          style: DriverTextStyles.semibold18.copyWith(
            color: DriverColors.neutral900,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                '$_assetRoot/location.svg',
                package: _assetPackage,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                flag.address,
                style: DriverTextStyles.medium14.copyWith(
                  color: DriverColors.neutral700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          key: const Key('supervisor-flag-facts'),
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: DriverColors.cool100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, row) in flag.rows.indexed) ...[
                if (i > 0) const SizedBox(height: 12),
                _LabelValue(label: row.$1, value: row.$2),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: DriverTextStyles.medium12.copyWith(
          color: DriverColors.flagLabel,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: DriverTextStyles.semibold14.copyWith(
          color: DriverColors.neutral900,
        ),
      ),
    ],
  );
}

class _WhatToDoCard extends StatelessWidget {
  const _WhatToDoCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.flagLabel,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral900,
            height: 20 / 14,
          ),
        ),
      ],
    ),
  );
}
