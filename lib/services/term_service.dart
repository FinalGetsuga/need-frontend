import 'package:need_mobile_app/models/term.dart';
import 'package:need_mobile_app/utils/api_endpoints.dart';
import 'package:need_mobile_app/utils/base_api_service.dart';

class TermService extends BaseApiService{
  Future<List<Term>> getTermsByEmployee(String id) async {
    var response = await get(ApiEndpoints.getTermsByEmployee(id));
    return (response.data as List)
        .map((e) => Term.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}