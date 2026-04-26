import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';



abstract class CacheService {
  Future<void> set<T>(String key, T value, {bool isSecure = false});
  Future<T?> get<T>(String key, {bool isSecure = false});
  Future<void> remove(String key, {bool isSecure = false});
  Future<void> clearAll({bool? isSecure});
}

class CacheServiceImpl implements CacheService {
  CacheServiceImpl() {
    _initialize();
  }

  final Completer<FlutterSecureStorage> _secureStorage =
      Completer<FlutterSecureStorage>();
  final Completer<SharedPreferences> _pref = Completer<SharedPreferences>();

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _pref.complete(prefs);

    final storage = const FlutterSecureStorage();
    if (prefs.getBool(StorageKeys.kRunBeforeKey) != true) {
      await storage.deleteAll();
      await prefs.setBool(StorageKeys.kRunBeforeKey, true);
    }

    _secureStorage.complete(storage);
  }

  @override
  Future<void> set<T>(String key, T value, {bool isSecure = false}) async {
    if (isSecure) {
      final storage = await _secureStorage.future;
      await storage.write(key: key, value: value.toString());
    } else {
      final prefs = await _pref.future;
      if (value is String) {
        await prefs.setString(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is double) {
        await prefs.setDouble(key, value);
      } else if (value is List<String>) {
        await prefs.setStringList(key, value);
      } else {
        await prefs.setString(key, value.toString());
      }
    }
  }

  @override
  Future<T?> get<T>(String key, {bool isSecure = false}) async {
    if (isSecure) {
      final storage = await _secureStorage.future;
      final data = await storage.read(key: key);
      if (data == null) return null;
      return data as T;
    } else {
      final prefs = await _pref.future; // ✅ Wait for initialization
      if (T == String) {
        return prefs.getString(key) as T?;
      } else if (T == bool) {
        return prefs.getBool(key) as T?;
      } else if (T == int) {
        return prefs.getInt(key) as T?;
      } else if (T == double) {
        return prefs.getDouble(key) as T?;
      } else if (T == List<String>) {
        return prefs.getStringList(key) as T?;
      } else {
        return prefs.getString(key) as T?;
      }
    }
  }

  @override
  Future<void> remove(String key, {bool isSecure = false}) async {
    if (isSecure) {
      final storage = await _secureStorage.future;
      await storage.delete(key: key);
    } else {
      final prefs = await _pref.future; // ✅ Wait for initialization
      await prefs.remove(key);
    }
  }

  @override
  Future<void> clearAll({bool? isSecure}) async {
    if (isSecure == null) {
      final storage = await _secureStorage.future;
      await storage.deleteAll();
      final prefs = await _pref.future; // ✅ Wait for initialization
      await prefs.clear();
    } else if (isSecure) {
      final storage = await _secureStorage.future;
      await storage.deleteAll();
    } else {
      final prefs = await _pref.future; // ✅ Wait for initialization
      await prefs.clear();
    }
  }
}
