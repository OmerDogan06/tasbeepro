import 'package:get/get.dart';
import '../models/zikr.dart';
import '../models/counter_data.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/vibration_service.dart';
import '../widgets/islamic_snackbar.dart';

class CounterController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  final SoundService _sound = Get.find<SoundService>();
  final VibrationService _vibration = Get.find<VibrationService>();
  
  final _currentZikr = const Zikr(
    id: 'subhanallah',
    name: 'Subhanallah',
  ).obs;
  
  final _count = 0.obs;
  final _target = 33.obs;
  final _dailyTotal = 0.obs;
  final _isAnimating = false.obs;
  
  final _completedTargets = 0.obs; // Tamamlanan hedef sayısını takip et
  
  final List<int> targetOptions = [33, 99, 100, 500, 1000];
  
  Zikr get currentZikr => _currentZikr.value;
  int get count => _count.value;
  int get target => _target.value;
  int get dailyTotal => _dailyTotal.value;
  bool get isAnimating => _isAnimating.value;
  double get progress => target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => count >= target;
  
  @override
  void onInit() {
    super.onInit();
    _loadData();
  }
  
  void _loadData() {
    // Load current zikr
    final currentZikrId = _storage.getCurrentZikr();
    final localizedZikrs = Zikr.getLocalizedDefaultZikrs();
    final zikr = localizedZikrs.firstWhere(
      (z) => z.id == currentZikrId,
      orElse: () => localizedZikrs.first,
    );
    _currentZikr.value = zikr;
    
    // Load counter data
    final counterData = _storage.getCounterData(zikr.id);
    if (counterData != null) {
      _count.value = counterData.count;
      _target.value = counterData.target;
    }
    
    // Load daily total (tüm zikirlerden)
    _dailyTotal.value = _storage.getTotalDailyCount();
  }
  
  Future<void> increment() async {
    if (_isAnimating.value) return;
    
    _isAnimating.value = true;
    
    // Play sound and vibration
    _sound.playClickSound();
    _vibration.vibrate();
    
    // Store previous count to check if target was just completed
    final previousCount = _count.value;
    
    // Increment counter
    _count.value++;
    
    // Günlük zikir sayısını artır
    final currentDailyCount = _storage.getDailyZikrCount(_currentZikr.value.id);
    await _storage.saveDailyZikrCount(_currentZikr.value.id, currentDailyCount + 1);
    
    // Toplam günlük sayıyı güncelle
    _dailyTotal.value = _storage.getTotalDailyCount();

    // Save data
    final counterData = CounterData(
      zikrId: _currentZikr.value.id,
      count: _count.value,
      target: _target.value,
      lastUpdated: DateTime.now(),
    );
    
    await _storage.saveCounterData(counterData);
    
    // Check if target just completed (was not completed before but is now)
    if (previousCount < _target.value && _count.value >= _target.value) {
      _completedTargets.value++;
      _showCompletionMessage();
    }
    
    // Animation delay
    await Future.delayed(const Duration(milliseconds: 150));
    _isAnimating.value = false;
  }
  
  void _showCompletionMessage() {
    IslamicSnackbar.showSuccess(
      'Tebrikler! 🎉',
      'Hedefini tamamladın!',
      duration: const Duration(seconds: 2),
    );
  }
  
  Future<void> reset() async {
    _count.value = 0;
    
    final counterData = CounterData(
      zikrId: _currentZikr.value.id,
      count: 0,
      target: _target.value,
      lastUpdated: DateTime.now(),
    );
    
    await _storage.saveCounterData(counterData);
  }
  
  Future<void> setTarget(int newTarget) async {
    _target.value = newTarget;
    
    final counterData = CounterData(
      zikrId: _currentZikr.value.id,
      count: _count.value,
      target: newTarget,
      lastUpdated: DateTime.now(),
    );
    
    await _storage.saveCounterData(counterData);
  }
  
  Future<void> selectZikr(Zikr zikr) async {
    // Save current counter data
    final currentCounterData = CounterData(
      zikrId: _currentZikr.value.id,
      count: _count.value,
      target: _target.value,
      lastUpdated: DateTime.now(),
    );
    await _storage.saveCounterData(currentCounterData);
    
    // Switch to new zikr
    _currentZikr.value = zikr;
    await _storage.saveCurrentZikr(zikr.id);
    
    // Load new zikr data
    final newCounterData = _storage.getCounterData(zikr.id);
    if (newCounterData != null) {
      _count.value = newCounterData.count;
      _target.value = newCounterData.target;
    } else {
      _count.value = 0;
      _target.value = 33;
    }
  }
  
  // Custom zikir ekleme (Pro özelliği)
  Future<void> addCustomZikr(Zikr customZikr) async {
    final customZikrs = _storage.getCustomZikrs();
    customZikrs.add(customZikr.toJson());
    await _storage.saveCustomZikrs(customZikrs);
    
    IslamicSnackbar.showSuccess(
      'Başarılı! 🎉',
      'Özel zikir eklendi',
    );
  }
  
  // Mevcut zikir listesini yenile
  List<Zikr> getAllZikrs() {
    final allZikrs = <Zikr>[];
    
    // Varsayılan zikirler (localized)
    allZikrs.addAll(Zikr.getLocalizedDefaultZikrs());
    
    // Custom zikirler
    final customZikrs = _storage.getCustomZikrs();
    for (var customData in customZikrs) {
      allZikrs.add(Zikr.fromJson(customData));
    }
    
    return allZikrs;
  }
  
  // İstatistikler için zikir sayısını al
  double getZikrCount(String zikrId) {
    final counterData = _storage.getCounterData(zikrId);
    return counterData?.count.toDouble() ?? 0.0;
  }

  // Tarihe göre zikir sayılarını al
  int getZikrCountForPeriod(String zikrId, String period) {
    switch (period) {
      case 'Günlük':
        return _storage.getTodayZikrCount(zikrId);
      case 'Haftalık':
        return _storage.getWeeklyZikrCount(zikrId);
      case 'Aylık':
        return _storage.getMonthlyZikrCount(zikrId);
      case 'Yıllık':
        return _storage.getYearlyZikrCount(zikrId);
      default:
        return getZikrCount(zikrId).toInt(); // Toplam
    }
  }


}