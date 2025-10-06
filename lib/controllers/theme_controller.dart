import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class ThemeController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  
  final _themeMode = ThemeMode.system.obs;
  
  ThemeMode get themeMode => _themeMode.value;
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
  }
  
  void _loadThemeMode() {
    final savedMode = _storage.getThemeMode();
    switch (savedMode) {
      case 'light':
        _themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        _themeMode.value = ThemeMode.dark;
        break;
      default:
        _themeMode.value = ThemeMode.system;
    }
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode.value = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }
    await _storage.saveThemeMode(modeString);
    Get.changeThemeMode(mode);
  }
  
  String get themeModeText {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Açık';
      case ThemeMode.dark:
        return 'Koyu';
      default:
        return 'Sistem';
    }
  }
}