import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class LanguageService extends GetxService {
  static const String _languageKey = 'selected_language';
  
  final RxString _currentLanguage = 'tr'.obs;
  String get currentLanguage => _currentLanguage.value;
  
  final Rx<Locale> _currentLocale = const Locale('tr', 'TR').obs;
  Locale get currentLocale => _currentLocale.value;

  Future<LanguageService> init() async {
    await _loadSavedLanguage();
    return this;
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedLanguage = prefs.getString(_languageKey);
      
      if (savedLanguage == null) {
        // Cihaz dilini kontrol et
        String deviceLanguage = ui.window.locale.languageCode;
        savedLanguage = deviceLanguage == 'tr' ? 'tr' : 'en';
      }
      
      await changeLanguage(savedLanguage);
    } catch (e) {
      // Hata durumunda varsayılan Türkçe
      await changeLanguage('tr');
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    try {
      _currentLanguage.value = languageCode;
      
      Locale newLocale;
      switch (languageCode) {
        case 'tr':
          newLocale = const Locale('tr', 'TR');
          break;
        case 'en':
          newLocale = const Locale('en', 'US');
          break;
        default:
          newLocale = const Locale('tr', 'TR');
      }
      
      _currentLocale.value = newLocale;
      
      // GetX'te locale'i güncelle - Bu anlık değişiklik sağlar
      Get.updateLocale(newLocale);
      
      // SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
    } catch (e) {
      print('Dil değiştirme hatası: $e');
    }
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];
}