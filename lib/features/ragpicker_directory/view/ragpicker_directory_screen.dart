import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/logging/app_logger.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/core/utils/uuid_generator.dart';
import 'package:eerl_app/core/utils/image_compressor.dart';
import 'package:eerl_app/features/bootstrap/service/bootstrap_sync_service.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';
import 'package:eerl_app/shared/widgets/app_snackbar.dart';
import 'package:eerl_app/shared/widgets/in_app_camera_screen.dart';
import 'package:eerl_app/shared/widgets/app_top_notification.dart';
import 'package:eerl_app/shared/widgets/app_required_text.dart';
import 'package:eerl_app/shared/widgets/app_mobile_number_field.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import '../model/ragpicker_directory_item.dart';
import '../model/ragpicker_directory_view.dart';
import '../widgets/ragpicker_center_selector.dart';
import '../widgets/ragpicker_details_cards.dart';
import '../widgets/ragpicker_directory_card.dart';
import '../widgets/ragpicker_empty_state.dart';
import '../widgets/ragpicker_form_field.dart';
import '../widgets/ragpicker_photo_section.dart';
import '../widgets/ragpicker_segmented_control.dart';
import '../widgets/ragpicker_status_confirmation_dialog.dart';

class RagpickerDirectoryScreen extends StatefulWidget {
  const RagpickerDirectoryScreen({
    super.key,
    this.initialView = RagpickerDirectoryView.activeList,
    this.isSupervisor = false,
  });

  final RagpickerDirectoryView initialView;
  final bool isSupervisor;

  @override
  State<RagpickerDirectoryScreen> createState() =>
      _RagpickerDirectoryScreenState();
}

class _RagpickerDirectoryScreenState extends State<RagpickerDirectoryScreen> {
  static const _cameraRecoveryId = 'ragpicker.directory.form';
  late RagpickerDirectoryView _view = widget.initialView;
  late RagpickerStatus _status = switch (widget.initialView) {
    RagpickerDirectoryView.deactivatedList ||
    RagpickerDirectoryView.deactivatedDetails => RagpickerStatus.deactivated,
    _ => RagpickerStatus.active,
  };
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _identityController = TextEditingController();
  final _imagePicker = ImagePicker();
  List<RagpickerModel> _allItems = const [];
  List<CenterModel> _centers = const [];
  bool _loading = true;
  RagpickerModel? _selectedItem;
  RagpickerModel? _editingItem;
  String _query = '';
  String? _nameError;
  List<String> _photoSources = const [];
  bool _saving = false;
  bool _centerExpanded = false;
  bool _formZoneExpanded = false;
  late int _selectedCenter = _status == RagpickerStatus.deactivated ? 0 : -1;
  int _formZoneIndex = -1;

  List<String> get _centerOptions =>
      _centers.map((center) => center.name).toList(growable: false);

  List<RagpickerModel> get _items => _allItems
      .where((item) => item.isActive == (_status == RagpickerStatus.active))
      .where((item) {
        final query = _query.trim().toLowerCase();
        return query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            (item.phone ?? '').contains(query);
      })
      .toList(growable: false);

  @override
  void initState() {
    super.initState();
    _load();
    _restoreCameraResult();
  }

  Future<void> _restoreCameraResult() async {
    final photo = await ImageCompressor.claimRecoveredImage(_cameraRecoveryId);
    if (photo == null || !mounted) return;
    setState(() {
      if (_photoSources.length < 2) {
        _photoSources = [..._photoSources, photo.path];
      }
      _view = RagpickerDirectoryView.addEmpty;
    });
  }

  Future<void> _load({String? centerId}) async {
    setState(() => _loading = true);
    final repository = EerlLocalRepository.instance;
    final centers = await repository.getMyCenters();
    var selected = centerId ?? await repository.activeCenterId;
    if (selected == null && centers.isNotEmpty) selected = centers.first.id;
    final items = selected == null
        ? const <RagpickerModel>[]
        : await repository.getRagpickers(centerId: selected);
    if (!mounted) return;
    setState(() {
      _centers = centers;
      _selectedCenter = centers.indexWhere((center) => center.id == selected);
      _allItems = items;
      if ((_view == RagpickerDirectoryView.activeDetails ||
              _view == RagpickerDirectoryView.deactivatedDetails) &&
          _selectedItem == null) {
        for (final item in items) {
          if (item.isActive == (_status == RagpickerStatus.active)) {
            _selectedItem = item;
            break;
          }
        }
      }
      _loading = false;
    });
  }

