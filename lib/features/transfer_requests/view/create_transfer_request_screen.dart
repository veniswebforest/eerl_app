import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../model/create_transfer_request_view.dart';
import '../model/transfer_destination.dart';
import '../widgets/transfer_destination_card.dart';
import '../widgets/transfer_material_card.dart';
import '../widgets/transfer_request_success_dialog.dart';

class CreateTransferRequestScreen extends StatefulWidget {
  const CreateTransferRequestScreen({
    super.key,
    required this.onBack,
    required this.onBackToList,
    this.initialView = CreateTransferRequestView.items,
  });

  final VoidCallback onBack;
  final VoidCallback onBackToList;
  final CreateTransferRequestView initialView;

  @override
  State<CreateTransferRequestScreen> createState() =>
      _CreateTransferRequestScreenState();
}

class _CreateTransferRequestScreenState
    extends State<CreateTransferRequestScreen> {
  late CreateTransferRequestView _view = widget.initialView;
  late final TextEditingController _totalController;
  late final TextEditingController _plateController;
  late final TextEditingController _capacityController;
  int _selectedMaterial = 0;
  int _selectedDestination = 0;
  String? _vehicleType;
  bool _vehicleTypeOpen = false;
  bool _managerArrangesVehicle = false;
  bool _showStockError = false;

  @override
  void initState() {
    super.initState();
    final errorState = widget.initialView == CreateTransferRequestView.error;
    _totalController = TextEditingController(
      text: errorState ? '27000.00' : '',
    );
    _plateController = TextEditingController(
      text: errorState ? 'GJ-05-BX-1234' : '',
    );
    _capacityController = TextEditingController(text: errorState ? '3000' : '');
    _vehicleType = errorState ? 'truck' : null;
    _showStockError = errorState;
    _managerArrangesVehicle = errorState;
    if (_view == CreateTransferRequestView.error) {
      _view = CreateTransferRequestView.items;
    }
  }

  @override
  void didUpdateWidget(covariant CreateTransferRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialView != widget.initialView) {
      _view = widget.initialView == CreateTransferRequestView.error
          ? CreateTransferRequestView.items
          : widget.initialView;
      _showStockError = widget.initialView == CreateTransferRequestView.error;
    }
  }

  @override
  void dispose() {
    _totalController.dispose();
    _plateController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_view == CreateTransferRequestView.destination) {
      setState(() => _view = CreateTransferRequestView.items);
      return;
    }
    widget.onBack();
  }

  void _continue() {
    final total = double.tryParse(_totalController.text.trim()) ?? 0;
    if (total > 1200.60) {
      setState(() => _showStockError = true);
      return;
    }
    setState(() {
      _showStockError = false;
      _view = CreateTransferRequestView.destination;
    });
  }

  Future<void> _submit() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (dialogContext) => TransferRequestSuccessDialog(
        onBackToList: () {
          Navigator.of(dialogContext).pop();
          widget.onBackToList();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    appBar: CustomAppBar(
      title: _view == CreateTransferRequestView.destination
          ? context.l10n.transferSelectDestination
          : null,
      onBackTap: _handleBack,
      backIconAsset: 'assets/icons/records/back.svg',
    ),
    body: SafeArea(
      top: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _view == CreateTransferRequestView.destination
              ? _destinationStep(context)
              : _itemsStep(context),
        ),
      ),
    ),
  );

  Widget _itemsStep(BuildContext context) {
    final materials = [
      (
        context.l10n.configurePetBottles,
        context.l10n.transferCapacity('1200.60 KG'),
      ),
      (
        context.l10n.transferPlasticWaste,
        context.l10n.transferCapacity('950.60 KG'),
      ),
      (
        context.l10n.configureMilkPouch,
        context.l10n.transferCapacity('800.60 KG'),
      ),
      (
        context.l10n.configurePaperCardboard,
        context.l10n.transferCapacity('1200.60 KG'),
      ),
      (
        context.l10n.transferToyWaste,
        context.l10n.transferCapacity('650.00 KG'),
      ),
      (
        context.l10n.configureMetals,
        context.l10n.transferCapacity('480.00 KG'),
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: const Key('create-transfer-scroll'),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.transferSelectItemsTitle,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  context.l10n.transferSelectItemsSubtitle,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 18),
                _SearchField(hint: context.l10n.transferSearchHint),
                const SizedBox(height: 16),
                for (var index = 0; index < materials.length; index++) ...[
                  TransferMaterialCard(
                    key: Key('transfer-material-$index'),
                    name: materials[index].$1,
                    capacity: materials[index].$2,
                    selected: _selectedMaterial == index,
                    onTap: () => setState(() => _selectedMaterial = index),
                    child: _materialForm(context),
                  ),
                  if (index != materials.length - 1) const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
        _BottomAction(
          weight: context.l10n.transferSelectedWeight,
          price: context.l10n.transferSelectedPrice,
          buttonLabel: context.l10n.transferContinue,
          enabled: !_showStockError,
          buttonKey: const Key('transfer-continue'),
          onPressed: _continue,
        ),
      ],
    );
  }

  Widget _materialForm(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _TransferField(
        key: const Key('transfer-total-kg'),
        label: context.l10n.transferTotalKgLabel,
        hint: context.l10n.transferTotalKgHint,
        controller: _totalController,
        prefix: context.l10n.transferKgPrefix,
        errorText: _showStockError
            ? context.l10n.transferStockValidation
            : null,
        keyboardType: TextInputType.number,
        onChanged: (_) {
          if (_showStockError) setState(() => _showStockError = false);
        },
      ),
      const SizedBox(height: 14),
      _TransferField(
        label: context.l10n.transferVehiclePlateLabel,
        hint: context.l10n.transferVehiclePlateHint,
        controller: _plateController,
      ),
      const SizedBox(height: 14),
      Text(
        context.l10n.transferVehicleTypeLabel,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      _VehicleTypeSelector(
        selectedValue: _vehicleType,
        open: _vehicleTypeOpen,
        labelFor: (value) => _vehicleTypeLabel(context, value),
        hint: context.l10n.transferVehicleTypeHint,
        onToggle: () => setState(() => _vehicleTypeOpen = !_vehicleTypeOpen),
        onSelected: (value) => setState(() {
          _vehicleType = value;
          _vehicleTypeOpen = false;
        }),
      ),
      const SizedBox(height: 14),
      _TransferField(
        label: context.l10n.transferVehicleCapacityLabel,
        hint: context.l10n.transferVehicleCapacityHint,
        controller: _capacityController,
        prefix: _capacityController.text.isEmpty
            ? null
            : context.l10n.transferKgPrefix,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 12),
      _ManagerArrangeOption(
        selected: _managerArrangesVehicle,
        label: context.l10n.transferManagerArrangeVehicle,
        onTap: () =>
            setState(() => _managerArrangesVehicle = !_managerArrangesVehicle),
      ),
    ],
  );

  Widget _destinationStep(BuildContext context) {
    final destinations = [
      TransferDestination(
        name: context.l10n.transferDestinationCityHub,
        address: context.l10n.transferDestinationCityAddress,
      ),
      TransferDestination(
        name: context.l10n.transferDestinationHighway,
        address: context.l10n.transferDestinationHighwayAddress,
      ),
      TransferDestination(
        name: context.l10n.transferDestinationApex,
        address: context.l10n.transferDestinationApexAddress,
      ),
      TransferDestination(
        name: context.l10n.transferDestinationSouthside,
        address: context.l10n.transferDestinationSouthsideAddress,
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.transferSelectDestination,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 14),
                _CurrentLocationCard(
                  name: context.l10n.transferCurrentFacility,
                  subtitle: context.l10n.transferFromCurrentLocation,
                ),
                const SizedBox(height: 22),
                Text(
                  context.l10n.transferDestinationQuestion,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 12),
                for (var index = 0; index < destinations.length; index++) ...[
                  TransferDestinationCard(
                    key: Key('transfer-destination-$index'),
                    destination: destinations[index],
                    selected: _selectedDestination == index,
                    onTap: () => setState(() => _selectedDestination = index),
                  ),
                  if (index != destinations.length - 1)
                    const SizedBox(height: 12),
                ],
                const SizedBox(height: 14),
                Text(
                  context.l10n.transferManagerApprovalNote,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ),
        _BottomAction(
          weight: context.l10n.transferSelectedWeight,
          price: context.l10n.transferSelectedPrice,
          buttonLabel: context.l10n.transferSubmitRequest,
          buttonKey: const Key('transfer-submit-request'),
          onPressed: _submit,
        ),
      ],
    );
  }

  String _vehicleTypeLabel(BuildContext context, String value) =>
      switch (value) {
        'truck' => context.l10n.transferVehicleTruck,
        'miniTruck' => context.l10n.transferVehicleMiniTruck,
        'pickupTruck' => context.l10n.transferVehiclePickupTruck,
        'tempo' => context.l10n.transferVehicleTempo,
        'trailer' => context.l10n.transferVehicleTrailer,
        _ => context.l10n.transferVehicleOther,
      };
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 50,
    child: TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.neutral400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset('assets/icons/wallet/search.svg'),
        ),
        filled: true,
        fillColor: AppColors.neutral50,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}

