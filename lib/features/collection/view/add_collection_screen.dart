import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/router/app_routes.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import '../model/collection_entry_state.dart';
import '../widgets/collection_step_indicator.dart';
import '../widgets/collection_success_dialog.dart';
import '../widgets/d2d_collection_photos_step.dart';
import '../widgets/d2d_vehicle_details_form.dart';
import '../widgets/d2d_waste_items_step.dart';
import '../widgets/mrf_details_form.dart';
import '../widgets/ramp_details_form.dart';
import 'package:go_router/go_router.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({
    super.key,
    this.initialStep = CollectionEntryStep.items,
    this.initialType,
    this.initialSelectedItems = const <int>{},
    this.initialD2dReview = false,
  });

  final CollectionEntryStep initialStep;
  final CollectionType? initialType;
  final Set<int> initialSelectedItems;
  final bool initialD2dReview;

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  late CollectionEntryStep _step;
  CollectionType? _type;
  bool _typeOpen = false, _itemsOpen = false;
  bool _conditionalFieldOpen = false;
  bool _showPlasticItems = true;
  late bool _d2dReview;
  final Set<int> _selected = {};
  final Map<int, List<XFile>> _photos = {};
  final Map<int, String> _collectionWeights = {};
  final Map<int, String> _verifiedWeights = {};
  final Map<int, D2dMeasureUnit> _d2dUnits = {};
  final ImagePicker _imagePicker = ImagePicker();
  String? _vehicleNumber;
  String _givenBy = '';
  String? _personName;
  String? _mrfAgentName;
  String? _mrfLabor;
  D2dPaymentMode _d2dPaymentMode = D2dPaymentMode.cash;
  List<VehicleModel> _vehicles = const [];
  List<MrfPersonModel> _mrfPeople = const [];
  List<RagpickerModel> _ragpickers = const [];
  List<ItemModel> _materials = const [];
  ProfileModel? _profile;
  String? _centerId;
  String? _userId;
  String? _draftId;

  List<String> get _vehicleNumbers =>
      _vehicles.map((item) => item.plateNumber).toList(growable: false);
  List<String> get _personNamesList =>
      _ragpickers.map((item) => item.name).toList(growable: false);
  List<String> get _mrfPersonNames =>
      _mrfPeople.map((item) => item.name).toList(growable: false);

  @override
  void initState() {
    super.initState();
    _step = widget.initialStep;
    _d2dReview = widget.initialD2dReview;
    _type = widget.initialType;
    if (_type == CollectionType.mrfStation) {
      _mrfAgentName = null;
    }
    _selected.addAll(widget.initialSelectedItems);
    _loadReferenceData();
  }

  List<String> _itemNames(BuildContext c) =>
      _materials.map((item) => item.name).toList(growable: false);

  String get _channel => switch (_type) {
    CollectionType.d2d => 'D2D',
    CollectionType.mrfStation => 'MRF',
    CollectionType.ramp => 'RAMP',
    null => 'D2D',
  };

  Future<void> _loadReferenceData() async {
    final repository = EerlLocalRepository.instance;
    final centerId = await repository.activeCenterId;
    final values = await Future.wait([
      repository.getVehicles(centerId: centerId),
      repository.getMrfPeople(centerId: centerId),
      repository.getRagpickers(centerId: centerId, activeOnly: true),
      repository.getItems(
        centerId: centerId,
        channel: _channel,
        selectedOnly: true,
      ),
      repository.getProfile(),
      repository.currentUserId,
    ]);
    if (!mounted) return;
    setState(() {
      _centerId = centerId;
      _vehicles = values[0] as List<VehicleModel>;
      _mrfPeople = values[1] as List<MrfPersonModel>;
      _ragpickers = values[2] as List<RagpickerModel>;
      _materials = values[3] as List<ItemModel>;
      _profile = values[4] as ProfileModel;
      _userId = values[5] as String?;
      _mrfAgentName = _profile?.userName;
      _selected.removeWhere((index) => index >= _materials.length);
    });
  }

  int get _stepNumber => _step.index + 1;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _step == CollectionEntryStep.items && !_d2dReview,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _goBack();
    },
    child: _buildContent(context),
  );

  Widget _buildContent(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BackButton(onTap: _goBack),
                      if (!_d2dReview) ...[
                        const SizedBox(height: 24),
                        CollectionStepIndicator(currentStep: _stepNumber),
                        const SizedBox(height: 24),
                      ] else
                        const SizedBox(height: 20),
                      if (_d2dReview)
                        _reviewStep(context)
                      else if (_step == CollectionEntryStep.items)
                        _itemsStep(context)
                      else if (_step == CollectionEntryStep.photos)
                        _type == CollectionType.d2d ||
                                _type == CollectionType.mrfStation ||
                                _type == CollectionType.ramp
                            ? _d2dWasteItemsStep(context)
                            : _photosStep(context)
                      else if (_type == CollectionType.d2d ||
                          _type == CollectionType.mrfStation ||
                          _type == CollectionType.ramp)
                        _d2dCollectionPhotosStep(context)
                      else
                        _reviewStep(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: _bottomButtons(context),
          ),
        ],
      ),
    ),
  );

  Widget _itemsStep(BuildContext context) {
    if (_type == CollectionType.d2d) {
      return D2dVehicleDetailsForm(
        vehicleNumbers: _vehicleNumbers,
        selectedVehicle: _vehicleNumber,
        givenBy: _givenBy,
        vehiclePhoto: (_photos[-1]?.isNotEmpty ?? false)
            ? _photos[-1]!.first
            : null,
        onVehicleSelected: (vehicle) => setState(() {
          _vehicleNumber = vehicle;
        }),
        onGivenByChanged: (value) => setState(() => _givenBy = value),
        onCapturePhoto: _pickVehicleImage,
        onRemovePhoto: () => setState(() => _photos.remove(-1)),
        onPreviewPhoto: () {
          final image = (_photos[-1]?.isNotEmpty ?? false)
              ? _photos[-1]!.first
              : null;
          if (image != null) _showImagePreview(image);
        },
      );
    }
    if (_type == CollectionType.mrfStation) {
      return MrfDetailsForm(
        people: _mrfPersonNames,
        selectedLabor: _mrfLabor,
        onLaborSelected: (person) => setState(() => _mrfLabor = person),
        supervisorName: _profile?.supervisorName,
        supervisorPhone: _profile?.supervisorPhone,
      );
    }
    if (_type == CollectionType.ramp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(context.l10n.collectionTypeLabel),
          const SizedBox(height: 8),
          Container(
            key: const Key('ramp-collection-type'),
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cool200,
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  _typeIcon,
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    AppColors.neutral900,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
                Text(_typeLabel(context), style: AppTextStyles.regularB7_14),
              ],
            ),
          ),
          const SizedBox(height: 24),
          RampDetailsForm(
            personNames: _personNamesList,
            selectedPerson: _personName,
            photo: (_photos[99]?.isNotEmpty ?? false)
                ? _photos[99]!.first
                : null,
            onPersonSelected: (person) => setState(() {
              _personName = person;
            }),
            onAddNewPerson: (newPerson) => setState(() {
              if (!_personNamesList.contains(newPerson)) {
                _personNamesList.add(newPerson);
              }
              _personName = newPerson;
            }),
            onCapturePhoto: () async {
              try {
                final image = await _imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  setState(() => _photos[99] = [image]);
                }
              } catch (_) {}
            },
            onRemovePhoto: () => setState(() => _photos.remove(99)),
            onPreviewPhoto: () {
              final image = (_photos[99]?.isNotEmpty ?? false)
                  ? _photos[99]!.first
                  : null;
              if (image != null) _showImagePreview(image);
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.collectionItemsReceived,
          style: AppTextStyles.semiboldH7_18,
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.collectionItemsReceivedSubtitle,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 24),
        _label(context.l10n.collectionTypeLabel),
        const SizedBox(height: 8),
        _Selector(
          key: const Key('collection-type-selector'),
          text: _typeLabel(context),
          open: _typeOpen,
          leadingIcon: _type == null ? null : _typeIcon,
          onTap: () => setState(() => _typeOpen = !_typeOpen),
        ),
        if (_typeOpen) _typeDropdown(context),
        if (_type != null) ...[
          const SizedBox(height: 24),
          ..._conditionalField(context),
        ],
        const SizedBox(height: 24),
        _label(context.l10n.collectionAddItemLabel),
        const SizedBox(height: 8),
        _Selector(
          key: const Key('collection-item-selector'),
          text: _selected.isEmpty
              ? context.l10n.collectionSelectWasteItem
              : context.l10n.collectionItemsSelected(_selected.length),
          open: _itemsOpen,
          onTap: () => setState(() => _itemsOpen = !_itemsOpen),
        ),
        if (_itemsOpen) _itemDropdown(context),
      ],
    );
  }

  List<Widget> _conditionalField(BuildContext context) {
    if (_type == CollectionType.mrfStation) {
      return [
        _label(context.l10n.collectionMrfAgentName),
        const SizedBox(height: 8),
        Container(
          key: const Key('collection-mrf-agent-fixed-field'),
          width: double.infinity,
          height: 55,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.neutral50,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _mrfAgentName ?? '',
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.cool950,
            ),
          ),
        ),
      ];
    }

    final (label, placeholder, value, options) = switch (_type!) {
      CollectionType.d2d => (
        context.l10n.collectionVehicleNumber,
        context.l10n.collectionSelectVehicle,
        _vehicleNumber,
        _vehicleNumbers,
      ),
      CollectionType.mrfStation => throw StateError('Handled above'),
      CollectionType.ramp => (
        context.l10n.collectionPersonName,
        context.l10n.collectionSelectPerson,
        _personName,
        _personNamesList,
      ),
    };
    return [
      _label(label),
      const SizedBox(height: 8),
      _Selector(
        key: const Key('collection-conditional-selector'),
        text: value ?? placeholder,
        open: _conditionalFieldOpen,
        onTap: () =>
            setState(() => _conditionalFieldOpen = !_conditionalFieldOpen),
      ),
      if (_conditionalFieldOpen)
        _DropdownBox(
          children: options
              .map(
                (option) => InkWell(
                  onTap: () => setState(() {
                    switch (_type!) {
                      case CollectionType.d2d:
                        _vehicleNumber = option;
                        break;
                      case CollectionType.mrfStation:
                        _mrfAgentName = option;
                        break;
                      case CollectionType.ramp:
                        _personName = option;
                        break;
                    }
                    _conditionalFieldOpen = false;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        _Radio(selected: value == option),
                        const SizedBox(width: 10),
                        Text(option, style: AppTextStyles.regularB7_14),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
    ];
  }

  Widget _typeDropdown(BuildContext context) => _DropdownBox(
    children: List.generate(CollectionType.values.length, (i) {
      final type = CollectionType.values[i];
      final labels = [
        context.l10n.d2d,
        context.l10n.mrfStation,
        context.l10n.ramp,
      ];
      final icons = [
        'assets/icons/home/collection_d2d.svg',
        'assets/icons/home/collection_mrf.svg',
        'assets/icons/home/collection_ramp.svg',
      ];
      return InkWell(
        onTap: () {
          setState(() {
            _type = type;
            _selected.clear();
            _itemsOpen = false;
            _mrfAgentName = _profile?.userName;
            _typeOpen = false;
            _conditionalFieldOpen = false;
          });
          _loadReferenceData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _Radio(selected: _type == type),
              const SizedBox(width: 10),
              SvgPicture.asset(
                icons[i],
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(
                  AppColors.neutral900,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
              Text(labels[i], style: AppTextStyles.regularB7_14),
            ],
          ),
        ),
      );
    }),
  );

  Widget _itemDropdown(BuildContext context) {
    final names = _itemNames(context);
    return _DropdownBox(
      children: [
        Row(
          children: [
            Expanded(
              child: _Tab(
                text: context.l10n.collectionPlasticCount,
                active: _showPlasticItems,
                onTap: () => setState(() => _showPlasticItems = true),
              ),
            ),
            Expanded(
              child: _Tab(
                text: context.l10n.collectionNonPlasticCount,
                active: !_showPlasticItems,
                onTap: () => setState(() => _showPlasticItems = false),
              ),
            ),
          ],
        ),
        ...List.generate(
          names.length,
          (i) => InkWell(
            onTap: () => setState(() {
              if (!_selected.add(i)) _selected.remove(i);
            }),
            child: Container(
              height: 38,
              margin: EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    [
                      const Color(0xFFAFB4F1),
                      const Color(0xFFFFF8D2),
                      const Color(0xFF96FFF4),
                      const Color(0xFFFF9FA1),
                      const Color(0xFFB5FFDF),
                      const Color(0xFFF9C7FE),
                    ][i],
                  ],
                ),
              ),
              child: Row(
                children: [
                  _Check(selected: _selected.contains(i)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(names[i], style: AppTextStyles.regularB7_14),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: AppColors.cool50,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.collectionItemsSelected(_selected.length),
                  style: AppTextStyles.semiboldH9_14,
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.all(Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => setState(() => _itemsOpen = false),
                child: Text(context.l10n.recordsContinue),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photosStep(BuildContext context) {
    final selected = _selected.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.collectionCaptureInstruction,
          style: AppTextStyles.mediumSH8_14,
        ),
        const SizedBox(height: 16),
        ...selected.map(
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PhotoMaterialCard(
              name: _itemNames(context)[i],
              pickedImages: _photos[i] ?? const [],
              onCapture: () => _pickImage(i),
              onRemove: (index) => setState(() => _photos[i]!.removeAt(index)),
              onPreview: _showImagePreview,
              collectionWeight: _collectionWeights[i] ?? '',
              verifiedWeight: _verifiedWeights[i] ?? '',
              onCollectionWeightChanged: (value) =>
                  _collectionWeights[i] = value,
              onVerifiedWeightChanged: (value) => _verifiedWeights[i] = value,
            ),
          ),
        ),
        if (_type == CollectionType.ramp)
          _PhotoMaterialCard(
            name: context.l10n.collectionRampPersonPhoto,
            pickedImages: _photos[99] ?? const [],
            onCapture: () => _pickImage(99),
            onRemove: (index) => setState(() => _photos[99]!.removeAt(index)),
            onPreview: _showImagePreview,
            person: true,
          ),
      ],
    );
  }

  Widget _d2dWasteItemsStep(BuildContext context) => D2dWasteItemsStep(
    items: _itemNames(context),
    selectedItems: _selected,
    isOpen: _itemsOpen,
    showPlasticItems: _showPlasticItems,
    onSelectorTap: () => setState(() => _itemsOpen = !_itemsOpen),
    onCategoryChanged: (showPlastic) => setState(() {
      _showPlasticItems = showPlastic;
    }),
    onItemChanged: (item) => setState(() {
      if (!_selected.add(item)) _selected.remove(item);
    }),
    onDone: () => setState(() => _itemsOpen = false),
  );

  Widget _d2dCollectionPhotosStep(BuildContext context) =>
      D2dCollectionPhotosStep(
        selectedItems: _selected.toList(),
        itemNames: _itemNames(context),
        photos: _photos,
        collectionWeights: _collectionWeights,
        verifiedWeights: _verifiedWeights,
        units: _d2dUnits,
        paymentMode: _d2dPaymentMode,
        showPaymentMode: _type != CollectionType.mrfStation,
        onCollectionWeightChanged: (item, value) => setState(() {
          _collectionWeights[item] = value;
        }),
        onVerifiedWeightChanged: (item, value) {
          _verifiedWeights[item] = value;
        },
        onCapture: _pickD2dCollectionImage,
        onRemove: (item, index) => setState(() {
          _photos[item]?.removeAt(index);
        }),
        onPreview: _showImagePreview,
        onPaymentModeChanged: (mode) => setState(() {
          _d2dPaymentMode = mode;
        }),
      );

  Widget _reviewStep(BuildContext context) => Column(
    children: [
      _ReviewDetailCard(
        label: context.l10n.collectionDetailId,
        value: _draftId ?? '—',
      ),
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailDateTime,
        value: DateTime.now().toLocal().toString(),
      ),
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailType,
        value: _typeLabel(context),
        icon: _typeIcon,
      ),
      if (_type == CollectionType.mrfStation) ...[
        const SizedBox(height: 12),
        _ReviewDetailCard(
          label: context.l10n.collectionGivenBy,
          value: _mrfAgentName ?? '',
        ),
        const SizedBox(height: 12),
        _ReviewDetailCard(
          label: context.l10n.collectionMrfLabor,
          value: _mrfLabor ?? '',
        ),
      ],
      if (_type == CollectionType.d2d) ...[
        const SizedBox(height: 12),
        _ReviewDetailCard(
          label: context.l10n.collectionGivenBy,
          value: _givenBy,
        ),
        const SizedBox(height: 12),
        _ReviewDetailCard(
          label: context.l10n.collectionD2dVehicleNumber,
          value: _vehicleNumber ?? '',
        ),
      ],
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailAgent,
        value: _profile?.userName ?? '',
      ),
      if (_type == CollectionType.d2d || _type == CollectionType.ramp) ...[
        const SizedBox(height: 12),
        _ReviewDetailCard(
          label: context.l10n.collectionPaymentType,
          value: _d2dPaymentMode == D2dPaymentMode.cash
              ? context.l10n.collectionPaymentCash
              : context.l10n.collectionPaymentUpi,
        ),
        const SizedBox(height: 12),
        _ReviewVehiclePhotoCard(
          images: _photos[_type == CollectionType.ramp ? 99 : -1] ?? const [],
          onPreview: _showImagePreview,
        ),
      ],
      const SizedBox(height: 12),
      _ReviewItemsCard(
        title: context.l10n.collectionDetailReceivedItems,
        children: [
          ..._selected.indexed.map(
            (entry) => Column(
              children: [
                _ReviewMaterial(
                  name: _itemNames(context)[entry.$2],
                  collectionWeight: _collectionWeights[entry.$2] ?? '',
                  verifiedWeight: _verifiedWeights[entry.$2] ?? '',
                  pickedImages: _photos[entry.$2] ?? const [],
                  onPreview: _showImagePreview,
                  unit: _d2dUnits[entry.$2] ?? defaultCollectionUnit(entry.$2),
                ),
                if (entry.$1 < _selected.length - 1)
                  const Divider(height: 49, color: AppColors.cool400),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _ReviewTotalsCard(
        collectionWeight: _totalWeight(_collectionWeights),
        verifiedWeight: _totalWeight(_verifiedWeights),
      ),
    ],
  );

  Widget _bottomButtons(BuildContext context) {
    if (_d2dReview) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              key: const Key('d2d-review-save-draft'),
              onPressed: () => _saveCollection(submit: false),
              child: Text(context.l10n.collectionSaveDraft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              key: const Key('d2d-review-submit'),
              onPressed: _submit,
              child: Text(context.l10n.collectionSubmit),
            ),
          ),
        ],
      );
    }
    if (_step == CollectionEntryStep.review) {
      if (_type == CollectionType.d2d ||
          _type == CollectionType.mrfStation ||
          _type == CollectionType.ramp) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            key: const Key('d2d-step-three-continue'),
            onPressed: _photosComplete
                ? () => setState(() => _d2dReview = true)
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.l10n.recordsContinue),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  'assets/icons/profile/arrow_right.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              key: const Key('collection-save-draft'),
              onPressed: () => _saveCollection(submit: false),
              child: Text(context.l10n.collectionSaveDraft),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(context.l10n.collectionSubmit),
            ),
          ),
        ],
      );
    }
    final enabled = _step == CollectionEntryStep.photos
        ? _type == CollectionType.d2d ||
                  _type == CollectionType.mrfStation ||
                  _type == CollectionType.ramp
              ? _selected.isNotEmpty
              : _photosComplete
        : _type == CollectionType.d2d
        ? _vehicleNumber != null &&
              _givenBy.trim().isNotEmpty &&
              (_photos[-1]?.isNotEmpty ?? false)
        : _type == CollectionType.mrfStation
        ? _mrfLabor != null
        : _type == CollectionType.ramp
        ? _personName != null && (_photos[99]?.isNotEmpty ?? false)
        : (_type != null && _hasConditionalSelection && _selected.isNotEmpty);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const Key('collection-continue'),
        onPressed: enabled
            ? () => setState(() {
                if (_step == CollectionEntryStep.photos) {
                  for (final item in _selected) {
                    if (_type == CollectionType.d2d ||
                        _type == CollectionType.mrfStation ||
                        _type == CollectionType.ramp) {
                      _d2dUnits.putIfAbsent(
                        item,
                        () => defaultCollectionUnit(item),
                      );
                    }
                  }
                }
                _step = CollectionEntryStep.values[_step.index + 1];
              })
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.recordsContinue),
            const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/icons/profile/arrow_right.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() => _saveCollection(submit: true);

  Future<void> _saveCollection({required bool submit}) async {
    final centerId = _centerId;
    final userId = _userId;
    final profile = _profile;
    if (centerId == null ||
        userId == null ||
        profile == null ||
        _type == null) {
      return;
    }
    final id =
        _draftId ?? 'local_collection_${DateTime.now().microsecondsSinceEpoch}';
    _draftId = id;
    VehicleModel? vehicle;
    for (final value in _vehicles) {
      if (value.plateNumber == _vehicleNumber) vehicle = value;
    }
    MrfPersonModel? mrfPerson;
    for (final value in _mrfPeople) {
      if (value.name == _mrfLabor) mrfPerson = value;
    }
    RagpickerModel? ragpicker;
    for (final value in _ragpickers) {
      if (value.name == _personName) ragpicker = value;
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final items = <CollectionItemModel>[];
    for (final entry in _selected.indexed) {
      final index = entry.$2;
      if (index < 0 || index >= _materials.length) continue;
      final material = _materials[index];
      final qty = double.tryParse(_collectionWeights[index] ?? '') ?? 0;
      final verified = double.tryParse(_verifiedWeights[index] ?? '');
      items.add(
        CollectionItemModel(
          id: '${id}_${material.id}',
          collectionId: id,
          itemId: material.id,
          qty: qty,
          verifiedQty: verified,
          rate: material.rate,
          amount: material.rate == null ? null : material.rate! * qty,
          photoUrls: (_photos[index] ?? const [])
              .map((photo) => photo.path)
              .toList(growable: false),
          sortOrder: entry.$1,
          name: material.name,
          unitCode: material.unitCode,
          unitName: material.unitName,
        ),
      );
    }
    final handoverPhotos =
        (_photos[_type == CollectionType.ramp ? 99 : -1] ?? const <XFile>[])
            .map((photo) => photo.path)
            .toList(growable: false);
    await EerlLocalRepository.instance.saveCollection(
      collection: CollectionModel(
        id: id,
        centerId: centerId,
        agentId: userId,
        agentName: profile.userName ?? '',
        channel: _channel,
        status: submit ? 'PENDING' : 'DRAFT',
        collectedAt: submit ? now : null,
        vehicleId: vehicle?.id,
        mrfPersonId: mrfPerson?.id,
        ragpickerId: ragpicker?.id,
        givenByName: _type == CollectionType.d2d ? _givenBy : null,
        handedOverBy: _type == CollectionType.ramp ? _personName : null,
        paidBy: _type == CollectionType.mrfStation
            ? null
            : _d2dPaymentMode.name.toUpperCase(),
        totalAmount: items.fold<double>(
          0,
          (total, item) => total + (item.amount ?? 0),
        ),
        handoverPhotoUrls: handoverPhotos,
        updatedAt: now,
        syncState: 'pending',
      ),
      items: items,
      submit: submit,
    );
    if (!mounted) return;
    if (!submit) {
      Navigator.of(context).pop(true);
      return;
    }
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => CollectionSuccessDialog(
        onPreview: () {
          Navigator.of(context, rootNavigator: true).pop();
          context.push<void>(AppRoutes.collectionDetail, extra: id);
        },
        onAddNew: () {
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            _draftId = null;
            _step = CollectionEntryStep.items;
            _type = null;
            _selected.clear();
          });
        },
      ),
    );
  }

  Future<void> _pickImage(int itemId) async {
    if ((_photos[itemId]?.length ?? 0) >= 2) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.collectionChoosePhotoSource,
                style: AppTextStyles.semiboldH8_16,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(context.l10n.collectionCamera),
                onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(context.l10n.collectionGallery),
                onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    setState(() => (_photos[itemId] ??= []).add(image));
  }

  Future<void> _pickVehicleImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    setState(() => _photos[-1] = [image]);
  }

  Future<void> _pickD2dCollectionImage(int itemId) async {
    if ((_photos[itemId]?.length ?? 0) >= 2) return;
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1600,
    );
    if (image == null || !mounted) return;
    setState(() => (_photos[itemId] ??= []).add(image));
  }

  void _showImagePreview(XFile image) {
    context.push<void>(
      AppRoutes.collectionImagePreview,
      extra: FileImage(File(image.path)),
    );
  }

  void _goBack() {
    if (_d2dReview) {
      setState(() => _d2dReview = false);
      return;
    }
    if (_step == CollectionEntryStep.items) {
      Navigator.of(context).maybePop();
    } else {
      setState(() => _step = CollectionEntryStep.values[_step.index - 1]);
    }
  }

  String _typeLabel(BuildContext c) => switch (_type) {
    CollectionType.d2d => c.l10n.d2d,
    CollectionType.mrfStation => c.l10n.mrfStation,
    CollectionType.ramp => c.l10n.ramp,
    null => c.l10n.collectionSelectType,
  };

  bool get _hasConditionalSelection => switch (_type) {
    CollectionType.d2d => _vehicleNumber != null,
    CollectionType.mrfStation => _mrfAgentName != null,
    CollectionType.ramp => _personName != null,
    null => false,
  };

  String get _typeIcon => switch (_type) {
    CollectionType.d2d => 'assets/icons/home/collection_d2d.svg',
    CollectionType.mrfStation => 'assets/icons/home/collection_mrf.svg',
    CollectionType.ramp => 'assets/icons/home/collection_ramp.svg',
    null => 'assets/icons/home/collection_d2d.svg',
  };

  double _totalWeight(Map<int, String> values) => _selected.fold<double>(
    0,
    (total, item) => total + (double.tryParse(values[item] ?? '') ?? 0),
  );

  bool get _photosComplete =>
      _selected.isNotEmpty &&
      _selected.every(
        (item) =>
            (_collectionWeights[item]?.trim().isNotEmpty ?? false) &&
            (_photos[item]?.isNotEmpty ?? false),
      ) &&
      (_type != CollectionType.ramp || (_photos[99]?.isNotEmpty ?? false));

  Widget _label(String text, {bool required = true}) => Text.rich(
    TextSpan(
      text: text,
      children: required
          ? const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red600),
              ),
            ]
          : [],
    ),
    style: AppTextStyles.mediumSH8_14,
  );
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    key: const Key('add-collection-back'),
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary500,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset('assets/icons/records/back.svg'),
    ),
  );
}

