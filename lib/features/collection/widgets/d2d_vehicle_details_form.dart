import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/home/widgets/home_styles.dart';

class D2dVehicleDetailsForm extends StatefulWidget {
  const D2dVehicleDetailsForm({
    super.key,
    required this.vehicleNumbers,
    required this.selectedVehicle,
    required this.givenBy,
    required this.vehiclePhoto,
    required this.onVehicleSelected,
    required this.onGivenByChanged,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    required this.onPreviewPhoto,
    this.supervisorName,
    this.supervisorPhone,
  });

  final List<String> vehicleNumbers;
  final String? selectedVehicle;
  final String givenBy;
  final XFile? vehiclePhoto;
  final ValueChanged<String?> onVehicleSelected;
  final ValueChanged<String> onGivenByChanged;
  final VoidCallback onCapturePhoto;
  final VoidCallback onRemovePhoto;
  final VoidCallback onPreviewPhoto;
  final String? supervisorName;
  final String? supervisorPhone;

  @override
  State<D2dVehicleDetailsForm> createState() => _D2dVehicleDetailsFormState();
}

class _D2dVehicleDetailsFormState extends State<D2dVehicleDetailsForm> {
  late final TextEditingController _vehicleController;
  late final TextEditingController _givenByController;
  bool _isVehicleListOpen = false;

  @override
  void initState() {
    super.initState();
    _vehicleController = TextEditingController(text: widget.selectedVehicle);
    _givenByController = TextEditingController(text: widget.givenBy);
  }

  @override
  void didUpdateWidget(covariant D2dVehicleDetailsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedVehicle != null &&
        widget.selectedVehicle != oldWidget.selectedVehicle &&
        widget.selectedVehicle != _vehicleController.text) {
      _vehicleController.text = widget.selectedVehicle!;
    }
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _givenByController.dispose();
    super.dispose();
  }

  void _showSupervisor() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.collectionContactSupervisor,
                style: AppTextStyles.semiboldH7_18,
              ),
              const SizedBox(height: 16),
              _SupervisorContactCard(
                fullName: widget.supervisorName?.trim() ?? '',
                mobileNumber: widget.supervisorPhone?.trim() ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _vehicleController.text.trim().toLowerCase();
    final filteredVehicles = widget.vehicleNumbers
        .where((number) => number.toLowerCase().contains(query))
        .toList(growable: false);
    final noVehicleFound = query.isNotEmpty && filteredVehicles.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(text: l10n.collectionTypes),
        const SizedBox(height: 8),
        Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cool200,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cool400),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/icons/home/collection_d2d.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.neutral900,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(l10n.d2d, style: AppTextStyles.regularB7_14),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _FieldLabel(text: l10n.collectionD2dVehicleNumber),
        const SizedBox(height: 8),
        TextField(
          key: const Key('d2d-vehicle-search'),
          controller: _vehicleController,
          onTap: () => setState(() => _isVehicleListOpen = true),
          onChanged: (value) {
            if (value != widget.selectedVehicle) {
              widget.onVehicleSelected(null);
            }
            setState(() => _isVehicleListOpen = true);
          },
          style: AppTextStyles.regularB7_14,
          decoration: _inputDecoration(
            hint: l10n.collectionSelectVehicle,
            error: noVehicleFound,
            suffixIcon: SvgPicture.asset(
              'assets/icons/wallet/search.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
        if (_isVehicleListOpen) ...[
          const SizedBox(height: 4),
          if (noVehicleFound)
            _NoVehicleFoundCard(onContactSupervisor: _showSupervisor)
          else
            _VehicleDropdown(
              vehicles: filteredVehicles,
              selectedVehicle: widget.selectedVehicle,
              onContactSupervisor: _showSupervisor,
              onSelected: (vehicle) {
                _vehicleController.text = vehicle;
                widget.onVehicleSelected(vehicle);
                setState(() => _isVehicleListOpen = false);
              },
            ),
        ],
        const SizedBox(height: 24),
        _FieldLabel(text: l10n.collectionGivenBy),
        const SizedBox(height: 8),
        TextField(
          key: const Key('d2d-given-by'),
          controller: _givenByController,
          onChanged: widget.onGivenByChanged,
          style: AppTextStyles.regularB7_14,
          decoration: _inputDecoration(hint: l10n.collectionDriverNameHint),
        ),
        const SizedBox(height: 24),
        _FieldLabel(text: l10n.collectionCaptureVehiclePhoto),
        const SizedBox(height: 8),
        InkWell(
          key: const Key('d2d-capture-vehicle-photo'),
          onTap: widget.vehiclePhoto == null ? widget.onCapturePhoto : null,
          borderRadius: BorderRadius.circular(10),
          child: DottedBorder(
            options: const RoundedRectDottedBorderOptions(
              radius: Radius.circular(10),
              color: AppColors.primary500,
              dashPattern: [4, 3],
              strokeWidth: 1,
              padding: EdgeInsets.zero,
            ),
            child: Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/collection/capture_camera.svg',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.collectionCapturePhoto,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.collectionVehiclePhotoHint,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        if (widget.vehiclePhoto != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: InkWell(
                  onTap: widget.onPreviewPhoto,
                  child: Image.file(
                    File(widget.vehiclePhoto!.path),
                    width: 109,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: InkWell(
                  key: const Key('d2d-remove-vehicle-photo'),
                  onTap: widget.onRemovePhoto,
                  child: SvgPicture.asset(
                    'assets/icons/wallet/expense_remove.svg',
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    bool error = false,
    Widget? suffixIcon,
  }) {
    final borderColor = error ? AppColors.red500 : AppColors.cool400;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: borderColor),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.regularB7_14.copyWith(color: AppColors.cool500),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon == null
          ? null
          : Padding(padding: const EdgeInsets.all(16), child: suffixIcon),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(
          color: error ? AppColors.red500 : AppColors.primary500,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.red600),
        ),
      ],
    ),
    style: AppTextStyles.mediumSH8_14,
  );
}

class _VehicleDropdown extends StatelessWidget {
  const _VehicleDropdown({
    required this.vehicles,
    required this.selectedVehicle,
    required this.onSelected,
    required this.onContactSupervisor,
  });

  final List<String> vehicles;
  final String? selectedVehicle;
  final ValueChanged<String> onSelected;
  final VoidCallback onContactSupervisor;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 250),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final selected = selectedVehicle == vehicle;
              return InkWell(
                key: ValueKey('d2d-vehicle-$index'),
                onTap: () => onSelected(vehicle),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? AppColors.primary500
                                : AppColors.neutral400,
                          ),
                        ),
                        child: selected
                            ? const DecoratedBox(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary500,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Text(vehicle, style: AppTextStyles.regularB7_14),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _ContactSupervisorButton(
          label: context.l10n.collectionContactSupervisorIfNotFound,
          onPressed: onContactSupervisor,
        ),
      ],
    ),
  );
}

