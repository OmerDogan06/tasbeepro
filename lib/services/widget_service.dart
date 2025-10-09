import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/widget_zikr_record.dart';

class WidgetService extends GetxService {
  static const MethodChannel _channel = MethodChannel('widget_database');

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
}