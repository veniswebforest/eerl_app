import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/services/driver_photo_capture.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _iconRoot = 'assets/icons/supervisor/add_route';
const _assetPackage = 'pickup_supervisor';
const _fieldBorder = DriverColors.cool400;

class SupervisorAddRouteScreen extends StatefulWidget {
  const SupervisorAddRouteScreen({super.key});

  @override
  State<SupervisorAddRouteScreen> createState() =>
      _SupervisorAddRouteScreenState();
}

class _SupervisorAddRouteScreenState extends State<SupervisorAddRouteScreen> {
  final _routeNameController = TextEditingController();
  String? _warehouse;
  String? _shift;
  var _warehouseOpen = false;
  var _shiftOpen = false;

  @override
  void dispose() {
    _routeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final warehouses = [
            l10n.addRouteWarehouseAdajan,
            l10n.addRouteWarehouseVesu,
            l10n.addRouteWarehouseKatargam,
            l10n.addRouteWarehousePal,
            l10n.addRouteWarehouseUdhna,
          ];
          final shifts = [
            l10n.addRouteShiftMorningEarly,
            l10n.addRouteShiftMorningLate,
            l10n.addRouteShiftFullDay,
          ];
          final enabled =
              _routeNameController.text.trim().isNotEmpty &&
              _warehouse != null &&
              _shift != null;
          return _FlowScaffold(
            screenKey: const Key('supervisor-add-route-step-1'),
            bottom: _PrimaryButton(
              key: const Key('add-route-step1-continue'),
              label: l10n.addRouteContinue,
              enabled: enabled,
              showArrow: true,
              onPressed: () => _openStep2(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FlowBackButton(),
                const SizedBox(height: 24),
                _StepProgress(label: l10n.addRouteStep1, step: 1),
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteRouteName, required: true),
                const SizedBox(height: 8),
                _TextEntry(
                  key: const Key('add-route-name'),
                  controller: _routeNameController,
                  hint: l10n.addRouteRouteNameHint,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteWarehouse, required: true),
                const SizedBox(height: 8),
                _SelectionField(
                  key: const Key('add-route-warehouse'),
                  value: _warehouse,
                  hint: l10n.addRouteSelectWarehouse,
                  expanded: _warehouseOpen,
                  onTap: () => setState(() {
                    _warehouseOpen = !_warehouseOpen;
                    _shiftOpen = false;
                  }),
                ),
                if (_warehouseOpen)
                  _RadioOptions(
                    keyPrefix: 'warehouse-option',
                    items: warehouses,
                    selected: _warehouse,
                    onSelected: (value) => setState(() {
                      _warehouse = value;
                      _warehouseOpen = false;
                    }),
                  ),
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteShift, required: true),
                const SizedBox(height: 8),
                _SelectionField(
                  key: const Key('add-route-shift'),
                  value: _shift,
                  hint: l10n.addRouteSelectShift,
                  expanded: _shiftOpen,
                  onTap: () => setState(() {
                    _shiftOpen = !_shiftOpen;
                    _warehouseOpen = false;
                  }),
                ),
                if (_shiftOpen)
                  _RadioOptions(
                    keyPrefix: 'shift-option',
                    items: shifts,
                    selected: _shift,
                    onSelected: (value) => setState(() {
                      _shift = value;
                      _shiftOpen = false;
                    }),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openStep2(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => SupervisorAddRouteAssignmentScreen(
          routeName: _routeNameController.text.trim(),
          warehouse: _warehouse!,
          shift: _shift!,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }
}

class SupervisorAddRouteAssignmentScreen extends StatefulWidget {
  const SupervisorAddRouteAssignmentScreen({
    super.key,
    required this.routeName,
    required this.warehouse,
    required this.shift,
  });

  final String routeName;
  final String warehouse;
  final String shift;

  @override
  State<SupervisorAddRouteAssignmentScreen> createState() =>
      _SupervisorAddRouteAssignmentScreenState();
}

class _SupervisorAddRouteAssignmentScreenState
    extends State<SupervisorAddRouteAssignmentScreen> {
  final _driverController = TextEditingController();
  final _labourController = TextEditingController();
  _VehicleOption? _vehicle;
  String? _driver;
  String? _labour;
  var _driverOpen = false;
  var _labourOpen = false;
  var _driverSearch = '';
  var _labourSearch = '';
  final _deactivatedDrivers = <String>{};
  final _deactivatedLabours = <String>{};

  @override
  void dispose() {
    _driverController.dispose();
    _labourController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final drivers = <String>[
            l10n.addRouteDriverVikram,
            l10n.addRouteDriverSuresh,
            l10n.addRouteDriverMahesh,
            l10n.addRouteDriverRakesh,
            l10n.addRouteDriverAmit,
          ].where((name) => !_deactivatedDrivers.contains(name)).toList();
          final labours = <String>[
            l10n.addRouteLabourRavi,
            l10n.addRouteLabourRam,
            l10n.addRouteLabourRamesh,
            l10n.addRouteLabourArjun,
          ].where((name) => !_deactivatedLabours.contains(name)).toList();
          final enabled =
              _vehicle != null && _driver != null && _labour != null;
          return _FlowScaffold(
            screenKey: const Key('supervisor-add-route-step-2'),
            bottom: _PrimaryButton(
              key: const Key('add-route-step2-continue'),
              label: l10n.addRouteContinue,
              enabled: enabled,
              showArrow: true,
              onPressed: () => _openReview(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FlowBackButton(),
                const SizedBox(height: 24),
                _StepProgress(label: l10n.addRouteStep2, step: 2),
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteSelectVehicle, required: true),
                const SizedBox(height: 8),
                _SelectionField(
                  key: const Key('add-route-vehicle'),
                  value: _vehicle == null
                      ? null
                      : '${_vehicle!.number}  •  ${_vehicle!.shortType}',
                  hint: l10n.addRouteVehicleHint,
                  onTap: () => _showVehiclePicker(context, l10n),
                ),
                if (_vehicle != null) ...[
                  const SizedBox(height: 7),
                  Text(
                    l10n.addRouteCapacity,
                    style: DriverTextStyles.medium14.copyWith(
                      color: DriverColors.primary500,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteSelectDriver, required: true),
                const SizedBox(height: 8),
                _SearchSelectionField(
                  key: const Key('add-route-driver'),
                  controller: _driverController,
                  hint: l10n.addRouteDriverHint,
                  onTap: () => setState(() {
                    _driverOpen = true;
                    _labourOpen = false;
                  }),
                  onChanged: (value) => setState(() {
                    _driverSearch = value;
                    _driverOpen = true;
                  }),
                ),
                if (_driverOpen)
                  _PersonOptions(
                    keyPrefix: 'driver-option',
                    items: _filtered(drivers, _driverSearch),
                    selected: _driver,
                    emptyTitle: l10n.addRouteDriverNotFound,
                    emptyMessage: l10n.addRouteDriverNotFoundHint,
                    addLabel: l10n.addRouteAdd,
                    deactivateLabel: l10n.addRouteDeactivate,
                    onSelected: (value) => setState(() {
                      _driver = value;
                      _driverController.text = value;
                      _driverOpen = false;
                      _driverSearch = '';
                    }),
                    onAdd: () => _showAddPerson(context, driver: true),
                    onDeactivate: (value) => _showDeactivateDialog(
                      context,
                      person: value,
                      driver: true,
                    ),
                  ),
                const SizedBox(height: 24),
                _FieldLabel(label: l10n.addRouteSelectLabour, required: true),
                const SizedBox(height: 8),
                _SearchSelectionField(
                  key: const Key('add-route-labour'),
                  controller: _labourController,
                  hint: l10n.addRouteLabourHint,
                  onTap: () => setState(() {
                    _labourOpen = true;
                    _driverOpen = false;
                  }),
                  onChanged: (value) => setState(() {
                    _labourSearch = value;
                    _labourOpen = true;
                  }),
                ),
                if (_labourOpen)
                  _PersonOptions(
                    keyPrefix: 'labour-option',
                    items: _filtered(labours, _labourSearch),
                    selected: _labour,
                    emptyTitle: l10n.addRouteLabourNotFound,
                    emptyMessage: l10n.addRouteLabourNotFoundHint,
                    addLabel: l10n.addRouteAdd,
                    deactivateLabel: l10n.addRouteDeactivate,
                    onSelected: (value) => setState(() {
                      _labour = value;
                      _labourController.text = value;
                      _labourOpen = false;
                      _labourSearch = '';
                    }),
                    onAdd: () => _showAddPerson(context, driver: false),
                    onDeactivate: (value) => _showDeactivateDialog(
                      context,
                      person: value,
                      driver: false,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _filtered(List<String> values, String query) {
    if (query.trim().isEmpty) return values;
    return values
        .where((value) => value.toLowerCase().contains(query.toLowerCase()))
        .toList(growable: false);
  }

  Future<void> _showVehiclePicker(
    BuildContext context,
    DriverLocalizations l10n,
  ) async {
    final options = [
      _VehicleOption(
        number: l10n.addRouteVehicleCompany1001,
        type: l10n.addRouteCompanyTruck,
        shortType: l10n.addRouteCompanyTruck,
      ),
      _VehicleOption(
        number: l10n.addRouteVehicleCompany1234,
        type: l10n.addRouteCompanyTruck,
        shortType: l10n.addRouteCompanyTruck,
      ),
      _VehicleOption(
        number: l10n.addRouteVehicleRental1002,
        type: l10n.addRouteRentalShreeRam,
        shortType: l10n.addRouteRentalShreeRam,
        hired: true,
      ),
      _VehicleOption(
        number: l10n.addRouteVehicleRental1001,
        type: l10n.addRouteRentalKhodiyar,
        shortType: l10n.addRouteRentalKhodiyar,
        hired: true,
      ),
    ];
    final result = await showModalBottomSheet<_VehicleOption>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .6),
      isScrollControlled: true,
      builder: (_) =>
          DriverLocalizationScope(child: _VehiclePicker(options: options)),
    );
    if (result != null && mounted) {
      setState(() {
        _vehicle = result;
        _driver = null;
        _labour = null;
        _driverOpen = false;
        _labourOpen = false;
      });
    }
  }

  Future<void> _showAddPerson(
    BuildContext context, {
    required bool driver,
  }) async {
    final added = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) =>
          DriverLocalizationScope(child: _AddPersonDialog(driver: driver)),
    );
    if (added == true && context.mounted) {
      final l10n = DriverLocalizations.of(context);
      setState(() {
        if (driver) {
          _driver = l10n.addRouteDriverVikram;
          _driverController.text = _driver!;
          _driverSearch = '';
          _driverOpen = false;
        } else {
          _labour = l10n.addRouteLabourRavi;
          _labourController.text = _labour!;
          _labourSearch = '';
          _labourOpen = false;
        }
      });
    }
  }

  Future<void> _showDeactivateDialog(
    BuildContext context, {
    required String person,
    required bool driver,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .6),
      builder: (_) => const DriverLocalizationScope(child: _DeactivateDialog()),
    );
    if (confirmed == true && context.mounted) {
      setState(() {
        if (driver) {
          _deactivatedDrivers.add(person);
          if (_driver == person) {
            _driver = null;
            _driverController.clear();
          }
          _driverSearch = '';
          _driverOpen = true;
        } else {
          _deactivatedLabours.add(person);
          if (_labour == person) {
            _labour = null;
            _labourController.clear();
          }
          _labourSearch = '';
          _labourOpen = true;
        }
      });
    }
  }

  Future<void> _openReview(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => _SupervisorAddRouteReviewScreen(
          routeName: widget.routeName,
          warehouse: widget.warehouse,
          shift: widget.shift,
          vehicle: _vehicle!,
          driver: _driver!,
          labour: _labour!,
        ),
      ),
    );
    if (saved == true && context.mounted) Navigator.pop(context, true);
  }
}

class _SupervisorAddRouteReviewScreen extends StatelessWidget {
  const _SupervisorAddRouteReviewScreen({
    required this.routeName,
    required this.warehouse,
    required this.shift,
    required this.vehicle,
    required this.driver,
    required this.labour,
  });

  final String routeName;
  final String warehouse;
  final String shift;
  final _VehicleOption vehicle;
  final String driver;
  final String labour;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return _FlowScaffold(
            screenKey: const Key('supervisor-add-route-review'),
            bottom: _PrimaryButton(
              key: const Key('add-route-save'),
              label: l10n.addRouteAddToRoute,
              enabled: true,
              onPressed: () => Navigator.pop(context, true),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FlowBackButton(),
                const SizedBox(height: 24),
                _ReviewCard(label: l10n.addRouteRouteName, value: routeName),
                const SizedBox(height: 12),
                _ReviewCard(label: l10n.addRouteShift, value: shift),
                const SizedBox(height: 12),
                _ReviewCard(label: l10n.addRouteWarehouse, value: warehouse),
                const SizedBox(height: 12),
                _ReviewVehicleCard(
                  label: l10n.addRouteVehicleLabel,
                  vehicle: vehicle,
                  capacity: l10n.addRouteCapacity,
                ),
                const SizedBox(height: 12),
                _ReviewCard(label: l10n.addRouteDriverWord, value: driver),
                const SizedBox(height: 12),
                _ReviewCard(label: l10n.addRouteLabourWord, value: labour),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({
    required this.screenKey,
    required this.child,
    required this.bottom,
  });

  final Key screenKey;
  final Widget child;
  final Widget bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      backgroundColor: DriverColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: child,
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        child: bottom,
      ),
    );
  }
}

class _FlowBackButton extends StatelessWidget {
  const _FlowBackButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.primary500,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: const Key('add-route-back'),
        onTap: () => Navigator.maybePop(context),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SvgPicture.asset(
              '$_iconRoot/back.svg',
              package: _assetPackage,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.label, required this.step});

  final String label;
  final int step;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.neutral600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _ProgressSegment(active: true)),
            const SizedBox(width: 4),
            Expanded(child: _ProgressSegment(active: step == 2)),
          ],
        ),
      ],
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: active ? DriverColors.primary500 : DriverColors.cool300,
        borderRadius: BorderRadius.circular(25),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, this.required = false});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        children: required
            ? const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: DriverColors.red600),
                ),
              ]
            : const [],
      ),
      style: DriverTextStyles.medium14.copyWith(color: DriverColors.neutral950),
    );
  }
}

