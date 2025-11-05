import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../controllers/counter_controller.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';


class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExportingPDF = false; // PDF export loading state
  CounterController controller = Get.find<CounterController>();

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void initState() {
    dataload();
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  dataload()  {
     controller.getAllZikrs();
  }


  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
      TextDirection textDirection = Directionality.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
         statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar:PreferredSize(preferredSize: Size.fromHeight(104), child:  SafeArea(
          child: AppBar(
            title: Text(
              AppLocalizations.of(context)?.statsTitle ?? 'Detaylı İstatistikler 💎',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: emeraldGreen,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFDF7), Color(0xFFF8F6F0)],
                ),
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [lightGold, goldColor],
                  center: Alignment(-0.2, -0.2),
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withAlpha(38),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                icon: const Icon(Icons.arrow_back, color: emeraldGreen, size: 20),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              // PDF Export Button
              Container(
                width: 40,
                height: 40,
                margin:textDirection == TextDirection.ltr
                    ? const EdgeInsets.only(right: 12)
                    : const EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  gradient: const RadialGradient(
                    colors: [lightGold, goldColor],
                    center: Alignment(-0.2, -0.2),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: darkGreen.withAlpha(38),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.zero),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  icon: _isExportingPDF
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: emeraldGreen,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.picture_as_pdf,
                          color: emeraldGreen,
                          size: 20,
                        ),
                  onPressed: _isExportingPDF ? null : () {
                    // Güncel tab index'ine göre period'u belirle
                    String currentPeriod;
                    switch (_tabController.index) {
                      case 0:
                        currentPeriod = AppLocalizations.of(context)?.statsDaily ?? 'Günlük';
                        break;
                      case 1:
                        currentPeriod = AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık';
                        break;
                      case 2:
                        currentPeriod = AppLocalizations.of(context)?.statsMonthly ?? 'Aylık';
                        break;
                      case 3:
                        currentPeriod = AppLocalizations.of(context)?.statsYearly ?? 'Yıllık';
                        break;
                      default:
                        currentPeriod = AppLocalizations.of(context)?.statsDaily ?? 'Günlük';
                    }
                    _exportToPDF(currentPeriod, context);
                  },
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: emeraldGreen,
              unselectedLabelColor: emeraldGreen.withAlpha(153),
              indicatorColor: goldColor,
              indicatorSize: TabBarIndicatorSize.label,
              tabAlignment: TabAlignment.center,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: AppLocalizations.of(context)?.statsDaily ?? 'Günlük'),
                Tab(text: AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık'),
                Tab(text: AppLocalizations.of(context)?.statsMonthly ?? 'Aylık'),
                Tab(text: AppLocalizations.of(context)?.statsYearly ?? 'Yıllık'),
              ],
            ),
          ),
        )),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPeriodStats(AppLocalizations.of(context)?.statsDaily ?? 'Günlük', controller),
              _buildPeriodStats(AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık', controller),
              _buildPeriodStats(AppLocalizations.of(context)?.statsMonthly ?? 'Aylık', controller),
              _buildPeriodStats(AppLocalizations.of(context)?.statsYearly ?? 'Yıllık', controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodStats(String period, CounterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Bilgi Kartı - Dönemsel açıklama
          _buildPeriodInfoCard(period),
          const SizedBox(height: 10),

          // Özet Kartı
          _buildSummaryCard(period, controller),
          const SizedBox(height: 15),

          // Grafik Kartı
          _buildChartCard(period, controller),
          const SizedBox(height: 15),

          // Zikir Listesi
          _buildZikrList(period, controller),
        ],
      ),
    );
  }

  Widget _buildPeriodInfoCard(String period) {
    String info;
    String emoji;
    
    // Map English period names to Turkish for comparison
    String periodKey = period;
    if (period == 'Daily') {
      periodKey = 'Günlük';
    } else if (period == 'Weekly') {
      periodKey = 'Haftalık';
    } else if (period == 'Monthly') {
      periodKey = 'Aylık';
    } else if (period == 'Yearly') {
      periodKey = 'Yıllık';
    }
   
    
    switch (periodKey) {
      case 'Günlük':
        info = AppLocalizations.of(context)?.statsDailyInfo ?? 'Bugün çekilen zikirlerinizin detayları';
        emoji = '📅';
        break;
      case 'Haftalık':
        info = AppLocalizations.of(context)?.statsWeeklyInfo ?? 'Bu hafta çekilen zikirlerinizin detayları';
        emoji = '📊';
        break;
      case 'Aylık':
        info = AppLocalizations.of(context)?.statsMonthlyInfo ?? 'Bu ay çekilen zikirlerinizin detayları';
        emoji = '📈';
        break;
      case 'Yıllık':
        info = AppLocalizations.of(context)?.statsYearlyInfo ?? 'Bu yıl çekilen zikirlerinizin detayları';
        emoji = '🏆';
        break;
      default:
         info =  AppLocalizations.of(context)?.widgetStatsTitle ?? 'Widget İstatistikleri';
        emoji = '📋';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [lightGold, Color(0xFFF0E9D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withAlpha(77), width: 1),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: goldColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                AppLocalizations.of(context)?.statsPeriodStatsFor(period) ?? '$period İstatistikler',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: emeraldGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(
                    fontSize: 12,
                    color: emeraldGreen.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String period, CounterController controller) {
    Map<String, dynamic>  stats = _calculatePeriodStats(period, controller).obs;
    

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)?.statsPeriodStatsFor(period) ?? '$period İstatistikler',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)?.statsTotal ?? 'Toplam Zikir',
                  '${stats['totalCount']}',
                  Icons.numbers,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)?.statsMostUsed ?? 'En Çok Çekilen',
                  stats['mostUsed'] ?? '',
                  Icons.star,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)?.statsActiveZikrs ?? 'Aktif Zikir',
                  '${stats['activeZikrs']}',
                  Icons.list,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  AppLocalizations.of(context)?.statsAverage ?? 'Ortalama',
                  '${stats['average']}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: lightGold.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: emeraldGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: emeraldGreen.withAlpha(179),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String period, CounterController controller) {
    final chartData = _getChartData(period, controller);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$period ${AppLocalizations.of(context)?.statsDistribution ?? 'Zikir Dağılımı'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 20),
          chartData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pie_chart,
                        size: 48,
                        color: emeraldGreen.withAlpha(128),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.statsNoData ?? 'Henüz $period veri yok',
                        style: TextStyle(
                          color: emeraldGreen.withAlpha(179),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Pie Chart - Tam genişlik
                    SizedBox(
                      height: 325,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 95,
                          sections: chartData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final data = entry.value;
                            final total = chartData.fold<double>(0, (sum, item) => sum + item.y);
                            final percentage = total > 0 ? (data.y / total * 100) : 0;
                            
                            return PieChartSectionData(
                              color: _getChartColor(index),
                              value: data.y,
                              title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '', // Sadece %5'ten büyükse yüzde göster
                              radius: 65,
                              titleStyle: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(0.5, 0.5),
                                    blurRadius: 1,
                                  ),
                                ],
                              ),
                              titlePositionPercentageOffset: 0.6,
                            );
                          }).toList(),
                          pieTouchData: PieTouchData(
                            enabled: true,
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              // Touch feedback eklenebilir
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Legend - Sabit yükseklikli iki sütunlu düzen
                    _buildTwoColumnLegend(chartData),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildZikrList(String period, CounterController controller) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$period ${AppLocalizations.of(context)?.statsDetails ?? 'Zikir Detayları'}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 10),
          ...controller.allZikrs.map((zikr) {
            final count = controller.getZikrCountForPeriod(zikr.id, period);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGold.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldColor.withAlpha(51)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const RadialGradient(
                        colors: [lightGold, goldColor],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      zikr.isCustom ? Icons.edit : Icons.book,
                      color: emeraldGreen,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zikr.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: emeraldGreen,
                            fontSize: 14,
                          ),
                        ),
                        if (zikr.meaning != null && zikr.meaning!.isNotEmpty)
                          Text(
                            zikr.meaning!,
                            style: TextStyle(
                              color: emeraldGreen.withAlpha(179),
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [goldColor, lightGold],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      count.toString(), // Zaten int
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculatePeriodStats(
    String period,
    CounterController controller,
  ) {
    final allZikrs = controller.allZikrs;
    int totalCount = 0;
    int activeZikrs = 0;
    String? mostUsed;
    int mostUsedCount = 0;

    for (final zikr in allZikrs) {
      // Tarihe göre zikir sayısını al
      final count = controller.getZikrCountForPeriod(zikr.id, period);
      totalCount += count;
      if (count > 0) {
        activeZikrs++;
        if (count > mostUsedCount) {
          mostUsedCount = count;
          mostUsed = zikr.name;
        }
      }
    }

    final average = activeZikrs > 0 ? (totalCount / activeZikrs).round() : 0;

    return {
      'totalCount': totalCount,
      'activeZikrs': activeZikrs,
      'mostUsed': mostUsed,
      'average': average,
    };
  }

  List<ChartData> _getChartData(String period, CounterController controller) {
    final allZikrs = controller.allZikrs;
    final List<ChartData> chartData = [];

    // Tüm zikirleri al ve sırala (count'a göre)
    final sortedZikrs = allZikrs.where((zikr) {
      final count = controller.getZikrCountForPeriod(zikr.id, period);
      return count > 0; // Sadece kullanılan zikirler
    }).toList();

    // Count'a göre sırala (büyükten küçüğe)
    sortedZikrs.sort((a, b) {
      final countA = controller.getZikrCountForPeriod(a.id, period);
      final countB = controller.getZikrCountForPeriod(b.id, period);
      return countB.compareTo(countA);
    });

    // Tüm aktif zikirleri ekle (16 zikir de dahil)
    for (final zikr in sortedZikrs) {
      final count = controller.getZikrCountForPeriod(zikr.id, period);
      chartData.add(
        ChartData(
          label: zikr.name,
          y: count.toDouble(),
        ),
      );
    }

    return chartData;
  }

  // Grafik renkleri için metod
  Color _getChartColor(int index) {
    final colors = [
      const Color(0xFFD4AF37), // goldColor
      const Color(0xFF2D5016), // emeraldGreen
      const Color(0xFFF5E6A8), // lightGold
      const Color(0xFF1A3409), // darkGreen
      const Color(0xFFE8B931), // darker gold
      const Color(0xFF4A6B2A), // lighter green
      const Color(0xFFF0D65C), // light yellow
      const Color(0xFF3E5C1E), // medium green
      const Color(0xFFDDA94B), // orange gold
      const Color(0xFF5A7D34), // forest green
      const Color(0xFFF7E89A), // pale gold
      const Color(0xFF2F4A17), // deep green
      const Color(0xFFE1C547), // mustard
      const Color(0xFF657F3A), // olive green
      const Color(0xFFF4E2B7), // cream
      const Color(0xFF3C5B1F), // pine green
    ];
    return colors[index % colors.length];
  }

  // Sabit yükseklikli iki sütunlu legend düzeni
  Widget _buildTwoColumnLegend(List<ChartData> chartData) {
    return Column(
      children: [
        for (int i = 0; i < chartData.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                // Sol sütun
                Expanded(
                  child: _buildLegendItem(chartData[i], i),
                ),
                const SizedBox(width: 12),
                // Sağ sütun (eğer varsa)
                Expanded(
                  child: i + 1 < chartData.length
                      ? _buildLegendItem(chartData[i + 1], i + 1)
                      : const SizedBox(), // Boş alan
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Legend item builder - sabit yükseklik
  Widget _buildLegendItem(ChartData data, int index) {
    final total = _getTotalFromAllData();
    final percentage = total > 0 ? (data.y / total * 100) : 0;

    return Container(
      height: 50, // Sabit yükseklik
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: _getChartColor(index).withAlpha(26),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getChartColor(index).withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getChartColor(index),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: emeraldGreen,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatNumber(data.y.toInt()),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getChartColor(index),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: emeraldGreen.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Chart data'dan toplam değeri hesapla
  double _getTotalFromAllData() {
    final controller = Get.find<CounterController>();
    final currentPeriod = _getCurrentPeriod();
    final chartData = _getChartData(currentPeriod, controller);
    return chartData.fold<double>(0, (sum, item) => sum + item.y);
  }

  // Güncel period'u al
  String _getCurrentPeriod() {
    switch (_tabController.index) {
      case 0:
        return AppLocalizations.of(context)?.statsDaily ?? 'Günlük';
      case 1:
        return AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık';
      case 2:
        return AppLocalizations.of(context)?.statsMonthly ?? 'Aylık';
      case 3:
        return AppLocalizations.of(context)?.statsYearly ?? 'Yıllık';
      default:
        return AppLocalizations.of(context)?.statsDaily ?? 'Günlük';
    }
  }

  // Sayıları formatlamak için metod (büyük sayılar için K, M gibi kısaltmalar)
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  Future<void> _exportToPDF(String period, BuildContext buildContext) async {
    // Loading state'ini başlat
    setState(() {
      _isExportingPDF = true;
    });

    try {
      final controller = Get.find<CounterController>();

      final moonBytes = await rootBundle.load('assets/image/islam.png');
      final moonImage = pw.MemoryImage(moonBytes.buffer.asUint8List());
      final pdf = pw.Document();

      // Unicode destekli fontları yükle
      pw.Font? regularFont;

      pw.Font? amiriFont;
      pw.Font? japaneseFont;

      pw.Font? koreanFont;

      pw.Font? chineseFont;

      pw.Font? bengaliFont;

      pw.Font? thaiFont;

      pw.Font? cyrillicFont;


      try {
        // Latin karakterler için
        final regularFontData = await rootBundle.load(
          'assets/fonts/Poppins-Regular.ttf',
        );
        regularFont = pw.Font.ttf(regularFontData);



        // Arapça/İslami metinler için
        final amiriFontData = await rootBundle.load(
          'assets/fonts/Amiri-Regular.ttf',
        );
        amiriFont = pw.Font.ttf(amiriFontData);

        // Japonca için
        try {
          final japaneseFontData = await rootBundle.load(
            'assets/fonts/NotoSansJP-Regular.ttf',
          );
          japaneseFont = pw.Font.ttf(japaneseFontData);
          

        } catch (jpError) {
          debugPrint('Japonca font yüklenemedi: $jpError');
        }

        // Korece için
        try {
          final koreanFontData = await rootBundle.load(
            'assets/fonts/NotoSansKR-Regular.ttf',
          );
          koreanFont = pw.Font.ttf(koreanFontData);
          

        } catch (krError) {
          debugPrint('Korece font yüklenemedi: $krError');
        }

        // Tayca için
        try {
          final thaiFontData = await rootBundle.load(
            'assets/fonts/NotoSansThai-Regular.ttf',
          );
          thaiFont = pw.Font.ttf(thaiFontData);
          

        } catch (thError) {
          debugPrint('Tayca font yüklenemedi: $thError');
        }

        // Çince için (Simplified Chinese - 简体中文)
        try {
          final chineseFontData = await rootBundle.load(
            'assets/fonts/NotoSansSC-Regular.ttf',
          );
          chineseFont = pw.Font.ttf(chineseFontData);
          

        } catch (cnError) {
          debugPrint('Çince font yüklenemedi: $cnError - Fallback olarak Latin font kullanılacak');
          chineseFont = null;

        }

        // Bengalce için
        try {
          final bengaliFontData = await rootBundle.load(
            'assets/fonts/NotoSansBengali-Regular.ttf',
          );
          bengaliFont = pw.Font.ttf(bengaliFontData);
          

        } catch (bnError) {
          debugPrint('Bengalce font yüklenemedi: $bnError');
        }

        // Rusça ve Kiril alfabesi için
        try {
          final cyrillicFontData = await rootBundle.load(
            'assets/fonts/NotoSans-cyrillic-Regular.ttf',
          );
          cyrillicFont = pw.Font.ttf(cyrillicFontData);


        } catch (cyError) {
          debugPrint('Kiril alfabesi font yüklenemedi: $cyError');
        }

      } catch (fontError) {
        debugPrint('Font yüklenemedi: $fontError');
        // Font yüklenemezse fallback fontları kullan
        try {
          // En azından temel fontları yüklemeye çalış
          if (regularFont == null) {
            final fallbackFontData = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
            regularFont = pw.Font.ttf(fallbackFontData);
          }

        } catch (fallbackError) {
          debugPrint('Fallback fontlar da yüklenemedi: $fallbackError');
          // En son çare olarak built-in fontları kullan
          regularFont = pw.Font.helvetica();
        }
        
        // Diğer fontlar için fallback
        amiriFont ??= regularFont;
        japaneseFont ??= regularFont;
        koreanFont ??= regularFont;
        chineseFont ??= regularFont;
        thaiFont ??= regularFont;
        bengaliFont ??= regularFont;
        cyrillicFont ??= regularFont;
      }

      // PDF sayfası oluştur
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            final allZikrs = controller.allZikrs;
            
            // Dönemsel istatistikleri doğru hesapla
            final periodStats = _calculatePeriodStats(period, controller);
            final totalCount = periodStats['totalCount'] as int;
            final activeZikrs = periodStats['activeZikrs'] as int;
            final average = periodStats['average'] as int;
            
            final now = DateTime.now();

            // En çok kullanılan zikirler (aktif olanlar - max 5)
            final sortedZikrs =
                allZikrs
                    .where(
                      (zikr) => controller.getZikrCountForPeriod(zikr.id, period) > 0,
                    ) // Sadece aktif zikirler
                    .toList()
                  ..sort(
                    (a, b) => controller
                        .getZikrCountForPeriod(b.id, period)
                        .compareTo(controller.getZikrCountForPeriod(a.id, period)),
                  );
            final topZikrs = sortedZikrs.take(10).toList(); // Max 10 zikir göster
            TextDirection textDirection = Directionality.of(buildContext);

            // Font seçim fonksiyonu - dile göre uygun font döndürür
            pw.Font? selectFontForText(String text, {bool isBold = false}) {
              // Arapça karakterler kontrolü
              if (RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text)) {
                return amiriFont ?? regularFont ?? pw.Font.helvetica();
              }
              
              // Bengalce karakterler kontrolü
              if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
                return  (bengaliFont ?? regularFont ?? pw.Font.helvetica());
              }

              // Tayca karakterler kontrolü
              if (RegExp(r'[\u0E00-\u0E7F]').hasMatch(text)) {
                return  (thaiFont ?? regularFont ?? pw.Font.helvetica());
              }
              
              // Çince karakterler kontrolü (Simplified & Traditional)
              if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
                debugPrint('Çince karakter tespit edildi: $text');
                return  (chineseFont ?? japaneseFont ?? regularFont ?? pw.Font.helvetica());
              }
              
              // Japonca karakterler kontrolü (Hiragana, Katakana, Kanji)
              if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
                return  (japaneseFont ?? regularFont ?? pw.Font.helvetica());
              }
              
              // Korece karakterler kontrolü
              if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
                return (koreanFont ?? regularFont ?? pw.Font.helvetica());
              }
              
              // Kiril alfabesi kontrolü (Rusça vb.)
              if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) {
              
                  return cyrillicFont ?? regularFont ?? pw.Font.helvetica();
                
              }
              
              // Varsayılan Latin fontları
              if (textDirection == TextDirection.rtl) {
                return amiriFont ?? regularFont ?? pw.Font.helvetica();
              }
              
          
                return regularFont ?? pw.Font.helvetica();
              
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // İslami Başlık - Daha şık tasarım
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    gradient: pw.LinearGradient(
                      colors: [
                        PdfColor.fromHex('#2D5016'), // emerald green
                        PdfColor.fromHex('#1A3409'), // dark green
                      ],
                    ),
                    borderRadius: pw.BorderRadius.circular(12),
                  ),
                  child: pw.Column(
                    children: [
                      // İslami simgeler ve dekorasyon
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 45,
                            height: 45,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#D4AF37'),
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Image(moonImage, width: 65, height: 65),
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Expanded(
                            child: pw.Text(
                              AppLocalizations.of(buildContext)?.pdfBismillah ?? 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                              textAlign: pw.TextAlign.center,
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(
                                fontSize: 20,
                                color: PdfColor.fromHex('#F5E6A8'),
                                font: amiriFont,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 16),
                          pw.Container(
                            width: 45,
                            height: 45,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromHex('#D4AF37'),
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Image(moonImage, width: 65, height: 65),
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 12),
                      pw.Text(
                       '${AppLocalizations.of(buildContext)?.pdfReportTitle ?? 'Tasbee Pro - Detaylı İstatistik Raporu'} ($period)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          font: selectFontForText('${AppLocalizations.of(buildContext)?.pdfReportTitle ?? 'Tasbee Pro - Detaylı İstatistik Raporu'} ($period)', isBold: true),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '${AppLocalizations.of(buildContext)?.pdfDate ?? 'Tarih'}: ${now.day}/${now.month}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#F5E6A8'),
                          font: selectFontForText('${AppLocalizations.of(buildContext)?.pdfDate ?? 'Tarih'}: ${now.day}/${now.month}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'),
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // Ana İstatistikler - Kartlar halinde
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: _buildStatCard(
                        AppLocalizations.of(buildContext)?.pdfTotalZikrCard ?? 'Toplam Zikir',
                        totalCount.toString(),
                        'O',
                        regularFont,
                        textDirection,
                        amiriFont,
                        japaneseFont,
                        koreanFont,
                        chineseFont,
                        thaiFont,
                        bengaliFont,
                        cyrillicFont,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildStatCard(
                        AppLocalizations.of(buildContext)?.statsAverage ?? 'Ortalama',
                        average.toString(),
                        '#',
                        regularFont,
                         textDirection,
                        amiriFont,
                        japaneseFont,
                        koreanFont,
                        chineseFont,
                        thaiFont,
                        bengaliFont,
                        cyrillicFont,
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildStatCard(
                        AppLocalizations.of(buildContext)?.pdfActiveZikrRatio ?? 'Aktif Zikir',
                        '$activeZikrs/${allZikrs.length}',
                        '+',
                        regularFont,
                         textDirection,
                        amiriFont,
                        japaneseFont,
                        koreanFont,
                        chineseFont,
                        thaiFont,
                        bengaliFont,
                        cyrillicFont,
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // En Çok Kullanılan Zikirler - Grafik benzeri görünüm
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F8F6F0'),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#D4AF37'),
                      width: 1,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '>> ${AppLocalizations.of(buildContext)?.pdfMostUsedZikrs ?? 'En Cok Kullanilan Zikirler'}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2D5016'),
                          font: selectFontForText('>> ${AppLocalizations.of(buildContext)?.pdfMostUsedZikrs ?? 'En Cok Kullanilan Zikirler'}', isBold: true),
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      // Grafik benzeri çubuklar - sadece aktif zikirler gösterilir
                      if (topZikrs.isNotEmpty) ...[
                        ...topZikrs.map((zikr) {
                          final count = controller
                              .getZikrCountForPeriod(zikr.id, period);
                          final maxCount = topZikrs.isEmpty
                              ? 1
                              : controller
                                    .getZikrCountForPeriod(topZikrs.first.id, period);
                          final percentage = maxCount > 0
                              ? (count / maxCount) * 100
                              : 0;

                          return pw.Container(
                            margin: const pw.EdgeInsets.only(bottom: 8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Row(
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Expanded(
                                      child: pw.Text(
                                        zikr.name,
                                        style: pw.TextStyle(
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold,
                                          color: PdfColor.fromHex('#2D5016'),
                                          font: selectFontForText(zikr.name, isBold: true),
                                        ),
                                      ),
                                    ),
                                    pw.Text(
                                      count.toString(),
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColor.fromHex('#D4AF37'),
                                        font: selectFontForText(count.toString(), isBold: true),
                                      ),
                                    ),
                                  ],
                                ),
                                pw.SizedBox(height: 4),
                                // Progress bar - dinamik genişlik
                                pw.Stack(
                                  children: [
                                    pw.Container(
                                      height: 8,
                                      width: double.infinity,
                                      decoration: pw.BoxDecoration(
                                        color: PdfColor.fromHex('#E8E0C7'),
                                        borderRadius: pw.BorderRadius.circular(
                                          4,
                                        ),
                                      ),
                                    ),
                                    pw.Container(
                                      height: 8,
                                      width:
                                          (percentage / 100) *
                                          300, // 300 points max width
                                      decoration: pw.BoxDecoration(
                                        gradient: pw.LinearGradient(
                                          colors: [
                                            PdfColor.fromHex('#D4AF37'),
                                            PdfColor.fromHex('#F5E6A8'),
                                          ],
                                        ),
                                        borderRadius: pw.BorderRadius.circular(
                                          4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      ] else ...[
                        pw.Text(
                          AppLocalizations.of(buildContext)?.pdfNoZikrYet ?? 'Henuz hic zikir cekilmemis.',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#2D5016'),
                            font: selectFontForText(AppLocalizations.of(buildContext)?.pdfNoZikrYet ?? 'Henuz hic zikir cekilmemis.'),
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // İslami alt bilgi
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0E9D2'),
                    borderRadius: pw.BorderRadius.circular(10),
                    border: pw.Border.all(
                      color: PdfColor.fromHex('#D4AF37'),
                      width: 1,
                    ),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Container(
                        padding: const pw.EdgeInsets.all(8),
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromHex('#2D5016'),
                          borderRadius: pw.BorderRadius.circular(8),
                        ),
                        child: pw.Text(
                          AppLocalizations.of(buildContext)?.pdfQuranVerse ?? 'وَاذْكُرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ',
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(fontSize: 12, font: amiriFont,color: PdfColor.fromHex('#FFFFFF')),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        AppLocalizations.of(buildContext)?.pdfQuranTranslation ?? '"Allah\'ı çok zikredin ki kurtulursunuz." (Enfal: 45)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font: selectFontForText(AppLocalizations.of(buildContext)?.pdfQuranTranslation ?? '"Allah\'ı çok zikredin ki kurtulursunuz." (Enfal: 45)')),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        AppLocalizations.of(buildContext)?.pdfAppCredit ?? 'Bu rapor Tasbee Pro uygulaması tarafından oluşturulmuştur.',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('#2D5016'),
                          font: selectFontForText(AppLocalizations.of(buildContext)?.pdfAppCredit ?? 'Bu rapor Tasbee Pro uygulaması tarafından oluşturulmuştur.'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // PDF'i kaydet - External storage (izin gerektirmez)
      Directory saveDir;
      String saveLocation;

      try {
        // Android external storage directory (app-specific, izin gerektirmez)
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          // Ana external storage path'ini al (/storage/emulated/0/Android/data/package/files)
          // Buradan ana directory'ye çıkalım (/storage/emulated/0)
          final mainPath = externalDir.path.split('/Android/data/')[0];
          saveDir = Directory('$mainPath/TasbeePro');
          saveLocation = buildContext.mounted ? AppLocalizations.of(buildContext)?.pdfMainStoragePath ?? "Ana depolama/TasbeePro" : "Ana depolama/TasbeePro";

          // Klasör yoksa oluştur
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } else {
          throw Exception(buildContext.mounted ? AppLocalizations.of(buildContext)?.pdfExternalStorageError ?? 'External storage not available' : 'External storage not available');
        }
      } catch (e) {
        // Fallback - App-specific external directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          saveDir = Directory('${externalDir.path}/TasbeePro_Reports');
          saveLocation = buildContext.mounted ? AppLocalizations.of(buildContext)?.pdfAppSpecificPath ?? "Uygulamaya özel klasör/TasbeePro_Reports" : "Uygulamaya özel klasör/TasbeePro_Reports";

          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } else {
          // Son fallback - Documents directory
          saveDir = await getApplicationDocumentsDirectory();
          saveLocation = buildContext.mounted ? AppLocalizations.of(buildContext)?.pdfDocumentsPath ?? "Uygulama belgeler klasörü" : "Uygulama belgeler klasörü";
        }
      }

      final fileName =
          'Tasbee_Pro_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}_$period.pdf';
      final file = File('${saveDir.path}/$fileName');

      try {
        await file.writeAsBytes(await pdf.save());

        // PDF başarıyla kaydedildikten sonra kullanıcıya seçenekler sun
        await _showPdfOptionsDialog(file.path, fileName, saveLocation);
      } catch (pdfError) {
        debugPrint('PDF kaydetme hatası: $pdfError');
        
       
      
      }
    } catch (e) {
      debugPrint('PDF oluşturma hatası: $e');
    
    } finally {
      // Loading state'ini sonlandır
      setState(() {
        _isExportingPDF = false;
      });
    }
  }

  // Depolama izni kontrolü ve isteği

  // PDF seçenekleri dialog'u
  Future<void> _showPdfOptionsDialog(
    String filePath,
    String fileName,
    String saveLocation,
  ) async {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(51),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [lightGold, goldColor],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.pdfSuccessTitle ?? 'PDF Başarıyla Oluşturuldu! 📄',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      goldColor.withAlpha(77),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dosya bilgileri
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lightGold.withAlpha(51),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: goldColor.withAlpha(77),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: emeraldGreen,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: emeraldGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.folder,
                                color: emeraldGreen.withAlpha(179),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  saveLocation,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: emeraldGreen.withAlpha(204),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildDialogButton(
                            icon: Icons.open_in_new,
                            label: AppLocalizations.of(context)?.pdfButtonOpen ?? 'Aç',
                            onTap: () async {
                              Get.back();
                              await _openPdf(filePath, context);
                            },
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogButton(
                            icon: Icons.share,
                            label: AppLocalizations.of(context)?.pdfButtonShare ?? 'Paylaş',
                            onTap: () async {
                              Get.back();
                              await _sharePdf(filePath, context);
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: _buildDialogButton(
                        icon: Icons.close,
                        label: AppLocalizations.of(context)?.pdfButtonClose ?? 'Kapat',
                        onTap: () => Get.back(),
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Dialog button builder
  Widget _buildDialogButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        overlayColor: WidgetStateProperty.all(goldColor.withAlpha(26)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(colors: [lightGold, goldColor])
                : null,
            color: isSecondary
                ? lightGold.withAlpha(77)
                : isPrimary
                ? null
                : goldColor.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary
                  ? emeraldGreen.withAlpha(77)
                  : goldColor.withAlpha(102),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: emeraldGreen, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: emeraldGreen,
                  fontSize: 13,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PDF'i aç
  Future<void> _openPdf(String filePath, BuildContext buildContext) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        if(buildContext.mounted) {
        IslamicSnackbar.showError(
          AppLocalizations.of(buildContext)?.pdfFileCannotOpen ?? 'Dosya Açılamadı',
          AppLocalizations.of(buildContext)?.pdfFileNotOpen ?? 'PDF dosyası açılamadı. PDF okuyucu uygulaması yüklü olduğundan emin olun.',
        );
        }
      }
    } catch (e) {
      if(buildContext.mounted) {
      IslamicSnackbar.showError(
        AppLocalizations.of(buildContext)?.statsError ?? 'Hata', 
        '${AppLocalizations.of(buildContext)?.statsPdfOpenError ?? 'PDF açılırken bir hata oluştu'}: $e'
      );
      }
    }
  }

  // PDF'i paylaş
  Future<void> _sharePdf(String filePath, BuildContext buildContext) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: AppLocalizations.of(buildContext)?.statsPdfShareText ?? 'Tasbee Pro İstatistik Raporum',
        subject: AppLocalizations.of(buildContext)?.statsPdfShareSubject ?? 'Tasbee Pro - İstatistik Raporu',
      );
    } catch (e) {
      if(buildContext.mounted) {
      IslamicSnackbar.showError(
        AppLocalizations.of(buildContext)?.statsError ?? 'Hata',
        '${AppLocalizations.of(buildContext)?.statsPdfShareError ?? 'PDF paylaşılırken bir hata oluştu'}: $e',
      );
      }
    }
  }

  // PDF için stat card builder
  pw.Widget _buildStatCard(
    String title,
    String value,
    String icon,
    pw.Font? regularFont,
    TextDirection textDirection,
    pw.Font? amiriFont,
    pw.Font? japaneseFont,
    pw.Font? koreanFont,
    pw.Font? chineseFont,
    pw.Font? thaiFont,
    pw.Font? bengaliFont,
    pw.Font? cyrillicFont,
  ) {
    // Font seçim fonksiyonu - dile göre uygun font döndürür
    pw.Font? selectFontForText(String text, {bool isBold = false}) {
      // Arapça karakterler kontrolü
      if (RegExp(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(text)) {
        return amiriFont ?? regularFont ?? pw.Font.helvetica();
      }
      
      // Bengalce karakterler kontrolü
      if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) {
        return (bengaliFont ?? regularFont ?? pw.Font.helvetica());
      }

      // Tayca karakterler kontrolü
      if (RegExp(r'[\u0E00-\u0E7F]').hasMatch(text)) {
        return (thaiFont ?? regularFont ?? pw.Font.helvetica());
      }
      
      // Çince karakterler kontrolü (Simplified Chinese)
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(text)) {
        return (chineseFont ?? regularFont ?? pw.Font.helvetica());
      }
      
      // Japonca karakterler kontrolü (Hiragana, Katakana)
      if (RegExp(r'[\u3040-\u309f\u30a0-\u30ff]').hasMatch(text)) {
        return  (japaneseFont ?? regularFont ?? pw.Font.helvetica());
      }
      
      // Korece karakterler kontrolü
      if (RegExp(r'[\uac00-\ud7af]').hasMatch(text)) {
        return  (koreanFont ?? regularFont ?? pw.Font.helvetica());
      }
      
      // Kiril alfabesi kontrolü (Rusça vb.)
      if (RegExp(r'[\u0400-\u04FF]').hasMatch(text)) {
        return  (cyrillicFont ?? regularFont ?? pw.Font.helvetica());
      }
      
      // Varsayılan Latin fontları
      if (textDirection == TextDirection.rtl) {
        return amiriFont ?? regularFont ?? pw.Font.helvetica();
      }
      
      return (regularFont ?? pw.Font.helvetica());
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [
            PdfColor.fromHex('#F5E6A8'), // light gold
            PdfColor.fromHex('#E8E0C7'), // lighter
          ],
        ),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromHex('#D4AF37'), width: 1),
      ),
      child: pw.Column(
        children: [
          pw.Text(icon, style: pw.TextStyle(fontSize: 24)),
          pw.SizedBox(height: 8),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#2D5016'),
              font: selectFontForText(value, isBold: true),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#2D5016'),
              font: selectFontForText(title),
            ),
          ),
        ],
      ),
    );
  }


}

class ChartData {
  final String label;
  final double y;

  ChartData({required this.label, required this.y});
}