  String _centerName(String id) {
    for (final center in _centers) {
      if (center.id == id) return center.name;
    }
    return '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop:
        _selectedItem == null &&
        _view != RagpickerDirectoryView.addEmpty &&
        _view != RagpickerDirectoryView.addFilled,
    onPopInvokedWithResult: (didPop, _) {
      if (didPop) return;
      setState(() {
        _selectedItem = null;
        _view = RagpickerDirectoryView.activeList;
      });
    },
    child: _selectedItem != null
        ? _buildDetails()
        : _view == RagpickerDirectoryView.addEmpty ||
              _view == RagpickerDirectoryView.addFilled
        ? _buildForm()
        : _buildDirectory(),
  );

  Future<void> _confirmStatusChange(bool currentlyActive) async {
    final confirmed = await RagpickerStatusConfirmationDialog.show(
      context: context,
      title: context.l10n.ragpickerConfirmationTitle,
      message: currentlyActive
          ? context.l10n.ragpickerDeactivateConfirmation
          : context.l10n.ragpickerReactivateConfirmation,
      cancelLabel: context.l10n.cancel,
      confirmLabel: context.l10n.ragpickerYes,
      confirmColor: currentlyActive ? AppColors.red500 : AppColors.primary500,
    );
    if (!mounted || !confirmed) return;

    final item = _selectedItem!;
    await EerlLocalRepository.instance.setRagpickerActive(
      item,
      !currentlyActive,
    );
    unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
    if (!mounted) return;
    setState(() {
      _status = currentlyActive
          ? RagpickerStatus.deactivated
          : RagpickerStatus.active;
      _selectedItem = RagpickerModel(
        id: item.id,
        number: item.number,
        centerId: item.centerId,
        name: item.name,
        phone: item.phone,
        idNumber: item.idNumber,
        photoUrl: item.photoUrl,
        isActive: !currentlyActive,
        syncState: 'pending',
      );
    });
    AppTopNotification.show(
      context,
      key: const Key('ragpicker-status-notification'),
      title: currentlyActive
          ? context.l10n.ragpickerDeactivatedSuccess
          : context.l10n.ragpickerReactivatedSuccess,
      subtitle: currentlyActive
          ? context.l10n.ragpickerDeactivatedSubtitle
          : context.l10n.ragpickerReactivatedSubtitle,
      tone: currentlyActive
          ? AppTopNotificationTone.error
          : AppTopNotificationTone.success,
    );
    await _load(centerId: item.centerId);
  }

