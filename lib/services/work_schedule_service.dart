import 'package:need_mobile_app/models/work_schedule.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

class WorkScheduleService extends BaseApiService{

  Future<WorkSchedule> getScheduleByBusiness(String id) async {
    var response = await get(ApiEndpoints.getScheduleByBusinessId(id));
    return WorkSchedule.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WorkSchedule> createSchedule({
    required String businessId,
    required int termDurationMinutes,
    required List<WorkingDayInput> workingDays,
  }) async {
    var response = await post(ApiEndpoints.createSchedule, {
      'businessId': businessId,
      'termDurationMinutes': termDurationMinutes,
      'workingDays': workingDays.map((d) => d.toJson()).toList(),
    });
    return WorkSchedule.fromJson(response.data as Map<String,dynamic>);
  }

  Future<WorkSchedule> updateSchedule(
      String businessId, {
        required int termDurationMinutes,
        required List<WorkingDayInput> workingDays,
      }) async {
    var response = await put(ApiEndpoints.updateSchedule(businessId), {
      'businessId': businessId,
      'termDurationMinutes': termDurationMinutes,
      'workingDays': workingDays.map((d) => d.toJson()).toList(),
    });
    return WorkSchedule.fromJson(response.data as Map<String, dynamic>);
  }
}