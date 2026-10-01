import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/d2d_vehicle_item.dart';

class D2dVehicleSegmentedControl extends StatelessWidget {
  const D2dVehicleSegmentedControl({
    super.key,
    required this.status,
    required this.activeLabel,
    required this.deactivatedLabel,
    required this.onChanged,
  });

  final D2dVehicleStatus status;
  final String activeLabel;
  final String deactivatedLabel;
  final ValueChanged<D2dVehicleStatus> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 52,
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: _Tab(
            key: const Key('d2d-vehicle-active-tab'),
            label: activeLabel,
            selected: status == D2dVehicleStatus.active,
            onTap: () => onChanged(D2dVehicleStatus.active),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _Tab(
            key: const Key('d2d-vehicle-deactivated-tab'),
            label: deactivatedLabel,
            selected: status == D2dVehicleStatus.deactivated,
            onTap: () => onChanged(D2dVehicleStatus.deactivated),
          ),
        ),
      ],
    ),
  );
}

class _Tab extends StatelessWidget {
  const _Tab({
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
    color: selected ? AppColors.primary500 : Colors.transparent,
    borderRadius: BorderRadius.circular(9),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: selected ? Colors.white : AppColors.neutral700,
          ),
        ),
      ),
    ),
  );
}
