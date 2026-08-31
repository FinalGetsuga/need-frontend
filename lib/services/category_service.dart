import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

import '../models/category.dart';

class CategoryService extends BaseApiService {

  Future<List<Category>> getAllCategories() async {
    final response = await get(ApiEndpoints.getAllCategories);
    return (response.data as List)
        .map((e) => Category.fromJson(e as Map<String,dynamic>))
        .toList();
  }

  Future<Category> getCategoryById(String id) async {
    final response = await get(ApiEndpoints.getCategoryById(id));
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Category> createCategory({
    required String name,
    String? description,
    bool isActive = true,
  }) async {
    final response = await post(ApiEndpoints.createCategory, {
      'name': name,
      'description': description,
      'isActive': isActive
    });
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Category> updateCategory(
      String id, {
      required String name,
      String? description,
      bool isActive = true,
    }) async {
    final response = await put(ApiEndpoints.updateCategory(id), {
      'name': name,
      'description': description,
      'isActive': isActive,
    });
    return Category.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Category> deleteCategory(String id) async {
    final response = await delete(ApiEndpoints.deleteCategory(id));
    return Category.fromJson(response.data as Map<String, dynamic>);
  }
}