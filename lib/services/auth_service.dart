import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  // Check if user is logged in
  Future<bool> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;
      return _isAuthenticated;
    } catch (e) {
      debugPrint('Error checking auth status: $e');
      return false;
    }
  }

  // Set login status
  Future<void> setLoggedIn(bool status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', status);
      _isAuthenticated = status;
    } catch (e) {
      debugPrint('Error setting login status: $e');
    }
  }

  // Log out
  Future<void> logout() async {
    await setLoggedIn(false);
  }

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final String _passwordHashKey = 'password_hash';
  final String _isSetupKey = 'is_setup_complete';

  // Hash the password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if the app has been set up with a password
  Future<bool> isSetupComplete() async {
    return await _secureStorage.read(key: _isSetupKey) == 'true';
  }

  // Set up the app with a new password
  Future<void> setupPassword(String password) async {
    final passwordHash = _hashPassword(password);
    await _secureStorage.write(key: _passwordHashKey, value: passwordHash);
    await _secureStorage.write(key: _isSetupKey, value: 'true');
  }

  // Verify the password
  Future<bool> verifyPassword(String password) async {
    final storedHash = await _secureStorage.read(key: _passwordHashKey);
    final inputHash = _hashPassword(password);
    return storedHash == inputHash;
  }

  // Change the password
  Future<void> changePassword(String newPassword) async {
    final passwordHash = _hashPassword(newPassword);
    await _secureStorage.write(key: _passwordHashKey, value: passwordHash);
  }
}
