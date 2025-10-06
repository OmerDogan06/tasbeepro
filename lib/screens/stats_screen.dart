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

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExportingPDF = false; // PDF export loading state
  
  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2D5016),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: AppBar(
          title: const Text(
            'Detaylı İstatistikler 💎',
            style: TextStyle(
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
                  color: darkGreen.withOpacity(0.15),
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
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  colors: [lightGold, goldColor],
                  center: Alignment(-0.2, -0.2),
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: darkGreen.withOpacity(0.15),
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
                  : const Icon(Icons.picture_as_pdf, color: emeraldGreen, size: 20),
                onPressed: _isExportingPDF ? null : () => _exportToPDF(),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: emeraldGreen,
            unselectedLabelColor: emeraldGreen.withOpacity(0.6),
            indicatorColor: goldColor,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
            tabs: const [
              Tab(text: 'Günlük'),
              Tab(text: 'Haftalık'),
              Tab(text: 'Aylık'),
              Tab(text: 'Yıllık'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPeriodStats('Günlük', controller),
            _buildPeriodStats('Haftalık', controller),
            _buildPeriodStats('Aylık', controller),
            _buildPeriodStats('Yıllık', controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodStats(String period, CounterController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Özet Kartı
          _buildSummaryCard(period, controller),
          const SizedBox(height: 20),
          
          // Grafik Kartı
          _buildChartCard(period, controller),
          const SizedBox(height: 20),
          
          // Zikir Listesi
          _buildZikrList(period, controller),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String period, CounterController controller) {
    final stats = _calculatePeriodStats(period, controller);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$period İstatistikler',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Toplam Zikir',
                  '${stats['totalCount']}',
                  Icons.numbers,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'En Çok Çekilen',
                  stats['mostUsed'] ?? 'Yok',
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
                  'Aktif Zikir',
                  '${stats['activeZikrs']}',
                  Icons.list,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Ortalama',
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightGold.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: emeraldGreen, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: emeraldGreen.withOpacity(0.7),
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
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$period Zikir Grafiği',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: chartData.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 48,
                          color: emeraldGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Henüz $period veri yok',
                          style: TextStyle(
                            color: emeraldGreen.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 10,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => emeraldGreen.withOpacity(0.9),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() >= 0 && value.toInt() < chartData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    chartData[value.toInt()].label,
                                    style: TextStyle(
                                      color: emeraldGreen.withOpacity(0.8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: emeraldGreen.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: chartData.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.y,
                              color: goldColor,
                              width: 16,
                              borderRadius: BorderRadius.circular(4),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [goldColor, lightGold],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildZikrList(String period, CounterController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: goldColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$period Zikir Detayları',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.getAllZikrs().map((zikr) {
            final count = controller.getZikrCount(zikr.id);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: goldColor.withOpacity(0.2)),
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
                              color: emeraldGreen.withOpacity(0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [goldColor, lightGold],
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      count.toString(),
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
          }).toList(),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculatePeriodStats(String period, CounterController controller) {
    final allZikrs = controller.getAllZikrs();
    double totalCount = 0;
    int activeZikrs = 0;
    String? mostUsed;
    double mostUsedCount = 0;

    for (final zikr in allZikrs) {
      final count = controller.getZikrCount(zikr.id);
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
      'totalCount': totalCount.round(),
      'activeZikrs': activeZikrs,
      'mostUsed': mostUsed,
      'average': average,
    };
  }

  List<ChartData> _getChartData(String period, CounterController controller) {
    final allZikrs = controller.getAllZikrs();
    final List<ChartData> chartData = [];

    for (int i = 0; i < allZikrs.length && i < 8; i++) {
      final zikr = allZikrs[i];
      final count = controller.getZikrCount(zikr.id);
      if (count > 0) {
        chartData.add(ChartData(
          label: zikr.name.length > 8 
              ? '${zikr.name.substring(0, 8)}...' 
              : zikr.name,
          y: count.toDouble(),
        ));
      }
    }

    return chartData;
  }

  Future<void> _exportToPDF() async {
    // Loading state'ini başlat
    setState(() {
      _isExportingPDF = true;
    });

    try {
      final controller = Get.find<CounterController>();
      final pdf = pw.Document();

      // Unicode destekli Poppins fontunu yükle
      pw.Font? regularFont;
      pw.Font? boldFont;
      
      try {
        final regularFontData = await rootBundle.load('assets/fonts/Poppins-Regular.ttf');
        regularFont = pw.Font.ttf(regularFontData);
        
        final boldFontData = await rootBundle.load('assets/fonts/Poppins-Bold.ttf');
        boldFont = pw.Font.ttf(boldFontData);
      } catch (fontError) {
        print('Font yüklenemedi: $fontError');
        // Font yüklenemezse varsayılan font kullanılacak
      }

      // PDF sayfası oluştur
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Başlık
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Tasbee Pro - İstatistik Raporu',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          font: boldFont,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Tarih: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: pw.TextStyle(fontSize: 14, font: regularFont),
                      ),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 30),
                
                // Özet istatistikler
                pw.Text(
                  'Genel İstatistikler',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                  ),
                ),
                
                pw.SizedBox(height: 15),

                // İstatistik özeti
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Toplam istatistikler hesapla
                      pw.Builder(builder: (context) {
                        final allZikrs = controller.getAllZikrs();
                        final totalCount = allZikrs.fold<int>(0, (sum, zikr) => sum + controller.getZikrCount(zikr.id).toInt());
                        final activeZikrs = allZikrs.where((zikr) => controller.getZikrCount(zikr.id) > 0).length;
                        final now = DateTime.now();
                        final firstDate = DateTime(2024, 1, 1); // Varsayılan başlangıç tarihi
                        final daysSinceStart = now.difference(firstDate).inDays + 1;
                        final dailyAverage = (totalCount / daysSinceStart).toStringAsFixed(1);

                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Toplam Zikir: $totalCount',
                              style: pw.TextStyle(font: regularFont, fontSize: 12),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Günlük Ortalama: $dailyAverage',
                              style: pw.TextStyle(font: regularFont, fontSize: 12),
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Aktif Zikir Türleri: $activeZikrs/${allZikrs.length}',
                              style: pw.TextStyle(font: regularFont, fontSize: 12),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                
                pw.SizedBox(height: 20),
                
                // Tablo
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    // Başlık satırı
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.green50),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Zikir Adı',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Sayı',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Durum',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              font: boldFont,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    // Veri satırları
                    ...controller.getAllZikrs().map((zikr) {
                      final count = controller.getZikrCount(zikr.id);
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              zikr.name,
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              count.toString(),
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              count > 0 ? 'Aktif' : 'Kullanılmadı',
                              style: pw.TextStyle(font: regularFont),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                
                // Alt bilgi
                pw.Text(
                  'Bu rapor Tasbee Pro uygulaması tarafından otomatik oluşturulmuştur.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontStyle: pw.FontStyle.italic,
                    font: regularFont,
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
          saveLocation = "Ana depolama/TasbeePro";
          
          // Klasör yoksa oluştur
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } else {
          throw Exception('External storage not available');
        }
        
      } catch (e) {
        // Fallback - App-specific external directory
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          saveDir = Directory('${externalDir.path}/TasbeePro_Reports');
          saveLocation = "Uygulamaya özel klasör/TasbeePro_Reports";
          
          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } else {
          // Son fallback - Documents directory
          saveDir = await getApplicationDocumentsDirectory();
          saveLocation = "Uygulama belgeler klasörü";
        }
      }
      
      final fileName = 'Tasbee_Pro_Istatistik_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}.pdf';
      final file = File('${saveDir.path}/$fileName');
      
      try {
        await file.writeAsBytes(await pdf.save());
        
        // PDF başarıyla kaydedildikten sonra kullanıcıya seçenekler sun
        await _showPdfOptionsDialog(file.path, fileName, saveLocation);
        
      } catch (pdfError) {
        print('PDF kaydetme hatası: $pdfError');
        IslamicSnackbar.showError(
          'PDF Hatası',
          'PDF kaydedilemedi: $pdfError',
        );
      }
    } catch (e) {
      IslamicSnackbar.showError(
        'Hata',
        'PDF oluşturulurken bir hata oluştu: $e',
      );
    } finally {
      // Loading state'ini sonlandır
      setState(() {
        _isExportingPDF = false;
      });
    }
  }

  // Depolama izni kontrolü ve isteği


  // PDF seçenekleri dialog'u
  Future<void> _showPdfOptionsDialog(String filePath, String fileName, String saveLocation) async {
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
            border: Border.all(
              color: goldColor.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withOpacity(0.2),
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
                    const Expanded(
                      child: Text(
                        'PDF Başarıyla Oluşturuldu! 📄',
                        style: TextStyle(
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
                      goldColor.withOpacity(0.3),
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
                        color: lightGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: goldColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, 
                                color: emeraldGreen, size: 16),
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
                              Icon(Icons.folder, 
                                color: emeraldGreen.withOpacity(0.7), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  saveLocation,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: emeraldGreen.withOpacity(0.8),
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
                            label: 'Aç',
                            onTap: () async {
                              Get.back();
                              await _openPdf(filePath);
                            },
                            isPrimary: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDialogButton(
                            icon: Icons.share,
                            label: 'Paylaş',
                            onTap: () async {
                              Get.back();
                              await _sharePdf(filePath);
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
                        label: 'Kapat',
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
        overlayColor: WidgetStateProperty.all(goldColor.withOpacity(0.1)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            gradient: isPrimary 
              ? const LinearGradient(
                  colors: [lightGold, goldColor],
                )
              : null,
            color: isSecondary 
              ? lightGold.withOpacity(0.3) 
              : isPrimary ? null : goldColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isPrimary 
                ? emeraldGreen.withOpacity(0.3)
                : goldColor.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                color: emeraldGreen, 
                size: 16,
              ),
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
  Future<void> _openPdf(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        IslamicSnackbar.showError(
          'Dosya Açılamadı',
          'PDF dosyası açılamadı. PDF okuyucu uygulaması yüklü olduğundan emin olun.',
        );
      }
    } catch (e) {
      IslamicSnackbar.showError(
        'Hata',
        'PDF açılırken bir hata oluştu: $e',
      );
    }
  }

  // PDF'i paylaş
  Future<void> _sharePdf(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Tasbee Pro İstatistik Raporum',
        subject: 'Tasbee Pro - İstatistik Raporu',
      );
    } catch (e) {
      IslamicSnackbar.showError(
        'Hata',
        'PDF paylaşılırken bir hata oluştu: $e',
      );
    }
  }
}

class ChartData {
  final String label;
  final double y;

  ChartData({required this.label, required this.y});
}