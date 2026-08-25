import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/collection_entry_state.dart';
import '../widgets/collection_step_indicator.dart';
import '../widgets/collection_success_dialog.dart';
import 'collection_image_preview_screen.dart';

class AddCollectionScreen extends StatefulWidget {
  const AddCollectionScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<AddCollectionScreen> createState() => _AddCollectionScreenState();
}

class _AddCollectionScreenState extends State<AddCollectionScreen> {
  CollectionEntryStep _step = CollectionEntryStep.items;
  CollectionType? _type;
  bool _typeOpen = false, _itemsOpen = false, _receipt = false;
  bool _conditionalFieldOpen = false;
  bool _showPlasticItems = true;
  final Set<int> _selected = {};
  final Map<int, List<XFile>> _photos = {};
  final Map<int, String> _collectionWeights = {};
  final Map<int, String> _verifiedWeights = {};
  final ImagePicker _imagePicker = ImagePicker();
  String? _vehicleNumber;
  String? _personName;
  String? _mrfAgentName;

  static const _vehicleNumbers = [
    'GJ-05-BX-1234',
    'GJ-05-RT-9087',
    'GJ-01-AB-4421',
  ];
  static const _personNames = ['Ramesh Shah', 'Mahesh Patel', 'Jignesh Parmar'];
  static const _mrfAgentNames = ['Hardik Pandya', 'Amit Shah', 'Neha Patel'];

  final _images = const [
    'assets/images/collection_detail/pet_collection.png',
    'assets/images/collection_detail/hdpe_collection.png',
    'assets/images/collection_detail/pp_collection.png',
  ];

  List<String> _itemNames(BuildContext c) => [
    c.l10n.collectionDetailPetBottles,
    c.l10n.collectionDetailHdpeRigid,
    c.l10n.collectionMilkPouch,
    c.l10n.collectionDetailPpHardPlastics,
    c.l10n.collectionMultiLayer,
    c.l10n.collectionMixedGarbage,
  ];

  int get _stepNumber => _step.index + 1;

