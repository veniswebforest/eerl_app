import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import '../widgets/configurable_material_tile.dart';
import '../widgets/material_segmented_control.dart';

enum _MaterialCollectionType { d2d, mrfStation, ramp }

class ConfigureMaterialScreen extends StatefulWidget {
  const ConfigureMaterialScreen({super.key});

  @override
  State<ConfigureMaterialScreen> createState() =>
      _ConfigureMaterialScreenState();
}

class _ConfigureMaterialScreenState extends State<ConfigureMaterialScreen> {
  bool _showPlastic = true;
  bool _typeDropdownOpen = true;
  bool _saved = false;
  bool _hasChanges = false;
  bool _loading = true;
  bool _saving = false;
  Object? _error;
  _MaterialCollectionType _collectionType = _MaterialCollectionType.d2d;
  List<ItemModel> _plasticItems = const [];
  List<ItemModel> _nonPlasticItems = const [];

  List<ItemModel> get _visibleItems =>
      _showPlastic ? _plasticItems : _nonPlasticItems;

  String get _channel => switch (_collectionType) {
    _MaterialCollectionType.d2d => 'D2D',
    _MaterialCollectionType.mrfStation => 'MRF',
    _MaterialCollectionType.ramp => 'RAMP',
  };

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await EerlLocalRepository.instance.getItems(
        channel: _channel,
      );
      if (!mounted) return;
      setState(() {
        _plasticItems = items
            .where((item) => item.materialType.toUpperCase() == 'PLASTIC')
            .toList();
        _nonPlasticItems = items
            .where((item) => item.materialType.toUpperCase() != 'PLASTIC')
            .toList();
        _hasChanges = false;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

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
                        _BackButton(
                          onTap: () => Navigator.of(context).maybePop(),
                        ),
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
                          _plasticItems.length,
                        ),
                        nonPlasticLabel: context.l10n.configureNonPlasticCount(
                          _nonPlasticItems.length,
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
                          onSelected: (type) {
                            setState(() {
                              _collectionType = type;
                              _saved = false;
                            });
                            _loadItems();
                          },
                        ),
                      SizedBox(height: _typeDropdownOpen ? 10 : 24),
                    ],
                  ),
                ),
                if (_loading)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: TextButton(
                        onPressed: _loadItems,
                        child: const Text('Retry'),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverReorderableList(
                      itemCount: _visibleItems.length,
                      onReorderItem: _reorder,
                      itemBuilder: (context, index) {
                        final item = _visibleItems[index];
                        return Padding(
                          key: ValueKey(
                            '${_showPlastic ? 'p' : 'n'}-${item.id}',
                          ),
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ConfigurableMaterialTile(
                            index: index,
                            label: item.name,
                            selected: item.isSelected == true,
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
                onPressed: _hasChanges && !_saving ? _saveOrder : null,
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

  void _toggleItem(int index, bool selected) {
    setState(() {
      final list = _visibleItems;
      final item = list[index];
      list[index] = ItemModel(
        id: item.id,
        name: item.name,
        categoryName: item.categoryName,
        materialType: item.materialType,
        colour: item.colour,
        hsnCode: item.hsnCode,
        unitCode: item.unitCode,
        unitName: item.unitName,
        rate: item.rate,
        isSelected: selected,
        sortOrder: item.sortOrder,
      );
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

  Future<void> _saveOrder() async {
    setState(() => _saving = true);
    try {
      await EerlLocalRepository.instance.saveItemConfiguration(
        channel: _channel,
        items: [..._plasticItems, ..._nonPlasticItems],
      );
      if (!mounted) return;
      setState(() {
        _typeDropdownOpen = false;
        _saved = true;
        _hasChanges = false;
        _saving = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _saving = false;
      });
    }
  }
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
  Widget build(BuildContext context) => AppMessageBanner(
    height: 45,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    borderRadius: 10,
    title: context.l10n.configureSequenceSaved,
    color: AppColors.primary500,
    backgroundColor: AppColors.primary50,
    borderColor: AppColors.primary200,
    titleStyle: AppTextStyles.mediumSH9_12.copyWith(
      color: AppColors.primary500,
    ),
    icon: const Icon(Icons.check_circle, size: 20, color: AppColors.primary500),
    closeIcon: SvgPicture.asset(
      'assets/icons/profile/sync_close.svg',
      width: 20,
      height: 20,
    ),
    onClose: onClose,
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
