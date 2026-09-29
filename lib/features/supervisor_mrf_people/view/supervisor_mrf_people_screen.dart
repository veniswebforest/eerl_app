import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import '../model/supervisor_mrf_people_view.dart';
import '../widgets/supervisor_mrf_people_assets.dart';

class SupervisorMrfPeopleScreen extends StatefulWidget {
  const SupervisorMrfPeopleScreen({
    super.key,
    this.initialView = SupervisorMrfPeopleView.list,
  });

  final SupervisorMrfPeopleView initialView;

  @override
  State<SupervisorMrfPeopleScreen> createState() =>
      _SupervisorMrfPeopleScreenState();
}

class _SupervisorMrfPeopleScreenState extends State<SupervisorMrfPeopleScreen> {
  late SupervisorMrfPeopleView _view = widget.initialView;
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<_LaborControllers> _labors = [];
  int _selectedCenter = -1;
  bool _centersOpen = false;

  bool get _isForm => switch (_view) {
    SupervisorMrfPeopleView.addEmpty ||
    SupervisorMrfPeopleView.addWithLabor ||
    SupervisorMrfPeopleView.addFilled => true,
    _ => false,
  };

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _selectedCenter >= 0 &&
      _labors.every(
        (labor) =>
            labor.name.text.trim().isNotEmpty &&
            labor.phone.text.trim().isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    if (_view == SupervisorMrfPeopleView.addWithLabor) {
      _addLabor();
    } else if (_view == SupervisorMrfPeopleView.addFilled) {
      _prefillForm();
      _centersOpen = true;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    for (final labor in _labors) {
      labor.dispose();
    }
    super.dispose();
  }

  void _addLabor({String name = '', String phone = ''}) {
    _labors.add(_LaborControllers(name: name, phone: phone));
    if (mounted) setState(() {});
  }

  void _removeLabor(int index) {
    _labors.removeAt(index).dispose();
    setState(() {});
  }

  void _prefillForm() {
    _nameController.text = 'Chunilal Yadav';
    _phoneController.text = '1234567890';
    _selectedCenter = 0;
    _addLabor(name: 'Haresh Matiya', phone: '0987654321');
  }

  void _openAddForm() {
    _nameController.clear();
    _phoneController.clear();
    for (final labor in _labors) {
      labor.dispose();
    }
    _labors.clear();
    setState(() {
      _selectedCenter = -1;
      _centersOpen = false;
      _view = SupervisorMrfPeopleView.addEmpty;
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isForm && _view != SupervisorMrfPeopleView.details,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) setState(() => _view = SupervisorMrfPeopleView.list);
    },
    child: _isForm
        ? _buildForm(context)
        : _view == SupervisorMrfPeopleView.details
        ? _buildDetails(context)
        : _buildList(context),
  );

  Widget _buildList(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final items = _listItems(context)
        .where((item) => item.name.toLowerCase().contains(query))
        .toList(growable: false);
    final banner = _view == SupervisorMrfPeopleView.removed
        ? _MrfBannerData(
            title: context.l10n.supervisorMrfRemovedTitle,
            subtitle: context.l10n.supervisorMrfRemovedSubtitle,
            color: AppColors.red500,
            backgroundColor: AppColors.red50,
            icon: SvgPicture.asset(
              SupervisorMrfPeopleAssets.removed,
              width: 20,
              height: 20,
            ),
          )
        : _view == SupervisorMrfPeopleView.added
        ? _MrfBannerData(
            title: context.l10n.supervisorMrfAddedTitle,
            subtitle: context.l10n.supervisorMrfAddedSubtitle,
            color: AppColors.primary400,
            backgroundColor: AppColors.primary50,
            icon: const Icon(Icons.check, size: 20, color: Colors.white),
          )
        : null;

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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    children: [
                      if (banner != null)
                        AppMessageBanner(
                          key: const Key('supervisor-mrf-banner'),
                          title: banner.title,
                          subtitle: banner.subtitle,
                          color: banner.color,
                          backgroundColor: banner.backgroundColor,
                          borderColor: AppColors.cool300,
                          iconBackgroundColor: banner.color,
                          iconPadding: const EdgeInsets.all(5),
                          icon: banner.icon,
                          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                          onClose: () => setState(
                            () => _view = SupervisorMrfPeopleView.list,
                          ),
                        )
                      else
                        Row(
                          children: [
                            _BackButton(
                              onTap: () => Navigator.of(context).maybePop(),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                context.l10n.supervisorMrfTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.semiboldH6_20,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      _SearchField(
                        controller: _searchController,
                        hint: context.l10n.supervisorMrfSearch,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      for (var index = 0; index < items.length; index++) ...[
                        _PersonCard(
                          item: items[index],
                          onTap: () => setState(
                            () => _view = SupervisorMrfPeopleView.details,
                          ),
                        ),
                        if (index != items.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
                _FullWidthAction(
                  label: context.l10n.supervisorMrfAddNewPerson,
                  onPressed: _openAddForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_MrfPersonItem> _listItems(BuildContext context) {
    if (_view == SupervisorMrfPeopleView.added ||
        _view == SupervisorMrfPeopleView.removed) {
      return [
        _MrfPersonItem(
          context.l10n.supervisorMrfPersonManohar,
          context.l10n.supervisorMrfLocationKargil,
        ),
        _MrfPersonItem(
          context.l10n.supervisorMrfPersonRamesh,
          context.l10n.supervisorMrfLocationMagdalla,
        ),
        _MrfPersonItem(
          context.l10n.supervisorMrfPersonRamesh,
          context.l10n.supervisorMrfLocationSilver,
        ),
        _MrfPersonItem(
          context.l10n.supervisorMrfPersonSureshSharma,
          context.l10n.supervisorMrfLocationSardar,
        ),
      ];
    }
    return [
      _MrfPersonItem(
        context.l10n.supervisorMrfPersonChunilal,
        context.l10n.supervisorMrfCenterSurat,
        labor: context.l10n.supervisorMrfLaborAssigned(2),
      ),
      _MrfPersonItem(
        context.l10n.supervisorMrfPersonRamesh,
        context.l10n.supervisorMrfCenterSuratEast,
        labor: context.l10n.supervisorMrfLaborAssigned(3),
      ),
      _MrfPersonItem(
        context.l10n.supervisorMrfPersonSuresh,
        context.l10n.supervisorMrfCenterSuratWest,
        labor: context.l10n.supervisorMrfLaborAssigned(1),
      ),
    ];
  }

  Widget _buildForm(BuildContext context) {
    final centers = [
      context.l10n.supervisorMrfCenterSurat,
      context.l10n.supervisorMrfCenterSuratEast,
      context.l10n.supervisorMrfCenterSuratWest,
      context.l10n.supervisorMrfCenterSuratSouth,
    ];
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _BackButton(
                          onTap: () => setState(
                            () => _view = SupervisorMrfPeopleView.list,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _RequiredField(
                        label: context.l10n.supervisorMrfFullName,
                        hint: context.l10n.supervisorMrfEnterFullName,
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _PhoneField(
                        label: context.l10n.supervisorMrfMobileNumber,
                        hint: context.l10n.supervisorMrfEnterMobile,
                        controller: _phoneController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 24),
                      _RequiredLabel(context.l10n.supervisorMrfAssignCenter),
                      const SizedBox(height: 8),
                      _CenterPicker(
                        value: _selectedCenter < 0
                            ? context.l10n.supervisorMrfSelectCenter
                            : centers[_selectedCenter],
                        expanded: _centersOpen,
                        options: centers,
                        selectedIndex: _selectedCenter,
                        onToggle: () =>
                            setState(() => _centersOpen = !_centersOpen),
                        onSelected: (index) => setState(() {
                          _selectedCenter = index;
                          _centersOpen = false;
                        }),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.supervisorMrfCenterHelper,
                        style: AppTextStyles.regularB8_12.copyWith(
                          color: AppColors.cool600,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Divider(height: 1, color: AppColors.cool300),
                      const SizedBox(height: 24),
                      for (var index = 0; index < _labors.length; index++) ...[
                        _LaborCard(
                          index: index,
                          labor: _labors[index],
                          onRemove: () => _removeLabor(index),
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          key: const Key('supervisor-mrf-add-labor'),
                          onPressed: _addLabor,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(161, 46),
                            foregroundColor: AppColors.primary500,
                            side: const BorderSide(color: AppColors.primary500),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: AppTextStyles.boldH7_16,
                          ),
                          child: Text(context.l10n.supervisorMrfAddLabor),
                        ),
                      ),
                    ],
                  ),
                ),
                _FormActions(
                  cancelLabel: context.l10n.cancel,
                  saveLabel: context.l10n.supervisorMrfSave,
                  canSave: _canSave,
                  onCancel: () =>
                      setState(() => _view = SupervisorMrfPeopleView.list),
                  onSave: () =>
                      setState(() => _view = SupervisorMrfPeopleView.added),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) => Scaffold(
    backgroundColor: AppColors.backgroundColor,
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _BackButton(
                        onTap: () => setState(
                          () => _view = SupervisorMrfPeopleView.list,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _RegistrationCard(
                      id: context.l10n.supervisorMrfRegistrationId,
                    ),
                    const SizedBox(height: 16),
                    _DetailsCard(
                      rows: [
                        (
                          context.l10n.supervisorMrfFullNamePlain,
                          context.l10n.supervisorMrfPersonChunilal,
                        ),
                        (
                          context.l10n.supervisorMrfMobileNumberPlain,
                          '1234567890',
                        ),
                        (
                          context.l10n.supervisorMrfAssignedCenter,
                          context.l10n.supervisorMrfCenterSurat,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _LaborDetailsCard(
                      title: context.l10n.supervisorMrfLaborNumber(1),
                      nameLabel: context.l10n.supervisorMrfFullNamePlain,
                      name: context.l10n.supervisorMrfLaborHaresh,
                      phoneLabel: context.l10n.supervisorMrfMobileNumberPlain,
                      phone: '0987654321',
                    ),
                  ],
                ),
              ),
              _DetailActions(
                removeLabel: context.l10n.supervisorMrfRemovePerson,
                editLabel: context.l10n.edit,
                onRemove: () => _showRemoveDialog(context),
                onEdit: () {
                  for (final labor in _labors) {
                    labor.dispose();
                  }
                  _labors.clear();
                  _prefillForm();
                  setState(() => _view = SupervisorMrfPeopleView.addFilled);
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _showRemoveDialog(BuildContext context) async {
    final remove = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .56),
      builder: (dialogContext) => _RemovePersonDialog(
        title: context.l10n.supervisorMrfRemoveDialogTitle,
        message: context.l10n.supervisorMrfRemoveDialogMessage,
        cancelLabel: context.l10n.cancel,
        yesLabel: context.l10n.supervisorMrfYes,
      ),
    );
    if (remove == true && mounted) {
      setState(() => _view = SupervisorMrfPeopleView.removed);
    }
  }
}

class _LaborControllers {
  _LaborControllers({String name = '', String phone = ''})
    : name = TextEditingController(text: name),
      phone = TextEditingController(text: phone);

  final TextEditingController name;
  final TextEditingController phone;

  void dispose() {
    name.dispose();
    phone.dispose();
  }
}

class _MrfPersonItem {
  const _MrfPersonItem(this.name, this.center, {this.labor});

  final String name;
  final String center;
  final String? labor;
}

class _MrfBannerData {
  const _MrfBannerData({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color backgroundColor;
  final Widget icon;
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.primary500,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      key: const Key('supervisor-mrf-back'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SvgPicture.asset(
            SupervisorMrfPeopleAssets.back,
            width: 20,
            height: 20,
          ),
        ),
      ),
    ),
  );
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 55,
    child: TextField(
      key: const Key('supervisor-mrf-search'),
      controller: controller,
      onChanged: onChanged,
      style: AppTextStyles.regularB7_14,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.neutral500,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(15),
          child: SvgPicture.asset(SupervisorMrfPeopleAssets.search),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.primary500),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({required this.item, required this.onTap});

  final _MrfPersonItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      key: ValueKey('supervisor-mrf-${item.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: item.labor == null ? 88 : 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [HomeStyles.cardShadow],
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.semiboldH7_18),
                const SizedBox(height: 6),
                _IconText(
                  icon: SupervisorMrfPeopleAssets.location,
                  text: item.center,
                ),
                if (item.labor != null)
                  _IconText(
                    icon: SupervisorMrfPeopleAssets.labor,
                    text: item.labor!,
                  ),
              ],
            ),
            Positioned(
              right: 0,
              top: 0,
              child: SvgPicture.asset(
                SupervisorMrfPeopleAssets.openDetails,
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _IconText extends StatelessWidget {
  const _IconText({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 30,
        height: 30,
        child: Center(child: SvgPicture.asset(icon, width: 20, height: 20)),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.regularB7_14.copyWith(
            color: AppColors.neutral700,
          ),
        ),
      ),
    ],
  );
}

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: '$label ',
      children: const [
        TextSpan(
          text: '*',
          style: TextStyle(color: AppColors.red600),
        ),
      ],
    ),
    style: AppTextStyles.mediumSH8_14,
  );
}

class _RequiredField extends StatelessWidget {
  const _RequiredField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _RequiredLabel(label),
      const SizedBox(height: 8),
      _TextBox(controller: controller, hint: hint, onChanged: onChanged),
    ],
  );
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _RequiredLabel(label),
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
            child: _TextBox(
              controller: controller,
              hint: hint,
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    ],
  );
}

class _TextBox extends StatelessWidget {
  const _TextBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => SizedBox(
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
  );
}

class _CenterPicker extends StatelessWidget {
  const _CenterPicker({
    required this.value,
    required this.expanded,
    required this.options,
    required this.selectedIndex,
    required this.onToggle,
    required this.onSelected,
  });

  final String value;
  final bool expanded;
  final List<String> options;
  final int selectedIndex;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: const Key('supervisor-mrf-center-picker'),
          onTap: onToggle,
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
                    value,
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: selectedIndex < 0
                          ? AppColors.cool500
                          : AppColors.neutral950,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? .25 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: SvgPicture.asset(
                    SupervisorMrfPeopleAssets.dropdown,
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (expanded) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              for (var index = 0; index < options.length; index++)
                InkWell(
                  key: ValueKey('supervisor-mrf-center-$index'),
                  onTap: () => onSelected(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.neutral400),
                          ),
                          child: selectedIndex == index
                              ? const DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary500,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            options[index],
                            style: AppTextStyles.regularB7_14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ],
  );
}

class _LaborCard extends StatelessWidget {
  const _LaborCard({
    required this.index,
    required this.labor,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _LaborControllers labor;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.supervisorMrfLaborNumber(index + 1),
                style: AppTextStyles.semiboldH7_18,
              ),
            ),
            IconButton(
              key: ValueKey('supervisor-mrf-remove-labor-$index'),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              icon: SvgPicture.asset(
                SupervisorMrfPeopleAssets.delete,
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _RequiredField(
          label: context.l10n.supervisorMrfFullName,
          hint: context.l10n.supervisorMrfEnterFullName,
          controller: labor.name,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 24),
        _PhoneField(
          label: context.l10n.supervisorMrfMobileNumber,
          hint: context.l10n.supervisorMrfEnterMobile,
          controller: labor.phone,
          onChanged: (_) => onChanged(),
        ),
      ],
    ),
  );
}

class _FullWidthAction extends StatelessWidget {
  const _FullWidthAction({required this.label, required this.onPressed});

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
        key: const Key('supervisor-mrf-add-person'),
        onPressed: onPressed,
        style: _buttonStyle(AppColors.primary500, Colors.white),
        child: Text(label),
      ),
    ),
  );
}

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.cancelLabel,
    required this.saveLabel,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  final String cancelLabel;
  final String saveLabel;
  final bool canSave;
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
              style: _buttonStyle(AppColors.cool200, AppColors.neutral950),
              child: Text(cancelLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const Key('supervisor-mrf-save'),
              onPressed: canSave ? onSave : null,
              style: _buttonStyle(AppColors.primary500, Colors.white).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? AppColors.neutral400
                      : AppColors.primary500,
                ),
              ),
              child: Text(saveLabel),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RegistrationCard extends StatelessWidget {
  const _RegistrationCard({required this.id});

  final String id;

  @override
  Widget build(BuildContext context) => Container(
    height: 56,
    padding: const EdgeInsets.all(8),
    decoration: _cardDecoration(12),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SvgPicture.asset(SupervisorMrfPeopleAssets.profile),
        ),
        const SizedBox(width: 10),
        Text(id, style: AppTextStyles.semiboldH8_16),
      ],
    ),
  );
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.rows});

  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(12),
    child: Column(
      children: [
        for (var index = 0; index < rows.length; index++) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rows[index].$1,
                  style: AppTextStyles.mediumSH8_14.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '  •  ${rows[index].$2}',
                  style: AppTextStyles.semiboldH9_14,
                ),
              ],
            ),
          ),
          if (index != rows.length - 1) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.cool400),
            const SizedBox(height: 10),
          ],
        ],
      ],
    ),
  );
}

