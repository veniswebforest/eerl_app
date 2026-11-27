import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_danger_button.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/stop_detail/model/stop_detail_models.dart';
import 'package:pickup_supervisor/features/stop_detail/widgets/stop_detail_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Skip Source form: reasons, remarks and a Confirm Skip button.
///
/// Pops with `true` when the skip is confirmed.
class SkipSourceScreen extends StatelessWidget {
  const SkipSourceScreen({
    super.key,
    required this.sourceName,
    this.initialReasons = const {},
    this.initialRemarks = '',
    this.duePickupId,
  });

  final String sourceName;
  final Set<SkipReason> initialReasons;
  final String initialRemarks;

  /// The live pickup; with a session, Confirm queues the skip.
  final String? duePickupId;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _SkipSourceView(
      duePickupId: duePickupId,
      sourceName: sourceName,
      initialReasons: initialReasons,
      initialRemarks: initialRemarks,
    ),
  );
}

class _SkipSourceView extends StatefulWidget {
  const _SkipSourceView({
    this.duePickupId,
    required this.sourceName,
    required this.initialReasons,
    required this.initialRemarks,
  });

  final String? duePickupId;
  final String sourceName;
  final Set<SkipReason> initialReasons;
  final String initialRemarks;

  @override
  State<_SkipSourceView> createState() => _SkipSourceViewState();
}

class _SkipSourceViewState extends State<_SkipSourceView> {
  static const _maxChars = 150;

  late final Set<SkipReason> _reasons = {...widget.initialReasons};
  late final TextEditingController _remarks = TextEditingController(
    text: widget.initialRemarks,
  );

  @override
  void initState() {
    super.initState();
    _remarks.addListener(() => setState(() {}));
  }

  static const _codes = {
    SkipReason.sourceClosed: 'SOURCE_CLOSED',
    SkipReason.holiday: 'HOLIDAY',
    SkipReason.sourceAsked: 'SOURCE_ASKED',
    SkipReason.vehicleUnavailable: 'VEHICLE_UNAVAILABLE',
    SkipReason.capacityFull: 'CAPACITY_FULL',
    SkipReason.notEnoughTime: 'NOT_ENOUGH_TIME',
    SkipReason.other: 'OTHER',
  };

  /// Live: queue the skip (outbound doc, Pickup Supervisor writes); it
  /// leaves its trip. Then pop `true` as the design does.
  Future<void> _confirm() async {
    final navigator = Navigator.of(context);
    final session = OutboundLiveSession.of(context);
    final id = widget.duePickupId;
    if (session != null && id != null) {
      try {
        final note = _remarks.text.trim();
        await session.change(
          () => session.writes.decidePickup(
            duePickupId: id,
            action: PickupDecision.skip,
            skipReasons: [
              for (final reason in SkipReason.values)
                if (_reasons.contains(reason)) _codes[reason]!,
            ],
            skipNote: note.isEmpty ? null : note,
          ),
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
    navigator.pop(true);
  }

  bool get _canConfirm =>
      _reasons.isNotEmpty &&
      (!_reasons.contains(SkipReason.other) || _remarks.text.trim().isNotEmpty);

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  String _label(DriverLocalizations l10n, SkipReason reason) =>
      switch (reason) {
        SkipReason.sourceClosed => l10n.skReasonClosed,
        SkipReason.holiday => l10n.skReasonHoliday,
        SkipReason.sourceAsked => l10n.skReasonSourceAsked,
        SkipReason.vehicleUnavailable => l10n.skReasonVehicle,
        SkipReason.capacityFull => l10n.skReasonCapacity,
        SkipReason.notEnoughTime => l10n.skReasonShift,
        SkipReason.other => l10n.skReasonOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      bottom: ModuleDangerButton(
        key: const Key('skip-source-confirm'),
        label: l10n.skConfirm,
        // One or more reasons; Other needs a note.
        onPressed: !_canConfirm ? null : _confirm,
      ),
      child: ListView(
        clipBehavior: Clip.none,
        key: const Key('skip-source-scroll'),
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              const ModuleBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.skTitle,
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SourceCard(name: widget.sourceName),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: l10n.skReasonLabel,
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: DriverColors.red600),
                ),
              ],
            ),
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          for (final reason in SkipReason.values) ...[
            _ReasonRow(
              key: Key('skip-reason-${reason.name}'),
              label: _label(l10n, reason),
              selected: _reasons.contains(reason),
              onTap: () => setState(() {
                if (!_reasons.add(reason)) _reasons.remove(reason);
              }),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          Text(
            l10n.skRemarks,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          ModuleRemarksField(
            controller: _remarks,
            maxChars: _maxChars,
            fieldKey: const Key('skip-remarks'),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DriverColors.primary100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: stopDetailIcon(StopDetailAssets.skipSource, 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: DriverColors.neutral50,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? DriverColors.red400 : DriverColors.cool400,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? DriverColors.red600 : DriverColors.neutral50,
                borderRadius: BorderRadius.circular(4),
                border: selected
                    ? null
                    : Border.all(color: const Color(0xFF888888)),
              ),
              child: selected
                  ? SvgPicture.asset(
                      StopDetailAssets.check,
                      package: StopDetailAssets.package,
                      width: 14,
                      height: 14,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: DriverTextStyles.regular14.copyWith(
                  color: DriverColors.neutral900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
