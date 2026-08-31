import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:need_mobile_app/models/business.dart';
import 'package:need_mobile_app/models/business_image.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

class BusinessService extends BaseApiService{

  Future<List<Business>> getAllBusinesses() async {
    final response = await get(ApiEndpoints.getAllBusinesses);
    return (response.data as List)
        .map((e) => Business.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Business>> getNewestBusinesses() async {
    final response = await get(ApiEndpoints.getNewestBusinesses);
    return (response.data as List)
        .map((e) => Business.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Business>> getTopRatedBusinesses() async {
    final response = await get(ApiEndpoints.getTopRatedBusinesses);
    return (response.data as List)
        .map((e) => Business.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Business>> getAllBusinessesByCategory(String id) async {
    final response = await get(ApiEndpoints.getAllBusinessesByCategory(id));
    return (response.data as List)
        .map((e) => Business.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Business>> searchBusinesses(String name) async {
    var response = await get(ApiEndpoints.searchBusinesses, queryParameters: {'name': name});
    return (response.data as List)
        .map((e) => Business.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Business> getBusinessById(String id) async {
    final response = await get(ApiEndpoints.getBusinessById(id));
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Business> getMineBusiness() async {
    final response = await get(ApiEndpoints.getMineBusiness);
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Business> createBusiness({
      required String name,
      required String description,
      required String address,
      String? websiteUrl,
      required String categoryId,
  }) async {
      final response = await post(ApiEndpoints.createBusiness, {
        'name': name,
        'description': description,
        'address': address,
        'websiteUrl': websiteUrl,
        'categoryId': categoryId
      });
      return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Business> updateBusiness(
    String id, {
    required String name,
    required String description,
    required String address,
    String? websiteUrl,
    required String categoryId,
  }) async {
    final response = await put(ApiEndpoints.updateBusiness(id), {
      'name': name,
      'description': description,
      'address': address,
      'websiteUrl': websiteUrl,
      'categoryId': categoryId
    });
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Business> deleteBusiness(String id) async {
    final response = await delete(ApiEndpoints.deleteBusiness(id));
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Business> uploadLogo(String businessId, XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
    final response = await postMultipart(ApiEndpoints.uploadBusinessLogo(businessId), {'file': multipartFile});
    return Business.fromJson(response.data as Map<String, dynamic>);
  }

  Future<BusinessImage> addBusinessImage(String businessId, XFile imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final multipartFile = MultipartFile.fromBytes(bytes, filename: imageFile.name);
    final response = await postMultipart(ApiEndpoints.addBusinessImage(businessId), {'file': multipartFile});
    return BusinessImage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteBusinessImage(String businessId, String imageId) async {
    await delete(ApiEndpoints.deleteBusinessImage(businessId, imageId));
  }
}