class _NoVehicleFoundCard extends StatelessWidget {
  const _NoVehicleFoundCard({required this.onContactSupervisor});

  final VoidCallback onContactSupervisor;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(
          context.l10n.collectionNoVehicleFound,
          style: AppTextStyles.semiboldH9_14,
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.collectionContactSupervisorUpdateFleet,
          textAlign: TextAlign.center,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 12),
        _ContactSupervisorButton(
          label: context.l10n.collectionContactSupervisor,
          onPressed: onContactSupervisor,
        ),
      ],
    ),
  );
}

class _ContactSupervisorButton extends StatelessWidget {
  const _ContactSupervisorButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton.icon(
      key: const Key('d2d-contact-supervisor'),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: Colors.white,
        backgroundColor: AppColors.primary500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: AppTextStyles.semiboldH9_14,
      ),
      icon: SvgPicture.asset(
        'assets/icons/help_support/call.svg',
        width: 20,
        height: 20,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
      label: Text(label, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _SupervisorContactCard extends StatelessWidget {
  const _SupervisorContactCard({
    required this.fullName,
    required this.mobileNumber,
  });

  final String fullName;
  final String mobileNumber;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('d2d-supervisor-details'),
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [HomeStyles.cardShadow],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SupervisorDetailLine(
          label: context.l10n.collectionFullName,
          value: fullName.isEmpty ? '-' : fullName,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: AppColors.cool400),
        ),
        _SupervisorDetailLine(
          label: context.l10n.collectionMobileNumber,
          value: mobileNumber.isEmpty ? '-' : mobileNumber,
        ),
      ],
    ),
  );
}

class _SupervisorDetailLine extends StatelessWidget {
  const _SupervisorDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral700),
      ),
      const SizedBox(height: 5),
      Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: AppColors.neutral900,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.semiboldH9_14,
            ),
          ),
        ],
      ),
    ],
  );
}
