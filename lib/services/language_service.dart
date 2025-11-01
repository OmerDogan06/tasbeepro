import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class LanguageService extends GetxService {
  static const String _languageKey = 'selected_language';
  
  final RxString _currentLanguage = 'en'.obs;
  String get currentLanguage => _currentLanguage.value;
  
  final Rx<Locale> _currentLocale = const Locale('en', 'GB').obs;
  Locale get currentLocale => _currentLocale.value;
  
  // Public getter for listening to changes
  RxString get currentLanguageRx => _currentLanguage;

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
        String deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
        
        // Desteklenen diller listesi
        const supportedLanguages = ['tr', 'en', 'ar', 'id', 'ur', 'ms', 'bn', 'fr', 'hi', 'fa', 'uz', 'ru', 'es', 'pt'];
        
        // Eğer cihaz dili desteklenen diller arasında varsa onu kullan, yoksa İngilizce
        savedLanguage = supportedLanguages.contains(deviceLanguage) ? deviceLanguage : 'en';
      }
      
      await changeLanguage(savedLanguage);
    } catch (e) {
      // Hata durumunda varsayılan İngilizce
      await changeLanguage('en');
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
          newLocale = const Locale('en', 'GB');
          break;
        case 'ar':
          newLocale = const Locale('ar', 'SA');
          break;
        case 'id':
          newLocale = const Locale('id', 'ID');
          break;
        case 'ur':
          newLocale = const Locale('ur', 'PK');
          break;
        case 'ms':
          newLocale = const Locale('ms', 'MY');
          break;
        case 'bn':
          newLocale = const Locale('bn', 'BD');
          break;
        case 'fr':
          newLocale = const Locale('fr', 'FR');
          break;
        case 'hi':
          newLocale = const Locale('hi', 'IN');
          break;
        case 'fa':
          newLocale = const Locale('fa', 'IR');
          break;
        case 'uz':
          newLocale = const Locale('uz', 'UZ');
          break;
        case 'ru':
          newLocale = const Locale('ru', 'RU');
          break;
        case 'es':
          newLocale = const Locale('es', 'ES');
          break;
        case 'pt':
          newLocale = const Locale('pt', 'BR');
          break;
        default:
          newLocale = const Locale('en', 'GB');
      }
      
      _currentLocale.value = newLocale;
      
      // GetX'te locale'i güncelle - Bu anlık değişiklik sağlar
      Get.updateLocale(newLocale);
      
      // SharedPreferences'a kaydet
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
    } catch (e) {
      debugPrint('Dil değiştirme hatası: $e');
    }
  }

  String getLanguageName(String code) {
    switch (code) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ur':
        return 'اردو';
      case 'ms':
        return 'Bahasa Melayu';
      case 'bn':
        return 'বাংলা';
      case 'fr':
        return 'Français';
      case 'hi':
        return 'हिन्दी';
      case 'fa':
        return 'فارسی';
      case 'uz':
        return 'O\'zbekcha';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      case 'pt':
        return 'Português';
      default:
        return 'English';
    }
  }

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'fa', 'name': 'فارسی', 'flag': '🇮🇷'},
    {'code': 'uz', 'name': 'O\'zbekcha', 'flag': '🇺🇿'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
  ];
}