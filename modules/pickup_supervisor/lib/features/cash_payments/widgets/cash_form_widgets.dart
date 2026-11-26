import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';

/// Whole rupees typed in an amount box ("1,250" → 1250).
int cashAmount(String text) =>
    int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Back button and a 20px title (Request cash, Pay …).
class CashFormHeader extends StatelessWidget {
  const CashFormHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

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
            if (subtitle != null)
              Text(
                subtitle!,
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

/// "₹ 1,250" box: digits and commas only.
class CashAmountField extends StatelessWidget {
  const CashAmountField({
    super.key,
    required this.controller,
    this.fieldKey,
    this.errorText,
  });

  final TextEditingController controller;
  final Key? fieldKey;
  final String? errorText;

  @override
  Widget build(BuildContext context) => ModuleInputBox(
    controller: controller,
    fieldKey: fieldKey,
    prefix: '₹ ',
    kind: ModuleInputKind.rupees,
    textInputAction: TextInputAction.next,
    errorText: errorText,
  );
}
