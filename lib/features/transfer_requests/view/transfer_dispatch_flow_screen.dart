import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/transfer_request_detail_widgets.dart';

enum _DispatchStep { vehicle, weighbridge }

class TransferDispatchFlowScreen extends StatefulWidget {
  const TransferDispatchFlowScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<TransferDispatchFlowScreen> createState() =>
      _TransferDispatchFlowScreenState();
}

class _TransferDispatchFlowScreenState
    extends State<TransferDispatchFlowScreen> {
  final _imagePicker = ImagePicker();
  final _vehicleController = TextEditingController();
  final _weightController = TextEditingController();
  final _balesController = TextEditingController();
  _DispatchStep _step = _DispatchStep.vehicle;
  String? _driver;
  XFile? _vehiclePhoto;
  XFile? _slipPhoto;

  bool get _vehicleReady =>
      _vehicleController.text.trim().isNotEmpty &&
      _driver != null &&
      _vehiclePhoto != null;

  bool get _weighbridgeReady =>
      _weightController.text.trim().isNotEmpty &&
      _balesController.text.trim().isNotEmpty &&
      _slipPhoto != null;

  @override
  void dispose() {
    _vehicleController.dispose();
    _weightController.dispose();
    _balesController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto({required bool vehicle}) async {
    final photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 82,
    );
    if (photo == null || !mounted) return;
    setState(() {
      if (vehicle) {
        _vehiclePhoto = photo;
      } else {
        _slipPhoto = photo;
      }
    });
  }

  void _handleBack() {
    if (_step == _DispatchStep.weighbridge) {
      setState(() => _step = _DispatchStep.vehicle);
    } else {
      widget.onBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleStep = _step == _DispatchStep.vehicle;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: vehicleStep
            ? context.l10n.transferVehicleDetailsTitle
            : context.l10n.transferWeighbridgeTitle,
        onBackTap: _handleBack,
        backIconAsset: 'assets/icons/records/back.svg',
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: vehicleStep ? _vehicleForm() : _weighbridgeForm(),
          ),
        ),
      ),
    );
  }

  Widget _vehicleForm() => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          key: const Key('transfer-vehicle-details-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              _DispatchField(
                label: context.l10n.transferVehicleNumberRequired,
                hint: context.l10n.transferVehicleNumberPlateHint,
                controller: _vehicleController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              _DriverField(
                value: _driver,
                onTap: () => setState(
                  () => _driver = context.l10n.transferDriverMockName,
                ),
              ),
              const SizedBox(height: 24),
              _PhotoField(
                label: context.l10n.transferVehiclePhotoRequired,
                photo: _vehiclePhoto,
                onCapture: () => _capturePhoto(vehicle: true),
                onRemove: () => setState(() => _vehiclePhoto = null),
              ),
            ],
          ),
        ),
      ),
      _ActionButton(
        buttonKey: const Key('transfer-start-loading'),
        label: context.l10n.transferStartLoading,
        enabled: _vehicleReady,
        onPressed: () => setState(() => _step = _DispatchStep.weighbridge),
      ),
    ],
  );

  Widget _weighbridgeForm() => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          key: const Key('transfer-weighbridge-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            children: [
              const _TransferSummaryCard(),
              const SizedBox(height: 20),
              _DispatchField(
                label: context.l10n.transferLoadedWeight,
                hint: context.l10n.transferLoadedWeightHint,
                controller: _weightController,
                prefix: context.l10n.transferKgPrefix,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _DispatchField(
                label: context.l10n.transferNumberOfBales,
                hint: context.l10n.transferNumberOfBalesHint,
                controller: _balesController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _PhotoField(
                label: context.l10n.transferWeighbridgeSlip,
                photo: _slipPhoto,
                onCapture: () => _capturePhoto(vehicle: false),
                onRemove: () => setState(() => _slipPhoto = null),
              ),
            ],
          ),
        ),
      ),
      _ActionButton(
        buttonKey: const Key('transfer-submit-transfer'),
        label: context.l10n.transferSubmitTransfer,
        enabled: _weighbridgeReady,
        onPressed: _showSuccess,
      ),
    ],
  );

  Future<void> _showSuccess() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .58),
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: 303,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.transferCompletedTitle,
                style: AppTextStyles.semiboldH7_18,
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.transferCompletedMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    widget.onComplete();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cool200,
                    foregroundColor: AppColors.neutral950,
                    elevation: 0,
                  ),
                  child: Text(context.l10n.requestBackToList),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DispatchField extends StatelessWidget {
  const _DispatchField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.prefix,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefix;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      SizedBox(
        height: 55,
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.cool500,
            ),
            prefixIcon: prefix == null
                ? null
                : Center(
                    child: Text(
                      prefix!,
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: AppColors.neutral950,
                      ),
                    ),
                  ),
            prefixIconConstraints: prefix == null
                ? null
                : const BoxConstraints(minWidth: 48, maxWidth: 48),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
      ),
    ],
  );
}

class _DriverField extends StatelessWidget {
  const _DriverField({required this.value, required this.onTap});
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.transferDriverDetailRequired,
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      InkWell(
        key: const Key('transfer-driver-selector'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            value ?? context.l10n.transferSelectDriverName,
            style: AppTextStyles.regularB7_14.copyWith(
              color: value == null ? AppColors.cool500 : AppColors.neutral950,
            ),
          ),
        ),
      ),
    ],
  );
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.label,
    required this.photo,
    required this.onCapture,
    required this.onRemove,
  });

  final String label;
  final XFile? photo;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(10),
          color: photo == null ? AppColors.primary500 : AppColors.cool300,
          dashPattern: const [5, 4],
        ),
        child: InkWell(
          key: Key('transfer-capture-${label.hashCode}'),
          onTap: photo == null ? onCapture : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 80,
            width: double.infinity,
            color: photo == null ? AppColors.primary50 : AppColors.cool100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/collection/capture_camera.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    photo == null ? AppColors.primary500 : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.collectionCapturePhoto,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: photo == null
                        ? AppColors.neutral900
                        : AppColors.cool400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (photo != null) ...[
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  File(photo!.path),
                  width: 82,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: InkWell(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.neutral50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      const SizedBox(height: 10),
      Text(
        context.l10n.requestPhotoSupport,
        style: AppTextStyles.regularB8_12.copyWith(color: AppColors.neutral600),
      ),
    ],
  );
}

class _TransferSummaryCard extends StatelessWidget {
  const _TransferSummaryCard();

  @override
  Widget build(BuildContext context) => TransferDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.transferDetails, style: AppTextStyles.semiboldH7_18),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.cool300),
        const SizedBox(height: 12),
        TransferDetailRow(
          label: context.l10n.transferId,
          values: [context.l10n.transferDetailRequestId],
        ),
        TransferDetailRow(
          label: context.l10n.transferItem,
          values: [context.l10n.transferDetailPetBottles],
        ),
        TransferDetailRow(
          label: context.l10n.transferDetailFromLocation,
          values: [context.l10n.transferDetailFromLocationValue],
        ),
        TransferDetailRow(
          label: context.l10n.transferDetailToLocation,
          values: [context.l10n.transferDetailToLocationValue],
          showDivider: false,
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.buttonKey,
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  final Key buttonKey;
  final String label;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          key: buttonKey,
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary500,
            disabledBackgroundColor: AppColors.neutral400,
            foregroundColor: AppColors.neutral50,
            disabledForegroundColor: AppColors.neutral50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(label, style: AppTextStyles.boldH7_16),
        ),
      ),
    ),
  );
}
