import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'storage_service.dart';

class SoundService extends GetxService {
  late AudioPlayer _audioPlayer;
  final StorageService _storage = Get.find<StorageService>();
  
  final _soundEnabled = true.obs; // Reaktif değişken
  
  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _soundEnabled.value = _storage.getSoundEnabled();
  }
  
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
  
  Future<void> playClickSound() async {
    try {
      if (_soundEnabled.value) {
        // Önce durdur, sonra çal - hızlı tıklamalar için
        await _audioPlayer.stop();
        await _audioPlayer.play(AssetSource('sounds/click.wav'));
      }
    } catch (e) {
      // Ses dosyası bulunamazsa sessizce devam et
      debugPrint('Sound file not found, continuing silently: $e');
    }
  }
  
  bool get isSoundEnabled => _soundEnabled.value;
  
  Future<void> toggleSound() async {
    _soundEnabled.value = !_soundEnabled.value;
    await _storage.saveSoundEnabled(_soundEnabled.value);
  }
}