  @override
  Widget build(BuildContext context) {
    if (_receipt) {
      return _ReceiptView(onBack: () => setState(() => _receipt = false));
    }
    return Scaffold(
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
                        const SizedBox(height: 24),
                        CollectionStepIndicator(currentStep: _stepNumber),
                        const SizedBox(height: 24),
                        if (_step == CollectionEntryStep.items)
                          _itemsStep(context)
                        else if (_step == CollectionEntryStep.photos)
                          _photosStep(context)
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
  }

  Widget _itemsStep(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.collectionItemsReceived,
        style: AppTextStyles.semiboldH7_18,
      ),
      const SizedBox(height: 6),
      Text(
        context.l10n.collectionItemsReceivedSubtitle,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral600),
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

  List<Widget> _conditionalField(BuildContext context) {
    final (label, placeholder, value, options) = switch (_type!) {
      CollectionType.d2d => (
        context.l10n.collectionVehicleNumber,
        context.l10n.collectionSelectVehicle,
        _vehicleNumber,
        _vehicleNumbers,
      ),
      CollectionType.mrfStation => (
        context.l10n.collectionMrfAgentName,
        context.l10n.collectionSelectMrfAgent,
        _mrfAgentName,
        _mrfAgentNames,
      ),
      CollectionType.ramp => (
        context.l10n.collectionPersonName,
        context.l10n.collectionSelectPerson,
        _personName,
        _personNames,
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
        onTap: () => setState(() {
          _type = type;
          _typeOpen = false;
          _conditionalFieldOpen = false;
        }),
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
              materialImage: _images[i % 3],
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

  Widget _reviewStep(BuildContext context) => Column(
    children: [
      _ReviewDetailCard(
        label: context.l10n.collectionDetailId,
        value: '#COL-2026-089',
      ),
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailDateTime,
        value: context.l10n.collectionDetailDateValue,
      ),
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailType,
        value: _typeLabel(context),
        icon: _typeIcon,
      ),
      const SizedBox(height: 12),
      _ReviewDetailCard(
        label: context.l10n.collectionDetailAgent,
        value: 'Rahul Patel',
      ),
      const SizedBox(height: 12),
      _ReviewItemsCard(
        title: context.l10n.collectionDetailReceivedItems,
        children: [
          ..._selected.indexed.map(
            (entry) => Column(
              children: [
                _ReviewMaterial(
                  name: _itemNames(context)[entry.$2],
                  image: _images[entry.$2 % 3],
                  collectionWeight: _collectionWeights[entry.$2] ?? '',
                  verifiedWeight: _verifiedWeights[entry.$2] ?? '',
                  pickedImages: _photos[entry.$2] ?? const [],
                  onPreview: _showImagePreview,
                ),
                if (entry.$1 < _selected.length - 1)
                  const Divider(height: 49, color: AppColors.cool400),
              ],
            ),
          ),
          if (_type == CollectionType.ramp) ...[
            const Divider(height: 25, color: AppColors.cool400),
            Text(
              context.l10n.collectionDetailRampPersonPhoto,
              style: AppTextStyles.semiboldH9_14,
            ),
            const SizedBox(height: 16),
            _ReviewPhotos(
              images: _photos[99] ?? const [],
              onPreview: _showImagePreview,
            ),
          ],
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
    if (_step == CollectionEntryStep.review) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
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
        ? _photosComplete
        : (_type != null && _hasConditionalSelection && _selected.isNotEmpty);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        key: const Key('collection-continue'),
        onPressed: enabled
            ? () => setState(() {
                if (_step == CollectionEntryStep.items) {
                  for (final item in _selected) {
                    _collectionWeights.putIfAbsent(item, () => '270.00');
                  }
                } else if (_step == CollectionEntryStep.photos) {
                  for (final item in _selected) {
                    _verifiedWeights.putIfAbsent(
                      item,
                      () => item == 1 ? '250.00' : '270.00',
                    );
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

  void _submit() => showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (_) => CollectionSuccessDialog(
      onPreview: () {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _receipt = true);
      },
      onAddNew: () {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _step = CollectionEntryStep.items;
          _type = null;
          _selected.clear();
        });
      },
    ),
  );

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

  void _showImagePreview(XFile image) {
    Navigator.of(
      context,
    ).push(CollectionImagePreviewScreen.route(FileImage(File(image.path))));
  }

  void _goBack() {
    if (_step == CollectionEntryStep.items) {
      widget.onBack();
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
    this.materialImage,
    this.collectionWeight = '',
    this.verifiedWeight = '',
    this.onCollectionWeightChanged,
    this.onVerifiedWeightChanged,
    this.person = false,
  });

  final String name;
  final String? materialImage;
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    materialImage!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
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
            Text(value, style: AppTextStyles.semiboldH9_14),
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

class _ReviewMaterial extends StatelessWidget {
  const _ReviewMaterial({
    required this.name,
    required this.image,
    required this.collectionWeight,
    required this.verifiedWeight,
    required this.pickedImages,
    required this.onPreview,
  });

  final String name, image;
  final String collectionWeight, verifiedWeight;
  final List<XFile> pickedImages;
  final ValueChanged<XFile> onPreview;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.asset(image, width: 40, height: 40, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: AppTextStyles.boldH8_14.copyWith(color: AppColors.cool950),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _ReviewWeightBox(
              label: context.l10n.collectionWeight,
              value: collectionWeight,
              color: AppColors.cool200,
              required: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _ReviewWeightBox(
              label: context.l10n.collectionVerifiedWeight,
              value: verifiedWeight,
              color: AppColors.primary100,
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
      _ReviewPhotos(images: pickedImages, onPreview: onPreview),
    ],
  );
}

class _ReviewWeightBox extends StatelessWidget {
  const _ReviewWeightBox({
    required this.label,
    required this.value,
    required this.color,
    this.required = false,
  });

  final String label, value;
  final Color color;
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('KG', style: AppTextStyles.semiboldH8_16),
            const SizedBox(width: 10),
            Text(value, style: AppTextStyles.regularB7_14),
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
              Text(
                '${difference.toStringAsFixed(2)} KG',
                style: AppTextStyles.boldH7_16,
              ),
            ],
          ),
          const Divider(height: 25, color: AppColors.cool400),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.collectionDetailTotalPrice,
                style: AppTextStyles.boldH6_20.copyWith(
                  color: AppColors.primary500,
                ),
              ),
              Text(
                '₹35,550.00',
                style: AppTextStyles.boldH6_20.copyWith(
                  color: AppColors.primary500,
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
      Text(label, style: AppTextStyles.semiboldH9_14),
      Text(value, style: AppTextStyles.boldH7_16),
    ],
  );
}

class _ReceiptView extends StatelessWidget {
  const _ReceiptView({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _BackButton(onTap: onBack),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0x18000000), blurRadius: 8),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/collection_detail/eer_logo.png',
                        width: 141,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'RCP-2026-000245',
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      const Divider(height: 32),
                      _receiptRow(
                        context.l10n.collectionDetailId,
                        '#COL-2026-089',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptDate,
                        '24 Oct 2026',
                      ),
                      _receiptRow(
                        context.l10n.collectionReceiptTime,
                        '03:45 PM',
                      ),
                      _receiptRow(context.l10n.collectionDetailType, 'D2D'),
                      const Divider(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          context.l10n.collectionCollectedItems,
                          style: AppTextStyles.boldH8_14.copyWith(
                            color: AppColors.cool950,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailPetBottles,
                        context.l10n.collectionPetReceiptDetail,
                        '₹1,440.00',
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailHdpeRigid,
                        context.l10n.collectionHdpeReceiptDetail,
                        '₹726.75',
                      ),
                      const SizedBox(height: 16),
                      _receiptItem(
                        context.l10n.collectionDetailPpHardPlastics,
                        context.l10n.collectionPpReceiptDetail,
                        '₹540.00',
                      ),
                      const Divider(height: 32),
                      _receiptRow(
                        context.l10n.collectionTotalWeight,
                        '217.5 KG',
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.collectionReceiptTotal,
                            style: AppTextStyles.mediumSH6_18,
                          ),
                          Text(
                            '₹2,706.75',
                            style: AppTextStyles.mediumSH6_18.copyWith(
                              color: AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Text(
                        context.l10n.collectionReceiptAgent,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Rahul Patel', style: AppTextStyles.mediumSH8_14),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.collectionThankYou,
                        style: AppTextStyles.boldH8_14.copyWith(
                          color: AppColors.primary500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.collectionSystemGeneratedSlip,
                        style: AppTextStyles.mediumSH9_12.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SvgPicture.asset(
                        'assets/icons/collection/receipt_dots.svg',
                        width: 116,
                        height: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.collectionPrinterHint,
              textAlign: TextAlign.center,
              style: AppTextStyles.mediumSH9_12.copyWith(
                color: AppColors.cool600,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/collection/share_slip.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(context.l10n.collectionShareSlip),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/collection/print_slip.svg',
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(context.l10n.collectionPrintSlip),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _receiptRow(String a, String b) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            a,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: AppColors.neutral600,
            ),
          ),
        ),
        Text(b, style: AppTextStyles.mediumSH8_14),
      ],
    ),
  );

  Widget _receiptItem(String name, String detail, String price) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.mediumSH8_14),
            const SizedBox(height: 4),
            Text(
              detail,
              style: AppTextStyles.mediumSH9_12.copyWith(
                color: AppColors.neutral500,
              ),
            ),
          ],
        ),
      ),
      Text(price, style: AppTextStyles.mediumSH8_14),
    ],
  );
}
