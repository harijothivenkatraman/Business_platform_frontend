import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  String get role => _user?['role'] ?? '';
  String get businessId => _user?['businessId'] ?? '';
  String get userName => _user?['name'] ?? '';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final userData = prefs.getString('user');
    if (token != null && userData != null) {
      _user = jsonDecode(userData);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.post('/auth/login', {'email': email, 'password': password});
      final data = result['data'];
      _user = data['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);
      await prefs.setString('user', jsonEncode(_user));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String role, {String? businessId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final body = <String, dynamic>{'name': name, 'email': email, 'password': password, 'role': role};
      if (businessId != null && businessId.isNotEmpty) body['businessId'] = businessId;
      final result = await ApiService.post('/auth/register', body);
      final data = result['data'];
      _user = data['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);
      await prefs.setString('user', jsonEncode(_user));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _user = null;
    notifyListeners();
  }
}
