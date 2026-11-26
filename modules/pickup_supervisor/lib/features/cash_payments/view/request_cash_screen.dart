import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/utils/module_money.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_confirm_popup.dart';
import 'package:pickup_supervisor/core/widgets/module_info_note.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/features/cash_payments/widgets/cash_form_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Request cash: amount and reason; the office approves it in the web panel.
class RequestCashScreen extends StatelessWidget {
  const RequestCashScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const DriverLocalizationScope(child: _RequestView());
}

class _RequestView extends StatefulWidget {
  const _RequestView();

  @override
  State<_RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<_RequestView> {
  final _amount = TextEditingController();
  final _reason = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
    _reason.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    _reason.dispose();
    super.dispose();
  }

  int get _value => cashAmount(_amount.text);
  bool get _canSend => _value > 0 && _reason.text.trim().isNotEmpty;

  /// Shown once something is typed, so a "0" says why Send stays off.
  String? _amountError(DriverLocalizations l10n) => _amount.text.trim().isEmpty
      ? null
      : ModuleValidators.rupees(l10n, _amount.text, format: moduleRupees);

  Future<void> _send() async {
    final l10n = DriverLocalizations.of(context);
    final navigator = Navigator.of(context);
    await showModulePopup<void>(
      context,
      builder: (_) => DriverLocalizationScope(
        child: ModuleSuccessPopup(
          key: const Key('request-cash-sent'),
          title: l10n.cpRequestSent,
          message: l10n.cpRequestSentBody(moduleRupees(_value)),
          buttonLabel: l10n.cpBackToCash,
        ),
      ),
    );
    if (mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      key: const Key('request-cash-screen'),
      bottom: Opacity(
        opacity: _canSend ? 1 : .5,
        child: ModuleButton(
          key: const Key('request-cash-send'),
          label: l10n.cpSendRequest,
          height: 52,
          onPressed: _canSend ? _send : null,
        ),
      ),
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: [
          CashFormHeader(title: l10n.cpRequestCash),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpAmountLabel, required: true),
          const SizedBox(height: 8),
          CashAmountField(
            controller: _amount,
            fieldKey: const Key('request-cash-amount'),
            errorText: _amountError(l10n),
          ),
          const SizedBox(height: 24),
          ModuleFieldLabel(l10n.cpReason, required: true),
          const SizedBox(height: 8),
          ModuleRemarksField(
            controller: _reason,
            fieldKey: const Key('request-cash-reason'),
            maxChars: 300,
            counterLabel: l10n.cpMaxChars(300),
          ),
          const SizedBox(height: 12),
          ModuleInfoNote.blue(message: l10n.cpRequestInfo),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