class _TransferField extends StatelessWidget {
  const _TransferField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.prefix,
    this.errorText,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? prefix;
  final String? errorText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: AppTextStyles.regularB7_14,
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          errorText: errorText,
          errorStyle: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.red600,
          ),
          filled: true,
          fillColor: AppColors.neutral50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: errorText == null ? AppColors.cool400 : AppColors.red500,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: errorText == null
                  ? AppColors.primary500
                  : AppColors.red500,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.red500),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ],
  );
}

class _VehicleTypeSelector extends StatelessWidget {
  const _VehicleTypeSelector({
    required this.selectedValue,
    required this.open,
    required this.labelFor,
    required this.hint,
    required this.onToggle,
    required this.onSelected,
  });

  final String? selectedValue;
  final bool open;
  final String Function(String) labelFor;
  final String hint;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelected;

  static const _values = [
    'truck',
    'miniTruck',
    'pickupTruck',
    'tempo',
    'trailer',
    'other',
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      InkWell(
        key: const Key('transfer-vehicle-type'),
        onTap: onToggle,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cool400),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selectedValue == null ? hint : labelFor(selectedValue!),
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: selectedValue == null
                        ? AppColors.neutral400
                        : AppColors.neutral950,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: open ? .5 : 0,
                duration: const Duration(milliseconds: 160),
                child: SvgPicture.asset(
                  'assets/icons/home/chevron_down.svg',
                  width: 20,
                  height: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      if (open)
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cool400),
          ),
          child: Column(
            children: _values
                .map(
                  (value) => InkWell(
                    key: Key('transfer-vehicle-$value'),
                    onTap: () => onSelected(value),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 9,
                      ),
                      child: Row(
                        children: [
                          _RadioCircle(selected: selectedValue == value),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              labelFor(value),
                              style: AppTextStyles.regularB7_14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
    ],
  );
}

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.neutral500,
      ),
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.primary500,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );
}

