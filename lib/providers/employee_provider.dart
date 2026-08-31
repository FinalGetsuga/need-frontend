import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/bookable_employee.dart';
import 'package:need_mobile_app/models/employee.dart';
import 'package:need_mobile_app/models/employment.dart';
import 'package:need_mobile_app/services/employee_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class EmployeeProvider extends ChangeNotifier{
  final EmployeeService _service = EmployeeService();

  List<Employee> _employees = [];
  List<Employee> get employees => _employees;

  List<Employee> _businessEmployees = [];
  List<Employee> get businessEmployees => _businessEmployees;

  List<BookableEmployee> _bookableEmployees = [];
  List<BookableEmployee> get bookableEmployees => _bookableEmployees;

  bool _isBookableLoading = false;
  bool get isBookableLoading => _isBookableLoading;

  String? _bookableErrorMessage;
  String? get bookableErrorMessage => _bookableErrorMessage;

  Employee? _selectedEmployee;
  Employee? get selectedEmployee => _selectedEmployee;

  Employment? _myEmployment;
  Employment? get myEmployment => _myEmployment;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<Employee> get activeBusinessEmployees =>
      _businessEmployees.where((e) => e.isActive).toList();

  Future<void> loadAllEmployees() async {
    _setLoading(true);
    try {
      _employees = await _service.getAllEmployees();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadEmployeesByBusiness(String businessId) async {
    _setLoading(true);
    try {
      _businessEmployees = await _service.getAllEmployeesByBusiness(businessId);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBookableEmployees(String businessId) async {
    _isBookableLoading = true;
    notifyListeners();
    try {
      _bookableEmployees = await _service.getBookableEmployeesByBusiness(businessId);
      _bookableErrorMessage = null;
    } on ApiException catch(e) {
      _bookableEmployees = [];
      _bookableErrorMessage = e.message;
    } finally {
      _isBookableLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyEmployment() async {
    try {
      _myEmployment = await _service.getMyEmployment();
    } on ApiException catch(_) {
      _myEmployment = null;
    }
    notifyListeners();
  }

  Future<void> loadEmployeeById(String id) async {
    _setLoading(true);
    try {
      _selectedEmployee = await _service.getEmployeeById(id);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createEmployee({
    required String businessId,
    required String email,
    bool isActive = true,
  }) async {
    _setLoading(true);
    try {
      final employee = await _service.createEmployee(
          businessId: businessId,
          email: email,
          isActive: isActive,
      );
      _businessEmployees = [..._businessEmployees, employee];
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEmployee(
    String id, {
    required bool isActive ,
  }) async {
    _setLoading(true);
    try {
      final employee = await _service.updateEmployee(
          id,
          isActive: isActive,
      );
      _replaceInCaches(employee);
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEmployee(String id) async {
    _setLoading(true);
    try {
      await _service.deleteEmployee(id);

      _businessEmployees.removeWhere((e) => e.id == id);
      _employees.removeWhere((e) => e.id == id);

      if (_selectedEmployee?.id == id) _selectedEmployee = null;

      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _replaceInCaches(Employee updated) {
    if (_selectedEmployee?.id == updated.id) _selectedEmployee = updated;

    final businessIndex = _businessEmployees.indexWhere((e) => e.id == updated.id);
    if (businessIndex != -1) _businessEmployees[businessIndex] = updated;

    final allIndex = _employees.indexWhere((e) => e.id == updated.id);
    if (allIndex != -1) _employees[allIndex] = updated;
  }

  void _setLoading(bool value) {
    _isLoading = true;
    notifyListeners();
  }

  void clearMyEmployment() {
    _myEmployment = null;
    notifyListeners();
  }
}