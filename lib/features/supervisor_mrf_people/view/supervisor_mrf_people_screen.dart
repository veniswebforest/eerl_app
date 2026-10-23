import 'package:eerl_app/features/home/widgets/home_styles.dart';
import 'package:eerl_app/features/bootstrap/service/outgoing_sync_service.dart';
import 'package:eerl_app/features/local_data/data/eerl_local_repository.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/core/utils/uuid_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import '../model/supervisor_mrf_people_view.dart';
import '../widgets/supervisor_mrf_people_assets.dart';

typedef SupervisorMrfTeamData = ({
  List<CenterModel> centers,
  List<MrfPersonModel> active,
  List<MrfPersonModel> inactive,
});

class SupervisorMrfPeopleScreen extends StatefulWidget {
  const SupervisorMrfPeopleScreen({
    super.key,
    this.initialView = SupervisorMrfPeopleView.list,
    this.repository,
    this.teamLoader,
  });

  final SupervisorMrfPeopleView initialView;
  final EerlLocalRepository? repository;
  final Future<SupervisorMrfTeamData> Function()? teamLoader;

  @override
  State<SupervisorMrfPeopleScreen> createState() =>
      _SupervisorMrfPeopleScreenState();
}

class _SupervisorMrfPeopleScreenState extends State<SupervisorMrfPeopleScreen> {
  EerlLocalRepository get _repository =>
      widget.repository ?? EerlLocalRepository.instance;
  late SupervisorMrfPeopleView _view = widget.initialView;
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final List<_LaborControllers> _labors = [];
  int _selectedCenter = -1;
  bool _centersOpen = false;
  List<MrfPersonModel> _activePeople = const [];
  List<MrfPersonModel> _inactivePeople = const [];
  MrfPersonModel? _selectedPerson;
  List<CenterModel> _centers = const [];
  bool _loading = true;
  bool _isSaving = false;
  String? _loadError;

  bool get _isForm => switch (_view) {
    SupervisorMrfPeopleView.addEmpty ||
    SupervisorMrfPeopleView.addWithLabor ||
    SupervisorMrfPeopleView.addFilled => true,
    _ => false,
  };

