import 'package:dio/dio.dart';
import 'package:need_mobile_app/utils/api_client.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

abstract class BaseApiService {
  final Dio _dio = ApiClient().dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch(e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response> post(String path, [Map<String, dynamic>? body]) async {
    try {
      return await _dio.post(path, data: body);
    } on DioException catch(e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response> put(String path, [Map<String, dynamic>? body]) async {
    try {
      return await _dio.put(path, data: body);
    } on DioException catch(e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch(e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response> postMultipart(String path, Map<String, dynamic> data) async {
    try {
      return await _dio.post(path, data: FormData.fromMap(data));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}