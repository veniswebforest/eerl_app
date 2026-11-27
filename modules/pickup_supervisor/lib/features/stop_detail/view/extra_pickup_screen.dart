import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_approval_widgets.dart';
import 'package:pickup_supervisor/features/stop_detail/widgets/stop_detail_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// "Add an extra pickup" for a 0 kg, missed or cancelled stop.
///
/// Static: due at once, no approval. Submitting shows "Extra pickup added";
/// "Back to the stop" closes the popup and this form.
class ExtraPickupScreen extends StatelessWidget {
  const ExtraPickupScreen({
    super.key,
    required this.stopName,
    required this.address,
    required this.time,
    required this.routeName,
    required this.initialDate,
    this.sourceId,
  });

  /// The live pickup point; with a session, Submit queues the extra pickup
  /// (due at once: the supervisor's own needs no approval).
  final String? sourceId;
  final String stopName;
  final String address;

  /// The stop's usual pickup window ("10 am – 12 pm").
  final String time;
  final String routeName;
  final DateTime initialDate;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _ExtraPickupView(screen: this));
}

class _ExtraPickupView extends StatefulWidget {
  const _ExtraPickupView({required this.screen});

  final ExtraPickupScreen screen;

  @override
  State<_ExtraPickupView> createState() => _ExtraPickupViewState();
}

class _ExtraPickupViewState extends State<_ExtraPickupView> {
  late DateTime _date = widget.screen.initialDate;
  final _amount = TextEditingController();
  final _remarks = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _remarks.dispose();
    super.dispose();
  }

  String _dateLabel(DriverLocalizations l10n) =>
      '${l10n.calWeekdayShort('${_date.weekday}')} ${l10n.dayMonth(_date)}';

  Future<void> _pickDate() async {
    final today = widget.screen.initialDate.subtract(const Duration(days: 1));
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: DateTimeRange(start: _date, end: _date),
      firstDate: today,
      today: today,
      initialMonth: _date,
      weekdayInSummary: true,
    );
    if (range != null && mounted) setState(() => _date = range.start);
  }

  Future<void> _submit() async {
    final l10n = DriverLocalizations.of(context);
    // The amount is optional, but a typed one must be valid.
    if (ModuleValidators.positiveDecimal(l10n, _amount.text) != null) return;
    FocusScope.of(context).unfocus();
    final s = widget.screen;
    final navigator = Navigator.of(context);
    final session = OutboundLiveSession.of(context);
    final sourceId = s.sourceId;
    if (session != null && sourceId != null) {
      final amount = double.tryParse(_amount.text.trim());
      final note = _remarks.text.trim();
      final day =
          '${_date.year.toString().padLeft(4, '0')}-'
          '${_date.month.toString().padLeft(2, '0')}-'
          '${_date.day.toString().padLeft(2, '0')}';
      try {
        await session.change(
          () => session.writes.addExtraPickup(
            id: session.newId(),
            sourceId: sourceId,
            date: day,
            asSupervisor: true,
            expectedQtyKg: amount,
            note: note.isEmpty ? null : note,
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
      if (!mounted) return;
    }
    await showModulePopup<void>(
      context,
      builder: (popupContext) => DriverLocalizationScope(
        child: ApprovalSuccessPopup(
          key: const Key('extra-pickup-added'),
          title: l10n.exAddedTitle,
          message: l10n.exAddedBody(
            s.stopName,
            _dateLabel(l10n),
            s.time,
            s.routeName,
          ),
          primaryLabel: l10n.exBackToStop,
          onPrimary: () {
            Navigator.of(popupContext).pop();
            navigator.pop(true);
          },
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: ModuleFieldLabel(text, required: required),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final s = widget.screen;
    return ModulePage(
      key: const Key('extra-pickup-screen'),
      bottom: ModuleButton(
        key: const Key('extra-pickup-submit'),
        label: l10n.exSubmit,
        onPressed: _submit,
      ),
      child: ListView(
        clipBehavior: Clip.none,
        key: const Key('extra-pickup-scroll'),
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              const ModuleBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.sxAddExtra,
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.exIntro(s.stopName, s.address),
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.slate600,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 24),
          _label(l10n.exDateLabel, required: true),
          ModuleInputBox(
            fieldKey: const Key('extra-pickup-date'),
            value: l10n.sdDueOn(_dateLabel(l10n), s.time),
            trailing: stopDetailIcon(StopDetailAssets.calendar, 24),
            onTap: _pickDate,
          ),
          const SizedBox(height: 16),
          _label(l10n.exAmountLabel),
          ModuleInputBox(
            fieldKey: const Key('extra-pickup-amount'),
            controller: _amount,
            kind: ModuleInputKind.decimal,
            textInputAction: TextInputAction.next,
            // Optional; when typed it must be more than 0 kg.
            errorText: ModuleValidators.positiveDecimal(l10n, _amount.text),
          ),
          const SizedBox(height: 16),
          _label(l10n.skRemarks),
          ModuleRemarksField(
            controller: _remarks,
            fieldKey: const Key('extra-pickup-remarks'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
