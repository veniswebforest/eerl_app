import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';

/// Two-segment switcher used for Driver/Labour, Today/Next 7 Days, List/Map.
class ModuleSegmentedSwitch extends StatelessWidget {
  const ModuleSegmentedSwitch({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.keyPrefix = 'module-switch',
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 2.5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                key: Key('$keyPrefix-$i'),
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: Container(
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? DriverColors.primary500
                        : DriverColors.neutral50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: i == selectedIndex
                        ? DriverTextStyles.bold14.copyWith(
                            color: DriverColors.neutral50,
                          )
                        : DriverTextStyles.medium14.copyWith(
                            color: DriverColors.neutral900,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
