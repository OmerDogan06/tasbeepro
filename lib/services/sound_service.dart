import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class SoundService extends GetxService {
  late SoLoud _soloud;
  AudioSource? _clickSound;
  final StorageService _storage = Get.find<StorageService>();
  static const platform = MethodChannel('com.skyforgestudios.tasbeepro/sound');
  
  final _soundEnabled = true.obs; // Reaktif değişken
  final _soundVolume = 2.obs; // Ses seviyesi: 0=Düşük, 1=Orta, 2=Yüksek
  
  @override
  void onInit() {
    super.onInit();
    _soundEnabled.value = _storage.getSoundEnabled();
    _soundVolume.value = _storage.getSoundVolume();
    _initSoloud();
  }
  
  // SoLoud'u başlat ve ses dosyasını yükle
  Future<void> _initSoloud() async {
    try {
      _soloud = SoLoud.instance;
      await _soloud.init();
      await _preloadSounds();
    } catch (e) {
      debugPrint('Failed to initialize SoLoud: $e');
    }
  }
  
  // Ses dosyalarını önceden yükle
  Future<void> _preloadSounds() async {
    try {
      // Ses dosyasını önceden yükle
      _clickSound = await _soloud.loadAsset('assets/sounds/click2.wav');
      debugPrint('Sound preloaded successfully');
    } catch (e) {
      debugPrint('Failed to preload sound: $e');
    }
  }
  
   Future<void> playClickSound() async {
    try {
      if (_soundEnabled.value && _clickSound != null) {
        // Anında ses çal - SoLoud en düşük gecikme!
        await _soloud.play(
          _clickSound!,
          volume: volumeMultiplier(),
        );
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void onClose() {
    // SoLoud'u temizle
    _soloud.deinit();
    super.onClose();
  }

  double volumeMultiplier() {
    switch (_soundVolume.value) {
      case 0:
        return 0.45; // Düşük
      case 1:
        return 0.65; // Orta
      case 2:
        return 1; // Yüksek
      default:
        return  1;
    }
  }
  
  bool get isSoundEnabled => _soundEnabled.value;
  int get soundVolume => _soundVolume.value;
  
  String get soundVolumeText {
    switch (_soundVolume.value) {
      case 0: return 'Düşük';
      case 1: return 'Orta';
      case 2: return 'Yüksek';
      default: return 'Yüksek';
    }
  }
  
  Future<void> toggleSound() async {
    _soundEnabled.value = !_soundEnabled.value;
    await _storage.saveSoundEnabled(_soundEnabled.value);
  }
  
  Future<void> setSoundVolume(int volume) async {
    _soundVolume.value = volume;
    await _storage.saveSoundVolume(volume);
  }
}










