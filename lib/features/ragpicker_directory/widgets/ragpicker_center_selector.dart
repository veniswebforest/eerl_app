import 'package:flutter/material.dart';

import 'package:eerl_app/shared/widgets/app_labeled_dropdown.dart';

class RagpickerCenterSelector extends StatelessWidget {
  const RagpickerCenterSelector({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    required this.selectedIndex,
    required this.expanded,
    required this.onToggle,
    required this.onSelected,
    this.requiredField = false,
  });

  final String label;
  final String hint;
  final List<String> options;
  final int selectedIndex;
  final bool expanded;
  final bool requiredField;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => AppLabeledDropdown(
    label: label,
    hint: hint,
    options: options,
    selectedIndex: selectedIndex,
    expanded: expanded,
    requiredField: requiredField,
    selectorKey: const Key('ragpicker-center-selector'),
    optionsKey: const Key('ragpicker-center-options'),
    optionKeyPrefix: 'ragpicker-center',
    onToggle: onToggle,
    onSelected: onSelected,
  );
}
