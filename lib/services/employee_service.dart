import 'package:need_mobile_app/models/bookable_employee.dart';
import 'package:need_mobile_app/models/employee.dart';
import 'package:need_mobile_app/models/employment.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

class EmployeeService extends BaseApiService {

  Future<List<Employee>> getAllEmployees() async {
    var response = await get(ApiEndpoints.getAllEmployees);
    return (response.data as List)
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Employee>> getAllEmployeesByBusiness(String businessId) async {
    var response = await get(ApiEndpoints.getAllEmployeesByBusiness(businessId));
    return (response.data as List)
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookableEmployee>> getBookableEmployeesByBusiness(String businessId) async {
    var response = await get(ApiEndpoints.getBookableEmployeesByBusiness(businessId));
    return (response.data as List)
        .map((e) => BookableEmployee.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Employment?> getMyEmployment() async {
    var response = await get(ApiEndpoints.getMyEmployment);
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    return Employment.fromJson(data);
  }

  Future<Employee> getEmployeeById(String id) async {
    var response = await get(ApiEndpoints.getEmployeeById(id));
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> createEmployee({
      required String businessId,
      required String email,
      bool isActive = true,
  }) async {
    var response = await post(ApiEndpoints.createEmployee, {
      'businessId': businessId,
      'email': email,
      'isActive': isActive,
    });

    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> updateEmployee(
  String id, {
    bool isActive = true,
  }) async {
    var response = await put(ApiEndpoints.updateEmployee(id), {
      'isActive': isActive,
    });

    return Employee.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Employee> deleteEmployee(String id) async {
    var response = await delete(ApiEndpoints.deleteEmployee(id));
    return Employee.fromJson(response.data as Map<String, dynamic>);
  }
}