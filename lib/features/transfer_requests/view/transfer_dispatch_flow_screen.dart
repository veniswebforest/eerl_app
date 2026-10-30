import 'dart:async';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_data_source.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import '../widgets/transfer_dispatch_date_time_picker.dart';

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
  List<TransferDispatchPhotoModel> _vehiclePhotos = const [];
  List<TransferDispatchPhotoModel> _weighbridgePhotos = const [];
  DateTime? _loadedAt;
  bool _calendarExpanded = true;
  late bool _usePieces;
  bool _loadingDraft = true;
  bool _saving = false;
  List<TransferDispatchStockModel>? _stockAvailability;
  String? _loadedQuantityError;

  bool get _isPieces =>
      widget.items.length == 1 &&
      widget.items.single.unitCode?.toUpperCase() == 'PCS';

  List<TransferDispatchPhotoModel> get _dispatchPhotos => [
    ..._vehiclePhotos,
    ..._weighbridgePhotos,
  ];

  TextEditingController get _loadedQuantityController =>
      _usePieces ? _piecesController : _weightController;

  bool get _formReady =>
      _vehicleController.text.trim().length >= 4 &&
      _vehicleController.text.trim().length <= 20 &&
      _driverController.text.trim().isNotEmpty &&
      (double.tryParse(_loadedQuantityController.text.trim()) ?? 0) > 0 &&
      ((int.tryParse(_balesController.text.trim()) ?? 0) >= 1 &&
          (int.tryParse(_balesController.text.trim()) ?? 10000) <= 9999) &&
      _loadedAt != null &&
      _vehiclePhotos.isNotEmpty &&
      _dispatchPhotos.length <= 5 &&
      _stockAvailability != null &&
      _loadedQuantityError == null &&
      !_saving;

  @override
  void initState() {
    super.initState();
    _usePieces = _isPieces;
    _restoreDraftThenCameraResult();
  }

  Future<void> _restoreDraftThenCameraResult() async {
    await Future.wait([_restoreDraft(), _loadStockAvailability()]);
    await _restoreCameraResult();
  }

  Future<void> _loadStockAvailability() async {
    final stock = await EerlLocalRepository.instance.getTransferDispatchStock(
      widget.transfer.id,
    );
    if (!mounted) return;
    setState(() {
      _stockAvailability = stock;
      _loadedQuantityError = _stockErrorForCurrentInput();
    });
  }

  String? _stockErrorForCurrentInput() {
    final stock = _stockAvailability;
    final attempted = double.tryParse(_loadedQuantityController.text.trim());
    if (stock == null || stock.length != 1 || attempted == null) return null;
    final available = stock.single.quantityCanGo;
    if ((attempted * 1000).round() <= (available * 1000).round()) return null;
    return context.l10n.transferDispatchStockExceeded(
      _formatQuantity(available),
      stock.single.unitCode.toLowerCase(),
      stock.single.name,
    );
  }

  void _onLoadedQuantityChanged(String _) {
    setState(() => _loadedQuantityError = _stockErrorForCurrentInput());
  }

  String _cameraRecoveryId(String field) =>
      'transfer.dispatch.${widget.transfer.id}.$field';

  Future<void> _restoreCameraResult() async {
    final recoveryId = await ImageCompressor.recoveredImageId();
    final prefix = 'transfer.dispatch.${widget.transfer.id}.';
    if (recoveryId == null || !recoveryId.startsWith(prefix)) return;
    final field = recoveryId.substring(prefix.length);
    if (field != 'vehicle' && field != 'weighbridge') return;
    final photo = await ImageCompressor.claimRecoveredImage(recoveryId);
    if (photo == null || !mounted) return;
    await _storePhoto(field, photo);
  }

  Future<void> _restoreDraft() async {
    final draft = await EerlLocalRepository.instance.getTransferDispatchDraft(
      widget.transfer.id,
    );
    if (!mounted) return;
    _vehicleController.text =
        draft.vehicleNumber ?? widget.transfer.plannedVehicleNumber ?? '';
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
    final photo = await InAppCameraScreen.capture(
      context,
      picker: _imagePicker,
      recoveryId: _cameraRecoveryId(field),
      title: field == 'vehicle'
          ? 'Capture Vehicle Photo'
          : 'Capture Weighbridge Slip',
    );
    if (photo == null || !mounted) return;
    await _storePhoto(field, photo);
  }

  Future<void> _storePhoto(String field, XFile photo) async {
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onBack();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: CustomAppBar(
          title: context.l10n.transferVehicleDetailsTitle,
          titleStyle: AppTextStyles.semiboldH6_20,
          onBackTap: widget.onBack,
          backIconAsset: 'assets/icons/records/back.svg',
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _loadingDraft
                  ? const Center(child: CircularProgressIndicator())
                  : _dispatchForm(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dispatchForm() => Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          key: const Key('transfer-vehicle-details-scroll'),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TransferNumberCard(
                number: widget.transfer.number ?? widget.transfer.id,
              ),
              const SizedBox(height: 24),
              _DispatchField(
                label: context.l10n.transferVehicleNumberRequired,
                hint: context.l10n.transferVehiclePlateInputHint,
                controller: _vehicleController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.transferVehicleNumberExample,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: 24),
              _DispatchField(
                label: context.l10n.transferDriverDetailRequired,
                hint: context.l10n.transferSelectDriverName,
                controller: _driverController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              AppRequiredText(
                context.l10n.transferLoadedWeightRequired,
                style: AppTextStyles.mediumSH8_14,
              ),
              const SizedBox(height: 8),
              _WeightUnitSelector(
                usePieces: _usePieces,
                onChanged: (value) => setState(() {
                  _usePieces = value;
                  _loadedQuantityError = _stockErrorForCurrentInput();
                }),
              ),
              const SizedBox(height: 8),
              _DispatchField(
                showLabel: false,
                label: context.l10n.transferLoadedWeightRequired,
                hint: context.l10n.transferLoadedWeightHint,
                controller: _loadedQuantityController,
                prefix: _usePieces
                    ? context.l10n.collectionUnitPcs
                    : context.l10n.transferKgPrefix,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                errorText: _loadedQuantityError,
                onChanged: _onLoadedQuantityChanged,
              ),
              const SizedBox(height: 24),
              _DispatchField(
                label: context.l10n.transferBalesRequired,
                hint: context.l10n.transferBalesCountHint,
                controller: _balesController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),
              AppRequiredText(
                context.l10n.transferLoadedAtRequired,
                style: AppTextStyles.mediumSH8_14,
              ),
              const SizedBox(height: 8),
              _LoadedAtField(
                value: _loadedAt,
                onTap: () =>
                    setState(() => _calendarExpanded = !_calendarExpanded),
              ),
              if (_calendarExpanded) ...[
                const SizedBox(height: 4),
                TransferDispatchDateTimePicker(
                  initialDateTime: _loadedAt,
                  onCancel: () => setState(() => _calendarExpanded = false),
                  onConfirm: (value) => setState(() {
                    _loadedAt = value;
                    _calendarExpanded = false;
                  }),
                ),
              ],
              const SizedBox(height: 24),
              _PhotoField(
                label: context.l10n.transferVehicleWeighbridgePhotoRequired,
                photos: _dispatchPhotos,
                onCapture: () => _capturePhoto('vehicle'),
                onRemove: _removePhoto,
              ),
            ],
          ),
        ),
      ),
      _ActionButton(
        buttonKey: const Key('transfer-submit-transfer'),
        label: context.l10n.transferSubmitTransfer,
        enabled: _formReady,
        onPressed: _submit,
      ),
    ],
  );

  Future<void> _submit() async {
    if (!_formReady) return;
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.saveTransferDispatchDraft(
        transferId: widget.transfer.id,
        vehicleNumber: _vehicleController.text,
        driverName: _driverController.text,
      );
      final loadedQuantity = double.parse(
        _loadedQuantityController.text.trim(),
      );
      await EerlLocalRepository.instance.submitTransferDispatch(
        transferId: widget.transfer.id,
        vehicleNumber: _vehicleController.text,
        driverName: _driverController.text,
        dispatchedWeight: loadedQuantity,
        baleCount: int.parse(_balesController.text.trim()),
        piecesLoaded: _usePieces ? loadedQuantity : null,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
    } on TransferDispatchStockExceededException catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _loadedQuantityError = context.l10n.transferDispatchStockExceeded(
          _formatQuantity(error.availableQuantity),
          error.unitCode.toLowerCase(),
          error.itemName,
        );
      });
      return;
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error(context, message: error.toString());
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

