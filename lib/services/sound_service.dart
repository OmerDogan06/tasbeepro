import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'storage_service.dart';

class SoundService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StorageService _storage = Get.find<StorageService>();
  static const platform = MethodChannel('com.skyforgestudios.tasbeepro/sound');
  
  final _soundEnabled = true.obs; // Reaktif değişken
  final _soundVolume = 2.obs; // Ses seviyesi: 0=Düşük, 1=Orta, 2=Yüksek
  
  @override
  void onInit() {
    super.onInit();
    _soundEnabled.value = _storage.getSoundEnabled();
    _soundVolume.value = _storage.getSoundVolume();
  }
  
   Future<void> playClickSound() async {
    try {
      if (_soundEnabled.value) {
        // Önce durdur, sonra çal - hızlı tıklamalar için
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/click.mp3'),volume: volumeMultiplier());
      }
    } catch (e) {
      // Ses dosyası bulunamazsa sessizce devam et
      debugPrint('Sound file not found, continuing silently: $e');
    }
  }

  double volumeMultiplier() {
    switch (_soundVolume.value) {
      case 0:
        return 0.10; // Düşük
      case 1:
        return 0.35; // Orta
      case 2:
        return 0.65; // Yüksek
      default:
        return  0.65;
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










