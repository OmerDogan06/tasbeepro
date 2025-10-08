import 'package:get/get.dart';
import '../services/widget_service.dart';
import '../models/widget_zikr_record.dart';

class WidgetStatsController extends GetxController {
  final WidgetService _widgetService = Get.find<WidgetService>();

  // Android SQLite'tan tüm widget kayıtlarını al
  Future<List<WidgetZikrRecord>> getAllWidgetRecords() async {
    return await _widgetService.getAllWidgetRecords();
  }

  // Dönemsel widget kayıtlarını al
  Future<List<WidgetZikrRecord>> getRecordsForPeriod(String period) async {
    final now = DateTime.now();
    late DateTime startDate;

    switch (period) {
      case 'Günlük':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'Haftalık':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(monday.year, monday.month, monday.day);
        break;
      case 'Aylık':
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 'Yıllık':
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    final endDate = now;
    return await _widgetService.getRecordsInDateRange(startDate, endDate);
  }

  // Widget istatistiklerini al
  Future<Map<String, dynamic>> getWidgetStatsForPeriod(String period) async {
    final records = await getRecordsForPeriod(period);
    final Map<String, int> totals = {};

    // Zikir bazında toplamları hesapla
    for (final record in records) {
      totals[record.zikrId] = (totals[record.zikrId] ?? 0) + record.count;
    }

    int totalCount = totals.values.fold(0, (sum, count) => sum + count);
    int activeZikrs = totals.length;
    
    String? mostUsedZikrName;
    int mostUsedCount = 0;
    
    for (final entry in totals.entries) {
      if (entry.value > mostUsedCount) {
        mostUsedCount = entry.value;
        // Zikir adını bul
        final record = records.firstWhere(
          (r) => r.zikrId == entry.key,
          orElse: () => WidgetZikrRecord(
            id: '', 
            zikrId: '', 
            zikrName: '', 
            count: 0, 
            date: DateTime.now()
          ),
        );
        mostUsedZikrName = record.zikrName.isNotEmpty ? record.zikrName : entry.key;
      }
    }

    return {
      'totalCount': totalCount,
      'activeZikrs': activeZikrs,
      'mostUsed': mostUsedZikrName ?? '',
      'records': records.length,
    };
  }

  // Grafik verilerini al
  Future<List<Map<String, dynamic>>> getChartDataForPeriod(String period) async {
    final records = await getRecordsForPeriod(period);
    final Map<String, int> totals = {};
    final Map<String, String> zikrNames = {};

    // Zikir bazında toplamları hesapla
    for (final record in records) {
      totals[record.zikrId] = (totals[record.zikrId] ?? 0) + record.count;
      zikrNames[record.zikrId] = record.zikrName;
    }

    return totals.entries.map((entry) {
      return {
        'zikrId': entry.key,
        'zikrName': zikrNames[entry.key] ?? entry.key,
        'count': entry.value,
      };
    }).toList();
  }

  // Belirli bir zikir için dönemsel sayı
  Future<int> getZikrCountForPeriod(String zikrId, String period) async {
    final records = await getRecordsForPeriod(period);
    return records
        .where((record) => record.zikrId == zikrId)
        .fold<int>(0, (sum, record) => sum + record.count);
  }
}