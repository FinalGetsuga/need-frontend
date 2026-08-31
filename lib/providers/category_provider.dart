import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/category.dart';
import 'package:need_mobile_app/services/category_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class CategoryProvider extends ChangeNotifier{
  final CategoryService _service = CategoryService();

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  Category? _selectedCategory;
  Category? get selectedCategory => _selectedCategory;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Category> get activeCategories =>
      _categories.where((c) => c.isActive).toList();

  Future<void> loadCategories() async {
    _setLoading(true);
    try {
      _categories = await _service.getAllCategories();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategoryById(String id) async {
    _setLoading(true);
    try {
      _selectedCategory = await _service.getCategoryById(id);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    _setLoading(true);
    try {
      final category = await _service.createCategory(
          name: name,
          description: description,
          isActive: isActive,
      );
      _categories = [..._categories, category];
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory(
    String id, {
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    _setLoading(true);
    try {
      final category = await _service.updateCategory(
          id,
          name: name,
          description: description,
          isActive: isActive,
      );

      if (_selectedCategory?.id == id) _selectedCategory = category;

      final index = _categories.indexWhere((c) => c.id == id);
      if (index != -1) _categories[index] = category;

      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(String id) async {
    _setLoading(true);
    try {
      await _service.deleteCategory(id);

      _categories.removeWhere((c) => c.id == id);
      if (_selectedCategory?.id == id) _selectedCategory = null;

      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}