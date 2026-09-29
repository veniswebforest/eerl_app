import 'dart:io';
import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_assets.dart';
import 'package:eerl_app/features/supervisor_tasks/widgets/supervisor_task_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum AssignSupervisorTaskViewMode { empty, filled }

enum _TaskPriority { low, normal, high }

class AssignSupervisorTaskScreen extends StatefulWidget {
  const AssignSupervisorTaskScreen({
    super.key,
    this.viewMode = AssignSupervisorTaskViewMode.empty,
  });

  final AssignSupervisorTaskViewMode viewMode;

  @override
  State<AssignSupervisorTaskScreen> createState() =>
      _AssignSupervisorTaskScreenState();
}

class _AssignSupervisorTaskScreenState
    extends State<AssignSupervisorTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();
  final List<XFile> _capturedPhotos = [];
  late bool _agentExpanded;
  late bool _dateExpanded;
  late int _photoCount;
  int? _selectedAgent;
  String? _selectedDate;
  DateTime? _selectedDateTime;
  _TaskPriority _priority = _TaskPriority.low;

  bool get _isFilled => widget.viewMode == AssignSupervisorTaskViewMode.filled;

  int get _totalPhotos =>
      _capturedPhotos.length + (_capturedPhotos.isEmpty ? _photoCount : 0);

  bool get _canSend =>
      _selectedAgent != null &&
      _selectedDate != null &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _totalPhotos > 0;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _agentExpanded = !_isFilled;
    _dateExpanded = !_isFilled;
    _selectedAgent = _isFilled ? 0 : null;
    _photoCount = _isFilled ? 2 : 0;
    _selectedDateTime = _isFilled ? DateTime(2026, 8, 16, 15, 0) : null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFilled && _titleController.text.isEmpty) {
      _titleController.text = context.l10n.supervisorTaskFilledTitle;
      _descriptionController.text =
          context.l10n.supervisorTaskFilledDescription;
      _selectedDate = context.l10n.supervisorTaskFilledDate;
      _selectedDateTime = DateTime(2026, 8, 16, 15, 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 82,
      );
      if (photo != null && mounted) {
        setState(() {
          _capturedPhotos.add(photo);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _photoCount = 2;
        });
      }
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (_capturedPhotos.isNotEmpty && index < _capturedPhotos.length) {
        _capturedPhotos.removeAt(index);
      } else if (_photoCount > 0) {
        _photoCount--;
      }
    });
  }

  List<String> _agents(BuildContext context) => [
    context.l10n.supervisorTaskAgentRahul,
    context.l10n.supervisorTaskAgentAmit,
    context.l10n.supervisorTaskAgentSuresh,
    context.l10n.supervisorTaskAgentMayur,
  ];

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    behavior: HitTestBehavior.opaque,
    child: Scaffold(
      key: const Key('assign-supervisor-task-screen'),
      backgroundColor: Colors.white,
      appBar: SupervisorTaskHeader(title: context.l10n.supervisorAssignNewTask),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              children: [
                _requiredLabel(context.l10n.supervisorTaskAssignTo),
                const SizedBox(height: 8),
                _AgentSelector(
                  agents: _agents(context),
                  selectedIndex: _selectedAgent,
                  expanded: _agentExpanded,
                  hint: context.l10n.supervisorTaskSelectAgent,
                  onToggle: () =>
                      setState(() => _agentExpanded = !_agentExpanded),
                  onSelected: (index) => setState(() {
                    _selectedAgent = index;
                    _agentExpanded = false;
                  }),
                ),
                const SizedBox(height: 16),
                _requiredLabel(context.l10n.supervisorTaskPriorityLevel),
                const SizedBox(height: 8),
                _PrioritySelector(
                  selected: _priority,
                  onChanged: (value) => setState(() => _priority = value),
                ),
                const SizedBox(height: 24),
                _requiredLabel(context.l10n.supervisorTaskTaskTitle),
                const SizedBox(height: 8),
                _TaskTextField(
                  fieldKey: const Key('supervisor-task-title-field'),
                  controller: _titleController,
                  hint: context.l10n.supervisorTaskTitleHint,
                  height: 55,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _requiredLabel(context.l10n.supervisorTaskDescriptionLabel),
                const SizedBox(height: 8),
                _TaskTextField(
                  fieldKey: const Key('supervisor-task-description-field'),
                  controller: _descriptionController,
                  hint: context.l10n.supervisorTaskDescriptionHint,
                  height: 120,
                  maxLength: 150,
                  expands: true,
                  counterText: context.l10n.supervisorTaskMaxCharacters,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
                _requiredLabel(context.l10n.supervisorTaskFollowupDateTime),
                const SizedBox(height: 8),
                _DateField(
                  value: _selectedDate,
                  hint: context.l10n.supervisorTaskSelectDateTime,
                  onTap: () => setState(() => _dateExpanded = !_dateExpanded),
                ),
                if (_dateExpanded) ...[
                  const SizedBox(height: 4),
                  _DateTimePicker(
                    initialDateTime: _selectedDateTime,
                    onCancel: () => setState(() => _dateExpanded = false),
                    onConfirm: (dateTime) => setState(() {
                      _selectedDateTime = dateTime;
                      _selectedDate = DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(dateTime);
                      _dateExpanded = false;
                    }),
                  ),
                ],
                const SizedBox(height: 24),
                _requiredLabel(context.l10n.supervisorTaskAttachPhoto),
                const SizedBox(height: 8),
                _PhotoCapture(enabled: _totalPhotos < 2, onTap: _capturePhoto),
                if (_capturedPhotos.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      for (
                        var index = 0;
                        index < _capturedPhotos.length;
                        index++
                      ) ...[
                        Flexible(
                          fit: FlexFit.loose,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 143.5),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.file(
                                    File(_capturedPhotos[index].path),
                                    width: double.infinity,
                                    height: 92,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < _capturedPhotos.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ] else if (_photoCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (var index = 0; index < _photoCount; index++) ...[
                        Flexible(
                          fit: FlexFit.loose,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 143.5),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    SupervisorTaskAssets.referencePhoto,
                                    width: double.infinity,
                                    height: 92,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: InkWell(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (index < _photoCount - 1) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  _isFilled
                      ? context.l10n.supervisorTaskPhotoSupport
                      : context.l10n.supervisorTaskPhotoSupportDetailed,
                  style: AppTextStyles.regularB8_12.copyWith(
                    color: AppColors.neutral600,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    key: const Key('supervisor-task-send'),
                    onPressed: _canSend ? _showTaskSentDialog : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.primary500,
                      disabledBackgroundColor: AppColors.neutral400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      context.l10n.supervisorTaskSend,
                      style: AppTextStyles.boldH7_16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _requiredLabel(String text) => Text.rich(
    TextSpan(
      children: [
        TextSpan(text: text),
        const TextSpan(
          text: ' *',
          style: TextStyle(color: AppColors.red600),
        ),
      ],
    ),
    style: AppTextStyles.mediumSH8_14.copyWith(color: AppColors.neutral950),
  );

  Future<void> _showTaskSentDialog() => showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: context.l10n.supervisorTaskSentTitle,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    pageBuilder: (dialogContext, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
      child: Center(
        child: Dialog(
          key: const Key('supervisor-task-sent-dialog'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SizedBox(
            height: 330,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text(
                    context.l10n.supervisorTaskSentTitle,
                    style: AppTextStyles.boldH5_24.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.supervisorTaskSentMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.mediumSH8_14.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('supervisor-task-back-to-list'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.cool200,
                        foregroundColor: AppColors.neutral950,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.taskBackToList,
                        style: AppTextStyles.semiboldH8_16.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _AgentSelector extends StatelessWidget {
  const _AgentSelector({
    required this.agents,
    required this.selectedIndex,
    required this.expanded,
    required this.hint,
    required this.onToggle,
    required this.onSelected,
  });

  final List<String> agents;
  final int? selectedIndex;
  final bool expanded;
  final String hint;
  final VoidCallback onToggle;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: const Key('supervisor-task-agent-selector'),
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedIndex == null ? hint : agents[selectedIndex!],
                    style: AppTextStyles.regularB7_14.copyWith(
                      color: selectedIndex == null
                          ? AppColors.cool500
                          : AppColors.neutral950,
                    ),
                  ),
                ),
                SvgPicture.asset(
                  SupervisorTaskAssets.dropdown,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ),
        ),
      ),
      SizedBox(height: 4),
      if (expanded)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.cool400),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              for (var index = 0; index < agents.length; index++)
                InkWell(
                  key: ValueKey('supervisor-task-agent-$index'),
                  onTap: () => onSelected(index),
                  child: SizedBox(
                    height: 36,
                    child: Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.cool500),
                            color: selectedIndex == index
                                ? AppColors.primary500
                                : Colors.white,
                          ),
                          child: selectedIndex == index
                              ? const Center(
                                  child: CircleAvatar(
                                    radius: 3,
                                    backgroundColor: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            agents[index],
                            style: AppTextStyles.regularB8_12.copyWith(
                              color: AppColors.neutral700,
                            ),
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
  );
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected, required this.onChanged});

  final _TaskPriority selected;
  final ValueChanged<_TaskPriority> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
        width: 80,
        child: _PriorityButton(
          label: context.l10n.taskPriorityLow,
          selected: selected == _TaskPriority.low,
          onTap: () => onChanged(_TaskPriority.low),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 80,
        child: _PriorityButton(
          label: context.l10n.taskPriorityNormal,
          selected: selected == _TaskPriority.normal,
          onTap: () => onChanged(_TaskPriority.normal),
        ),
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 80,
        child: _PriorityButton(
          label: context.l10n.taskPriorityHigh,
          selected: selected == _TaskPriority.high,
          onTap: () => onChanged(_TaskPriority.high),
        ),
      ),
    ],
  );
}

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary500 : AppColors.cool200,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 45,
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.mediumSH8_14.copyWith(
              color: selected ? Colors.white : AppColors.neutral700,
            ),
          ),
        ),
      ),
    ),
  );
}

class _TaskTextField extends StatelessWidget {
  const _TaskTextField({
    required this.fieldKey,
    required this.controller,
    required this.hint,
    required this.height,
    required this.onChanged,
    this.maxLength,
    this.expands = false,
    this.counterText,
  });

  final Key fieldKey;
  final TextEditingController controller;
  final String hint;
  final double height;
  final ValueChanged<String> onChanged;
  final int? maxLength;
  final bool expands;
  final String? counterText;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: TextField(
      key: fieldKey,
      controller: controller,
      maxLength: maxLength,
      maxLines: expands ? null : 1,
      expands: expands,
      textAlignVertical: TextAlignVertical.top,
      onChanged: onChanged,
      style: AppTextStyles.regularB7_14,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.regularB7_14.copyWith(
          color: AppColors.cool500,
        ),
        counterText: counterText,
        counterStyle: AppTextStyles.regularB8_12.copyWith(
          color: AppColors.neutral400,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cool400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary500),
        ),
      ),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.value,
    required this.hint,
    required this.onTap,
  });

  final String? value;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      key: const Key('supervisor-task-date-field'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.cool400),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: AppTextStyles.regularB7_14.copyWith(
                  color: value == null
                      ? AppColors.cool500
                      : AppColors.neutral950,
                ),
              ),
            ),
            SvgPicture.asset(
              SupervisorTaskAssets.calendar,
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    ),
  );
}

