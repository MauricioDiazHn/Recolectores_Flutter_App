import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  
  factory SecureStorageService() {
    return _instance;
  }

  SecureStorageService._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    )
  );
  
  static const _tokenKey = 'user_token';
  static const _userDataKey = 'user_data';
  static const _mileageDialogKey = 'mileage_dialog_shown';
  static const _lastLoginKey = 'last_login';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(
        key: _lastLoginKey,
        value: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  Future<void> saveUserData({
    required int motoristaId,
    required String fullName,
    required String userName,
  }) async {
    try {
      final userData = json.encode({
        'motoristaId': motoristaId,
        'fullName': fullName,
        'userName': userName,
        'lastLogin': DateTime.now().toIso8601String(),
      });
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final data = await _storage.read(key: _userDataKey);
      if (data != null) {
        return json.decode(data);
      }
      return null;
    } catch (e) {
      print('Error reading user data: $e');
      return null;
    }
  }

  Future<void> setMileageDialogShown(bool shown) async {
    try {
      await _storage.write(key: _mileageDialogKey, value: shown.toString());
    } catch (e) {
      print('Error setting mileage dialog status: $e');
      rethrow;
    }
  }

  Future<bool> getMileageDialogShown() async {
    try {
      final value = await _storage.read(key: _mileageDialogKey);
      return value == 'true';
    } catch (e) {
      print('Error reading mileage dialog status: $e');
      return false;
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('Error clearing storage: $e');
      rethrow;
    }
  }

  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null;
    } catch (e) {
      print('Error checking token: $e');
      return false;
    }
  }

  Future<bool> isSessionValid() async {
    try {
      final lastLoginStr = await _storage.read(key: _lastLoginKey);
      if (lastLoginStr == null) return false;

      final lastLogin = DateTime.parse(lastLoginStr);
      final now = DateTime.now();
      final difference = now.difference(lastLogin);

      return difference.inDays < 2;
    } catch (e) {
      print('Error checking session validity: $e');
      return false;
    }
  }
}