class _ManagerArrangeOption extends StatelessWidget {
  const _ManagerArrangeOption({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.primary100,
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      key: const Key('transfer-manager-arrange'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.neutral50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.cool600),
              ),
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: SvgPicture.asset(
                        'assets/icons/wallet/status_verified.svg',
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary500,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: AppColors.neutral900,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.name, required this.subtitle});

  final String name;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.neutral50,
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x16000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset('assets/icons/profile/facility.svg'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: AppTextStyles.semiboldH9_14),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.weight,
    required this.price,
    required this.buttonLabel,
    required this.buttonKey,
    required this.onPressed,
    this.enabled = true,
  });

  final String weight;
  final String price;
  final String buttonLabel;
  final Key buttonKey;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
    decoration: const BoxDecoration(
      color: AppColors.backgroundColor,
      boxShadow: [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 8,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/wallet/status_verified.svg',
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary700,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  weight,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.primary700,
                  ),
                ),
              ),
              Container(width: 1, height: 22, color: AppColors.primary400),
              const SizedBox(width: 14),
              Text(
                price,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.primary700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            key: buttonKey,
            onPressed: enabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              textStyle: AppTextStyles.semiboldH9_14,
              disabledBackgroundColor: AppColors.neutral200,
              disabledForegroundColor: AppColors.neutral600,
            ),
            child: Text(buttonLabel, style: AppTextStyles.semiboldH9_14),
          ),
        ),
      ],
    ),
  );
}
