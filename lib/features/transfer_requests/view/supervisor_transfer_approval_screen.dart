import 'dart:ui' as ui;

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/transfer_requests/widgets/transfer_dispatch_date_time_picker.dart';
import 'package:eerl_app/features/transfer_requests/widgets/transfer_request_detail_widgets.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

typedef _ApprovalOptions = ({
  List<TransferVehicleModel> vehicles,
  List<DestinationModel> destinations,
});

enum _ApprovalStep { vehicle, destination }

class SupervisorTransferApprovalScreen extends StatefulWidget {
  const SupervisorTransferApprovalScreen({
    super.key,
    required this.transfer,
    required this.items,
    required this.onBack,
    required this.onApproved,
    this.vehicles,
    this.destinations,
  });

  final TransferModel transfer;
  final List<TransferItemModel> items;
  final VoidCallback onBack;
  final VoidCallback onApproved;
  final List<TransferVehicleModel>? vehicles;
  final List<DestinationModel>? destinations;

  @override
  State<SupervisorTransferApprovalScreen> createState() =>
      _SupervisorTransferApprovalScreenState();
}

class _SupervisorTransferApprovalScreenState
    extends State<SupervisorTransferApprovalScreen> {
  late final Future<_ApprovalOptions> _options = _loadOptions();
  final _vehicleNumber = TextEditingController();
  final _transporter = TextEditingController();
  final _fee = TextEditingController();
  final _description = TextEditingController();

  _ApprovalStep _step = _ApprovalStep.vehicle;
  TransferVehicleModel? _selectedVehicle;
  DestinationModel? _selectedDestination;
  bool _otherHired = false;
  bool _destinationExpanded = false;
  bool _calendarExpanded = false;
  bool _submitting = false;
  DateTime? _expectedAt;

  Future<_ApprovalOptions> _loadOptions() async {
    if (widget.vehicles != null && widget.destinations != null) {
      return (
        vehicles: widget.vehicles!,
        destinations: widget.destinations!
            .where((destination) => destination.id != widget.transfer.centerId)
            .toList(growable: false),
      );
    }
    final values = await Future.wait<Object?>([
      EerlLocalRepository.instance.getTransferVehicles(),
      EerlLocalRepository.instance.getDestinations(),
    ]);
    return (
      vehicles: values[0]! as List<TransferVehicleModel>,
      destinations: (values[1]! as List<DestinationModel>)
          .where((destination) => destination.id != widget.transfer.centerId)
          .toList(growable: false),
    );
  }

  bool get _vehicleReady {
    if (_otherHired) {
      return _vehicleNumber.text.trim().length >= 4 &&
          _transporter.text.trim().isNotEmpty &&
          (double.tryParse(_fee.text.trim()) ?? -1) >= 0;
    }
    if (_selectedVehicle == null) return false;
    return !_selectedVehicle!.isHired ||
        (double.tryParse(_fee.text.trim()) ?? -1) >= 0;
  }

  bool get _canSubmit => _selectedDestination != null && !_submitting;

  @override
  void dispose() {
    _vehicleNumber.dispose();
    _transporter.dispose();
    _fee.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_ApprovalOptions>(
    future: _options,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_step == _ApprovalStep.destination) {
            setState(() => _step = _ApprovalStep.vehicle);
          } else {
            widget.onBack();
          }
        },
        child: Scaffold(
          key: const Key('supervisor-transfer-approval-screen'),
          backgroundColor: AppColors.backgroundColor,
          appBar: CustomAppBar(
            title: _step == _ApprovalStep.vehicle
                ? context.l10n.supervisorTransferVehicleDetails
                : context.l10n.supervisorTransferSelectDestination,
            backIconAsset: 'assets/icons/records/back.svg',
            onBackTap: () {
              if (_step == _ApprovalStep.destination) {
                setState(() => _step = _ApprovalStep.vehicle);
              } else {
                widget.onBack();
              }
            },
          ),
          body: SafeArea(
            top: false,
            child: _step == _ApprovalStep.vehicle
                ? _vehicleStep(snapshot.data!.vehicles)
                : _destinationStep(snapshot.data!.destinations),
          ),
          bottomNavigationBar: _bottomButton(),
        ),
      );
    },
  );

  Widget _vehicleStep(List<TransferVehicleModel> vehicles) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      _TransferId(value: widget.transfer.number ?? widget.transfer.id),
      const SizedBox(height: 24),
      _FieldLabel(context.l10n.supervisorTransferSelectVehicle),
      const SizedBox(height: 8),
      InkWell(
        key: const Key('supervisor-transfer-vehicle-dropdown'),
        onTap: () => _showVehicleSheet(vehicles),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _vehicleSelectionText(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: _selectedVehicle == null && !_otherHired
                        ? AppColors.cool500
                        : AppColors.neutral950,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded),
            ],
          ),
        ),
      ),
      if (_selectedVehicle != null || _otherHired) ...[
        const SizedBox(height: 8),
        Text(
          context.l10n.supervisorTransferCapacity(
            (_selectedVehicle?.capacityKg ?? 5000).toStringAsFixed(0),
          ),
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.primary500,
          ),
        ),
      ],
      if (_otherHired) ...[
        const SizedBox(height: 24),
        _ApprovalTextField(
          fieldKey: const Key('supervisor-transfer-other-vehicle-number'),
          label: context.l10n.supervisorTransferVehicleNumber,
          hint: context.l10n.transferVehiclePlateInputHint,
          controller: _vehicleNumber,
          helper: context.l10n.transferVehicleNumberExample,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
        _ApprovalTextField(
          fieldKey: const Key('supervisor-transfer-other-transporter'),
          label: context.l10n.supervisorTransferTransporter,
          hint: context.l10n.supervisorTransferTransporterHint,
          controller: _transporter,
          onChanged: (_) => setState(() {}),
        ),
      ],
      if (_otherHired || _selectedVehicle?.isHired == true) ...[
        const SizedBox(height: 24),
        _ApprovalTextField(
          fieldKey: const Key('supervisor-transfer-other-fee'),
          label: context.l10n.supervisorTransferTruckFee,
          hint: '0',
          controller: _fee,
          prefixText: '₹  ',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: (_) => setState(() {}),
        ),
      ],
      const SizedBox(height: 24),
      _TransferItems(items: widget.items),
    ],
  );

  Widget _destinationStep(List<DestinationModel> destinations) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      _TransferId(value: widget.transfer.number ?? widget.transfer.id),
      const SizedBox(height: 24),
      _FieldLabel(context.l10n.supervisorTransferSelectDestinationRequired),
      const SizedBox(height: 8),
      InkWell(
        key: const Key('supervisor-transfer-destination-dropdown'),
        onTap: () => setState(() {
          _destinationExpanded = !_destinationExpanded;
          _calendarExpanded = false;
        }),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDestination?.name ??
                      context.l10n.supervisorTransferDestinationHint,
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: _selectedDestination == null
                        ? AppColors.cool500
                        : AppColors.neutral950,
                  ),
                ),
              ),
              Icon(
                _destinationExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
              ),
            ],
          ),
        ),
      ),
      if (_destinationExpanded)
        _DestinationList(
          destinations: destinations,
          selected: _selectedDestination,
          onSelected: (value) => setState(() {
            _selectedDestination = value;
            _destinationExpanded = false;
          }),
        ),
      const SizedBox(height: 24),
      _FieldLabel(context.l10n.supervisorTransferExpectedDateTime),
      const SizedBox(height: 8),
      InkWell(
        key: const Key('supervisor-transfer-date-time'),
        onTap: () => setState(() {
          _calendarExpanded = !_calendarExpanded;
          _destinationExpanded = false;
        }),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _expectedAt == null
                      ? context.l10n.transferSelectDateTime
                      : DateFormat(
                          'dd MMMM yyyy, hh:mm a',
                        ).format(_expectedAt!),
                  style: AppTextStyles.regularB7_14.copyWith(
                    color: _expectedAt == null
                        ? AppColors.cool500
                        : AppColors.neutral950,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_month_outlined,
                color: AppColors.primary500,
              ),
            ],
          ),
        ),
      ),
      if (_calendarExpanded)
        TransferDispatchDateTimePicker(
          initialDateTime: _expectedAt,
          minimumDateTime: DateTime.now(),
          onCancel: () => setState(() => _calendarExpanded = false),
          onConfirm: (value) => setState(() {
            _expectedAt = value;
            _calendarExpanded = false;
          }),
        )
      else
        Padding(
          padding: const EdgeInsets.only(top: 6, left: 4),
          child: Text(
            context.l10n.supervisorTransferDateOptional,
            style: AppTextStyles.regularB8_12.copyWith(
              color: AppColors.cool500,
            ),
          ),
        ),
      const SizedBox(height: 24),
      _FieldLabel(context.l10n.supervisorTransferDescription),
      const SizedBox(height: 8),
      TextField(
        key: const Key('supervisor-transfer-description'),
        controller: _description,
        minLines: 4,
        maxLines: 4,
        maxLength: 150,
        decoration: InputDecoration(
          hintText: context.l10n.supervisorTransferDescriptionHint,
          counterText: context.l10n.supervisorTransferMaxCharacters,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.cool400),
          ),
        ),
      ),
      const SizedBox(height: 16),
      _TransferItems(items: widget.items),
    ],
  );

  Widget _bottomButton() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: ElevatedButton(
        key: Key(
          _step == _ApprovalStep.vehicle
              ? 'supervisor-transfer-continue'
              : 'supervisor-transfer-confirm',
        ),
        onPressed: _step == _ApprovalStep.vehicle
            ? (_vehicleReady
                  ? () => setState(() => _step = _ApprovalStep.destination)
                  : null)
            : (_canSubmit ? _submit : null),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          disabledBackgroundColor: AppColors.neutral400,
          backgroundColor: AppColors.primary500,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _step == _ApprovalStep.vehicle
              ? context.l10n.transferContinuePlain
              : context.l10n.supervisorTransferConfirm,
          style: AppTextStyles.boldH7_16,
        ),
      ),
    ),
  );

  String _vehicleSelectionText() {
    if (_otherHired) return context.l10n.supervisorTransferOtherHired;
    final vehicle = _selectedVehicle;
    if (vehicle == null) return context.l10n.supervisorTransferVehicleHint;
    final detail = vehicle.isHired
        ? vehicle.transporterName ?? context.l10n.supervisorTransferHiredTruck
        : context.l10n.supervisorTransferCompanyTruck;
    return '${vehicle.number}  •  $detail';
  }

  Future<void> _showVehicleSheet(List<TransferVehicleModel> vehicles) async {
    final result = await showGeneralDialog<Object>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.supervisorTransferSelectVehicle,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, _, _) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.pop(dialogContext),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: ColoredBox(color: Colors.black.withValues(alpha: .60)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _VehicleSelectionSheet(
              vehicles: vehicles,
              onVehicleSelected: (vehicle) =>
                  Navigator.pop(dialogContext, vehicle),
              onOtherSelected: () => Navigator.pop(dialogContext, true),
            ),
          ),
        ],
      ),
      transitionBuilder: (_, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      if (result == true) {
        _otherHired = true;
        _selectedVehicle = null;
      } else {
        _otherHired = false;
        _selectedVehicle = result as TransferVehicleModel;
        _fee.clear();
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await EerlLocalRepository.instance.approveTransfer(
        transferId: widget.transfer.id,
        destinationId: _selectedDestination!.id,
        transferVehicleId: _otherHired ? null : _selectedVehicle!.id,
        vehicleNumber: _otherHired ? _vehicleNumber.text : null,
        transporterName: _otherHired ? _transporter.text : null,
        transferFee: _selectedVehicle?.isHired == true || _otherHired
            ? double.tryParse(_fee.text.trim())
            : 0,
        vehicleArrivalTime: _expectedAt,
        note: _description.text,
      );
      await OutgoingSyncService.instance.drain();
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: .58),
        builder: (context) => _ApprovalSuccessDialog(
          transfer: widget.transfer,
          destination: _selectedDestination!,
          vehicleNumber: _selectedVehicle?.number ?? _vehicleNumber.text,
          expectedAt: _expectedAt,
        ),
      );
      if (mounted) widget.onApproved();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _VehicleSelectionSheet extends StatelessWidget {
  const _VehicleSelectionSheet({
    required this.vehicles,
    required this.onVehicleSelected,
    required this.onOtherSelected,
  });

  final List<TransferVehicleModel> vehicles;
  final ValueChanged<TransferVehicleModel> onVehicleSelected;
  final VoidCallback onOtherSelected;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Material(
      key: const Key('supervisor-transfer-vehicle-sheet'),
      color: Colors.white,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: double.infinity,
        height: 346 + bottomInset,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottomInset),
          child: Column(
            children: [
              Container(
                width: 61,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  key: const Key('supervisor-transfer-vehicle-list'),
                  padding: EdgeInsets.zero,
                  itemCount: vehicles.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return _VehicleOption(
                      key: ValueKey('transfer-vehicle-${vehicle.id}'),
                      vehicle: vehicle,
                      onTap: () => onVehicleSelected(vehicle),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                key: const Key('supervisor-transfer-other-hired'),
                onPressed: onOtherSelected,
                icon: SvgPicture.asset(
                  'assets/icons/transfer_requests/add_vehicle.svg',
                  width: 24,
                  height: 24,
                ),
                label: Text(
                  context.l10n.supervisorTransferOtherHired,
                  style: AppTextStyles.semiboldH9_14,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  foregroundColor: AppColors.primary500,
                  backgroundColor: AppColors.primary50,
                  side: const BorderSide(color: AppColors.primary500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.value);
  final String value;
  @override
  Widget build(BuildContext context) {
    final required = value.trimRight().endsWith('*');
    final label = required
        ? value
              .trimRight()
              .substring(0, value.trimRight().length - 1)
              .trimRight()
        : value;
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.red600),
            ),
        ],
      ),
      style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
    );
  }
}

