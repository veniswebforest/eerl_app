import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/widgets/module_segmented_switch.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_mock_data.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_detail_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_form_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_directory_widgets.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M05 Driver & Labour Directory (drawer → Drivers & Labour).
class DriverLabourDirectoryScreen extends StatelessWidget {
  const DriverLabourDirectoryScreen({
    super.key,
    this.initialKind = DriverLabourKind.driver,
    this.initialShowActive = true,
  });

  final DriverLabourKind initialKind;
  final bool initialShowActive;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _DirectoryView(
      initialKind: initialKind,
      initialShowActive: initialShowActive,
    ),
  );
}

class _DirectoryView extends StatefulWidget {
  const _DirectoryView({
    required this.initialKind,
    required this.initialShowActive,
  });

  final DriverLabourKind initialKind;
  final bool initialShowActive;

  @override
  State<_DirectoryView> createState() => _DirectoryViewState();
}

class _DirectoryViewState extends State<_DirectoryView> {
  late DriverLabourKind _kind = widget.initialKind;
  late bool _showActive = widget.initialShowActive;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final query = _search.text.trim().toLowerCase();
    final people = DriverLabourMockData.peopleFor(_kind, active: _showActive)
        .where((p) => query.isEmpty || p.name.toLowerCase().contains(query))
        .toList(growable: false);
    final isDriver = _kind == DriverLabourKind.driver;
    final showAdd = _showActive || people.isEmpty;

    return ModulePage(
      bottom: showAdd
          ? DriverPrimaryButton(
              key: const Key('driver-labour-add'),
              radius: 12,
              label: isDriver
                  ? l10n.dlAddDriver
                  : people.isEmpty
                  ? l10n.dlAddLabourer
                  : l10n.dlAddLabour,
              onPressed: () => _open(DriverLabourFormScreen(kind: _kind)),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const ModuleBackButton(),
              DriverLabourFilterDropdown(
                activeLabel: l10n.dlFilterActive,
                inactiveLabel: l10n.dlFilterInactive,
                showActive: _showActive,
                onChanged: (value) => setState(() => _showActive = value),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            isDriver ? l10n.dlDriverDirectory : l10n.dlLabourDirectory,
            style: DriverTextStyles.semibold20.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 24),
          ModuleSegmentedSwitch(
            keyPrefix: 'driver-labour-tab',
            labels: [
              l10n.dlTabDrivers(DriverLabourMockData.driverCount),
              l10n.dlTabLabour(DriverLabourMockData.labourCount),
            ],
            selectedIndex: isDriver ? 0 : 1,
            onChanged: (index) => setState(
              () => _kind = index == 0
                  ? DriverLabourKind.driver
                  : DriverLabourKind.labour,
            ),
          ),
          const SizedBox(height: 24),
          DriverLabourSearchField(
            hint: l10n.dlSearchHint,
            controller: _search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: people.isEmpty
                ? DriverLabourEmptyState(message: l10n.dlNoDetailsFound)
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: people.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (_, index) {
                      final person = people[index];
                      return DriverLabourPersonCard(
                        key: Key('driver-labour-person-$index'),
                        name: person.name,
                        phone: person.phone ?? l10n.dlNoPhone,
                        inactive: !person.active,
                        onTap: () =>
                            _open(DriverLabourDetailScreen(person: person)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
