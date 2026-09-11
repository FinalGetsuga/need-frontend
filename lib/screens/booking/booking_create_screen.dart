import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/bookable_employee.dart';
import 'package:provider/provider.dart';
import '../../models/enums.dart';
import '../../models/term.dart';
import '../../providers/booking_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/term_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class BookingCreateScreen extends StatefulWidget {
  final String businessId;
  const BookingCreateScreen({super.key, required this.businessId});

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  final _notesController = TextEditingController();

  String? _selectedEmployeeId;
  DateTime? _selectedDate;
  Term? _selectedTerm;

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadBookableEmployees(widget.businessId);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onSelectEmployee(String employeeId) async {
    setState(() {
      _selectedEmployeeId = employeeId;
      _selectedDate = null;
      _selectedTerm = null;
      _errorMessage = null;
    });

    await context.read<TermProvider>().loadTerms(employeeId);

    if (!mounted) return;
    final dates = context.read<TermProvider>().termsByDate.keys.toList()..sort();
    if (dates.isNotEmpty) {
      setState(() => _selectedDate = dates.first);
    }
  }

  List<Term> _sortedTermsForDate(TermProvider provider, DateTime date) {
    final list = List<Term>.from(provider.termsByDate[date] ?? []);
    list.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });
    return list;
  }

  Future<void> _onConfirm() async {
    final term = _selectedTerm;
    if (term == null) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await context.read<BookingProvider>().createBooking(
      termId: term.id,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = context.read<BookingProvider>().errorMessage ?? 'Something went wrong. Please try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = context.watch<EmployeeProvider>();
    final termProvider = context.watch<TermProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Book Appointment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                ErrorBanner(message: _errorMessage!),
                const SizedBox(height: 16),
              ],
              const Text('Choose an Employee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildEmployeeSection(employeeProvider),
              if (_selectedEmployeeId != null) ...[
                const SizedBox(height: 28),
                const Text('Choose a Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildTermSection(termProvider),
              ],
              if (_selectedTerm != null) ...[
                const SizedBox(height: 28),
                const Text('Notes (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Anything the business/employee should know?',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _selectedTerm == null
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryButton(
            label: 'Confirm Booking - ${_selectedTerm!.startTime.format(context)}',
            isLoading: _isSubmitting,
            onPressed: _onConfirm,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeSection(EmployeeProvider provider) {
    if (provider.isBookableLoading && provider.bookableEmployees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.bookableErrorMessage != null && provider.bookableEmployees.isEmpty) {
      return Text(provider.bookableErrorMessage!, style: TextStyle(color: Colors.red.shade600));
    }

    final employees = provider.bookableEmployees;

    if (employees.isEmpty) {
      return Text('No employees available for booking yet.', style: TextStyle(color: Colors.grey.shade600));
    }

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return _EmployeePickerCard(
            employee: employee,
            isSelected: _selectedEmployeeId == employee.id,
            onTap: () => _onSelectEmployee(employee.id),
          );
        },
      ),
    );
  }

  Widget _buildTermSection(TermProvider provider) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return Text(provider.errorMessage!, style: TextStyle(color: Colors.red.shade600));
    }

    final dates = provider.termsByDate.keys.toList()..sort();

    if (dates.isEmpty) {
      return Text('No terms available for this employee yet.', style: TextStyle(color: Colors.grey.shade600));
    }

    final selectedDate = _selectedDate ?? dates.first;
    final dayTerms = _sortedTermsForDate(provider, selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              return _DayChip(
                date: date,
                isSelected: selectedDate == date,
                onTap: () => setState(() {
                  _selectedDate = date;
                  _selectedTerm = null; // switching days invalidates whatever was picked
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (dayTerms.isEmpty)
          Text('No terms this day.', style: TextStyle(color: Colors.grey.shade600))
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: dayTerms.map((term) {
              return _TermChip(
                term: term,
                isSelected: _selectedTerm?.id == term.id,
                onTap: () => setState(() => _selectedTerm = term),
              );
            }).toList(),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            _LegendDot(color: Colors.green.shade400),
            const SizedBox(width: 4),
            Text('Available', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(width: 16),
            _LegendDot(color: Colors.red.shade400),
            const SizedBox(width: 4),
            Text('Booked', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _EmployeePickerCard extends StatelessWidget {
  final BookableEmployee employee;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmployeePickerCard({required this.employee, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade200, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
              child: Text(
                employee.firstName.isNotEmpty ? employee.firstName[0].toUpperCase() : '?',
                style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 6),
            Text(employee.firstName,
                maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({required this.date, required this.isSelected, required this.onTap});

  String _label() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = date.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(_label(), style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _TermChip extends StatelessWidget {
  final Term term;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TermChip({required this.term, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = term.status == TermStatus.available;

    Color bg;
    Color border;
    Color text;

    if (isSelected) {
      bg = AppColors.primary;
      border = AppColors.primary;
      text = Colors.white;
    } else if (isAvailable) {
      bg = Colors.green.shade50;
      border = Colors.green.shade200;
      text = Colors.green.shade700;
    } else if (term.status == TermStatus.booked) {
      bg = Colors.red.shade50;
      border = Colors.red.shade200;
      text = Colors.red.shade700;
    } else {
      bg = Colors.grey.shade100;
      border = Colors.grey.shade300;
      text = Colors.grey.shade500;
    }

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: border)),
        child: Text(term.startTime.format(context), style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}