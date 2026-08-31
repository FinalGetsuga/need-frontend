import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/app_field_label.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/primary_button.dart';
import 'business_photos_screen.dart';

class BusinessCreateScreen extends StatefulWidget {
  const BusinessCreateScreen({super.key});

  @override
  State<BusinessCreateScreen> createState() => _BusinessCreateScreenState();
}

class _BusinessCreateScreenState extends State<BusinessCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _websiteUrlController = TextEditingController();

  String? _selectedCategoryId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

    final created = await context.read<BusinessProvider>().createBusiness(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      websiteUrl: _websiteUrlController.text.trim().isEmpty ? null : _websiteUrlController.text.trim(),
      categoryId: _selectedCategoryId!,
    );

    if (!mounted) return;

    if (created != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BusinessPhotosScreen(business: created)),
      );
    } else {
      setState(() {
        _errorMessage = context.read<BusinessProvider>().errorMessage ?? 'Something went wrong. Please try again.';
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
        title: const Text('Create Business', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: CircularProgressIndicator()))
                else
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    validator: (value) => value == null ? 'Please select a category' : null,
                    decoration: InputDecoration(
                      hintText: 'Select a category',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade500, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                    items: categoryProvider.activeCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: _isLoading ? null : (value) => setState(() => _selectedCategoryId = value),
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
                PrimaryButton(label: 'Create Business', isLoading: _isLoading, onPressed: _onSubmit),
              ],
            ),
          ),
        ),
      ),
    );
  }
}