import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/configurable_material_item.dart';
import '../widgets/configurable_material_tile.dart';
import '../widgets/material_segmented_control.dart';

enum _MaterialCollectionType { d2d, mrfStation, ramp }

class ConfigureMaterialScreen extends StatefulWidget {
  const ConfigureMaterialScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ConfigureMaterialScreen> createState() =>
      _ConfigureMaterialScreenState();
}

class _ConfigureMaterialScreenState extends State<ConfigureMaterialScreen> {
  bool _showPlastic = true;
  bool _typeDropdownOpen = true;
  bool _saved = false;
  bool _hasChanges = true;
  _MaterialCollectionType _collectionType = _MaterialCollectionType.d2d;

  final List<ConfigurableMaterialItem> _plasticItems = [
    const ConfigurableMaterialItem(id: 'pet', nameKey: 'pet', selected: true),
    const ConfigurableMaterialItem(id: 'hdpe', nameKey: 'hdpe', selected: true),
    const ConfigurableMaterialItem(
      id: 'milk_pouch',
      nameKey: 'milkPouch',
      selected: true,
    ),
    const ConfigurableMaterialItem(id: 'pp', nameKey: 'pp', selected: true),
    const ConfigurableMaterialItem(
      id: 'multi_layer',
      nameKey: 'multiLayer',
      selected: false,
    ),
    const ConfigurableMaterialItem(id: 'pvc', nameKey: 'pvc', selected: false),
    const ConfigurableMaterialItem(
      id: 'mixed',
      nameKey: 'mixed',
      selected: false,
    ),
  ];

  final List<ConfigurableMaterialItem> _nonPlasticItems = [
    const ConfigurableMaterialItem(
      id: 'metals',
      nameKey: 'metals',
      selected: true,
    ),
    const ConfigurableMaterialItem(
      id: 'glass',
      nameKey: 'glass',
      selected: true,
    ),
    const ConfigurableMaterialItem(
      id: 'paper',
      nameKey: 'paper',
      selected: true,
    ),
    const ConfigurableMaterialItem(
      id: 'organic',
      nameKey: 'organic',
      selected: true,
    ),
    const ConfigurableMaterialItem(
      id: 'concrete',
      nameKey: 'concrete',
      selected: false,
    ),
    const ConfigurableMaterialItem(
      id: 'ceramics',
      nameKey: 'ceramics',
      selected: false,
    ),
    const ConfigurableMaterialItem(
      id: 'mixed',
      nameKey: 'mixed',
      selected: false,
    ),
  ];