  Widget _buildDirectory() {
    final items = _items;
    final centers = _centerOptions;
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
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        sliver: SliverList.list(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: _FigmaBackButton(
                                onTap: () => Navigator.of(context).maybePop(),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              context.l10n.ragpickerDirectoryTitle,
                              style: AppTextStyles.semiboldH6_20.copyWith(
                                color: AppColors.neutral950,
                              ),
                            ),
                            SizedBox(height: widget.isSupervisor ? 16 : 24),
                            if (widget.isSupervisor) ...[
                              RagpickerCenterSelector(
                                label: _centerExpanded
                                    ? context.l10n.ragpickerAssignTargetCenter
                                    : context
                                          .l10n
                                          .ragpickerAssignTargetAgentCenter,
                                hint: _centerExpanded
                                    ? context.l10n.ragpickerSelectCenter
                                    : context.l10n.ragpickerAllCenters,
                                options: centers,
                                selectedIndex: _selectedCenter,
                                expanded: _centerExpanded,
                                requiredField:
                                    _centerExpanded ||
                                    _status == RagpickerStatus.deactivated,
                                onToggle: () => setState(
                                  () => _centerExpanded = !_centerExpanded,
                                ),
                                onSelected: (index) {
                                  setState(() {
                                    _selectedCenter = index;
                                    _centerExpanded = false;
                                  });
                                  _load(centerId: _centers[index].id);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                            RagpickerSegmentedControl(
                              status: _status,
                              activeLabel: context.l10n.ragpickerActiveCount(
                                _allItems.where((item) => item.isActive).length,
                              ),
                              deactivatedLabel: context.l10n
                                  .ragpickerDeactivatedCount(
                                    _allItems
                                        .where((item) => !item.isActive)
                                        .length,
                                  ),
                              onChanged: (value) => setState(() {
                                _status = value;
                                _view = value == RagpickerStatus.active
                                    ? RagpickerDirectoryView.activeList
                                    : RagpickerDirectoryView.deactivatedList;
                                _centerExpanded = false;
                              }),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 55,
                              child: TextField(
                                key: const Key('ragpicker-search-field'),
                                controller: _searchController,
                                onChanged: (value) =>
                                    setState(() => _query = value),
                                style: AppTextStyles.regularB7_14,
                                decoration: InputDecoration(
                                  hintText: context.l10n.ragpickerSearchHint,
                                  hintStyle: AppTextStyles.regularB7_14
                                      .copyWith(color: AppColors.neutral500),
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: SvgPicture.asset(
                                      'assets/icons/wallet/search.svg',
                                      width: 24,
                                      height: 24,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.cool600,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.cool400,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: AppColors.primary500,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (_loading)
                        const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (items.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: RagpickerEmptyState(
                              message: context.l10n.ragpickerNoDetailsFound,
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          sliver: SliverList.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) =>
                                RagpickerDirectoryCard(
                                  item: items[index],
                                  onTap: () => setState(() {
                                    _selectedItem = items[index];
                                    _view = _status == RagpickerStatus.active
                                        ? RagpickerDirectoryView.activeDetails
                                        : RagpickerDirectoryView
                                              .deactivatedDetails;
                                  }),
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (_status == RagpickerStatus.active)
                  _BottomAction(
                    label: context.l10n.ragpickerAddButton,
                    onPressed: () => setState(() {
                      _view = RagpickerDirectoryView.addEmpty;
                      _editingItem = null;
                      _nameController.clear();
                      _phoneController.clear();
                      _identityController.clear();
                      _nameError = null;
                      _photoSources = const [];
                      _formZoneIndex = -1;
                      _formZoneExpanded = false;
                    }),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final item = _selectedItem!;
    final active = item.isActive;
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
                  child: _FigmaBackButton(
                    onTap: () => setState(() => _selectedItem = null),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      RagpickerRegistrationCard(
                        registrationId: item.number ?? '',
                      ),
                      const SizedBox(height: 16),
                      RagpickerInformationCard(
                        item: item,
                        fullNameLabel: context.l10n.ragpickerFullNameLabel,
                        mobileLabel: context.l10n.ragpickerMobileLabel,
                        identityLabel: context.l10n.ragpickerIdentityLabel,
                        dateLabel: context.l10n.ragpickerDateTimeLabel,
                        zoneLabel: widget.isSupervisor
                            ? context.l10n.ragpickerZoneLocationLabel
                            : null,
                        zoneValue: widget.isSupervisor
                            ? _centerName(item.centerId)
                            : null,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<List<String>>(
                        future: EerlLocalRepository.instance
                            .getRagpickerPhotoSources(item.id),
                        initialData: item.photoUrls,
                        builder: (context, snapshot) {
                          final photos =
                              (snapshot.data != null &&
                                      snapshot.data!.isNotEmpty)
                                  ? snapshot.data!
                                  : item.photoUrls;
                          return RagpickerProofCard(
                            title: context.l10n.ragpickerProofLabel,
                            photoUrls: photos,
                            photoUrl: item.photoUrl,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                _DetailActions(
                  active: active,
                  onStatusTap: () => _confirmStatusChange(active),
                  onEdit: active
                      ? () async {
                          final localPhotos = await EerlLocalRepository.instance
                              .getRagpickerPhotoSources(item.id);
                          final initialPhotos = localPhotos.isNotEmpty
                              ? localPhotos
                              : item.photoUrls;
                          if (!mounted) return;
                          setState(() {
                            _nameController.text = item.name;
                            _phoneController.text = _editablePhone(item.phone);
                            _identityController.text = item.idNumber ?? '';
                            _nameError = null;
                            _photoSources = List<String>.from(initialPhotos);
                            _formZoneIndex = _centers.indexWhere(
                              (center) => center.id == item.centerId,
                            );
                            _formZoneExpanded = false;
                            _editingItem = item;
                            _selectedItem = null;
                            _view = RagpickerDirectoryView.addFilled;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _FigmaBackButton(
                        onTap: () => setState(
                          () => _view = RagpickerDirectoryView.activeList,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _view == RagpickerDirectoryView.addFilled
                          ? context.l10n.ragpickerEditTitle
                          : context.l10n.ragpickerAddNewTitle,
                      style: AppTextStyles.semiboldH6_20,
                    ),
                    const SizedBox(height: 24),
                    RagpickerFormField(
                      label: context.l10n.ragpickerNameLabel,
                      hint: context.l10n.ragpickerNameHint,
                      controller: _nameController,
                      errorText: _nameError,
                      onChanged: (value) {
                        final error = _nameValidationError(
                          value,
                          showRequired: false,
                        );
                        if (error != _nameError) {
                          setState(() => _nameError = error);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    _MobileField(
                      label: context.l10n.ragpickerMobileLabel,
                      hint: context.l10n.ragpickerPhoneHint,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 16),
                    RagpickerFormField(
                      label: context.l10n.ragpickerAadhaarLabel,
                      hint: context.l10n.ragpickerAadhaarHint,
                      controller: _identityController,
                    ),
                    if (widget.isSupervisor) ...[
                      const SizedBox(height: 16),
                      RagpickerCenterSelector(
                        label: context.l10n.ragpickerZoneLocationLabel,
                        hint: context.l10n.ragpickerSelectZone,
                        options: _centerOptions,
                        selectedIndex: _formZoneIndex,
                        expanded: _formZoneExpanded,
                        onToggle: () => setState(
                          () => _formZoneExpanded = !_formZoneExpanded,
                        ),
                        onSelected: (index) => setState(() {
                          _formZoneIndex = index;
                          _formZoneExpanded = false;
                        }),
                      ),
                    ],
                    const SizedBox(height: 16),
                    RagpickerPhotoSection(
                      label: context.l10n.ragpickerProofLabel,
                      captureLabel: context.l10n.ragpickerCapturePhoto,
                      helperText: context.l10n.ragpickerPhotoHelper,
                      photoSources: _photoSources,
                      onCapture: _capturePhoto,
                      onRemove: (index) => setState(() {
                        _photoSources = List<String>.from(_photoSources)
                          ..removeAt(index);
                      }),
                    ),
                  ],
                ),
              ),
              _FormActions(
                cancelLabel: context.l10n.cancel,
                saveLabel: context.l10n.saveAndSelect,
                onCancel: () =>
                    setState(() => _view = RagpickerDirectoryView.activeList),
                onSave: _saving ? null : _saveForm,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _capturePhoto() async {
    if (_photoSources.length >= 2) return;
    final photo = await InAppCameraScreen.capture(
      context,
      picker: _imagePicker,
      recoveryId: _cameraRecoveryId,
      title: 'Capture Ragpicker Photo',
    );
    if (photo == null || !mounted) return;
    setState(() => _photoSources = [..._photoSources, photo.path]);
  }

  Future<void> _saveForm() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final nameError = _nameValidationError(name, showRequired: true);
    if (nameError != null) {
      setState(() => _nameError = nameError);
      return;
    }
    final existing = _editingItem;
    if (phone.isNotEmpty && phone.length != 10) {
      AppSnackbar.error(context, message: context.l10n.ragpickerInvalidMobile);
      return;
    }
    if (_centers.isEmpty) return;
    var centerIndex = _formZoneIndex >= 0 ? _formZoneIndex : _selectedCenter;
    if (centerIndex < 0 || centerIndex >= _centers.length) {
      final activeCenterId = await EerlLocalRepository.instance.activeCenterId;
      centerIndex = _centers.indexWhere(
        (center) => center.id == activeCenterId,
      );
    }
    if (!mounted) return;
    if (centerIndex < 0 || centerIndex >= _centers.length) {
      AppSnackbar.error(context, message: 'Select a center.');
      return;
    }
    final localPhotoPaths = _photoSources
        .where(
          (s) =>
              s.trim().isNotEmpty &&
              !s.startsWith('http://') &&
              !s.startsWith('https://'),
        )
        .toList();
    final photoUrlValue = _photoSources.isEmpty
        ? null
        : (_photoSources.length == 1
            ? _photoSources.first
            : jsonEncode(_photoSources));
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.saveRagpicker(
        RagpickerModel(
          id: existing?.id ?? UuidGenerator.v4(),
          number: existing?.number,
          centerId: _centers[centerIndex].id,
          name: name,
          phone: phone.isEmpty ? null : phone,
          idNumber: _identityController.text.trim().isEmpty
              ? null
              : _identityController.text.trim(),
          photoUrl: photoUrlValue,
          isActive: true,
          syncState: 'pending',
        ),
        localPhotoPaths: localPhotoPaths,
      );
      unawaited(BootstrapSyncService.instance.triggerAfterLocalMutation());
      if (!mounted) return;
      setState(() {
        _editingItem = null;
        _status = RagpickerStatus.active;
        _view = RagpickerDirectoryView.activeList;
        _photoSources = const [];
      });
      await _load(centerId: _centers[centerIndex].id);
    } catch (error) {
      AppLogger.error('RAGPICKER_SAVE', error.toString());
      if (mounted) {
        AppSnackbar.error(context, message: error.toString());
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _normalizeRagpickerName(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _editablePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    return digits.length <= 10 ? digits : digits.substring(digits.length - 10);
  }

  String? _nameValidationError(String value, {required bool showRequired}) {
    final name = value.trim();
    if (name.isEmpty) {
      return showRequired ? context.l10n.ragpickerNameRequired : null;
    }
    final existing = _editingItem;
    final normalizedName = _normalizeRagpickerName(name);
    final nameAlreadyExists = _allItems.any(
      (item) =>
          item.id != existing?.id &&
          _normalizeRagpickerName(item.name) == normalizedName,
    );
    return nameAlreadyExists
        ? context.l10n.ragpickerNameAlreadyExists(name)
        : null;
  }
}

class _FigmaBackButton extends StatelessWidget {
  const _FigmaBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppSquareBackButton(
    key: const Key('ragpicker-back-button'),
    onTap: onTap,
  );
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({required this.label, required this.onPressed});

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
        key: const Key('ragpicker-primary-button'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
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

class _MobileField extends StatelessWidget {
  const _MobileField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppRequiredText(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      AppMobileNumberField(
        controller: controller,
        hintText: hint,
        countryCodeKey: const Key('ragpicker-country-code-box'),
        phoneFieldKey: const Key('ragpicker-mobile-number-field'),
      ),
    ],
  );
}

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.cancelLabel,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    minimum: const EdgeInsets.fromLTRB(20, 10, 20, 16),
    child: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cool200,
                foregroundColor: AppColors.neutral950,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.mediumSH7_16,
              ),
              child: Text(cancelLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const Key('ragpicker-primary-button'),
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.boldH7_16,
              ),
              child: Text(saveLabel),
            ),
          ),
        ),
      ],
    ),
  );
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.active,
    required this.onStatusTap,
    this.onEdit,
  });

  final bool active;
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
              key: const Key('ragpicker-status-button'),
              onPressed: onStatusTap,
              icon: SvgPicture.asset(
                active
                    ? 'assets/icons/ragpicker_deactivate.svg'
                    : 'assets/icons/profile/sync_refresh.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: active
                    ? AppColors.red600
                    : AppColors.primary500,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: AppTextStyles.boldH7_16,
              ),
              label: Text(
                active
                    ? context.l10n.deactivate
                    : context.l10n.ragpickerReactiveButton,
              ),
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
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: AppTextStyles.boldH7_16,
                ),
                label: Text(context.l10n.edit),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
