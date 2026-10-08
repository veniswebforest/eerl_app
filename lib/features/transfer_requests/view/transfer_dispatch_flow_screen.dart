import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import '../widgets/transfer_request_detail_widgets.dart';

enum _DispatchStep { vehicle, weighbridge }

class TransferDispatchFlowScreen extends StatefulWidget {
  const TransferDispatchFlowScreen({
    super.key,
    required this.onBack,
    required this.onComplete,
    required this.transfer,
    required this.items,
  });

  final VoidCallback onBack;
  final VoidCallback onComplete;
  final TransferModel transfer;
  final List<TransferItemModel> items;

  @override
  State<TransferDispatchFlowScreen> createState() =>
      _TransferDispatchFlowScreenState();
}

class _TransferDispatchFlowScreenState
    extends State<TransferDispatchFlowScreen> {
  final _imagePicker = ImagePicker();
  final _vehicleController = TextEditingController();
  final _driverController = TextEditingController();
  final _weightController = TextEditingController();
  final _balesController = TextEditingController();
  final _piecesController = TextEditingController();
  _DispatchStep _step = _DispatchStep.vehicle;
  List<TransferDispatchPhotoModel> _vehiclePhotos = const [];
  List<TransferDispatchPhotoModel> _weighbridgePhotos = const [];
  bool _loadingDraft = true;
  bool _saving = false;

  bool get _isPieces =>
      widget.items.length == 1 &&
      widget.items.single.unitCode?.toUpperCase() == 'PCS';

  bool get _vehicleReady =>
      _vehicleController.text.trim().length >= 4 &&
      _vehicleController.text.trim().length <= 20 &&
      _driverController.text.trim().isNotEmpty &&
      _vehiclePhotos.isNotEmpty &&
      _vehiclePhotos.length <= 5 &&
      !_saving;

  bool get _weighbridgeReady =>
      (double.tryParse(_weightController.text.trim()) ?? 0) > 0 &&
      (_balesController.text.trim().isEmpty ||
          ((int.tryParse(_balesController.text.trim()) ?? 0) >= 1 &&
              (int.tryParse(_balesController.text.trim()) ?? 10000) <= 9999)) &&
      (!_isPieces ||
          (double.tryParse(_piecesController.text.trim()) ?? 0) > 0) &&
      _weighbridgePhotos.length <= 5 &&
      !_saving;

  @override
  void initState() {
    super.initState();
    _restoreDraft();
  }

  Future<void> _restoreDraft() async {
    final draft = await EerlLocalRepository.instance.getTransferDispatchDraft(
      widget.transfer.id,
    );
    if (!mounted) return;
    _vehicleController.text = draft.vehicleNumber ?? '';
    _driverController.text = draft.driverName ?? '';
    setState(() {
      _vehiclePhotos = draft.photosFor('vehicle');
      _weighbridgePhotos = draft.photosFor('weighbridge');
      _loadingDraft = false;
    });
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    _driverController.dispose();
    _weightController.dispose();
    _balesController.dispose();
    _piecesController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(String field) async {
    final photo = await ImageCompressor.pickAndCompress(
      picker: _imagePicker,
      source: ImageSource.camera,
    );
    if (photo == null || !mounted) return;
    final stored = await EerlLocalRepository.instance.addTransferDispatchPhoto(
      transferId: widget.transfer.id,
      field: field,
      localPath: photo.path,
    );
    if (!mounted) return;
    setState(() {
      if (field == 'vehicle') {
        _vehiclePhotos = [..._vehiclePhotos, stored];
      } else {
        _weighbridgePhotos = [..._weighbridgePhotos, stored];
      }
    });
  }

  Future<void> _removePhoto(TransferDispatchPhotoModel photo) async {
    await EerlLocalRepository.instance.removeTransferDispatchPhoto(photo.id);
    if (!mounted) return;
    setState(() {
      if (photo.field == 'vehicle') {
        _vehiclePhotos = _vehiclePhotos
            .where((item) => item.id != photo.id)
            .toList();
      } else {
        _weighbridgePhotos = _weighbridgePhotos
            .where((item) => item.id != photo.id)
            .toList();
      }
    });
  }

  Future<void> _startLoading() async {
    if (!_vehicleReady) return;
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.saveTransferDispatchDraft(
        transferId: widget.transfer.id,
        vehicleNumber: _vehicleController.text,
        driverName: _driverController.text,
      );
      if (mounted) setState(() => _step = _DispatchStep.weighbridge);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
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
              child: _loadingDraft
                  ? const Center(child: CircularProgressIndicator())
                  : vehicleStep
                  ? _vehicleForm()
                  : _weighbridgeForm(),
            ),
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
              _DispatchField(
                label: 'Driver name *',
                hint: 'Enter driver name',
                controller: _driverController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              _PhotoField(
                label: context.l10n.transferVehiclePhotoRequired,
                photos: _vehiclePhotos,
                onCapture: () => _capturePhoto('vehicle'),
                onRemove: _removePhoto,
              ),
            ],
          ),
        ),
      ),
      _ActionButton(
        buttonKey: const Key('transfer-start-loading'),
        label: context.l10n.transferStartLoading,
        enabled: _vehicleReady,
        onPressed: _startLoading,
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
              _TransferSummaryCard(
                transfer: widget.transfer,
                items: widget.items,
              ),
              const SizedBox(height: 20),
              _DispatchField(
                label: 'Loaded weight (KG) *',
                hint: context.l10n.transferLoadedWeightHint,
                controller: _weightController,
                prefix: context.l10n.transferKgPrefix,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_isPieces) ...[
                const SizedBox(height: 20),
                _DispatchField(
                  label: 'Pieces loaded *',
                  hint: 'Enter number of pieces',
                  controller: _piecesController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ],
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
                label: 'Weighbridge photos (optional)',
                photos: _weighbridgePhotos,
                onCapture: () => _capturePhoto('weighbridge'),
                onRemove: _removePhoto,
              ),
            ],
          ),
        ),
      ),
      _ActionButton(
        buttonKey: const Key('transfer-submit-transfer'),
        label: context.l10n.transferSubmitTransfer,
        enabled: _weighbridgeReady,
        onPressed: _submit,
      ),
    ],
  );

  Future<void> _submit() async {
    if (!_weighbridgeReady) return;
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.submitTransferDispatch(
        transferId: widget.transfer.id,
        vehicleNumber: _vehicleController.text,
        driverName: _driverController.text,
        dispatchedWeight: double.parse(_weightController.text.trim()),
        baleCount: _balesController.text.trim().isEmpty
            ? null
            : int.parse(_balesController.text.trim()),
        piecesLoaded: _isPieces
            ? double.parse(_piecesController.text.trim())
            : null,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      setState(() => _saving = false);
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
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
              Image.asset(
                'assets/images/collection_detail/collection_success.png',
                key: const Key('transfer-dispatch-success-visual'),
                width: 135,
                height: 135,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text('Dispatched', style: AppTextStyles.semiboldH7_18),
              const SizedBox(height: 6),
              Text(
                '${widget.transfer.number ?? widget.transfer.id} has been dispatched.',
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

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.label,
    required this.photos,
    required this.onCapture,
    required this.onRemove,
  });

  final String label;
  final List<TransferDispatchPhotoModel> photos;
  final VoidCallback onCapture;
  final ValueChanged<TransferDispatchPhotoModel> onRemove;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(10),
          color: photos.length < 5 ? AppColors.primary500 : AppColors.cool300,
          dashPattern: const [5, 4],
        ),
        child: InkWell(
          key: Key('transfer-capture-${label.hashCode}'),
          onTap: photos.length < 5 ? onCapture : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 80,
            width: double.infinity,
            color: photos.length < 5 ? AppColors.primary50 : AppColors.cool100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/collection/capture_camera.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    photos.length < 5
                        ? AppColors.primary500
                        : AppColors.cool400,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.collectionCapturePhoto,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: photos.length < 5
                        ? AppColors.neutral900
                        : AppColors.cool400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (photos.isNotEmpty) ...[
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final photo in photos)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: photo.localPath == null
                        ? Container(
                            width: 82,
                            height: 58,
                            color: AppColors.cool200,
                            child: const Icon(Icons.image),
                          )
                        : Image.file(
                            File(photo.localPath!),
                            width: 82,
                            height: 58,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: InkWell(
                      onTap: () => onRemove(photo),
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
          ],
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
  const _TransferSummaryCard({required this.transfer, required this.items});

  final TransferModel transfer;
  final List<TransferItemModel> items;

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
          values: [transfer.number ?? transfer.id],
        ),
        TransferDetailRow(
          label: context.l10n.transferItem,
          values: [
            if (items.isEmpty)
              '-'
            else
              ...items.map((item) => item.name ?? item.itemId),
          ],
        ),
        TransferDetailRow(
          label: context.l10n.transferDetailFromLocation,
          values: [transfer.centerName ?? transfer.centerId],
        ),
        TransferDetailRow(
          label: context.l10n.transferDetailToLocation,
          values: [transfer.destinationName ?? '-'],
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
