import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'storage_service.dart';

class VibrationService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();
  
  final _vibrationLevel = 1.obs; // Reaktif değişken
  
  @override
  void onInit() {
    super.onInit();
    _vibrationLevel.value = _storage.getVibrationLevel();
  }
  
  Future<void> vibrate() async {
    final level = _vibrationLevel.value;
    
    switch (level) {
      case 0: // Off
        return;
      case 1: // Light
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 50);
        }
        break;
      case 2: // Medium
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 100);
        }
        break;
    }
  }
  
  int get vibrationLevel => _vibrationLevel.value;
  
  Future<void> setVibrationLevel(int level) async {
    _vibrationLevel.value = level;
    await _storage.saveVibrationLevel(level);
  }
  
  String get vibrationLevelText {
    switch (_vibrationLevel.value) {
      case 0:
        return 'Kapalı';
      case 1:
        return 'Hafif';
      case 2:
        return 'Orta';
      default:
        return 'Hafif';
    }
  }
}