  List<ConfigurableMaterialItem> get _visibleItems =>
      _showPlastic ? _plasticItems : _nonPlasticItems;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                  sliver: SliverList.list(
                    children: [
                      if (_saved) ...[
                        _SuccessBanner(
                          onClose: () => setState(() => _saved = false),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _BackButton(onTap: widget.onBack),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        context.l10n.configureMaterialsTitle,
                        style: AppTextStyles.semiboldH6_20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.configureMaterialsSubtitle,
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      MaterialSegmentedControl(
                        plasticLabel: context.l10n.configurePlasticCount(
                          _saved ? 25 : 12,
                        ),
                        nonPlasticLabel: context.l10n.configureNonPlasticCount(
                          _saved ? 20 : 10,
                        ),
                        showPlastic: _showPlastic,
                        onChanged: (value) =>
                            setState(() => _showPlastic = value),
                      ),
                      const SizedBox(height: 24),
                      _requiredLabel(context.l10n.collectionTypeLabel),
                      const SizedBox(height: 8),
                      _TypeSelector(
                        open: _typeDropdownOpen,
                        label: _typeDropdownOpen
                            ? context.l10n.collectionSelectType
                            : _typeLabel,
                        icon: _typeDropdownOpen ? null : _typeIcon,
                        onTap: () => setState(
                          () => _typeDropdownOpen = !_typeDropdownOpen,
                        ),
                      ),
                      if (_typeDropdownOpen)
                        _TypeDropdown(
                          selected: _collectionType,
                          onSelected: (type) => setState(() {
                            _collectionType = type;
                            _hasChanges = true;
                            _saved = false;
                          }),
                        ),
                      SizedBox(height: _typeDropdownOpen ? 10 : 24),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverReorderableList(
                    itemCount: _visibleItems.length,
                    onReorderItem: _reorder,
                    itemBuilder: (context, index) {
                      final item = _visibleItems[index];
                      return Padding(
                        key: ValueKey('${_showPlastic ? 'p' : 'n'}-${item.id}'),
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ConfigurableMaterialTile(
                          index: index,
                          label: _itemLabel(item.nameKey),
                          selected: item.selected,
                          onSelected: (selected) =>
                              _toggleItem(index, selected),
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                key: const Key('configure-material-save'),
                onPressed: _hasChanges ? _saveOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.neutral400,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: AppTextStyles.semiboldH9_14,
                ),
                child: Text(context.l10n.configureSaveOrder),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _requiredLabel(String label) => Text.rich(
    TextSpan(
      text: label,
      children: const [
        TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.red600),
        ),
      ],
    ),
    style: AppTextStyles.mediumSH8_14,
  );

  String get _typeLabel => switch (_collectionType) {
    _MaterialCollectionType.d2d => context.l10n.d2d,
    _MaterialCollectionType.mrfStation => context.l10n.mrfStation,
    _MaterialCollectionType.ramp => context.l10n.ramp,
  };

  String get _typeIcon => switch (_collectionType) {
    _MaterialCollectionType.d2d => 'assets/icons/home/collection_d2d.svg',
    _MaterialCollectionType.mrfStation =>
      'assets/icons/home/collection_mrf.svg',
    _MaterialCollectionType.ramp => 'assets/icons/home/collection_ramp.svg',
  };

  String _itemLabel(String key) => switch (key) {
    'pet' => context.l10n.configurePetBottles,
    'hdpe' => context.l10n.configureHdpeRigid,
    'milkPouch' => context.l10n.configureMilkPouch,
    'pp' => context.l10n.configurePpHardPlastics,
    'multiLayer' => context.l10n.configureMultiLayerPackaging,
    'pvc' => context.l10n.configurePvcPlastic,
    'mixed' => context.l10n.configureMixedGarbage,
    'metals' => context.l10n.configureMetals,
    'glass' => context.l10n.configureGlass,
    'paper' => context.l10n.configurePaperCardboard,
    'organic' => context.l10n.configureOrganicWood,
    'concrete' => context.l10n.configureConcreteMasonry,
    'ceramics' => context.l10n.configureCeramicsPorcelain,
    _ => key,
  };

  void _toggleItem(int index, bool selected) {
    setState(() {
      final list = _visibleItems;
      list[index] = list[index].copyWith(selected: selected);
      _hasChanges = true;
      _saved = false;
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final list = _visibleItems;
      final item = list.removeAt(oldIndex);
      list.insert(newIndex, item);
      _hasChanges = true;
      _saved = false;
    });
  }

  void _saveOrder() => setState(() {
    _typeDropdownOpen = false;
    _saved = true;
    _hasChanges = false;
  });
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: InkWell(
      key: const Key('configure-material-back'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset('assets/icons/records/back.svg'),
      ),
    ),
  );
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.primary50,
      border: Border.all(color: AppColors.primary200),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle, size: 20, color: AppColors.primary500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            context.l10n.configureSequenceSaved,
            style: AppTextStyles.mediumSH9_12.copyWith(
              color: AppColors.primary500,
            ),
          ),
        ),
        InkWell(
          onTap: onClose,
          child: SvgPicture.asset(
            'assets/icons/profile/sync_close.svg',
            width: 20,
            height: 20,
          ),
        ),
      ],
    ),
  );
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.open,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final bool open;
  final String label;
  final String? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      margin: EdgeInsets.only(bottom: 8),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon!,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                AppColors.neutral900,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(label, style: AppTextStyles.regularB7_14)),
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

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.selected, required this.onSelected});

  final _MaterialCollectionType selected;
  final ValueChanged<_MaterialCollectionType> onSelected;

  @override
  Widget build(BuildContext context) {
    final types = _MaterialCollectionType.values;
    final labels = [
      context.l10n.d2d,
      context.l10n.mrfStation,
      context.l10n.ramp,
    ];
    const icons = [
      'assets/icons/home/collection_d2d.svg',
      'assets/icons/home/collection_mrf.svg',
      'assets/icons/home/collection_ramp.svg',
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: List.generate(types.length, (index) {
          final selectedType = selected == types[index];
          return InkWell(
            onTap: () => onSelected(types[index]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.neutral400),
                    ),
                    child: selectedType
                        ? const DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary500,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  SvgPicture.asset(
                    icons[index],
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.neutral900,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(labels[index], style: AppTextStyles.regularB7_14),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