class _Selector extends StatelessWidget {
  const _Selector({
    super.key,
    required this.text,
    required this.open,
    required this.onTap,
    this.leadingIcon,
  });

  final String text;
  final String? leadingIcon;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(bottom: 5),
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            SvgPicture.asset(
              leadingIcon!,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.neutral900,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(text, style: AppTextStyles.regularB7_14)),
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
  );
}

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(10),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),

      child: Column(children: children),
    ),
  );
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.neutral400),
      color: Colors.white,
    ),
    child: selected
        ? const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary500,
            ),
          )
        : null,
  );
}

class _Check extends StatelessWidget {
  const _Check({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: selected ? AppColors.primary500 : Colors.white,
      border: Border.all(
        color: selected ? AppColors.primary500 : AppColors.neutral400,
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    child: selected
        ? const Icon(Icons.check, color: Colors.white, size: 16)
        : null,
  );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.text, required this.active, required this.onTap});

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 44,
      alignment: Alignment.center,
      color: active ? AppColors.primary500 : AppColors.cool50,
      child: Text(
        text,
        style: AppTextStyles.boldH8_14.copyWith(
          color: active ? Colors.white : AppColors.neutral900,
        ),
      ),
    ),
  );
}

class _PhotoMaterialCard extends StatelessWidget {
  const _PhotoMaterialCard({
    required this.name,
    required this.pickedImages,
    required this.onCapture,
    required this.onRemove,
    required this.onPreview,
    this.collectionWeight = '',
    this.verifiedWeight = '',
    this.onCollectionWeightChanged,
    this.onVerifiedWeightChanged,
    this.person = false,
  });

