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
import '../controllers/widget_stats_controller.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';

class WidgetStatsScreen extends StatefulWidget {
  const WidgetStatsScreen({super.key});

  @override
  State<WidgetStatsScreen> createState() => _WidgetStatsScreenState();
}

class _WidgetStatsScreenState extends State<WidgetStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isExportingPDF = false;

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
    final controller = Get.find<WidgetStatsController>();
    TextDirection textDirection = Directionality.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(104),
          child: SafeArea(
            child: AppBar(
              title: Text(
                AppLocalizations.of(context)?.widgetStatsTitle ??
                    'Widget İstatistikleri 📱',
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
                  icon: const Icon(
                    Icons.arrow_back,
                    color: emeraldGreen,
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                // PDF Export Button
                Container(
                  width: 40,
                  height: 40,
                  margin: textDirection == TextDirection.ltr
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
                    onPressed: _isExportingPDF
                        ? null
                        : () {
                            String currentPeriod;
                            switch (_tabController.index) {
                              case 0:
                                currentPeriod =
                                    AppLocalizations.of(context)?.statsDaily ??
                                    'Günlük';
                                break;
                              case 1:
                                currentPeriod =
                                    AppLocalizations.of(context)?.statsWeekly ??
                                    'Haftalık';
                                break;
                              case 2:
                                currentPeriod =
                                    AppLocalizations.of(
                                      context,
                                    )?.statsMonthly ??
                                    'Aylık';
                                break;
                              case 3:
                                currentPeriod =
                                    AppLocalizations.of(context)?.statsYearly ??
                                    'Yıllık';
                                break;
                              default:
                                currentPeriod =
                                    AppLocalizations.of(context)?.statsDaily ??
                                    'Günlük';
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
                  Tab(
                    text: AppLocalizations.of(context)?.statsDaily ?? 'Günlük',
                  ),
                  Tab(
                    text:
                        AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık',
                  ),
                  Tab(
                    text: AppLocalizations.of(context)?.statsMonthly ?? 'Aylık',
                  ),
                  Tab(
                    text: AppLocalizations.of(context)?.statsYearly ?? 'Yıllık',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPeriodStats(
                AppLocalizations.of(context)?.statsDaily ?? 'Günlük',
                controller,
              ),
              _buildPeriodStats(
                AppLocalizations.of(context)?.statsWeekly ?? 'Haftalık',
                controller,
              ),
              _buildPeriodStats(
                AppLocalizations.of(context)?.statsMonthly ?? 'Aylık',
                controller,
              ),
              _buildPeriodStats(
                AppLocalizations.of(context)?.statsYearly ?? 'Yıllık',
                controller,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodStats(String period, WidgetStatsController controller) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getWidgetStatsForPeriod(period),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: emeraldGreen.withAlpha(128)),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Bilgi Kartı - Widget'a özel açıklama
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
      },
    );
  }

  Widget _buildPeriodInfoCard(String period) {
    String info;
    String emoji;

    // Convert English period names to Turkish for info lookup
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
        info =
            AppLocalizations.of(context)?.widgetStatsDailyInfo ??
            'Bugün widget\'tan yapılan zikirlerinizin detayları';
        emoji = '📱';
        break;
      case 'Haftalık':
        info =
            AppLocalizations.of(context)?.widgetStatsWeeklyInfo ??
            'Bu hafta widget\'tan yapılan zikirlerinizin detayları';
        emoji = '📊';
        break;
      case 'Aylık':
        info =
            AppLocalizations.of(context)?.widgetStatsMonthlyInfo ??
            'Bu ay widget\'tan yapılan zikirlerinizin detayları';
        emoji = '📈';
        break;
      case 'Yıllık':
        info =
            AppLocalizations.of(context)?.widgetStatsYearlyInfo ??
            'Bu yıl widget\'tan yapılan zikirlerinizin detayları';
        emoji = '🏆';
        break;
      default:
        info =
            AppLocalizations.of(context)?.widgetStatsTitle ??
            'Widget İstatistikleri';
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
            alignment: Alignment.center,
            width: 40,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(77),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)?.statsPeriodStatsFor(period) ??
                      '$period İstatistikler',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: emeraldGreen,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  info,
                  style: TextStyle(
                    color: emeraldGreen.withAlpha(179),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String period, WidgetStatsController controller) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getWidgetStatsForPeriod(period),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: goldColor.withAlpha(77), width: 1.5),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(emeraldGreen),
              ),
            ),
          );
        }

        final stats = snapshot.data ?? {};

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
                color: darkGreen.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                AppLocalizations.of(context)?.statsPeriodStatsFor(period) ??
                    '$period İstatistikler',
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
                      AppLocalizations.of(context)?.widgetStatsTotal ??
                          'Toplam Zikir',
                      stats['totalCount']?.toString() ?? '0',
                      Icons.auto_awesome,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)?.widgetStatsActive ??
                          'Aktif Zikir',
                      stats['activeZikrs']?.toString() ?? '0',
                      Icons.bookmark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)?.widgetStatsMostUsed ??
                          'En Çok Yapılan',
                      stats['mostUsed']?.toString() ?? '',
                      Icons.star,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      AppLocalizations.of(context)?.widgetStatsTotalRecords ??
                          'Toplam Kayıt',
                      stats['records']?.toString() ?? '0',
                      Icons.storage,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
            value.length > 12 ? '${value.substring(0, 10)}...' : value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: emeraldGreen.withAlpha(179)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String period, WidgetStatsController controller) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getChartDataForPeriod(period),
      builder: (context, snapshot) {
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
                color: darkGreen.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                '$period ${AppLocalizations.of(context)?.widgetStatsDistribution ?? 'Widget Zikir Dağılımı'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                ),
              ),
              const SizedBox(height: 20),
              snapshot.connectionState == ConnectionState.waiting
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(emeraldGreen),
                      ),
                    )
                  : (snapshot.data?.isEmpty ?? true)
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
                            AppLocalizations.of(context)?.widgetStatsNoData ??
                                'Henüz $period widget verisi yok',
                            style: TextStyle(
                              color: emeraldGreen.withAlpha(179),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildChart(snapshot.data!),
            ],
          ),
        );
      },
    );
  }

  Widget _buildZikrList(String period, WidgetStatsController controller) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: controller.getChartDataForPeriod(period),
      builder: (context, snapshot) {
        final chartData = snapshot.data ?? [];

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
                color: darkGreen.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$period ${AppLocalizations.of(context)?.widgetStatsDetails ?? 'Widget Zikir Detayları'}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: emeraldGreen,
                ),
              ),
              const SizedBox(height: 10),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(emeraldGreen),
                  ),
                )
              else if (chartData.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: lightGold.withAlpha(77),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.widgets,
                        size: 25,
                        color: emeraldGreen.withAlpha(128),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.widgetStatsNoZikr ??
                            'Henüz widget\'tan $period zikir yapılmamış',
                        style: TextStyle(
                          color: emeraldGreen.withAlpha(179),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...chartData.map((data) {
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
                              center: Alignment(-0.2, -0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.widgets,
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
                                data['zikrName'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: emeraldGreen,
                                  fontSize: 14,
                                ),
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
                            data['count']?.toString() ?? '0',
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
      },
    );
  }

  Future<void> _exportToPDF(String period, BuildContext buildContext) async {
    // Loading state'ini başlat
    setState(() {
      _isExportingPDF = true;
    });

    try {
      final controller = Get.find<WidgetStatsController>();

      final moonBytes = await rootBundle.load('assets/image/islam.png');
      final moonImage = pw.MemoryImage(moonBytes.buffer.asUint8List());
      final pdf = pw.Document();

      // Unicode destekli Poppins fontunu yükle
      pw.Font? regularFont;
      pw.Font? boldFont;
      pw.Font? amiriFont;

      try {
        final regularFontData = await rootBundle.load(
          'assets/fonts/Poppins-Regular.ttf',
        );
        regularFont = pw.Font.ttf(regularFontData);

        final boldFontData = await rootBundle.load(
          'assets/fonts/Poppins-Bold.ttf',
        );
        boldFont = pw.Font.ttf(boldFontData);

        final amiriFontData = await rootBundle.load(
          'assets/fonts/Amiri-Regular.ttf',
        );
        amiriFont = pw.Font.ttf(amiriFontData);
      } catch (fontError) {
        debugPrint('Font yüklenemedi: $fontError');
        // Font yüklenemezse varsayılan font kullanılacak
      }

      // Widget istatistiklerini al
      final stats = await controller.getWidgetStatsForPeriod(period);

      // PDF sayfası oluştur
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(16),
          build: (pw.Context context) {
            final totalCount = stats['totalCount'] ?? 0;
            final activeZikrs = stats['activeZikrs'] ?? 0;
            final mostUsed = stats['mostUsed'] ?? 'Yok';
            final now = DateTime.now();

            TextDirection textDirection = Directionality.of(buildContext);

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
                              AppLocalizations.of(buildContext)?.pdfBismillah ??
                                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
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
                            width: 75,
                            height: 75,
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
                       '${AppLocalizations.of(
                              buildContext,
                            )?.pdfWidgetReportTitle ??
                            'Tasbee Pro - Widget İstatistik Raporu'} ($period)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          font:textDirection == TextDirection.ltr ? boldFont : amiriFont,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '${AppLocalizations.of(buildContext)?.pdfPeriodLabel ?? 'Dönem'}: $period - ${AppLocalizations.of(buildContext)?.pdfDateLabel ?? 'Tarih'}: ${now.day}/${now.month}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColor.fromHex('#F5E6A8'),
                          font: textDirection == TextDirection.ltr ? regularFont : amiriFont,
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
                        AppLocalizations.of(
                              buildContext,
                            )?.pdfWidgetTotalZikrCard ??
                            'Toplam Widget Zikir',
                        totalCount.toString(),
                        'O',
                        regularFont,
                        boldFont,
                        amiriFont,
                        textDirection
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildStatCard(
                        AppLocalizations.of(
                              buildContext,
                            )?.pdfWidgetMostUsedCard ??
                            'En Çok Kullanılan',
                        mostUsed.toString(),
                        '*',
                        regularFont,
                        boldFont,
                          amiriFont,
                        textDirection
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Expanded(
                      child: _buildStatCard(
                        AppLocalizations.of(
                              buildContext,
                            )?.pdfWidgetActiveTypesCard ??
                            'Aktif Zikir Türü',
                        activeZikrs.toString(),
                        '#',
                        regularFont,
                        boldFont,
                          amiriFont,
                        textDirection
                      ),
                    ),
                  ],
                ),

                pw.SizedBox(height: 16),

                // Widget Zikir Detayları
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
                        '>> $period ${AppLocalizations.of(buildContext)?.pdfWidgetStatsSection ?? 'Döneminde Kullanılan Widget Zikirler'}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2D5016'),
                          font: textDirection == TextDirection.ltr ? boldFont : amiriFont,
                        ),
                      ),
                      pw.SizedBox(height: 12),

                      if (totalCount > 0) ...[
                        pw.Text(
                          AppLocalizations.of(
                                buildContext,
                              )?.pdfWidgetPeriodText(totalCount) ??
                              'Bu dönemde widget üzerinden toplam $totalCount zikir çekilmiştir.',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#2D5016'),
                            font: textDirection == TextDirection.ltr ? regularFont : amiriFont,
                          ),
                        ),
                        if (activeZikrs > 0) ...[
                          pw.SizedBox(height: 8),
                          pw.Text(
                            AppLocalizations.of(
                                  buildContext,
                                )?.pdfWidgetTypesText(activeZikrs) ??
                                'Toplam $activeZikrs farklı zikir türü kullanılmıştır.',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex('#2D5016'),
                              font:textDirection == TextDirection.ltr ? regularFont : amiriFont,
                            ),
                          ),
                        ],
                        if (mostUsed != 'Yok') ...[
                          pw.SizedBox(height: 8),
                          pw.Text(
                            AppLocalizations.of(
                                  buildContext,
                                )?.pdfWidgetMostUsedText(mostUsed) ??
                                'En çok kullanılan zikir: $mostUsed',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex('#2D5016'),
                              font: textDirection == TextDirection.ltr ? regularFont : amiriFont,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ] else ...[
                        pw.Text(
                          AppLocalizations.of(
                                buildContext,
                              )?.pdfWidgetNoZikrText ??
                              'Bu dönemde henüz widget üzerinden zikir çekilmemiştir.',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColor.fromHex('#2D5016'),
                            font:textDirection == TextDirection.ltr ? regularFont : amiriFont,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // Widget özelliği açıklama
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#F0E9D2'),
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
                        AppLocalizations.of(buildContext)?.pdfWidgetInfoTitle ??
                            'Widget Hakkında',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#2D5016'),
                          font:textDirection == TextDirection.ltr ? boldFont : amiriFont,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        AppLocalizations.of(buildContext)?.pdfWidgetInfoText ??
                            'Widget üzerinden yapılan zikirler kalıcı olarak kaydedilir ve asla silinmez. Bu sayede widget zikirlerinizin geçmişini takip edebilirsiniz.',
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColor.fromHex('#2D5016'),
                          font:textDirection == TextDirection.ltr ? regularFont : amiriFont,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 16),

                // İslami alt bilgi
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
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
                          AppLocalizations.of(buildContext)?.pdfQuranVerse ??
                              'وَاذْكُرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ',
                          textAlign: pw.TextAlign.center,
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                            fontSize: 12,
                            font: amiriFont,
                            color: PdfColor.fromHex('#FFFFFF'),
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        AppLocalizations.of(
                              buildContext,
                            )?.pdfQuranTranslation ??
                            '"Allah\'ı çok zikredin ki kurtulursunuz." (Enfal: 45)',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(fontSize: 10, font:textDirection == TextDirection.ltr ? regularFont : amiriFont,),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        AppLocalizations.of(buildContext)?.pdfAppCredit ??
                            'Bu rapor Tasbee Pro uygulaması tarafından oluşturulmuştur.',
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColor.fromHex('#2D5016'),
                          font:textDirection == TextDirection.ltr ? regularFont : amiriFont,
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
          if (!buildContext.mounted)
            return; // ✅ widget hala yaşıyor mu kontrol et
          saveLocation =
              AppLocalizations.of(buildContext)?.pdfMainStoragePath ??
              "Ana depolama/TasbeePro";

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
          if (!buildContext.mounted)
            return; // ✅ widget hala yaşıyor mu kontrol et
          saveLocation =
              AppLocalizations.of(buildContext)?.pdfAppSpecificPath ??
              "Uygulamaya özel klasör/TasbeePro_Reports";

          if (!await saveDir.exists()) {
            await saveDir.create(recursive: true);
          }
        } else {
          // Son fallback - Documents directory
          saveDir = await getApplicationDocumentsDirectory();
          if (!buildContext.mounted)
            return; // ✅ widget hala yaşıyor mu kontrol et
          saveLocation =
              AppLocalizations.of(buildContext)?.pdfDocumentsPath ??
              "Uygulama belgeler klasörü";
        }
      }

      final fileName =
          'Tasbee_Pro_Widget_Istatistik_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}_${DateTime.now().hour}_${DateTime.now().minute}.pdf';
      final file = File('${saveDir.path}/$fileName');

      try {
        await file.writeAsBytes(await pdf.save());

        // PDF başarıyla kaydedildikten sonra kullanıcıya seçenekler sun
        await _showPdfOptionsDialog(file.path, fileName, saveLocation);
      } catch (pdfError) {
        debugPrint('PDF kaydetme hatası: $pdfError');
        if (!buildContext.mounted)
          return; // ✅ widget hala yaşıyor mu kontrol et
        IslamicSnackbar.showError(
          AppLocalizations.of(buildContext)?.statsPdfError ?? 'PDF Hatası',
          '${AppLocalizations.of(buildContext)?.statsPdfSaveError ?? 'PDF kaydedilemedi'}: $pdfError',
        );
      }
    } catch (e) {
      if (!buildContext.mounted) return; // ✅ widget hala yaşıyor mu kontrol et
      IslamicSnackbar.showError(
        AppLocalizations.of(buildContext)?.statsError ?? 'Hata',
        '${AppLocalizations.of(buildContext)?.statsPdfCreateError ?? 'PDF oluşturulurken bir hata oluştu'}: $e',
      );
    } finally {
      // Loading state'ini sonlandır
      setState(() {
        _isExportingPDF = false;
      });
    }
  }

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
                        AppLocalizations.of(context)?.pdfSuccessTitle ??
                            'PDF Başarıyla Oluşturuldu! 📄',
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
                            label:
                                AppLocalizations.of(context)?.pdfButtonOpen ??
                                'Aç',
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
                            label:
                                AppLocalizations.of(context)?.pdfButtonShare ??
                                'Paylaş',
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
                        label:
                            AppLocalizations.of(context)?.pdfButtonClose ??
                            'Kapat',
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
        if (!buildContext.mounted)
          return; // ✅ widget hala yaşıyor mu kontrol et
        IslamicSnackbar.showError(
          AppLocalizations.of(buildContext)?.pdfFileCannotOpen ??
              'Dosya Açılamadı',
          AppLocalizations.of(buildContext)?.pdfFileNotOpen ??
              'PDF dosyası açılamadı. PDF okuyucu uygulaması yüklü olduğundan emin olun.',
        );
      }
    } catch (e) {
      if (!buildContext.mounted) return; // ✅ widget hala yaşıyor mu kontrol et
      IslamicSnackbar.showError(
        AppLocalizations.of(buildContext)?.statsError ?? 'Hata',
        '${AppLocalizations.of(buildContext)?.statsPdfOpenError ?? 'PDF açılırken bir hata oluştu'}: $e',
      );
    }
  }

  // PDF'i paylaş
  Future<void> _sharePdf(String filePath, BuildContext buildContext) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text:
            AppLocalizations.of(buildContext)?.statsPdfShareText ??
            'Tasbee Pro Widget İstatistik Raporum',
        subject:
            AppLocalizations.of(buildContext)?.statsPdfShareSubject ??
            'Tasbee Pro - Widget İstatistik Raporu',
      );
    } catch (e) {
      if (!buildContext.mounted) return; // ✅ widget hala yaşıyor mu kontrol et
      IslamicSnackbar.showError(
        AppLocalizations.of(buildContext)?.statsError ?? 'Hata',
        '${AppLocalizations.of(buildContext)?.statsPdfShareError ?? 'PDF paylaşılırken bir hata oluştu'}: $e',
      );
    }
  }

  // PDF için stat card builder
  pw.Widget _buildStatCard(
    String title,
    String value,
    String icon,
    pw.Font? regularFont,
    pw.Font? boldFont,
    pw.Font? amiriFont,
    TextDirection textDirection,
  ) {
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
              font: textDirection == TextDirection.ltr ? boldFont : amiriFont,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#2D5016'),
              font:textDirection == TextDirection.ltr ? regularFont : amiriFont,
            ),
          ),
        ],
      ),
    );
  }

  // Chart build methods
  Widget _buildChart(List<Map<String, dynamic>> data) {
    final chartData = _convertToChartData(data);

    return Column(
      children: [
        // Pie Chart
        SizedBox(
          height: 325,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 95,
              sections: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return PieChartSectionData(
                  color: _getChartColor(index),
                  value: data.y,
                  title: '${data.y.toInt()}',
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
                );
              }).toList(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  // Touch işlemleri
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: chartData.length,
          itemBuilder: (context, index) {
            final data = chartData[index];
            final total = chartData.fold<double>(
              0,
              (sum, item) => sum + item.y,
            );
            final percentage = total > 0 ? (data.y / total * 100) : 0;

            return Container(
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
          },
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  List<ChartData> _convertToChartData(List<Map<String, dynamic>> data) {
    final List<ChartData> chartData = [];

    // Sadece count > 0 olan zikirler
    final activeData = data.where((item) => (item['count'] ?? 0) > 0).toList();

    // Count'a göre sırala (büyükten küçüğe)
    activeData.sort((a, b) => (b['count'] ?? 0).compareTo(a['count'] ?? 0));

    for (final item in activeData) {
      chartData.add(
        ChartData(
          label: item['zikrName'] ?? '',
          y: (item['count'] ?? 0).toDouble(),
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
}

class ChartData {
  final String label;
  final double y;

  ChartData({required this.label, required this.y});
}
