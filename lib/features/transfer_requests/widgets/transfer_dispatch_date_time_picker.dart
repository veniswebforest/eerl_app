import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class TransferDispatchDateTimePicker extends StatefulWidget {
  const TransferDispatchDateTimePicker({
    super.key,
    this.initialDateTime,
    this.minimumDateTime,
    required this.onCancel,
    required this.onConfirm,
  });

  final DateTime? initialDateTime;
  final DateTime? minimumDateTime;
  final VoidCallback onCancel;
  final ValueChanged<DateTime> onConfirm;

  @override
  State<TransferDispatchDateTimePicker> createState() =>
      _TransferDispatchDateTimePickerState();
}

class _TransferDispatchDateTimePickerState
    extends State<TransferDispatchDateTimePicker> {
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late final DateTime? _minimumDateTime;

  @override
  void initState() {
    super.initState();
    final configuredMinimum = widget.minimumDateTime;
    _minimumDateTime = configuredMinimum == null
        ? null
        : _ceilToMinute(configuredMinimum);
    final requested =
        widget.initialDateTime ?? _minimumDateTime ?? DateTime.now();
    final minimum = _minimumDateTime;
    final initial = minimum != null && requested.isBefore(minimum)
        ? minimum
        : requested;
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _displayedMonth = DateTime(initial.year, initial.month);
    _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
  }

  DateTime _ceilToMinute(DateTime value) {
    final minute = DateTime(
      value.year,
      value.month,
      value.day,
      value.hour,
      value.minute,
    );
    return value.second == 0 && value.millisecond == 0 && value.microsecond == 0
        ? minute
        : minute.add(const Duration(minutes: 1));
  }

  DateTime get _selectedDateTime => DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  bool _isBeforeMinimum(DateTime value) {
    final minimum = _minimumDateTime;
    return minimum != null && value.isBefore(minimum);
  }

  bool _isDateBeforeMinimum(DateTime value) {
    final minimum = _minimumDateTime;
    if (minimum == null) return false;
    return DateTime(
      value.year,
      value.month,
      value.day,
    ).isBefore(DateTime(minimum.year, minimum.month, minimum.day));
  }

  bool get _canGoToPreviousMonth {
    final minimum = _minimumDateTime;
    if (minimum == null) return true;
    return _displayedMonth.year > minimum.year ||
        (_displayedMonth.year == minimum.year &&
            _displayedMonth.month > minimum.month);
  }

  void _selectTime(TimeOfDay value) {
    final candidate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      value.hour,
      value.minute,
    );
    final minimum = _minimumDateTime;
    setState(() {
      _selectedTime = minimum != null && candidate.isBefore(minimum)
          ? TimeOfDay.fromDateTime(minimum)
          : value;
    });
  }

  List<({DateTime date, bool currentMonth})> _monthDays() {
    final first = DateTime(_displayedMonth.year, _displayedMonth.month);
    final leading = first.weekday % 7;
    final total = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;
    final days = <({DateTime date, bool currentMonth})>[];
    for (var offset = leading; offset > 0; offset--) {
      days.add((
        date: first.subtract(Duration(days: offset)),
        currentMonth: false,
      ));
    }
    for (var day = 1; day <= total; day++) {
      days.add((
        date: DateTime(_displayedMonth.year, _displayedMonth.month, day),
        currentMonth: true,
      ));
    }
    final trailing = (7 - days.length % 7) % 7;
    for (var day = 1; day <= trailing; day++) {
      days.add((
        date: DateTime(_displayedMonth.year, _displayedMonth.month + 1, day),
        currentMonth: false,
      ));
    }
    return days;
  }

  void _changeMonth(int offset) => setState(() {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + offset,
    );
  });

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) _selectTime(picked);
  }

  void _setPeriod(DayPeriod period) {
    if (_selectedTime.period == period) return;
    _selectTime(
      TimeOfDay(
        hour: period == DayPeriod.am
            ? _selectedTime.hour - 12
            : _selectedTime.hour + 12,
        minute: _selectedTime.minute,
      ),
    );
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
    final days = _monthDays();
    final hour = _selectedTime.hourOfPeriod == 0
        ? 12
        : _selectedTime.hourOfPeriod;
    final time =
        '${hour.toString().padLeft(2, '0')}:'
        '${_selectedTime.minute.toString().padLeft(2, '0')}';
    final isAm = _selectedTime.period == DayPeriod.am;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
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
                  DateFormat('MMMM yyyy').format(_displayedMonth),
                  style: AppTextStyles.semiboldH8_16.copyWith(
                    color: AppColors.primary500,
                  ),
                ),
              ),
              _CalendarArrow(
                key: const Key('transfer-calendar-previous'),
                asset: 'assets/icons/tasks/calendar_right.svg',
                onTap: _canGoToPreviousMonth ? () => _changeMonth(-1) : null,
              ),
              const SizedBox(width: 7),
              _CalendarArrow(
                key: const Key('transfer-calendar-next'),
                asset: 'assets/icons/tasks/calendar_left.svg',
                onTap: () => _changeMonth(1),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final day in weekdays)
                Expanded(
                  child: Text(
                    day,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: AppColors.cool400,
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
              mainAxisExtent: 48,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final item = days[index];
              final selected = DateUtils.isSameDay(item.date, _selectedDate);
              final disabled = _isDateBeforeMinimum(item.date);
              return Center(
                child: InkWell(
                  onTap: disabled
                      ? null
                      : () => setState(() {
                          _selectedDate = item.date;
                          if (!item.currentMonth) {
                            _displayedMonth = DateTime(
                              item.date.year,
                              item.date.month,
                            );
                          }
                          final minimum = _minimumDateTime;
                          if (minimum != null &&
                              _selectedDateTime.isBefore(minimum)) {
                            _selectedTime = TimeOfDay.fromDateTime(minimum);
                          }
                        }),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: selected
                        ? const BoxDecoration(
                            color: AppColors.primary500,
                            shape: BoxShape.circle,
                          )
                        : null,
                    child: Text(
                      '${item.date.day}',
                      style: AppTextStyles.mediumSH8_14.copyWith(
                        color: selected
                            ? Colors.white
                            : disabled
                            ? AppColors.neutral300
                            : item.currentMonth
                            ? AppColors.neutral700
                            : AppColors.secondary400,
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
                  style: AppTextStyles.semiboldH8_16,
                ),
              ),
              _TimePill(label: time, onTap: _pickTime),
              const SizedBox(width: 8),
              _TimePill(
                label: context.l10n.supervisorTaskAm,
                selected: isAm,
                onTap: () => _setPeriod(DayPeriod.am),
              ),
              _TimePill(
                label: context.l10n.supervisorTaskPm,
                selected: !isAm,
                onTap: () => _setPeriod(DayPeriod.pm),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.cool200),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.cool200,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.supervisorTaskCancel,
                    style: AppTextStyles.semiboldH8_16.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  key: const Key('transfer-calendar-confirm'),
                  onPressed: _isBeforeMinimum(_selectedDateTime)
                      ? null
                      : () => widget.onConfirm(_selectedDateTime),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    elevation: 0,
                    backgroundColor: AppColors.primary500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.supervisorTaskConfirm,
                    style: AppTextStyles.semiboldH8_16.copyWith(
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

class _CalendarArrow extends StatelessWidget {
  const _CalendarArrow({super.key, required this.asset, required this.onTap});

  final String asset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? .35 : 1,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: SvgPicture.asset(asset, width: 30, height: 30),
    ),
  );
}

class _TimePill extends StatelessWidget {
  const _TimePill({required this.label, this.selected = false, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.primary500 : AppColors.cool100,
    borderRadius: BorderRadius.circular(6),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: AppTextStyles.regularB7_14.copyWith(
            color: selected ? Colors.white : AppColors.neutral700,
          ),
        ),
      ),
    ),
  );
}
