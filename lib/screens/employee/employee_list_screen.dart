import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/employee.dart';
import '../../providers/employee_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';

class EmployeeListScreen extends StatefulWidget {
  final String businessId;
  const EmployeeListScreen({super.key, required this.businessId});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().loadEmployeesByBusiness(widget.businessId);
    });
  }

  Future<void> _openAddEmployeeSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddEmployeeSheet(businessId: widget.businessId),
    );
  }

  Future<void> _toggleStatus(BuildContext context, Employee employee) async {
    final action = employee.isActive ? 'Deactivate' : 'Reactivate';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('$action ${employee.displayName}?'),
        content: Text(
          employee.isActive
              ? 'They will stop receiving new bookable terms. Their existing bookings are unaffected.'
              : 'They will start receiving bookable terms again from the next schedule run.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(action)),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<EmployeeProvider>().updateEmployee(employee.id, isActive: !employee.isActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeeProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Employees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEmployeeSheet,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Employee', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(child: _buildBody(provider)),
    );
  }

  Widget _buildBody(EmployeeProvider provider) {
    if (provider.isLoading && provider.businessEmployees.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.businessEmployees.isEmpty) {
      return Center(
        child: Padding(padding: const EdgeInsets.all(24), child: Text(provider.errorMessage!, textAlign: TextAlign.center)),
      );
    }

    if (provider.businessEmployees.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text('No employees yet.', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text('Add your first employee to start generating bookable slots.',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadEmployeesByBusiness(widget.businessId),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), // bottom padding clears the FAB
        itemCount: provider.businessEmployees.length,
        itemBuilder: (context, index) {
          final employee = provider.businessEmployees[index];
          return _EmployeeCard(employee: employee, onToggleStatus: () => _toggleStatus(context, employee));
        },
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  final Employee employee;
  final VoidCallback onToggleStatus;
  const _EmployeeCard({required this.employee, required this.onToggleStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: employee.isActive ? AppColors.primary.withValues(alpha: 0.12) : Colors.grey.shade200,
            child: Text(
              employee.firstName.isNotEmpty ? employee.firstName[0].toUpperCase() : '?',
              style: TextStyle(color: employee.isActive ? AppColors.primary : Colors.grey.shade500, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(employee.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(employee.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StatusToggle(isActive: employee.isActive, onTap: onToggleStatus),
        ],
      ),
    );
  }
}

class _StatusToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  const _StatusToggle({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? Colors.green.shade200 : Colors.grey.shade300),
        ),
        child: Text(isActive ? 'Active' : 'Inactive',
            style: TextStyle(color: isActive ? Colors.green.shade700 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _AddEmployeeSheet extends StatefulWidget {
  final String businessId;
  const _AddEmployeeSheet({required this.businessId});

  @override
  State<_AddEmployeeSheet> createState() => _AddEmployeeSheetState();
}

class _AddEmployeeSheetState extends State<_AddEmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  Future<void> _onAdd() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<EmployeeProvider>().createEmployee(
      businessId: widget.businessId,
      email: _emailController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = context.read<EmployeeProvider>().errorMessage ?? 'Something went wrong.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add Employee', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('They must already have a Need account with this email.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              ErrorBanner(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'employee@example.com',
                prefixIcon: const Icon(Icons.mail_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              validator: _validateEmail,
              enabled: !_isLoading,
              onFieldSubmitted: (_) => _onAdd(),
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Add Employee', isLoading: _isLoading, onPressed: _onAdd),
          ],
        ),
      ),
    );
  }
}