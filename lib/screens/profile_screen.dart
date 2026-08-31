import 'package:flutter/material.dart';
import 'package:need_mobile_app/models/employment.dart';
import 'package:need_mobile_app/providers/employee_provider.dart';
import 'package:provider/provider.dart';
import '../../models/business.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/login_prompt.dart';
import 'business/business_create_screen.dart';
import 'business/business_update_screen.dart';
import 'employee/my_work_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Future<void> _openEditSheet(BuildContext context) async {
    final user = context.read<UserProvider>().currentUser;
    if (user == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _EditProfileSheet(firstName: user.firstName, lastName: user.lastName),
    );
  }

  Future<void> _onLogoutPressed(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthProvider>().isSignedIn) {
      return const LoginPrompt(message: 'Log in to view and edit your profile.');
    }

    final userProvider = context.watch<UserProvider>();
    final businessProvider = context.watch<BusinessProvider>();
    final employeeProvider = context.watch<EmployeeProvider>();
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: userProvider.isLoading && user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (userProvider.errorMessage != null) ...[
              ErrorBanner(message: userProvider.errorMessage!),
              const SizedBox(height: 16),
            ],
            if (user != null) ...[
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text('${user.firstName} ${user.lastName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              if (user.email != null)
                Center(child: Text(user.email!, style: TextStyle(color: Colors.grey.shade600))),
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => _openEditSheet(context),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit profile'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _WorkStatusSection(business: businessProvider.myBusiness, employment: employeeProvider.myEmployment),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out', style: TextStyle(color: Colors.red)),
                onTap: () => _onLogoutPressed(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkStatusSection extends StatelessWidget {
  final Business? business;
  final Employment? employment;
  const _WorkStatusSection({required this.business, required this.employment});

  @override
  Widget build(BuildContext context) {
    if (business != null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.storefront),
          title: Text(business!.name),
          subtitle: const Text('Manage your business'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessUpdateScreen(business: business!))),
        ),
      );
    }

    if (employment != null) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.badge_outlined),
          title: Text('You work at ${employment!.businessName}'),
          subtitle: const Text('View your schedule and bookings'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => MyWorkScreen(businessId: employment!.businessId, businessName: employment!.businessName),
          )),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: const Text('Register your business'),
        subtitle: const Text('Start taking bookings on Need'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BusinessCreateScreen())),
      ),
    );
  }
}

class _EditProfileSheet extends StatefulWidget {
  final String firstName;
  final String lastName;
  const _EditProfileSheet({required this.firstName, required this.lastName});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.firstName);
    _lastNameController = TextEditingController(text: widget.lastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<UserProvider>().updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _errorMessage = context.read<UserProvider>().errorMessage ?? 'Something went wrong.';
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
            const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              ErrorBanner(message: _errorMessage!),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First name', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'First name is required' : null,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last name', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Last name is required' : null,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}