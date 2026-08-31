import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/work_schedule.dart';
import 'package:need_mobile_app/services/work_schedule_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class WorkScheduleProvider extends ChangeNotifier{
  final WorkScheduleService _service = WorkScheduleService();

  WorkSchedule? _schedule;
  WorkSchedule? get schedule => _schedule;

  WorkSchedule? _viewedSchedule;
  WorkSchedule? get viewedSchedule => _viewedSchedule;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadSchedule(String businessId) async {
    _setLoading(true);
    try {
      _schedule = await _service.getScheduleByBusiness(businessId);
      _errorMessage = null;
    } on ApiException catch(e) {
      _schedule = null;
      _errorMessage = e.statusCode == 404 ? null : e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createSchedule({
    required String businessId,
    required int termDurationMinutes,
    required List<WorkingDayInput> workingDays,
  }) async {
    _setLoading(true);
    try {
      _schedule = await _service.createSchedule(
          businessId: businessId,
          termDurationMinutes: termDurationMinutes,
          workingDays: workingDays,
      );
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateSchedule(
      String businessId, {
        required int termDurationMinutes,
        required List<WorkingDayInput> workingDays,
      }) async {
    _setLoading(true);
    try {
      _schedule = await _service.updateSchedule(
        businessId,
        termDurationMinutes: termDurationMinutes,
        workingDays: workingDays,
      );
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadScheduleForViewing(String businessId) async {
    try {
      _viewedSchedule = await _service.getScheduleByBusiness(businessId);
    } on ApiException catch(_) {
      _viewedSchedule = null;
    }
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

}