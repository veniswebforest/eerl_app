import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_confirmation_dialog.dart';
import 'package:eerl_app/shared/widgets/app_labeled_dropdown.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';
import '../model/d2d_vehicle_item.dart';
import '../widgets/d2d_vehicle_card.dart';
import '../widgets/d2d_vehicle_details_card.dart';
import '../widgets/d2d_vehicle_form.dart';
import '../widgets/d2d_vehicle_message_banner.dart';
import '../widgets/d2d_vehicle_segmented_control.dart';

class D2dVehicleManagementScreen extends StatefulWidget {
  const D2dVehicleManagementScreen({super.key});

  @override
  State<D2dVehicleManagementScreen> createState() =>
      _D2dVehicleManagementScreenState();
}

class _D2dVehicleManagementScreenState
    extends State<D2dVehicleManagementScreen> {
  static const _vehicles = <D2dVehicleItem>[
    D2dVehicleItem(number: 'GJ-05-BX-1234', status: D2dVehicleStatus.active),
    D2dVehicleItem(number: 'GJ-05-AB-4567', status: D2dVehicleStatus.active),
    D2dVehicleItem(number: 'GJ-05-BX-7890', status: D2dVehicleStatus.active),
    D2dVehicleItem(
      number: 'GJ-05-BX-1234',
      status: D2dVehicleStatus.deactivated,
    ),
    D2dVehicleItem(
      number: 'GJ-05-AB-4567',
      status: D2dVehicleStatus.deactivated,
    ),
    D2dVehicleItem(
      number: 'GJ-05-BX-7890',
      status: D2dVehicleStatus.deactivated,
    ),
    D2dVehicleItem(
      number: 'GJ-05-BX-1546',
      status: D2dVehicleStatus.deactivated,
    ),
  ];

  final _searchController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  D2dVehicleStatus _status = D2dVehicleStatus.active;
  D2dVehicleItem? _selectedVehicle;
  int _selectedCenter = -1;
  bool _centerExpanded = false;
  bool _showForm = false;
  bool _editingForm = false;
  int _formCenter = -1;
  bool _formCenterExpanded = false;
  bool _showBanner = false;
  bool _bannerIsDeactivated = false;
  String _query = '';

  List<D2dVehicleItem> get _visibleVehicles {
    final query = _query.trim().toLowerCase();
    return _vehicles
        .where((vehicle) => vehicle.status == _status)
        .where(
          (vehicle) =>
              query.isEmpty || vehicle.number.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _vehicleNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _selectedVehicle == null && !_showForm,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      setState(() {
        if (_showForm) {
          _showForm = false;
        } else {
          _selectedVehicle = null;
        }
      });
    },
    child: _showForm
        ? _buildForm()
        : _selectedVehicle == null
        ? _buildList()
        : _buildDetails(),
  );

  List<String> _centerOptions(BuildContext context) => <String>[
    context.l10n.ragpickerCenterSurat,
    context.l10n.ragpickerCenterSuratEast,
    context.l10n.ragpickerCenterSuratWest,
    context.l10n.ragpickerCenterSuratSouth,
  ];

  void _openForm({required bool editing}) {
    setState(() {
      _editingForm = editing;
      _showForm = true;
      _formCenter = -1;
      _formCenterExpanded = false;
      _vehicleNumberController.text = editing
          ? _selectedVehicle?.number ?? 'GJ-05-BX-1234'
          : '';
    });
  }

  void _saveForm() {
    setState(() {
      _showForm = false;
      _selectedVehicle = null;
      _status = D2dVehicleStatus.active;
      _showBanner = true;
      _bannerIsDeactivated = false;
    });
  }

  Future<void> _confirmStatusChange(bool currentlyActive) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: context.l10n.ragpickerConfirmationTitle,
      message: currentlyActive
          ? context.l10n.d2dDeactivateConfirmation
          : context.l10n.d2dReactivateConfirmation,
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.ragpickerYes,
      confirmColor: currentlyActive ? AppColors.red500 : AppColors.primary500,
      dialogKey: const Key('d2d-vehicle-status-dialog'),
      cancelButtonKey: const Key('d2d-dialog-cancel'),
      confirmButtonKey: const Key('d2d-dialog-confirm'),
    );
    if (!mounted || !confirmed) return;

    setState(() {
      _selectedVehicle = null;
      _status = currentlyActive
          ? D2dVehicleStatus.deactivated
          : D2dVehicleStatus.active;
      _showBanner = true;
      _bannerIsDeactivated = currentlyActive;
    });
  }

  Widget _buildList() {
    final vehicles = _visibleVehicles;
    final centerOptions = _centerOptions(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList.list(
                          children: [
                            if (_showBanner) ...[
                              D2dVehicleMessageBanner(
                                deactivated: _bannerIsDeactivated,
                                onClose: () =>
                                    setState(() => _showBanner = false),
                              ),
                              const SizedBox(height: 8),
                            ] else ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: AppSquareBackButton(
                                  key: const Key('d2d-vehicle-back-button'),
                                  onTap: () => Navigator.of(context).maybePop(),
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                            Text(
                              context.l10n.d2dVehicleManagementTitle,
                              style: AppTextStyles.semiboldH6_20.copyWith(
                                color: AppColors.neutral950,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppLabeledDropdown(
                              label: context.l10n.d2dSelectTargetCenter,
                              hint: context.l10n.d2dSelectCenter,
                              options: centerOptions,
                              selectedIndex: _selectedCenter,
                              expanded: _centerExpanded,
                              selectorKey: const Key(
                                'd2d-vehicle-center-selector',
                              ),
                              optionsKey: const Key(
                                'd2d-vehicle-center-options',
                              ),
                              optionKeyPrefix: 'd2d-vehicle-center',
                              onToggle: () => setState(
                                () => _centerExpanded = !_centerExpanded,
                              ),
                              onSelected: (index) => setState(() {
                                _selectedCenter = index;
                                _centerExpanded = false;
                              }),
                            ),
                            const SizedBox(height: 16),
                            D2dVehicleSegmentedControl(
                              status: _status,
                              activeLabel: context.l10n.d2dVehicleActiveCount(
                                3,
                              ),
                              deactivatedLabel: context.l10n
                                  .d2dVehicleDeactivatedCount(5),
                              onChanged: (status) => setState(() {
                                _status = status;
                                _centerExpanded = false;
                              }),
                            ),
                            const SizedBox(height: 16),
                            _SearchField(
                              controller: _searchController,
                              hint: context.l10n.ragpickerSearchHint,
                              onChanged: (value) =>
                                  setState(() => _query = value),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        sliver: SliverList.separated(
                          itemCount: vehicles.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) => D2dVehicleCard(
                            item: vehicles[index],
                            activeLabel: context.l10n.ragpickerActive,
                            deactivatedLabel: context.l10n.ragpickerDeactivated,
                            onTap: () => setState(
                              () => _selectedVehicle = vehicles[index],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_status == D2dVehicleStatus.active)
                  _PrimaryBottomButton(
                    label: context.l10n.d2dAddVehicle,
                    onPressed: () => _openForm(editing: false),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final vehicle = _selectedVehicle!;
    final active = vehicle.status == D2dVehicleStatus.active;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppSquareBackButton(
                    key: const Key('d2d-vehicle-detail-back-button'),
                    onTap: () => setState(() => _selectedVehicle = null),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      Text(
                        active
                            ? context.l10n.d2dActivatedVehicleTitle
                            : context.l10n.d2dDeactivatedVehicleTitle,
                        style: AppTextStyles.semiboldH6_20.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 16),
                      D2dVehicleDetailsCard(
                        centerLabel: context.l10n.d2dCollectionCenter,
                        centerValue: context.l10n.ragpickerCenterSurat,
                        numberLabel: context.l10n.d2dVehicleNumber,
                        number: vehicle.number,
                      ),
                    ],
                  ),
                ),
                _DetailActions(
                  active: active,
                  deactivateLabel: context.l10n.deactivate,
                  reactivateLabel: context.l10n.ragpickerReactiveButton,
                  editLabel: context.l10n.edit,
                  onStatusTap: () => _confirmStatusChange(active),
                  onEdit: active ? () => _openForm(editing: true) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() => D2dVehicleForm(
    editing: _editingForm,
    numberController: _vehicleNumberController,
    centerOptions: _centerOptions(context),
    selectedCenter: _formCenter,
    centerExpanded: _formCenterExpanded,
    onCenterToggle: () =>
        setState(() => _formCenterExpanded = !_formCenterExpanded),
    onCenterSelected: (index) => setState(() {
      _formCenter = index;
      _formCenterExpanded = false;
    }),
    onBack: () => setState(() => _showForm = false),
    onCancel: () => setState(() => _showForm = false),
    onSave: _saveForm,
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      key: const Key('d2d-vehicle-search'),
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.regularB7_14,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.neutral500,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset(
            'assets/icons/tasks/search.svg',
            width: 24,
            height: 24,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

class _PrimaryBottomButton extends StatelessWidget {
  const _PrimaryBottomButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
    child: SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const Key('d2d-add-vehicle-button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.boldH7_16,
        ),
        child: Text(label),
      ),
    ),
  );
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.active,
    required this.deactivateLabel,
    required this.reactivateLabel,
    required this.editLabel,
    required this.onStatusTap,
    this.onEdit,
  });

  final bool active;
  final String deactivateLabel;
  final String reactivateLabel;
  final String editLabel;
  final VoidCallback onStatusTap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              key: const Key('d2d-vehicle-status-button'),
              onPressed: onStatusTap,
              icon: SvgPicture.asset(
                active
                    ? 'assets/icons/ragpicker_deactivate.svg'
                    : 'assets/icons/profile/sync_refresh.svg',
                width: 20,
                height: 20,
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: active
                    ? AppColors.red600
                    : AppColors.primary500,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.boldH7_16,
              ),
              label: Text(active ? deactivateLabel : reactivateLabel),
            ),
          ),
        ),
        if (onEdit != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: SvgPicture.asset(
                  'assets/icons/ragpicker_edit.svg',
                  width: 20,
                  height: 20,
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.boldH7_16,
                ),
                label: Text(editLabel),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