  final String name;
  final List<XFile> pickedImages;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;
  final ValueChanged<XFile> onPreview;
  final String collectionWeight;
  final String verifiedWeight;
  final ValueChanged<String>? onCollectionWeightChanged;
  final ValueChanged<String>? onVerifiedWeightChanged;
  final bool person;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: AppColors.cool400),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!person)
          Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
              color: AppColors.cool200,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.recycling,
                  size: 40,
                  color: AppColors.primary500,
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.cool950,
                  ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (person) ...[
                Text(name, style: AppTextStyles.mediumSH8_14),
                const SizedBox(height: 8),
              ],
              if (!person) ...[
                Row(
                  children: [
                    Expanded(
                      child: _WeightBox(
                        label: context.l10n.collectionWeight,
                        value: collectionWeight,
                        onChanged: onCollectionWeightChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _WeightBox(
                        label: context.l10n.collectionVerifiedWeight,
                        value: verifiedWeight,
                        onChanged: onVerifiedWeightChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.collectionDetailRate,
                      style: AppTextStyles.mediumSH8_14,
                    ),
                    Text(
                      context.l10n.collectionDetailMaterialTotal,
                      style: AppTextStyles.semiboldH9_14.copyWith(
                        color: AppColors.primary500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              InkWell(
                onTap: pickedImages.length < 2 ? onCapture : null,
                child: DottedBorder(
                  options: const RoundedRectDottedBorderOptions(
                    radius: Radius.circular(10),
                    color: AppColors.primary500,
                    dashPattern: [4, 3],
                    strokeWidth: 1,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    height: 82,
                    width: double.infinity,
                    alignment: Alignment.center,
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
                        Text.rich(
                          TextSpan(
                            text: context.l10n.collectionCapturePhoto,
                            children: person
                                ? const []
                                : const [
                                    TextSpan(
                                      text: ' *',
                                      style: TextStyle(color: AppColors.red600),
                                    ),
                                  ],
                          ),
                          style: AppTextStyles.semiboldH9_14.copyWith(
                            color: AppColors.neutral900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (person) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.collectionRampPhotoHint,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
              ],
              if (pickedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: pickedImages.indexed
                      .map(
                        (entry) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: InkWell(
                                key: ValueKey('collection-image-${entry.$1}'),
                                onTap: () => onPreview(entry.$2),
                                child: Image.file(
                                  File(entry.$2.path),
                                  width: 109,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: InkWell(
                                onTap: () => onRemove(entry.$1),
                                child: SvgPicture.asset(
                                  'assets/icons/wallet/expense_remove.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _WeightBox extends StatelessWidget {
  const _WeightBox({required this.label, required this.value, this.onChanged});

  final String label, value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        TextSpan(
          text: label,
          children: label == context.l10n.collectionWeight
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.red600),
                  ),
                ]
              : const [],
        ),
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 44,
        child: TextFormField(
          key: ValueKey('$label-$value'),
          initialValue: value,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: '---',
            hintStyle: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.cool600,
            ),
            prefixIcon: Center(
              child: Text('KG', style: AppTextStyles.semiboldH8_16),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 42,
              maxWidth: 42,
            ),
            contentPadding: const EdgeInsets.only(right: 10),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary500),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ReviewDetailCard extends StatelessWidget {
  const _ReviewDetailCard({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label, value;
  final String? icon;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.semiboldH8_16.copyWith(color: AppColors.cool600),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            if (icon != null) ...[
              SvgPicture.asset(icon!, width: 20, height: 20),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH9_14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ReviewItemsCard extends StatelessWidget {
  const _ReviewItemsCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

class _ReviewVehiclePhotoCard extends StatelessWidget {
  const _ReviewVehiclePhotoCard({
    required this.images,
    required this.onPreview,
  });

  final List<XFile> images;
  final ValueChanged<XFile> onPreview;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('d2d-review-vehicle-photo'),
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.collectionCaptureVehiclePhoto,
          style: AppTextStyles.semiboldH8_16.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _ReviewPhotos(images: images, onPreview: onPreview),
        ],
      ],
    ),
  );
}

class _ReviewMaterial extends StatelessWidget {
  const _ReviewMaterial({
    required this.name,
    required this.collectionWeight,
    required this.verifiedWeight,
    required this.pickedImages,
    required this.onPreview,
    this.unit = D2dMeasureUnit.kg,
  });

  final String name;
  final String collectionWeight, verifiedWeight;
  final List<XFile> pickedImages;
  final ValueChanged<XFile> onPreview;
  final D2dMeasureUnit unit;

  @override
  Widget build(BuildContext context) {
    final isKg = unit == D2dMeasureUnit.kg;
    final unitLabel = isKg
        ? context.l10n.collectionUnitKg
        : context.l10n.collectionUnitPcs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.recycling, size: 40, color: AppColors.primary500),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.boldH8_14.copyWith(
                  color: AppColors.cool950,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ReviewWeightBox(
                label: isKg
                    ? context.l10n.collectionWeight
                    : context.l10n.collectionPieces,
                value: collectionWeight,
                color: AppColors.cool200,
                required: true,
                unit: unitLabel,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _ReviewWeightBox(
                label: isKg
                    ? context.l10n.collectionVerifiedWeight
                    : context.l10n.collectionVerifiedPieces,
                value: verifiedWeight,
                color: AppColors.primary100,
                unit: unitLabel,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.l10n.collectionRatePerUnit(unitLabel),
                maxLines: 2,
                style: AppTextStyles.mediumSH8_14,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.l10n.collectionDetailMaterialTotal,
                maxLines: 2,
                textAlign: TextAlign.end,
                style: AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ReviewPhotos(images: pickedImages, onPreview: onPreview),
      ],
    );
  }
}

class _ReviewWeightBox extends StatelessWidget {
  const _ReviewWeightBox({
    required this.label,
    required this.value,
    required this.color,
    required this.unit,
    this.required = false,
  });

  final String label, value;
  final Color color;
  final String unit;
  final bool required;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text.rich(
        TextSpan(
          text: label,
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.red600),
                  ),
                ]
              : const [],
        ),
        style: AppTextStyles.mediumSH8_14,
      ),
      const SizedBox(height: 8),
      Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Text(
                unit,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.semiboldH9_14,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 3,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.regularB7_14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _ReviewPhotos extends StatelessWidget {
  const _ReviewPhotos({required this.images, required this.onPreview});

  final List<XFile> images;
  final ValueChanged<XFile> onPreview;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: images
        .map(
          (image) => InkWell(
            onTap: () => onPreview(image),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(image.path),
                width: 109,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
        .toList(),
  );
}

class _ReviewTotalsCard extends StatelessWidget {
  const _ReviewTotalsCard({
    required this.collectionWeight,
    required this.verifiedWeight,
  });

  final double collectionWeight, verifiedWeight;

  @override
  Widget build(BuildContext context) {
    final difference = verifiedWeight - collectionWeight;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _totalRow(
            context.l10n.collectionDetailTotalCollectionWeight,
            '${collectionWeight.toStringAsFixed(2)} KG',
          ),
          const SizedBox(height: 12),
          _totalRow(
            context.l10n.collectionDetailTotalVerifiedWeight,
            '${verifiedWeight.toStringAsFixed(2)} KG',
          ),
          const Divider(height: 25, color: AppColors.cool400),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.collectionDetailWeightComparison,
                      style: AppTextStyles.boldH8_14,
                    ),
                    Text(
                      context.l10n.collectionDetailComparisonHint,
                      style: AppTextStyles.mediumSH9_12.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${difference.toStringAsFixed(2)} KG',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.boldH7_16,
                ),
              ),
            ],
          ),
          const Divider(height: 25, color: AppColors.cool400),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.collectionDetailTotalPrice,
                  maxLines: 2,
                  style: AppTextStyles.boldH6_20.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '₹35,550.00',
                  textAlign: TextAlign.end,
                  style: AppTextStyles.boldH6_20.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(label, maxLines: 2, style: AppTextStyles.semiboldH9_14),
      ),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: AppTextStyles.boldH7_16,
        ),
      ),
    ],
  );
}
