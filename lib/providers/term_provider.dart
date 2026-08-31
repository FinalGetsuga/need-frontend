import 'package:flutter/cupertino.dart';
import 'package:need_mobile_app/models/enums.dart';
import 'package:need_mobile_app/models/term.dart';
import 'package:need_mobile_app/services/term_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class TermProvider extends ChangeNotifier {
  final TermService _service = TermService();

  List<Term> _terms = [];
  List<Term> get terms => _terms;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<DateTime, List<Term>> get termsByDate {
    final grouped = <DateTime, List<Term>>{};
    for (final term in _terms) {
      final dateKey = DateTime(term.date.year, term.date.month, term.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(term);
    }
    return grouped;
  }

  bool get hasAnyAvailable => _terms.any((t) => t.status == TermStatus.available);

  Future<void> loadTerms(String employeeId) async {
    _setLoading(true);
    try {
      _terms = await _service.getTermsByEmployee(employeeId);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _terms = [];
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}