  @override
  void initState() {
    super.initState();
    if (_view == SupervisorMrfPeopleView.addWithLabor) {
      _addLabor();
    } else if (_view == SupervisorMrfPeopleView.addFilled) {
      _prefillForm();
      _centersOpen = true;
    }
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _loadError = null;
      });
    }
    try {
      final customLoader = widget.teamLoader;
      if (customLoader != null) {
        final team = await customLoader();
        if (!mounted) return;
        _applyLoadedTeam(team);
        return;
      }
      final values = await Future.wait<Object?>([
        _repository.getAllCenters(),
        _repository.getMrfPeople(isActive: true, allCenters: true),
        _repository.getMrfPeople(isActive: false, allCenters: true),
      ]);
      if (!mounted) return;
      final active = values[1]! as List<MrfPersonModel>;
      final inactive = values[2]! as List<MrfPersonModel>;
      _applyLoadedTeam((
        centers: values[0]! as List<CenterModel>,
        active: active,
        inactive: inactive,
      ));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.toString();
        _loading = false;
      });
    }
  }

  void _applyLoadedTeam(SupervisorMrfTeamData team) {
    setState(() {
      _centers = team.centers;
      _activePeople = team.active;
      _inactivePeople = team.inactive;
      if (_view == SupervisorMrfPeopleView.details && _selectedPerson == null) {
        _selectedPerson = team.active.isEmpty ? null : team.active.first;
      }
      _loading = false;
    });
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

  void _addLabor({
    String name = '',
    String phone = '',
    MrfPersonModel? existing,
  }) {
    _labors.add(
      _LaborControllers(name: name, phone: phone, existing: existing),
    );
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

  void _openEditForm() {
    final person = _selectedPerson!;
    final team = person.isActive ? _activePeople : _inactivePeople;
    _nameController.text = person.name;
    _phoneController.text = person.phone ?? '';
    for (final labor in _labors) {
      labor.dispose();
    }
    _labors.clear();
    for (final labor in team.where(
      (member) => member.centerId == person.centerId && !_isSupervisor(member),
    )) {
      _labors.add(
        _LaborControllers(
          name: labor.name,
          phone: labor.phone ?? '',
          existing: labor,
        ),
      );
    }
    setState(() {
      _selectedCenter = _centers.indexWhere(
        (center) => center.id == person.centerId,
      );
      _centersOpen = false;
      _view = SupervisorMrfPeopleView.addFilled;
    });
  }

  Future<void> _saveForm() async {
    final error = _formValidationError();
    if (error != null) {
      await _showError(error);
      return;
    }
    final existingSupervisor = _selectedPerson;
    final selectedCenter = existingSupervisor == null
        ? _centers[_selectedCenter]
        : _centers.firstWhere(
            (center) => center.id == existingSupervisor.centerId,
          );
    final originalTeam = existingSupervisor == null
        ? const <MrfPersonModel>[]
        : (existingSupervisor.isActive ? _activePeople : _inactivePeople)
              .where((person) => person.centerId == existingSupervisor.centerId)
              .toList(growable: false);
    final supervisor = MrfPersonModel(
      id: existingSupervisor?.id ?? UuidGenerator.v4(),
      number: existingSupervisor?.number,
      centerId: selectedCenter.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      idNumber: existingSupervisor?.idNumber,
      photoUrl: existingSupervisor?.photoUrl,
      isActive: true,
      role: 'SUPERVISOR',
      syncState: 'pending',
    );

    setState(() => _isSaving = true);
    try {
      await _repository.saveMrfPerson(
        supervisor,
        isNew: existingSupervisor == null,
      );
      final retainedLaborIds = <String>{};
      for (final labor in _labors) {
        final existing = labor.existing;
        final id = existing?.id ?? UuidGenerator.v4();
        retainedLaborIds.add(id);
        await _repository.saveMrfPerson(
          MrfPersonModel(
            id: id,
            number: existing?.number,
            centerId: selectedCenter.id,
            name: labor.name.text.trim(),
            phone: labor.phone.text.trim(),
            idNumber: existing?.idNumber,
            photoUrl: existing?.photoUrl,
            isActive: true,
            role: 'LABOUR',
            syncState: 'pending',
          ),
          isNew: existing == null,
        );
      }
      for (final removed in originalTeam.where(
        (person) =>
            !_isSupervisor(person) && !retainedLaborIds.contains(person.id),
      )) {
        await _repository.setMrfPersonActive(removed, false);
      }
      await OutgoingSyncService.instance.drain();
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _selectedPerson = null;
        _view = SupervisorMrfPeopleView.added;
      });
      await _loadPeople();
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      await _showError(_readableError(error));
    }
  }

  String? _formValidationError() {
    if (_nameController.text.trim().isEmpty) return 'Full name is required.';
    if (!_isValidPhone(_phoneController.text)) {
      return 'Enter a valid 10-digit supervisor mobile number.';
    }
    if (_selectedPerson == null &&
        (_selectedCenter < 0 || _selectedCenter >= _centers.length)) {
      return 'Select a center.';
    }
    for (var index = 0; index < _labors.length; index++) {
      final labor = _labors[index];
      if (labor.name.text.trim().isEmpty) {
        return 'Labor ${index + 1} full name is required.';
      }
      if (!_isValidPhone(labor.phone.text)) {
        return 'Enter a valid 10-digit mobile number for Labor ${index + 1}.';
      }
    }
    return null;
  }

  bool _isValidPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length == 10 ||
        (digits.length == 12 && digits.startsWith('91'));
  }

  String _readableError(Object error) {
    if (error is ArgumentError) return error.message?.toString() ?? '$error';
    return error.toString().replaceFirst('Bad state: ', '');
  }

  Future<void> _showError(String message) => showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      key: const Key('supervisor-mrf-error-dialog'),
      title: Text(context.l10n.error),
      content: Text(message),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.confirm),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_isForm && _selectedPerson == null,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) {
        setState(() {
          _selectedPerson = null;
          _view = SupervisorMrfPeopleView.list;
        });
      }
    },
    child: _isForm
        ? _buildForm(context)
        : _selectedPerson != null
        ? _buildDetails(context)
        : _buildList(context),
  );

  Widget _buildList(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final allTeams = _teamsFor(_activePeople);
    final teams = allTeams
        .where((team) {
          if (query.isEmpty) return true;
          final centerName = _centerName(
            team.supervisor.centerId,
          ).toLowerCase();
          return centerName.contains(query) ||
              team.members.any(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    (item.phone ?? '').toLowerCase().contains(query) ||
                    (item.number ?? '').toLowerCase().contains(query),
              );
        })
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
                  child: RefreshIndicator(
                    onRefresh: _loadPeople,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 64),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (_loadError != null)
                          _MrfLoadError(onRetry: _loadPeople)
                        else if (allTeams.isEmpty)
                          const _MrfTeamEmptyState()
                        else if (teams.isEmpty)
                          _MrfEmptyState(message: context.l10n.personNotFound)
                        else
                          for (
                            var index = 0;
                            index < teams.length;
                            index++
                          ) ...[
                            _PersonCard(
                              item: _MrfPersonItem(
                                person: teams[index].supervisor,
                                center: _centerName(
                                  teams[index].supervisor.centerId,
                                ),
                                labor: context.l10n.supervisorMrfLaborAssigned(
                                  teams[index].labors.length,
                                ),
                              ),
                              onTap: () => setState(() {
                                _selectedPerson = teams[index].supervisor;
                                _view = SupervisorMrfPeopleView.details;
                              }),
                            ),
                            if (index != teams.length - 1)
                              const SizedBox(height: 12),
                          ],
                      ],
                    ),
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

  Widget _buildForm(BuildContext context) {
    final centers = _centers.isEmpty
        ? [
            context.l10n.supervisorMrfCenterSurat,
            context.l10n.supervisorMrfCenterSuratEast,
            context.l10n.supervisorMrfCenterSuratWest,
            context.l10n.supervisorMrfCenterSuratSouth,
          ]
        : _centers.map((center) => center.name).toList(growable: false);
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
                          onTap: () => setState(() {
                            _selectedPerson = null;
                            _view = SupervisorMrfPeopleView.list;
                          }),
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
                  canSave: !_isSaving,
                  onCancel: () => setState(() {
                    _selectedPerson = null;
                    _view = SupervisorMrfPeopleView.list;
                  }),
                  onSave: _saveForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final person = _selectedPerson!;
    final team = person.isActive ? _activePeople : _inactivePeople;
    final labors = team
        .where(
          (member) =>
              member.centerId == person.centerId && !_isSupervisor(member),
        )
        .toList(growable: false);
    final registration = person.number?.trim().isNotEmpty == true
        ? person.number!
        : person.id;
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
                          onTap: () => setState(() {
                            _selectedPerson = null;
                            _view = SupervisorMrfPeopleView.list;
                          }),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _RegistrationCard(id: '#$registration'),
                      const SizedBox(height: 16),
                      _DetailsCard(
                        rows: [
                          (
                            context.l10n.supervisorMrfFullNamePlain,
                            person.name,
                          ),
                          (
                            context.l10n.supervisorMrfMobileNumberPlain,
                            _valueOrDash(person.phone),
                          ),
                          (
                            context.l10n.supervisorMrfAssignedCenter,
                            _centerName(person.centerId),
                          ),
                        ],
                      ),
                      for (var index = 0; index < labors.length; index++) ...[
                        const SizedBox(height: 16),
                        _LaborDetailsCard(
                          title: context.l10n.supervisorMrfLaborNumber(
                            index + 1,
                          ),
                          nameLabel: context.l10n.supervisorMrfFullNamePlain,
                          name: labors[index].name,
                          phoneLabel:
                              context.l10n.supervisorMrfMobileNumberPlain,
                          phone: _valueOrDash(labors[index].phone),
                        ),
                      ],
                    ],
                  ),
                ),
                _DetailActions(
                  removeLabel: context.l10n.supervisorMrfRemovePerson,
                  editLabel: context.l10n.edit,
                  onRemove: () => _showRemoveDialog(context),
                  onEdit: _openEditForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      final person = _selectedPerson!;
      setState(() => _isSaving = true);
      try {
        await _repository.setMrfPersonActive(person, false);
        await OutgoingSyncService.instance.drain();
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _selectedPerson = null;
          _view = SupervisorMrfPeopleView.removed;
        });
        await _loadPeople();
      } catch (error) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        await _showError(_readableError(error));
      }
    }
  }

  String _valueOrDash(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? '-' : normalized;
  }

  bool _isSupervisor(MrfPersonModel person) =>
      person.role.trim().toUpperCase() == 'SUPERVISOR';

  MrfPersonModel? _supervisorIn(List<MrfPersonModel> people) {
    for (final person in people) {
      if (_isSupervisor(person)) return person;
    }
    return null;
  }

  String _centerName(String centerId) {
    for (final center in _centers) {
      if (center.id == centerId) return center.name;
    }
    return centerId;
  }

  List<_MrfTeam> _teamsFor(List<MrfPersonModel> people) {
    final byCenter = <String, List<MrfPersonModel>>{};
    for (final person in people) {
      byCenter.putIfAbsent(person.centerId, () => []).add(person);
    }
    final teams = <_MrfTeam>[];
    for (final members in byCenter.values) {
      final supervisor = _supervisorIn(members);
      if (supervisor != null) {
        teams.add(_MrfTeam(supervisor: supervisor, members: members));
      }
    }
    teams.sort(
      (left, right) => _centerName(left.supervisor.centerId)
          .toLowerCase()
          .compareTo(_centerName(right.supervisor.centerId).toLowerCase()),
    );
    return teams;
  }
}