class _CalendarDay {
  const _CalendarDay({required this.date, required this.isCurrentMonth});

  final DateTime date;
  final bool isCurrentMonth;
}

class _DateTimePicker extends StatefulWidget {
  const _DateTimePicker({
    this.initialDateTime,
    required this.onCancel,
    required this.onConfirm,
  });

  final DateTime? initialDateTime;
  final VoidCallback onCancel;
  final ValueChanged<DateTime> onConfirm;

  @override
  State<_DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<_DateTimePicker> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDateTime ?? DateTime.now();
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _displayedMonth = DateTime(initial.year, initial.month, 1);
    _selectedTime = widget.initialDateTime != null
        ? TimeOfDay(
            hour: widget.initialDateTime!.hour,
            minute: widget.initialDateTime!.minute,
          )
        : const TimeOfDay(hour: 9, minute: 30);
  }

  List<_CalendarDay> _generateMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final leadingCount = firstDay.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final daysInPrevMonth = DateTime(month.year, month.month, 0).day;

    final days = <_CalendarDay>[];

    for (var i = leadingCount - 1; i >= 0; i--) {
      final day = daysInPrevMonth - i;
      final date = DateTime(month.year, month.month - 1, day);
      days.add(_CalendarDay(date: date, isCurrentMonth: false));
    }

    for (var i = 1; i <= daysInMonth; i++) {
      final date = DateTime(month.year, month.month, i);
      days.add(_CalendarDay(date: date, isCurrentMonth: true));
    }

    final remaining = (7 - (days.length % 7)) % 7;
    for (var i = 1; i <= remaining; i++) {
      final date = DateTime(month.year, month.month + 1, i);
      days.add(_CalendarDay(date: date, isCurrentMonth: false));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            dayPeriodShape: RoundedRectangleBorder(
              borderRadius: BorderRadiusGeometry.circular(6),
            ),

            cancelButtonStyle: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.cool200),
              textStyle: WidgetStatePropertyAll(
                AppTextStyles.mediumSH8_14.copyWith(color: AppColors.cool500),
              ),
              foregroundColor: WidgetStatePropertyAll(AppColors.cool500),
              surfaceTintColor: WidgetStatePropertyAll(AppColors.cool500),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
            ),
            entryModeIconColor: AppColors.cool700,
            confirmButtonStyle: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(AppColors.primary500),
              textStyle: WidgetStatePropertyAll(
                AppTextStyles.semiboldH9_14.copyWith(
                  color: AppColors.primary200,
                ),
              ),
              foregroundColor: WidgetStatePropertyAll(AppColors.primary200),
              surfaceTintColor: WidgetStatePropertyAll(AppColors.primary200),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
              ),
            ),
          ),
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary500,
            tertiaryContainer: AppColors.primary500,
            onPrimary: Colors.white,
            onSurface: AppColors.neutral950,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _setPeriod(DayPeriod period) {
    if (_selectedTime.period != period) {
      final hour = period == DayPeriod.am
          ? (_selectedTime.hour >= 12
                ? _selectedTime.hour - 12
                : _selectedTime.hour)
          : (_selectedTime.hour < 12
                ? _selectedTime.hour + 12
                : _selectedTime.hour);
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: _selectedTime.minute);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      context.l10n.supervisorTaskSunday,
      context.l10n.supervisorTaskMonday,
      context.l10n.supervisorTaskTuesday,
      context.l10n.supervisorTaskWednesday,
      context.l10n.supervisorTaskThursday,
      context.l10n.supervisorTaskFriday,
      context.l10n.supervisorTaskSaturday,
    ];

    final days = _generateMonthDays(_displayedMonth);
    final monthHeader = DateFormat('MMMM  yyyy').format(_displayedMonth);

    final hour = _selectedTime.hourOfPeriod == 0
        ? 12
        : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final timeFormatted = '${hour.toString().padLeft(2, '0')}:$minute';
    final isAm = _selectedTime.period == DayPeriod.am;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  monthHeader,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.primary500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                key: const Key('supervisor-task-calendar-prev'),
                borderRadius: BorderRadius.circular(15),
                onTap: _previousMonth,
                child: SvgPicture.asset(
                  SupervisorTaskAssets.calendarRight,
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 7),
              InkWell(
                key: const Key('supervisor-task-calendar-next'),
                borderRadius: BorderRadius.circular(15),
                onTap: _nextMonth,
                child: SvgPicture.asset(
                  SupervisorTaskAssets.calendarLeft,
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final day in weekdays)
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.regularB8_12.copyWith(
                      color: AppColors.cool500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 30,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final item = days[index];
              final isSelected =
                  _selectedDate.year == item.date.year &&
                  _selectedDate.month == item.date.month &&
                  _selectedDate.day == item.date.day;

              return Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      _selectedDate = item.date;
                      if (!item.isCurrentMonth) {
                        _displayedMonth = DateTime(
                          item.date.year,
                          item.date.month,
                          1,
                        );
                      }
                    });
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: isSelected
                        ? const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary500,
                          )
                        : null,
                    child: Text(
                      '${item.date.day}',
                      style: AppTextStyles.regularB8_12.copyWith(
                        color: isSelected
                            ? Colors.white
                            : !item.isCurrentMonth
                            ? AppColors.cool500
                            : AppColors.neutral700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 18, color: AppColors.cool200),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.supervisorTaskTime,
                  style: AppTextStyles.semiboldH9_14,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _TimePill(
                label: timeFormatted,
                pillKey: const Key('supervisor-task-time-picker'),
                onTap: _pickTime,
              ),
              const SizedBox(width: 8),
              _TimePill(
                label: context.l10n.supervisorTaskAm,
                selected: isAm,
                pillKey: const Key('supervisor-task-am-pill'),
                onTap: () => _setPeriod(DayPeriod.am),
              ),
              // const SizedBox(width: 4),
              _TimePill(
                label: context.l10n.supervisorTaskPm,
                selected: !isAm,
                pillKey: const Key('supervisor-task-pm-pill'),
                onTap: () => _setPeriod(DayPeriod.pm),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.cool200,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n.supervisorTaskCancel,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  key: const Key('supervisor-task-date-confirm'),
                  onPressed: () {
                    final combined = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
                    widget.onConfirm(combined);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    elevation: 0,
                    backgroundColor: AppColors.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    context.l10n.supervisorTaskConfirm,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.label,
    this.selected = false,
    this.onTap,
    this.pillKey,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Key? pillKey;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary500 : AppColors.cool100,
    borderRadius: BorderRadius.circular(6),
    child: InkWell(
      key: pillKey,
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label,
          style: AppTextStyles.regularB8_12.copyWith(
            color: selected ? Colors.white : AppColors.neutral700,
          ),
        ),
      ),
    ),
  );
}

class _PhotoCapture extends StatelessWidget {
  const _PhotoCapture({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => DottedBorder(
    options: RoundedRectDottedBorderOptions(
      radius: const Radius.circular(8),
      color: enabled ? AppColors.primary500 : AppColors.cool300,
      dashPattern: const [5, 4],
    ),
    child: Material(
      color: enabled ? AppColors.primary50 : AppColors.cool100,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: const Key('supervisor-task-capture-photo'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 80,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                SupervisorTaskAssets.camera,
                width: 24,
                height: 24,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.supervisorTaskCapturePhoto,
                style: AppTextStyles.mediumSH8_14.copyWith(
                  color: enabled ? AppColors.neutral900 : AppColors.neutral400,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
