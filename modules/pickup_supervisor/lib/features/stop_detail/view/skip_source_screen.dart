import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_danger_button.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
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
  });

  final String sourceName;
  final Set<SkipReason> initialReasons;
  final String initialRemarks;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _SkipSourceView(
      sourceName: sourceName,
      initialReasons: initialReasons,
      initialRemarks: initialRemarks,
    ),
  );
}

class _SkipSourceView extends StatefulWidget {
  const _SkipSourceView({
    required this.sourceName,
    required this.initialReasons,
    required this.initialRemarks,
  });

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
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  String _label(DriverLocalizations l10n, SkipReason reason) =>
      switch (reason) {
        SkipReason.sourceClosed => l10n.skReasonClosed,
        SkipReason.holiday => l10n.skReasonHoliday,
        SkipReason.vehicleUnavailable => l10n.skReasonVehicle,
        SkipReason.other => l10n.skReasonOther,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      bottom: ModuleDangerButton(
        key: const Key('skip-source-confirm'),
        label: l10n.skConfirm,
        onPressed: _reasons.isEmpty
            ? null
            : () => Navigator.of(context).pop(true),
      ),
      child: ListView(
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
          _RemarksField(controller: _remarks, maxChars: _maxChars),
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

class _RemarksField extends StatelessWidget {
  const _RemarksField({required this.controller, required this.maxChars});

  final TextEditingController controller;
  final int maxChars;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      height: 159,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DriverColors.cool400),
      ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              key: const Key('skip-remarks'),
              controller: controller,
              maxLength: maxChars,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral900,
              ),
              decoration: const InputDecoration(
                isDense: true,
                filled: false,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              l10n.skMaxChars,
              style: DriverTextStyles.regular12.copyWith(
                color: const Color(0xFF888888),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