class _ApprovalTextField extends StatelessWidget {
  const _ApprovalTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.fieldKey,
    this.helper,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
  });
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;
  final String? helper;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _FieldLabel(label),
      const SizedBox(height: 8),
      SizedBox(
        height: 55,
        child: TextField(
          key: fieldKey,
          controller: controller,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            prefixStyle: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral950,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.cool400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary500),
            ),
          ),
        ),
      ),
      if (helper != null) ...[
        const SizedBox(height: 6),
        Text(
          helper!,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral500,
          ),
        ),
      ],
    ],
  );
}

class _TransferId extends StatelessWidget {
  const _TransferId({required this.value});
  final String value;
  @override
  Widget build(BuildContext context) => TransferDetailCard(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SvgPicture.asset('assets/icons/home/transfer.svg'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH8_16,
          ),
        ),
      ],
    ),
  );
}

class _TransferItems extends StatelessWidget {
  const _TransferItems({required this.items});
  final List<TransferItemModel> items;
  @override
  Widget build(BuildContext context) => TransferDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.transferItemsTitle,
          style: AppTextStyles.semiboldH7_18,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: Text(context.l10n.transferItemName)),
            Text(context.l10n.transferItemQuantity),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 14),
        for (var index = 0; index < items.length; index++) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  items[index].name ?? items[index].itemId,
                  style: AppTextStyles.boldH8_14.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
              Text(
                '${items[index].qty.toStringAsFixed(2)} ${items[index].unitCode ?? ''}'
                    .trim(),
                style: AppTextStyles.boldH8_14.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          if (index != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    ),
  );
}