class _LaborDetailsCard extends StatelessWidget {
  const _LaborDetailsCard({
    required this.title,
    required this.nameLabel,
    required this.name,
    required this.phoneLabel,
    required this.phone,
  });

  final String title;
  final String nameLabel;
  final String name;
  final String phoneLabel;
  final String phone;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.semiboldH7_18),
        const SizedBox(height: 16),
        Text(
          nameLabel,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Text('  •  $name', style: AppTextStyles.semiboldH9_14),
        const SizedBox(height: 10),
        const Divider(height: 1, color: AppColors.cool400),
        const SizedBox(height: 10),
        Text(
          phoneLabel,
          style: AppTextStyles.mediumSH8_14.copyWith(
            color: AppColors.neutral600,
          ),
        ),
        const SizedBox(height: 4),
        Text('  •  $phone', style: AppTextStyles.semiboldH9_14),
      ],
    ),
  );
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.removeLabel,
    required this.editLabel,
    required this.onRemove,
    required this.onEdit,
  });

  final String removeLabel;
  final String editLabel;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

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
              key: const Key('supervisor-mrf-remove-person'),
              onPressed: onRemove,
              style: _buttonStyle(AppColors.red500, Colors.white),
              child: Text(removeLabel),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              key: const Key('supervisor-mrf-edit-person'),
              onPressed: onEdit,
              style: _buttonStyle(AppColors.primary500, Colors.white),
              child: Text(editLabel),
            ),
          ),
        ),
      ],
    ),
  );
}

class _RemovePersonDialog extends StatelessWidget {
  const _RemovePersonDialog({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.yesLabel,
  });

  final String title;
  final String message;
  final String cancelLabel;
  final String yesLabel;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: AppTextStyles.semiboldH6_20),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral700,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: _buttonStyle(
                      AppColors.cool200,
                      AppColors.neutral900,
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
                    key: const Key('supervisor-mrf-confirm-remove'),
                    onPressed: () => Navigator.pop(context, true),
                    style: _buttonStyle(AppColors.red500, Colors.white),
                    child: Text(yesLabel),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

ButtonStyle _buttonStyle(Color background, Color foreground) =>
    ElevatedButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyles.boldH7_16,
    );

BoxDecoration _cardDecoration(double radius) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
  ],
);
