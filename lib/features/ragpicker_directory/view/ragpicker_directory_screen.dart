import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:eerl_app/shared/widgets/app_square_back_button.dart';
import '../model/ragpicker_directory_item.dart';
import '../model/ragpicker_directory_view.dart';
import '../widgets/ragpicker_center_selector.dart';
import '../widgets/ragpicker_details_cards.dart';
import '../widgets/ragpicker_directory_card.dart';
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
  static const _initialItems = <RagpickerDirectoryItem>[
    RagpickerDirectoryItem(
      id: 'ramesh',
      name: 'Ramesh Bhai Patel',
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'umesh',
      name: 'Umesh Yadav',
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'manohar',
      name: 'Manohar Tiwari',
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'ramchand',
      name: 'Ramchand Tripathi',
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'karshan',
      name: 'Karshan Yadav',
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'vikas',
      name: 'Vikas Prajapati',
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'suresh',
      name: 'Suresh Makwana',
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'munna',
      name: 'Munna Tripathi',
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
  ];

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
  RagpickerDirectoryItem? _selectedItem;
  String _query = '';
  bool _hasPhotos = false;
  bool _showStatusSuccess = false;
  bool _successIsReactivation = false;
  bool _centerExpanded = false;
  bool _formZoneExpanded = false;
  late int _selectedCenter = _status == RagpickerStatus.deactivated ? 0 : -1;
  int _formZoneIndex = -1;

  List<RagpickerDirectoryItem> _localizedItems(BuildContext context) => [
    RagpickerDirectoryItem(
      id: 'chunilal',
      name: context.l10n.ragpickerPersonChunilal,
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'umesh',
      name: context.l10n.ragpickerPersonUmesh,
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'manohar',
      name: context.l10n.ragpickerPersonManohar,
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'ramchand',
      name: context.l10n.ragpickerPersonRamchand,
      phone: '+91 98765 43210',
      status: RagpickerStatus.active,
    ),
    RagpickerDirectoryItem(
      id: 'karshan',
      name: context.l10n.ragpickerPersonKarshan,
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'vikas',
      name: context.l10n.ragpickerPersonVikas,
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'suresh',
      name: context.l10n.ragpickerPersonSuresh,
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
    RagpickerDirectoryItem(
      id: 'munna',
      name: context.l10n.ragpickerPersonMunna,
      phone: '+91 98765 43210',
      status: RagpickerStatus.deactivated,
    ),
  ];

  List<String> _centerOptions(BuildContext context) => [
    context.l10n.ragpickerCenterSurat,
    context.l10n.ragpickerCenterSuratEast,
    context.l10n.ragpickerCenterSuratWest,
    context.l10n.ragpickerCenterSuratSouth,
  ];

  List<RagpickerDirectoryItem> _items(BuildContext context) =>
      (widget.isSupervisor ? _localizedItems(context) : _initialItems)
          .where((item) => item.status == _status)
          .where((item) {
            final query = _query.trim().toLowerCase();
            return query.isEmpty ||
                item.name.toLowerCase().contains(query) ||
                item.phone.contains(query);
          })
          .toList(growable: false);

  @override
  void initState() {
    super.initState();
    if (_view == RagpickerDirectoryView.activeDetails) {
      _selectedItem = _initialItems.first;
    } else if (_view == RagpickerDirectoryView.deactivatedDetails) {
      _selectedItem = _initialItems.firstWhere(
        (item) => item.status == RagpickerStatus.deactivated,
      );
      _showStatusSuccess = true;
    } else if (_view == RagpickerDirectoryView.addFilled) {
      _nameController.text = 'Ramesh Bhai Patel';
      _phoneController.text = '1234567890';
      _identityController.text = '8478 8456 63245';
      _hasPhotos = true;
      _formZoneIndex = 0;
    }
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
        _showStatusSuccess = false;
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

    setState(() {
      _status = currentlyActive
          ? RagpickerStatus.deactivated
          : RagpickerStatus.active;
      _selectedItem = _selectedItem?.copyWith(status: _status);
      _showStatusSuccess = true;
      _successIsReactivation = !currentlyActive;
    });
  }

  Widget _buildDirectory() {
    final items = _items(context);
    final centers = _centerOptions(context);
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
                                onSelected: (index) => setState(() {
                                  _selectedCenter = index;
                                  _centerExpanded = false;
                                }),
                              ),
                              const SizedBox(height: 16),
                            ],
                            RagpickerSegmentedControl(
                              status: _status,
                              activeLabel: context.l10n.ragpickerActiveCount(
                                12,
                              ),
                              deactivatedLabel: context.l10n
                                  .ragpickerDeactivatedCount(5),
                              onChanged: (value) => setState(() {
                                _status = value;
                                _view = value == RagpickerStatus.active
                                    ? RagpickerDirectoryView.activeList
                                    : RagpickerDirectoryView.deactivatedList;
                                _selectedCenter =
                                    value == RagpickerStatus.active ? -1 : 0;
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
                                  _selectedItem = widget.isSupervisor
                                      ? items[index].copyWith(
                                          phone: '+91 1234567890',
                                        )
                                      : items[index];
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
                      _nameController.clear();
                      _phoneController.clear();
                      _identityController.clear();
                      _hasPhotos = false;
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
    final active =
        item.status == RagpickerStatus.active &&
        (!_showStatusSuccess || _successIsReactivation);
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
                    onTap: () => setState(() {
                      _selectedItem = null;
                      _showStatusSuccess = false;
                    }),
                  ),
                ),
                const SizedBox(height: 24),
                if (_showStatusSuccess)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _SuccessBanner(
                      reactivated: _successIsReactivation,
                      onClose: () => setState(() => _showStatusSuccess = false),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    children: [
                      RagpickerRegistrationCard(
                        registrationId: item.registrationId,
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
                            ? context.l10n.ragpickerCenterSurat
                            : null,
                      ),
                      const SizedBox(height: 16),
                      RagpickerProofCard(
                        title: context.l10n.ragpickerProofLabel,
                      ),
                    ],
                  ),
                ),
                _DetailActions(
                  active: active,
                  onStatusTap: () => _confirmStatusChange(active),
                  onEdit: active
                      ? () => setState(() {
                          _nameController.text = item.name;
                          _phoneController.text = item.phone
                              .replaceAll('+91 ', '')
                              .replaceAll(' ', '');
                          _identityController.text = item.identityNumber;
                          _hasPhotos = true;
                          _formZoneIndex = 0;
                          _formZoneExpanded = false;
                          _selectedItem = null;
                          _view = RagpickerDirectoryView.addFilled;
                        })
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
                    ),
                    const SizedBox(height: 16),
                    _MobileField(
                      label: context.l10n.ragpickerPhoneLabel,
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
                        options: _centerOptions(context),
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
                      hasPhotos: _hasPhotos,
                      onCapture: () => setState(() => _hasPhotos = true),
                      onRemove: (_) => setState(() => _hasPhotos = false),
                    ),
                  ],
                ),
              ),
              _FormActions(
                cancelLabel: context.l10n.cancel,
                saveLabel: context.l10n.saveAndSelect,
                onCancel: () =>
                    setState(() => _view = RagpickerDirectoryView.activeList),
                onSave: () => setState(() {
                  _status = RagpickerStatus.active;
                  _view = RagpickerDirectoryView.activeList;
                }),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
      Text(label, style: AppTextStyles.mediumSH8_14),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('+91', style: AppTextStyles.mediumSH8_14),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SizedBox(
              height: 55,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: AppTextStyles.regularB7_14,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: AppTextStyles.regularB7_14.copyWith(
                    color: AppColors.cool500,
                  ),
                  filled: true,
                  fillColor: Colors.white,
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
          ),
        ],
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
  final VoidCallback onSave;

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

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.reactivated, required this.onClose});

  final bool reactivated;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => AppMessageBanner(
    key: ValueKey(
      reactivated
          ? 'ragpicker-reactivated-banner'
          : 'ragpicker-deactivated-banner',
    ),
    padding: const EdgeInsets.all(12),
    title: reactivated
        ? context.l10n.ragpickerReactivatedSuccess
        : context.l10n.ragpickerDeactivatedSuccess,
    subtitle: reactivated
        ? context.l10n.ragpickerReactivatedSubtitle
        : context.l10n.ragpickerDeactivatedSubtitle,
    color: reactivated ? AppColors.primary500 : AppColors.red500,
    backgroundColor: reactivated ? AppColors.primary50 : AppColors.red50,
    borderColor: AppColors.cool400,
    autoDismiss: false,
    subtitleStyle: AppTextStyles.regularB7_14.copyWith(
      color: AppColors.neutral500,
    ),
    iconBackgroundColor: reactivated ? AppColors.primary500 : AppColors.red500,
    iconPadding: const EdgeInsets.all(5),
    icon: reactivated
        ? const Icon(Icons.check, size: 18, color: Colors.white)
        : SvgPicture.asset(
            'assets/icons/ragpicker_deactivated.svg',
            width: 22,
            height: 22,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
    onClose: onClose,
  );
}