class _TransferNumberCard extends StatelessWidget {
  const _TransferNumberCard({required this.number});

  final String number;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [HomeStyles.cardShadow],
    ),
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
            number,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral900,
            ),
          ),
        ),
      ],
    ),
  );
}

class _WeightUnitSelector extends StatelessWidget {
  const _WeightUnitSelector({required this.usePieces, required this.onChanged});

  final bool usePieces;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 32,
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
      color: AppColors.cool200,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _WeightUnitOption(
          label: context.l10n.transferKgPrefix,
          selected: !usePieces,
          onTap: () => onChanged(false),
        ),
        _WeightUnitOption(
          label: context.l10n.collectionUnitPcs,
          selected: usePieces,
          onTap: () => onChanged(true),
        ),
      ],
    ),
  );
}

class _WeightUnitOption extends StatelessWidget {
  const _WeightUnitOption({
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
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 32,
        child: Center(
          child: Text(
            label,
            style:
                (selected
                        ? AppTextStyles.semiboldH9_14
                        : AppTextStyles.mediumSH8_14)
                    .copyWith(
                      color: selected ? Colors.white : AppColors.neutral950,
                    ),
          ),
        ),
      ),
    ),
  );
}

class _LoadedAtField extends StatelessWidget {
  const _LoadedAtField({required this.value, required this.onTap});

  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      key: const Key('transfer-loaded-at-field'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value == null
                    ? context.l10n.transferSelectDateTime
                    : DateFormat('dd MMM yyyy, hh:mm a').format(value!),
                style: AppTextStyles.regularB7_14.copyWith(
                  color: value == null
                      ? AppColors.cool500
                      : AppColors.neutral950,
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/icons/tasks/calendar.svg',
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.primary500,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DispatchField extends StatelessWidget {
  const _DispatchField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.prefix,
    this.keyboardType,
    this.showLabel = true,
    this.errorText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? prefix;
  final TextInputType? keyboardType;
  final bool showLabel;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (showLabel) ...[
        AppRequiredText(label, style: AppTextStyles.mediumSH8_14),
        const SizedBox(height: 8),
      ],
      SizedBox(
        height: errorText == null ? 55 : 78,
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
            errorText: errorText,
            errorMaxLines: 2,
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

String _formatQuantity(double value) {
  final fixed = value.toStringAsFixed(3);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
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
      AppRequiredText(label, style: AppTextStyles.mediumSH8_14),
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
                        : Material(
                            color: AppColors.cool200,
                            child: InkWell(
                              key: ValueKey(
                                'preview-transfer-photo-${photo.id}',
                              ),
                              onTap: () => AppImagePreviewDialog.showSource(
                                context,
                                photo.localPath!,
                              ),
                              child: Image.file(
                                File(photo.localPath!),
                                width: 82,
                                height: 58,
                                fit: BoxFit.cover,
                              ),
                            ),
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
