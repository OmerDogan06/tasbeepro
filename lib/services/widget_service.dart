import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/widget_zikr_record.dart';
import '../models/zikr.dart';
import 'storage_service.dart';
import 'subscription_service.dart';

class WidgetService extends GetxService {
  static const MethodChannel _channel = MethodChannel('widget_database');
  static const MethodChannel _updateChannel = MethodChannel('com.skyforgestudios.tasbeepro/widget');

  @override
  void onInit() {
    super.onInit();
    _setupMethodCallHandler();
  }

  void _setupMethodCallHandler() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        default:
          throw PlatformException(
            code: 'Unimplemented',
            details: 'Method ${call.method} not implemented',
          );
      }
    });
  }

  // Android SQLite veritabanından tüm widget zikir kayıtlarını al
  Future<List<WidgetZikrRecord>> getAllWidgetRecords() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getAllRecords');
      return result.map((record) => WidgetZikrRecord.fromJson(Map<String, dynamic>.from(record))).toList();
    } catch (e) {
      debugPrint('Widget kayıtları alınamadı: $e');
      return [];
    }
  }

  // Belirli tarih aralığındaki kayıtları al
  Future<List<WidgetZikrRecord>> getRecordsInDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final Map<String, dynamic> params = {
        'startTimestamp': startDate.millisecondsSinceEpoch,
        'endTimestamp': endDate.millisecondsSinceEpoch,
      };
      final List<dynamic> result = await _channel.invokeMethod('getRecordsInDateRange', params);
      return result.map((record) => WidgetZikrRecord.fromJson(Map<String, dynamic>.from(record))).toList();
    } catch (e) {
      debugPrint('Tarih aralığındaki kayıtlar alınamadı: $e');
      return [];
    }
  }

  // Widget istatistikleri al
  Future<Map<String, dynamic>> getWidgetStats() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getWidgetStats');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      debugPrint('Widget istatistikleri alınamadı: $e');
      return {
        'totalRecords': 0,
        'totalZikrCount': 0,
        'mostUsedZikr': 'Veri yok',
        'mostUsedCount': 0,
      };
    }
  }

  // Widget'a veri gönder
  Future<void> sendDataToWidget({
    required String zikrId,
    required String zikrName,
    required int currentCount,
  }) async {
    try {
      await _channel.invokeMethod('updateWidget', {
        'zikrId': zikrId,
        'zikrName': zikrName,
        'currentCount': currentCount,
      });
    } catch (e) {
      debugPrint('Widget güncelleme hatası: $e');
    }
  }

  // Widget'a zikir ve hedef listelerini gönder
  Future<void> updateWidgetData() async {
    // Premium kontrolü
    if (!_canUseWidget()) {
      debugPrint('Widget özelliği premium üyelik gerektirir');
      return;
    }
    
    try {
      final storageService = Get.find<StorageService>();
      
      // Tüm zikirleri topla (default + custom)
      final allZikrs = <Map<String, dynamic>>[];
      
      // Default zikirler
      final defaultZikrs = Zikr.getLocalizedDefaultZikrs();
      for (var zikr in defaultZikrs) {
        allZikrs.add({
          'id': zikr.id,
          'name': zikr.name,
          'meaning': zikr.meaning ?? '',
          'isCustom': false,
        });
      }
      
      // Custom zikirler
      final customZikrs = storageService.getCustomZikrs();
      for (var customData in customZikrs) {
        allZikrs.add({
          'id': customData['id'],
          'name': customData['name'],
          'meaning': customData['meaning'] ?? '',
          'isCustom': true,
        });
      }
      
      // Hedef listesi (base + custom)
      final baseTargets = [33, 99, 100, 500, 1000];
      final customTargets = storageService.getCustomTargets();
      final allTargets = <int>{...baseTargets, ...customTargets}.toList()..sort();
      
      // Widget update channel'ına gönder
      await _updateChannel.invokeMethod('updateWidgetData', {
        'zikirList': allZikrs,
        'targetList': allTargets,
      });
      
      debugPrint('Widget verileri güncellendi - Zikir: ${allZikrs.length}, Hedef: ${allTargets.length}');
      
    } catch (e) {
      debugPrint('Widget veri güncelleme hatası: $e');
    }
  }

  // Premium kontrolü
  bool _canUseWidget() {
    try {
      final subscriptionService = Get.find<SubscriptionService>();
      return subscriptionService.isWidgetEnabled;
    } catch (e) {
      // SubscriptionService henüz initialize olmamış olabilir
      return false;
    }
  }
}