class _TextEntry extends StatelessWidget {
  const _TextEntry({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: DriverTextStyles.regular14.copyWith(
        color: DriverColors.neutral950,
      ),
      decoration: _inputDecoration(hint),
    );
  }
}

InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: DriverTextStyles.regular14.copyWith(
        color: DriverColors.cool500,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: DriverColors.neutral50,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      constraints: const BoxConstraints(minHeight: 55),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: DriverColors.primary500),
      ),
    );

class _SelectionField extends StatelessWidget {
  const _SelectionField({
    super.key,
    required this.value,
    required this.hint,
    required this.onTap,
    this.expanded = false,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: _fieldBorder),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value ?? hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.regular14.copyWith(
                    color: value == null
                        ? DriverColors.cool500
                        : DriverColors.neutral950,
                  ),
                ),
              ),
              Transform.rotate(
                angle: expanded ? -1.5708 : 1.5708,
                child: SvgPicture.asset(
                  '$_iconRoot/dropdown.svg',
                  package: _assetPackage,
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSelectionField extends StatelessWidget {
  const _SearchSelectionField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onTap,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onTap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: onTap,
      onChanged: onChanged,
      style: DriverTextStyles.regular14.copyWith(
        color: DriverColors.neutral950,
      ),
      decoration: _inputDecoration(
        hint,
        suffixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset(
            '$_iconRoot/search.svg',
            package: _assetPackage,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}

class _RadioOptions extends StatelessWidget {
  const _RadioOptions({
    required this.keyPrefix,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final String keyPrefix;
  final List<String> items;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        border: Border.all(color: _fieldBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: List.generate(
          items.length,
          (index) => InkWell(
            key: Key('$keyPrefix-$index'),
            onTap: () => onSelected(items[index]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _RadioMark(selected: selected == items[index]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[index],
                      style: DriverTextStyles.regular14.copyWith(
                        color: DriverColors.neutral950,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        border: Border.all(color: DriverColors.neutral400),
        shape: BoxShape.circle,
      ),
      child: selected
          ? const DecoratedBox(
              decoration: BoxDecoration(
                color: DriverColors.primary500,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

class _PersonOptions extends StatelessWidget {
  const _PersonOptions({
    required this.keyPrefix,
    required this.items,
    required this.selected,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.addLabel,
    required this.deactivateLabel,
    required this.onSelected,
    required this.onAdd,
    required this.onDeactivate,
  });

  final String keyPrefix;
  final List<String> items;
  final String? selected;
  final String emptyTitle;
  final String emptyMessage;
  final String addLabel;
  final String deactivateLabel;
  final ValueChanged<String> onSelected;
  final VoidCallback onAdd;
  final ValueChanged<String> onDeactivate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        border: Border.all(color: _fieldBorder),
        borderRadius: BorderRadius.circular(10),
      ),
      child: items.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    emptyTitle,
                    style: DriverTextStyles.semibold18.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    emptyMessage,
                    textAlign: TextAlign.center,
                    style: DriverTextStyles.regular14.copyWith(
                      color: DriverColors.neutral600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    key: Key('$keyPrefix-add'),
                    label: addLabel,
                    enabled: true,
                    leadingAsset: '$_iconRoot/add.svg',
                    onPressed: onAdd,
                  ),
                ],
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 205),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final value = items[index];
                  return Container(
                    color: selected == value ? DriverColors.red100 : null,
                    child: InkWell(
                      key: Key('$keyPrefix-$index'),
                      onTap: () => onSelected(value),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            _RadioMark(selected: selected == value),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                value,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: DriverTextStyles.regular14.copyWith(
                                  color: DriverColors.neutral950,
                                ),
                              ),
                            ),
                            PopupMenuButton<_PersonAction>(
                              key: Key('$keyPrefix-edit-$index'),
                              padding: EdgeInsets.zero,
                              tooltip: '',
                              position: PopupMenuPosition.over,
                              constraints: const BoxConstraints(),
                              menuPadding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: _fieldBorder),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onSelected: (action) {
                                if (action == _PersonAction.deactivate) {
                                  onDeactivate(value);
                                }
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem<_PersonAction>(
                                  key: Key('$keyPrefix-deactivate-$index'),
                                  value: _PersonAction.deactivate,
                                  height: 44,
                                  child: Text(
                                    deactivateLabel,
                                    style: DriverTextStyles.medium14.copyWith(
                                      color: DriverColors.red600,
                                    ),
                                  ),
                                ),
                              ],
                              child: SvgPicture.asset(
                                '$_iconRoot/edit.svg',
                                package: _assetPackage,
                                width: 20,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

enum _PersonAction { deactivate }

class _VehiclePicker extends StatelessWidget {
  const _VehiclePicker({required this.options});

  final List<_VehicleOption> options;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        decoration: const BoxDecoration(
          color: DriverColors.neutral50,
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: DriverColors.neutral200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              options.length,
              (index) => Padding(
                padding: EdgeInsets.only(
                  bottom: index == options.length - 1 ? 0 : 10,
                ),
                child: Material(
                  color: DriverColors.neutral50,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    key: Key('vehicle-option-$index'),
                    onTap: () => Navigator.pop(context, options[index]),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: _fieldBorder),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: options[index].hired
                                  ? DriverColors.orangeLight
                                  : DriverColors.primary100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: SvgPicture.asset(
                              options[index].hired
                                  ? '$_iconRoot/truck_rental.svg'
                                  : '$_iconRoot/truck_company.svg',
                              package: _assetPackage,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  options[index].number,
                                  style: DriverTextStyles.semibold14.copyWith(
                                    color: DriverColors.neutral950,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  options[index].type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: DriverTextStyles.regular14.copyWith(
                                    color: DriverColors.neutral950,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPersonDialog extends StatefulWidget {
  const _AddPersonDialog({required this.driver});

  final bool driver;

  @override
  State<_AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<_AddPersonDialog> {
  static const _driverPhotoRecoveryId = 'supervisor.route.add_driver';

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  XFile? _photo;
  var _restoredPhoto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.driver || _restoredPhoto) return;
    _restoredPhoto = true;
    unawaited(_restorePhoto());
  }

  Future<void> _restorePhoto() async {
    final recover = DriverPhotoCaptureScope.of(context).recover;
    if (recover == null) return;
    final photo = await recover(_driverPhotoRecoveryId);
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  Future<void> _capturePhoto() async {
    final l10n = DriverLocalizations.of(context);
    final photo = await DriverPhotoCaptureScope.of(context).capture(
      context,
      recoveryId: _driverPhotoRecoveryId,
      title: l10n.addRouteCapturePhoto,
    );
    if (photo != null && mounted) setState(() => _photo = photo);
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() != true) return;
    Navigator.pop(context, true);
  }

  String? _validateName(String? value, DriverLocalizations l10n) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return l10n.addRouteFullNameRequired;
    if (name.length < 2) return l10n.addRouteFullNameMinLength;
    return null;
  }

  String? _validateMobile(String? value, DriverLocalizations l10n) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) {
      return widget.driver ? l10n.addRouteMobileRequired : null;
    }
    return RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)
        ? null
        : l10n.addRouteMobileInvalid;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Dialog(
      key: Key(widget.driver ? 'add-driver-dialog' : 'add-labour-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 335,
          maxHeight: MediaQuery.sizeOf(context).height - 40,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            24,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: l10n.addRouteAddNewDriverPrefix,
                    children: [
                      TextSpan(
                        text: widget.driver
                            ? l10n.addRouteDriverWord
                            : l10n.addRouteLabourWord,
                        style: const TextStyle(color: DriverColors.primary500),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.bold24.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _FieldLabel(
                    label: l10n.addRouteFullName,
                    required: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  key: const Key('add-person-name'),
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  maxLength: 255,
                  buildCounter: _hideCounter,
                  validator: (value) => _validateName(value, l10n),
                  decoration: _inputDecoration(l10n.addRouteFullNameHint),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _FieldLabel(
                    label: l10n.addRouteMobileNumber,
                    required: widget.driver,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 55,
                      width: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: _fieldBorder),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.addRouteCountryCode,
                        style: DriverTextStyles.regular14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextFormField(
                        key: const Key('add-person-mobile'),
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) => _validateMobile(value, l10n),
                        decoration: _inputDecoration(
                          l10n.addRouteMobileNumberHint,
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.driver) ...[
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _FieldLabel(label: l10n.addRouteAadhaarNumber),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    key: const Key('add-person-id-number'),
                    controller: _aadhaarController,
                    maxLength: 100,
                    buildCounter: _hideCounter,
                    decoration: _inputDecoration(l10n.addRouteAadhaarHint),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _FieldLabel(label: l10n.addRouteProfileProof),
                  ),
                  const SizedBox(height: 8),
                  _DriverPhotoField(
                    photo: _photo,
                    label: l10n.addRouteCapturePhoto,
                    onCapture: _capturePhoto,
                    onRemove: () => setState(() => _photo = null),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.addRoutePhotoHint,
                      style: DriverTextStyles.regular12.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _DialogActions(
                  cancelLabel: l10n.addRouteCancel,
                  saveLabel: l10n.addRouteSaveSelect,
                  onCancel: () => Navigator.pop(context, false),
                  onSave: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _hideCounter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) => null;
}

class _DriverPhotoField extends StatelessWidget {
  const _DriverPhotoField({
    required this.photo,
    required this.label,
    required this.onCapture,
    required this.onRemove,
  });

  final XFile? photo;
  final String label;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.primary50,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        key: const Key('add-driver-capture-photo'),
        onTap: onCapture,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 82,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: DriverColors.primary500),
            borderRadius: BorderRadius.circular(10),
          ),
          child: photo == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      '$_iconRoot/camera.svg',
                      package: _assetPackage,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: DriverTextStyles.semibold14.copyWith(
                        color: DriverColors.neutral900,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(photo!.path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Center(
                          child: SvgPicture.asset(
                            '$_iconRoot/camera.svg',
                            package: _assetPackage,
                            width: 28,
                            height: 28,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: InkResponse(
                          key: const Key('remove-driver-photo'),
                          onTap: onRemove,
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: DriverColors.neutral50,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  const _DialogActions({
    required this.cancelLabel,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 270;
        final cancel = _SecondaryButton(
          label: cancelLabel,
          onPressed: onCancel,
        );
        final save = _PrimaryButton(
          key: const Key('save-add-person'),
          label: saveLabel,
          enabled: true,
          onPressed: onSave,
        );
        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [save, const SizedBox(height: 10), cancel],
          );
        }
        return Row(
          children: [
            Expanded(child: cancel),
            const SizedBox(width: 12),
            Expanded(child: save),
          ],
        );
      },
    );
  }
}

class _DeactivateDialog extends StatelessWidget {
  const _DeactivateDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Dialog(
      key: const Key('deactivate-person-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.addRouteDeactivateTitle,
              style: DriverTextStyles.bold24.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addRouteDeactivateMessage,
              textAlign: TextAlign.center,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral600,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    label: l10n.addRouteCancel,
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      key: const Key('confirm-deactivate'),
                      onPressed: () => Navigator.pop(context, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: DriverColors.red500,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.addRouteYes,
                        style: DriverTextStyles.bold16.copyWith(
                          color: DriverColors.neutral50,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.cool600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewVehicleCard extends StatelessWidget {
  const _ReviewVehicleCard({
    required this.label,
    required this.vehicle,
    required this.capacity,
  });

  final String label;
  final _VehicleOption vehicle;
  final String capacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: DriverColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.cool600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SvgPicture.asset(
                '$_iconRoot/truck_review.svg',
                package: _assetPackage,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${vehicle.number}  (${vehicle.shortType})',
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SvgPicture.asset(
                '$_iconRoot/capacity.svg',
                package: _assetPackage,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Text(
                capacity,
                style: DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.showArrow = false,
    this.leadingAsset,
  });

  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  final bool showArrow;
  final String? leadingAsset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: enabled ? onPressed : null,
        style: FilledButton.styleFrom(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 2),
          backgroundColor: DriverColors.primary500,
          disabledBackgroundColor: DriverColors.neutral400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leadingAsset != null) ...[
              SvgPicture.asset(
                leadingAsset!,
                package: _assetPackage,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: DriverTextStyles.bold16.copyWith(
                  color: DriverColors.neutral50,
                ),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              SvgPicture.asset(
                '$_iconRoot/forward.svg',
                package: _assetPackage,
                width: 20,
                height: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DriverColors.cool200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: DriverTextStyles.semibold16.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
      ),
    );
  }
}

class _VehicleOption {
  const _VehicleOption({
    required this.number,
    required this.type,
    required this.shortType,
    this.hired = false,
  });
  final String number;
  final String type;
  final String shortType;
  final bool hired;
}