class _MrfTeam {
  const _MrfTeam({required this.supervisor, required this.members});

  final MrfPersonModel supervisor;
  final List<MrfPersonModel> members;

  List<MrfPersonModel> get labors => members
      .where((person) => person.role.trim().toUpperCase() != 'SUPERVISOR')
      .toList(growable: false);
}

class _LaborControllers {
  _LaborControllers({String name = '', String phone = '', this.existing})
    : name = TextEditingController(text: name),
      phone = TextEditingController(text: phone);

  final MrfPersonModel? existing;
  final TextEditingController name;
  final TextEditingController phone;

  void dispose() {
    name.dispose();
    phone.dispose();
  }
}

class _MrfPersonItem {
  const _MrfPersonItem({
    required this.person,
    required this.center,
    required this.labor,
  });

  final MrfPersonModel person;
  final String center;
  final String labor;

  String get name => person.name;
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

class _MrfEmptyState extends StatelessWidget {
  const _MrfEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 64),
    child: Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.cool600),
      ),
    ),
  );
}

class _MrfTeamEmptyState extends StatelessWidget {
  const _MrfTeamEmptyState();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 140),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            SupervisorMrfPeopleAssets.emptyTeam,
            key: const Key('supervisor-mrf-empty-illustration'),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.supervisorMrfEmptyTeam,
            key: const Key('supervisor-mrf-empty-label'),
            textAlign: TextAlign.center,
            style: AppTextStyles.semiboldH8_16.copyWith(
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    ),
  );
}

class _MrfLoadError extends StatelessWidget {
  const _MrfLoadError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: IconButton(
        key: const Key('supervisor-mrf-retry'),
        onPressed: onRetry,
        tooltip: 'Retry',
        icon: const Icon(Icons.refresh, color: AppColors.primary500),
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
        constraints: const BoxConstraints(minHeight: 120),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 2.5,
              offset: Offset(0, 2),
            ),
          ],
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.semiboldH7_18.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
                const SizedBox(height: 6),
                _IconText(
                  icon: SupervisorMrfPeopleAssets.location,
                  text: item.center,
                ),
                _IconText(
                  icon: SupervisorMrfPeopleAssets.labor,
                  text: item.labor,
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
            color: AppColors.neutral950,
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
      boxShadow: [HomeStyles.cardShadow],
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
        Expanded(
          child: Text(
            id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.semiboldH8_16,
          ),
        ),
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
              style: _buttonStyle(Colors.white, AppColors.red500),
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
      padding: EdgeInsetsGeometry.symmetric(vertical: 10, horizontal: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: foreground),
      ),
      textStyle: AppTextStyles.boldH7_16,
    );

BoxDecoration _cardDecoration(double radius) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: [HomeStyles.cardShadow],
);
