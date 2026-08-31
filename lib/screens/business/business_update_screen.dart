import 'package:flutter/material.dart';
import 'package:need_mobile_app/screens/employee/employee_list_screen.dart';
import 'package:need_mobile_app/screens/schedule/work_schedule_screen.dart';
import 'package:provider/provider.dart';
import '../../models/business.dart';
import '../../providers/business_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_field_label.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';
import 'business_bookings_screen.dart';
import 'business_photos_screen.dart';

class BusinessUpdateScreen extends StatefulWidget {
  final Business business;

  const BusinessUpdateScreen({super.key, required this.business});

  @override
  State<BusinessUpdateScreen> createState() => _BusinessUpdateScreenState();
}

class _BusinessUpdateScreenState extends State<BusinessUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteUrlController;

  late String _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _descriptionController = TextEditingController(text: widget.business.description);
    _addressController = TextEditingController(text: widget.business.address);
    _websiteUrlController = TextEditingController(text: widget.business.websiteUrl ?? '');
    _selectedCategoryId = widget.business.categoryId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = context.read<CategoryProvider>();
      if (categoryProvider.categories.isEmpty) {
        categoryProvider.loadCategories();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _websiteUrlController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<BusinessProvider>().updateBusiness(
      widget.business.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      websiteUrl: _websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim(),
      categoryId: _selectedCategoryId,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = context.read<BusinessProvider>().errorMessage ?? 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _onDeletePressed() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Business?'),
        content: const Text(
          'This cannot be undone. Note: deleting may currently fail if your business already has staff with scheduled terms.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await context.read<BusinessProvider>().deleteBusiness(widget.business.id);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _errorMessage = context.read<BusinessProvider>().errorMessage ?? 'Failed to delete business.';
        _isLoading = false;
      });
    }
  }

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black87,
        title: const Text('Edit Business', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  controller: _nameController,
                  label: 'Name',
                  required: true,
                  hintText: 'Enter business name',
                  icon: Icons.storefront_outlined,
                  maxLength: 100,
                  validator: (v) => _validateRequired(v, 'Business name'),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  required: true,
                  hintText: 'Describe your business',
                  icon: Icons.description_outlined,
                  maxLength: 500,
                  maxLines: 4,
                  validator: (v) => _validateRequired(v, 'Description'),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _addressController,
                  label: 'Address',
                  required: true,
                  hintText: 'Enter business address',
                  icon: Icons.location_on_outlined,
                  validator: (v) => _validateRequired(v, 'Address'),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 18),
                const AppFieldLabel(label: 'Category', required: true),
                const SizedBox(height: 8),
                if (categoryProvider.isLoading && categoryProvider.categories.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                // Full categories list, not activeCategories - if this
                // business's current category has since been deactivated,
                // it still needs to appear here or DropdownButtonFormField
                // throws (its value must match one of its items).
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    decoration: InputDecoration(
                      hintText: 'Select a category',
                      prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade500, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    items: categoryProvider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                      if (value != null) setState(() => _selectedCategoryId = value);
                    },
                  ),
                const SizedBox(height: 18),
                AppTextField(
                  controller: _websiteUrlController,
                  label: 'Website URL',
                  hintText: 'https://yourwebsite.com',
                  icon: Icons.language,
                  keyboardType: TextInputType.url,
                  helperText: 'Enter your business website (optional)',
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 28),
                PrimaryButton(label: 'Save Changes', isLoading: _isLoading, onPressed: _onSubmit),
                const SizedBox(height: 28),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200)
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: const Text('Manage Employees'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EmployeeListScreen(businessId: widget.business.id))),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      ListTile(
                        leading: const Icon(Icons.bookmark_outline),
                        title: const Text('Business Bookings'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessBookingsScreen(businessId: widget.business.id))),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      ListTile(
                        leading: const Icon(Icons.schedule_outlined),
                        title: const Text('Working Hours'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkScheduleScreen(businessId: widget.business.id))),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: const Text('Manage Photos'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => BusinessPhotosScreen(business: widget.business))),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 12),
                const AppFieldLabel(label: 'Danger Zone'),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _onDeletePressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Delete Business', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}