class _VehicleOption extends StatelessWidget {
  const _VehicleOption({super.key, required this.vehicle, required this.onTap});
  final TransferVehicleModel vehicle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 66,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: vehicle.isHired
                    ? AppColors.orangeLight
                    : AppColors.primary100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                vehicle.isHired
                    ? 'assets/icons/transfer_requests/hired_truck.svg'
                    : 'assets/icons/transfer_requests/company_truck.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.number,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.semiboldH9_14,
                  ),
                  Text(
                    vehicle.isHired
                        ? context.l10n.supervisorTransferHiredFrom(
                            vehicle.transporterName ?? '-',
                          )
                        : context.l10n.supervisorTransferCompanyTruck,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularB7_14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DestinationList extends StatelessWidget {
  const _DestinationList({
    required this.destinations,
    required this.selected,
    required this.onSelected,
  });
  final List<DestinationModel> destinations;
  final DestinationModel? selected;
  final ValueChanged<DestinationModel> onSelected;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 190),
    padding: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListView(
      shrinkWrap: true,
      children: [
        for (final destination in destinations)
          InkWell(
            key: ValueKey('supervisor-transfer-destination-${destination.id}'),
            onTap: () => onSelected(destination),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.cool500),
                    ),
                    child: selected?.id == destination.id
                        ? const DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary500,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      destination.name,
                      style: AppTextStyles.regularB7_14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

class _ApprovalSuccessDialog extends StatelessWidget {
  const _ApprovalSuccessDialog({
    required this.transfer,
    required this.destination,
    required this.vehicleNumber,
    required this.expectedAt,
  });
  final TransferModel transfer;
  final DestinationModel destination;
  final String vehicleNumber;
  final DateTime? expectedAt;

  @override
  Widget build(BuildContext context) => Dialog(
    key: const Key('supervisor-transfer-approval-dialog'),
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    child: SizedBox(
      width: 335,
      height: 368,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    context.l10n.supervisorTransferApprovedTitle(
                      transfer.number ?? transfer.id,
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.boldH6_20,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.supervisorTransferApprovedMessage(
                      transfer.requestedByName,
                      destination.name,
                      vehicleNumber,
                      expectedAt == null
                          ? '-'
                          : DateFormat('dd MMM, hh:mm a').format(expectedAt!),
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    key: const Key('supervisor-transfer-back-to-requests'),
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      backgroundColor: AppColors.cool200,
                      foregroundColor: AppColors.neutral950,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(context.l10n.supervisorTransferBackToRequests),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
