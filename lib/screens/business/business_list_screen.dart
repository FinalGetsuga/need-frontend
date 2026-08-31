import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../models/category.dart';
import '../../providers/business_provider.dart';
import '../../providers/category_provider.dart';
import '../../utils/category_colors.dart';
import 'business_detail_screen.dart';

const _allCategoriesSentinel = '__all__';

class BusinessListScreen extends StatefulWidget{
  final String? initialCategoryId;
  const BusinessListScreen({super.key, this.initialCategoryId});

  @override
  State<BusinessListScreen> createState() => _BusinessListScreenState();
}

class _BusinessListScreenState extends State<BusinessListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      _selectedCategoryId == null
          ? context.read<BusinessProvider>().loadAllBusinesses()
          : context.read<BusinessProvider>().loadBusinessesByCategory(_selectedCategoryId!);
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() => _searchQuery = query);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final provider = context.read<BusinessProvider>();
      if (query.isEmpty) {
        // Search cleared - fall back to whatever category filter is active
        _selectedCategoryId == null
            ? provider.loadAllBusinesses()
            : provider.loadBusinessesByCategory(_selectedCategoryId!);
      } else {
        provider.searchBusinesses(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final provider = context.read<BusinessProvider>();
    if (_searchQuery.isNotEmpty) return provider.searchBusinesses(_searchQuery);
    return _selectedCategoryId == null
        ? provider.loadAllBusinesses()
        : provider.loadBusinessesByCategory(_selectedCategoryId!);
  }

  Future<void> _openFilterSheet() async {
    final categoryProvider = context.read<CategoryProvider>();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CategoryFilterSheet(
        categories: categoryProvider.activeCategories,
        selectedCategoryId: _selectedCategoryId,
      ),
    );

    if (result == null) return;

    _searchController.clear();

    setState(() => _selectedCategoryId = result == _allCategoriesSentinel ? null : result);
    await _refresh();
  }
  /*
  void _onCreateBusinessPressed() async {
    final loggedIn = context.read<AuthProvider>().isSignedIn;

    if (!loggedIn) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const BusinessCreateScreen()),
    );

    if (created == true) _refresh();
  }
   */

  @override
  Widget build(BuildContext context) {
    final businessProvider = context.watch<BusinessProvider>();
    final hasActiveFilter = _selectedCategoryId != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Businesses',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search businesses...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _searchController.clear(),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: hasActiveFilter ? Theme.of(context).colorScheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: hasActiveFilter ? Colors.transparent : Colors.grey.shade300,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _openFilterSheet,
                      icon: Icon(
                        Icons.tune,
                        color: hasActiveFilter ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(businessProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BusinessProvider provider) {
    if (provider.isLoading && provider.businesses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.businesses.isEmpty) {
      return _ErrorState(message: provider.errorMessage!, onRetry: _refresh);
    }

    if (provider.businesses.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isEmpty ? 'No businesses found.' : 'No results for "$_searchQuery"',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        itemCount: provider.businesses.length,
        itemBuilder: (context, index) {
          final business = provider.businesses[index];
          return _BusinessCard(
            business: business,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => BusinessDetailScreen(businessId: business.id)),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryFilterSheet extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;

  const _CategoryFilterSheet({required this.categories, required this.selectedCategoryId});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filter by category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('All'),
              trailing: selectedCategoryId == null ? const Icon(Icons.check, color: Colors.deepPurple) : null,
              onTap: () => Navigator.of(context).pop(_allCategoriesSentinel),
            ),
            for (final category in categories)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(category.name),
                trailing:
                selectedCategoryId == category.id ? const Icon(Icons.check, color: Colors.deepPurple) : null,
                onTap: () => Navigator.of(context).pop(category.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _BusinessCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;

  const _BusinessCard({required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    Category? category;
    for (final c in categoryProvider.categories) {
      if (c.id == business.categoryId) {
        category = c;
        break;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BusinessImage(imageUrl: business.logoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      business.description,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            business.address,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (category != null) ...[
                      const SizedBox(height: 8),
                      _CategoryPill(category: category),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final Category category;

  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = CategoryColors.forId(category.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: colors.background, borderRadius: BorderRadius.circular(20)),
      child: Text(
        category.name,
        style: TextStyle(color: colors.text, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BusinessImage extends StatelessWidget {
  final String? imageUrl;

  const _BusinessImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const size = 76.0;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
        child: Icon(Icons.storefront, color: Colors.grey.shade500),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: size,
          height: size,
          color: Colors.grey.shade200,
          child: Icon(Icons.broken_image, color: Colors.grey.shade500),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade500),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}