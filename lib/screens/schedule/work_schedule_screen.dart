import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/enums.dart';
import '../../models/work_schedule.dart';
import '../../providers/work_schedule_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_field_label.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class WorkScheduleScreen extends StatefulWidget {
  final String businessId;
  const WorkScheduleScreen({super.key, required this.businessId});

  @override
  State<WorkScheduleScreen> createState() => _WorkScheduleScreenState();
}

class _DayFormEntry {
  final AppDayOfWeek dayOfWeek;
  bool enabled;
  TimeOfDay startTime;
  TimeOfDay endTime;

  _DayFormEntry({
    required this.dayOfWeek,
    this.enabled = false,
    this.startTime = const TimeOfDay(hour: 9, minute: 0),
    this.endTime = const TimeOfDay(hour: 17, minute: 0),
  });
}

class _WorkScheduleScreenState extends State<WorkScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController(text: '30');

  final List<_DayFormEntry> _dayEntries = [
    _DayFormEntry(dayOfWeek: AppDayOfWeek.monday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.tuesday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.wednesday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.thursday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.friday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.saturday),
    _DayFormEntry(dayOfWeek: AppDayOfWeek.sunday),
  ];

  bool _isInitialLoading = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<WorkScheduleProvider>();
      await provider.loadSchedule(widget.businessId);
      if (!mounted) return;
      _applyScheduleToForm(provider.schedule);
      setState(() => _isInitialLoading = false);
    });
  }

  void _applyScheduleToForm(WorkSchedule? schedule) {
    if (schedule == null) return;
    _durationController.text = schedule.termDurationMinutes.toString();
    for (final workingDay in schedule.workingDays) {
      for (final entry in _dayEntries) {
        if (entry.dayOfWeek == workingDay.dayOfWeek) {
          entry.enabled = true;
          entry.startTime = workingDay.startTime;
          entry.endTime = workingDay.endTime;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _dayLabel(AppDayOfWeek day) {
    switch (day) {
      case AppDayOfWeek.monday: return 'Monday';
      case AppDayOfWeek.tuesday: return 'Tuesday';
      case AppDayOfWeek.wednesday: return 'Wednesday';
      case AppDayOfWeek.thursday: return 'Thursday';
      case AppDayOfWeek.friday: return 'Friday';
      case AppDayOfWeek.saturday: return 'Saturday';
      case AppDayOfWeek.sunday: return 'Sunday';
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final selectedDays = _dayEntries.where((e) => e.enabled).toList();
    if (selectedDays.isEmpty) {
      setState(() => _errorMessage = 'Select at least one working day');
      return;
    }

    for (final day in selectedDays) {
      if (_toMinutes(day.startTime) >= _toMinutes(day.endTime)) {
        setState(() => _errorMessage = 'Start time must be before end time for ${_dayLabel(day.dayOfWeek)}');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final duration = int.parse(_durationController.text.trim()); // validator already guarantees this
    final workingDays = selectedDays
        .map((e) => WorkingDayInput(dayOfWeek: e.dayOfWeek, startTime: e.startTime, endTime: e.endTime))
        .toList();

    final provider = context.read<WorkScheduleProvider>();
    final isEditing = provider.schedule != null;

    final success = isEditing
        ? await provider.updateSchedule(widget.businessId, termDurationMinutes: duration, workingDays: workingDays)
        : await provider.createSchedule(businessId: widget.businessId, termDurationMinutes: duration, workingDays: workingDays);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = provider.errorMessage ?? 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = context.watch<WorkScheduleProvider>().schedule != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                AppTextField(
                  controller: _durationController,
                  label: 'Term Duration (minutes)',
                  required: true,
                  hintText: 'e.g. 30',
                  icon: Icons.timer_outlined,
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                  validator: (v) {
                    final n = int.tryParse((v ?? '').trim());
                    if (n == null || n <= 0) return 'Enter a valid number of minutes';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const AppFieldLabel(label: 'Working Days', required: true),
                const SizedBox(height: 8),
                Text('Toggle each day you work and set your hours. Days can have different hours.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                const SizedBox(height: 12),
                for (final entry in _dayEntries)
                  _DayRow(
                    entry: entry,
                    label: _dayLabel(entry.dayOfWeek),
                    enabled: !_isLoading,
                    onToggle: (value) => setState(() => entry.enabled = value),
                    onStartTimeChanged: (time) => setState(() => entry.startTime = time),
                    onEndTimeChanged: (time) => setState(() => entry.endTime = time),
                  ),
                const SizedBox(height: 20),
                PrimaryButton(label: isEditing ? 'Save Changes' : 'Create Schedule', isLoading: _isLoading, onPressed: _onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final _DayFormEntry entry;
  final String label;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final ValueChanged<TimeOfDay> onStartTimeChanged;
  final ValueChanged<TimeOfDay> onEndTimeChanged;

  const _DayRow({
    required this.entry,
    required this.label,
    required this.enabled,
    required this.onToggle,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  Future<void> _pickTime(BuildContext context, TimeOfDay initial, ValueChanged<TimeOfDay> onPicked) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: entry.enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: entry.enabled ? AppColors.primary.withValues(alpha: 0.3) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Switch(value: entry.enabled, onChanged: enabled ? onToggle : null, activeThumbColor: AppColors.primary),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: entry.enabled ? Colors.black87 : Colors.grey.shade500)),
            ],
          ),
          if (entry.enabled)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: 8),
              child: Row(
                children: [
                  Expanded(child: _TimeButton(label: 'Start', time: entry.startTime, enabled: enabled, onTap: () => _pickTime(context, entry.startTime, onStartTimeChanged))),
                  const SizedBox(width: 10),
                  Expanded(child: _TimeButton(label: 'End', time: entry.endTime, enabled: enabled, onTap: () => _pickTime(context, entry.endTime, onEndTimeChanged))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeButton({required this.label, required this.time, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(time.format(context), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}