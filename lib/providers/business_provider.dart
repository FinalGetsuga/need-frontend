import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:need_mobile_app/models/business.dart';
import 'package:need_mobile_app/models/business_image.dart';
import 'package:need_mobile_app/services/business_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class BusinessProvider extends ChangeNotifier{
  final BusinessService _service = BusinessService();

  List<Business> _businesses = [];
  List<Business> get businesses => _businesses;

  List<Business> _topRatedBusinesses = [];
  List<Business> get topRatedBusinesses => _topRatedBusinesses;

  List<Business> _newBusinesses = [];
  List<Business> get newBusinesses => _newBusinesses;

  Business? _selectedBusiness;
  Business? get selectedBusiness => _selectedBusiness;

  Business? _myBusiness;
  Business? get myBusiness => _myBusiness;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllBusinesses() async {
    _setLoading(true);
    try {
      _businesses = await _service.getAllBusinesses();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNewestBusinesses() async {
    try {
      _newBusinesses = await _service.getNewestBusinesses();
    } on ApiException catch(_) {
      _newBusinesses = [];
    }
    notifyListeners();
  }

  Future<void> loadTopRatedBusinesses() async {
    try {
      _topRatedBusinesses = await _service.getTopRatedBusinesses();
    } on ApiException catch (_) {
      _topRatedBusinesses = [];
    }
    notifyListeners();
  }

  Future<void> loadBusinessesByCategory(String id) async {
    _setLoading(true);
    try {
      _businesses = await _service.getAllBusinessesByCategory(id);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchBusinesses(String name) async {
    _setLoading(true);
    try {
      _businesses = await _service.searchBusinesses(name);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBusinessById(String id) async {
    _setLoading(true);
    try {
      _selectedBusiness = await _service.getBusinessById(id);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyBusiness() async {
    _setLoading(true);
    try {
      _myBusiness = await _service.getMineBusiness();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<Business?> createBusiness({
    required String name,
    required String description,
    required String address,
    String? websiteUrl,
    required String categoryId,
  }) async {
    _setLoading(true);
    Business? result;
    try {
      result = await _service.createBusiness(
        name: name,
        description: description,
        address: address,
        websiteUrl: websiteUrl,
        categoryId: categoryId,
      );
      _myBusiness = result;
      unawaited(loadAllBusinesses());
      unawaited(loadNewestBusinesses());
      unawaited(loadTopRatedBusinesses());
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
    return result;
  }

  Future<bool> updateBusiness(
      String id, {
      required String name,
      required String description,
      required String address,
      String? imageUrl,
      String? websiteUrl,
      required String categoryId,
  }) async {
    _setLoading(true);
    try {
      final updated = await _service.updateBusiness(
          id,
          name: name,
          description: description,
          address: address,
          websiteUrl: websiteUrl,
          categoryId: categoryId,
      );

      if (_myBusiness?.id == id) _myBusiness = updated;
      if (_selectedBusiness?.id == id) _selectedBusiness = updated;

      final index = _businesses.indexWhere((b) => b.id == id);
      if (index != -1) _businesses[index] = updated;

      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBusiness(String id) async {
    _setLoading(true);
    try {
      await _service.deleteBusiness(id);

      _businesses.removeWhere((b) => b.id == id);
      if (_myBusiness?.id == id) _myBusiness = null;
      if (_selectedBusiness?.id == id) _selectedBusiness = null;

      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Business Image

  Future<Business?> uploadLogo(String businessId, XFile imageFile) async {
    _setLoading(true);
    Business? result;
    try {
      result = await _service.uploadLogo(businessId, imageFile);
      _replaceEverywhere(result);
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
    return result;
  }

  Future<BusinessImage?> addBusinessImage(String businessId, XFile imageFile) async {
    _setLoading(true);
    BusinessImage? result;
    try {
      result = await _service.addBusinessImage(businessId, imageFile);
      final current = _findCached(businessId);
      if (current != null) _replaceEverywhere(current.copyWith(images: [...current.images, result]));
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
    return result;
  }

  Future<bool> deleteBusinessImage(String businessId, String imageId) async {
    _setLoading(true);
    try {
      await _service.deleteBusinessImage(businessId, imageId);
      final current = _findCached(businessId);
      if (current != null) {
        _replaceEverywhere(current.copyWith(images: current.images.where((i) => i.id != imageId).toList()));
      }
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Business? _findCached(String businessId) {
    if (_selectedBusiness?.id == businessId) return _selectedBusiness;
    if (_myBusiness?.id == businessId) return _myBusiness;
    for (final b in _businesses) {
      if (b.id == businessId) return b;
    }
    for (final b in _topRatedBusinesses) {
      if (b.id == businessId) return b;
    }
    for (final b in _newBusinesses) {
      if (b.id == businessId) return b;
    }
    return null;
  }

  void _replaceEverywhere(Business updated) {
    if (_selectedBusiness?.id == updated.id) _selectedBusiness = updated;
    if (_myBusiness?.id == updated.id) _myBusiness = updated;
    void patch(List<Business> list) {
      final i = list.indexWhere((b) => b.id == updated.id);
      if (i != -1) list[i] = updated;
    }
    patch(_businesses);
    patch(_topRatedBusinesses);
    patch(_newBusinesses);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearMineBusiness() {
    _myBusiness = null;
    notifyListeners();
  }
}