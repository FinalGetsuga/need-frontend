import 'package:dio/dio.dart';

class ApiException implements Exception{
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException e){
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return ApiException(data['error'] as String, statusCode: e.response?.statusCode);
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('The request timed out. Check your connection and try again.');
      case DioExceptionType.connectionError:
        return ApiException('Could not reach the server. Check your connection.');
      default:
        return ApiException('Something went wrong. Please try again.', statusCode: e.response?.statusCode);
    }
  }

  @override
  String toString() => message;
}