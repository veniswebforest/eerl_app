import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/utils/module_date_format.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_choice_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_confirm_popup.dart';
import 'package:pickup_supervisor/core/widgets/module_date_range_sheet.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_mock_data.dart';
import 'package:pickup_supervisor/features/cash_payments/model/cash_payments_models.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_form_widgets.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_payments_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Pay a pickup point. Reference shows only for UPI or bank; the amount
/// can't be more than what is owed or the cash in hand.
class PayPointScreen extends StatelessWidget {
  const PayPointScreen({super.key, required this.point});

  final PickupPointToPay point;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _PayView(point: point));
}

class _PayView extends StatefulWidget {
  const _PayView({required this.point});

  final PickupPointToPay point;

  @override
  State<_PayView> createState() => _PayViewState();
}

class _PayViewState extends State<_PayView> {
  late final _amount = TextEditingController(
    text: moduleRupees(widget.point.owed).substring(1),
  );
  final _reference = TextEditingController();
  final _note = TextEditingController();
  late PayMethod _method = widget.point.method;
  late DateTime _paidOn = CashPaymentsMockData.today;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    _note.dispose();
    super.dispose();
  }

  int get _hold => CashPaymentsStore.cashInHand.value;
  int get _value => cashAmount(_amount.text);
  bool get _canRecord =>
      _value > 0 && _value <= widget.point.owed && _value <= _hold;

  /// Not more than what is owed or the cash in hand.
  String? _amountError(DriverLocalizations l10n) => _amount.text.trim().isEmpty
      ? l10n.vlRequired
      : ModuleValidators.rupees(
          l10n,
          _amount.text,
          required: true,
          max: widget.point.owed < _hold ? widget.point.owed : _hold,
          format: moduleRupees,
        );

  Future<void> _pickDate() async {
    final today = CashPaymentsMockData.today;
    final range = await showModuleDateRangeSheet(
      context,
      initialRange: DateTimeRange(start: _paidOn, end: _paidOn),
      lastDate: today,
      today: today,
      initialMonth: _paidOn,
    );
    if (range != null && mounted) setState(() => _paidOn = range.start);
  }

  Future<void> _record() async {
    final l10n = DriverLocalizations.of(context);
    final navigator = Navigator.of(context);
    final amount = _value;
    CashPaymentsStore.recordPayment(widget.point.name, amount);
    await showModulePopup<void>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: ModuleSuccessPopup(
          key: const Key('payment-recorded'),
          title: l10n.cpPaymentRecorded,
          message: l10n.cpPaymentRecordedBody(
            moduleRupees(amount),
            widget.point.name,
            moduleRupees(CashPaymentsStore.cashInHand.value),
          ),
          buttonLabel: l10n.cpBackToPoints,
        ),
      ),
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final p = widget.point;
    final date = l10n.dayMonthYear(_paidOn);
    return ModulePage(
      key: const Key('pay-point-screen'),
      bottom: Opacity(
        opacity: _canRecord ? 1 : .5,
        child: ModuleButton(
          key: const Key('pay-point-record'),
          label: l10n.cpRecordPayment,
          height: 52,
          onPressed: _canRecord ? _record : null,
        ),
      ),
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: [
          CashFormHeader(title: l10n.cpPayTitle(p.name)),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpAmountLabel, required: true),
          const SizedBox(height: 8),
          CashAmountField(
            controller: _amount,
            fieldKey: const Key('pay-point-amount'),
            errorText: _amountError(l10n),
          ),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpHowPaid, required: true),
          const SizedBox(height: 8),
          ModuleChoiceWrap<PayMethod>(
            keyPrefix: 'pay-method',
            compact: true,
            values: PayMethod.values,
            labelOf: (m) => switch (m) {
              PayMethod.cash => l10n.cpChipCash,
              PayMethod.upi => l10n.cpChipUpi,
              PayMethod.bank => l10n.cpChipBank,
            },
            isSelected: (m) => m == _method,
            onTap: (m) => setState(() => _method = m),
          ),
          if (_method != PayMethod.cash) ...[
            const SizedBox(height: 24),
            ModuleFieldLabel(l10n.cpReference),
            const SizedBox(height: 8),
            ModuleInputBox(
              controller: _reference,
              fieldKey: const Key('pay-point-reference'),
              // UPI / bank reference: letters and digits, up to 30.
              kind: ModuleInputKind.idNumber,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Za-z ]')),
                LengthLimitingTextInputFormatter(30),
              ],
              textInputAction: TextInputAction.next,
            ),
          ],
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpPaidOn, required: true),
          const SizedBox(height: 8),
          ModuleInputBox(
            fieldKey: const Key('pay-point-date'),
            value: DateUtils.isSameDay(_paidOn, CashPaymentsMockData.today)
                ? l10n.cpTodayDate(date)
                : date,
            trailing: cashIcon(CashPaymentsAssets.calendar, 20),
            onTap: _pickDate,
          ),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpReceiptPhoto),
          const SizedBox(height: 8),
          DriverCaptureArea(
            captureKey: const Key('pay-point-receipt'),
            label: l10n.dlCapturePhoto,
            icon: CashPaymentsAssets.camera,
            active: true,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.cpReceiptHint,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpNote),
          const SizedBox(height: 8),
          ModuleRemarksField(
            controller: _note,
            fieldKey: const Key('pay-point-note'),
            maxChars: 300,
            counterLabel: l10n.cpMaxChars(300),
          ),
          const SizedBox(height: 12),
          ModuleInfoNote.blue(
            message: l10n.cpPayInfo(moduleRupees(p.owed), moduleRupees(_hold)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
