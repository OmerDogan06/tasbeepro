import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import '../constants/sura_names.dart';

class QuranReadingScreen extends StatefulWidget {
  final int? initialSura;

  const QuranReadingScreen({super.key, this.initialSura});

  @override
  State<QuranReadingScreen> createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen> {
  List<Map<String, dynamic>> quranData = [];
  List<Map<String, dynamic>> currentSuraAyahs = [];
  int currentSura = 1;
  bool isLoading = true;
  PageController pageController = PageController();
  ScrollController scrollController = ScrollController();
  ScrollController suraListScrollController = ScrollController();
  double ayahFontSize = 22.0; // Default font size

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  void initState() {
    super.initState();
    currentSura = widget.initialSura ?? 1;
    _loadQuranData();
  }

  @override
  void dispose() {
    pageController.dispose();
    scrollController.dispose();
    suraListScrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuranData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final String data = await rootBundle.loadString(
        'assets/qurans/quran-uthmani-min.txt',
      );
      final List<String> lines = data.split('\n');

      quranData.clear();
      for (String line in lines) {
        if (line.trim().isEmpty) continue;

        final parts = line.split('|');
        if (parts.length >= 3) {
          quranData.add({
            'sura': int.parse(parts[0]),
            'ayah': int.parse(parts[1]),
            'text': parts[2],
          });
        }
      }

      _loadCurrentSura();
    } catch (e) {
      debugPrint('Error loading Quran data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadCurrentSura() async {
    currentSuraAyahs = quranData
        .where((ayah) => ayah['sura'] == currentSura)
        .toList();
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      isLoading = false;
    });
  }

  void _goToPreviousSura() async {
    suraListScrollController.jumpTo(
      suraListScrollController.initialScrollOffset,
    );
    setState(() {
      isLoading = true;
    });
    if (currentSura > 1) {
      currentSura--;
      HapticFeedback.lightImpact();
    }
    await _loadCurrentSura();
  }

  void _goToNextSura() async {
    suraListScrollController.jumpTo(
      suraListScrollController.initialScrollOffset,
    );
    setState(() {
      isLoading = true;
    });
    if (currentSura < 114) {
      currentSura++;
      HapticFeedback.lightImpact();
    }
    await _loadCurrentSura();
  }

  void _showFontSizeDialog() {
    HapticFeedback.lightImpact();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
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
                padding: const EdgeInsets.all(8),
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
                        Icons.text_fields,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Font Boyutu',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: emeraldGreen),
                      style: IconButton.styleFrom(
                        backgroundColor: goldColor.withAlpha(51),
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

              // Font size slider
              Padding(
                padding: const EdgeInsets.all(8),
                child: StatefulBuilder(
                  builder: (context, setDialogState) {
                    return Column(
                      children: [
                        SizedBox(height: 8),
                        // Size label
                        Text(
                          'Font Boyutu: ${ayahFontSize.toInt()}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: emeraldGreen,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: goldColor,
                            inactiveTrackColor: goldColor.withAlpha(51),
                            thumbColor: goldColor,
                            overlayColor: goldColor.withAlpha(25),
                            valueIndicatorColor: goldColor,
                            trackHeight: 4.0,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10.0,
                            ),
                          ),
                          child: Slider(
                            value: ayahFontSize,
                            min: 16.0,
                            max: 36.0,
                            divisions: 20,
                            onChanged: (value) {
                              setDialogState(() {
                                ayahFontSize = value;
                              });
                              setState(() {});
                            },
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Min-Max labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Küçük (16)',
                              style: TextStyle(
                                fontSize: 12,
                                color: emeraldGreen.withAlpha(153),
                              ),
                            ),
                            Text(
                              'Büyük (36)',
                              style: TextStyle(
                                fontSize: 12,
                                color: emeraldGreen.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuraSelection() {
    HapticFeedback.lightImpact();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
                padding: const EdgeInsets.all(8),
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
                        Icons.menu_book,
                        color: emeraldGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sure Seçimi',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: emeraldGreen,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, color: emeraldGreen),
                      style: IconButton.styleFrom(
                        backgroundColor: goldColor.withAlpha(51),
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

              // Sura list
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: WidgetStateProperty.all(goldColor),
                      trackColor: WidgetStateProperty.all(goldColor),
                      trackBorderColor: WidgetStateProperty.all(goldColor),
                    ),
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: 114,
                        itemBuilder: (context, index) {
                          final suraNumber = index + 1;
                          final isSelected = suraNumber == currentSura;
                          final locale = Localizations.localeOf(
                            context,
                          ).languageCode;
                          final suraName = SuraNames.getSuraName(index, locale);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? goldColor.withAlpha(38)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? goldColor.withAlpha(128)
                                    : goldColor.withAlpha(51),
                                width: 1.5,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  setState(() {
                                    currentSura = suraNumber;
                                    _loadCurrentSura();
                                  });
                                  Get.back();
                                  HapticFeedback.selectionClick();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? const RadialGradient(
                                                  colors: [
                                                    lightGold,
                                                    goldColor,
                                                  ],
                                                )
                                              : RadialGradient(
                                                  colors: [
                                                    lightGold.withAlpha(77),
                                                    goldColor.withAlpha(77),
                                                  ],
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            suraNumber.toString(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? emeraldGreen
                                                  : emeraldGreen.withAlpha(153),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          suraName,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: isSelected
                                                ? emeraldGreen
                                                : emeraldGreen.withAlpha(179),
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons.check_circle,
                                          color: goldColor,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final suraName = SuraNames.getSuraName(currentSura - 1, locale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: const Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SafeArea(
            child: AppBar(
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
                      color: darkGreen.withAlpha(39),
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
              title: GestureDetector(
                onTap: _showSuraSelection,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightGold, goldColor],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: emeraldGreen.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_book,
                          color: emeraldGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$currentSura. $suraName',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: emeraldGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: emeraldGreen,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Container(
                  height: 40,
                  width: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [lightGold, goldColor],
                      center: Alignment(-0.2, -0.2),
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withAlpha(39),
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
                      Icons.text_fields,
                      color: emeraldGreen,
                      size: 20,
                    ),
                    onPressed: _showFontSizeDialog,
                  ),
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFFDF7), Color(0xFFF8F6F0)],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: goldColor))
            : currentSuraAyahs.isEmpty
            ? Center(
                child: Text(
                  'Veri bulunamadı',
                  style: const TextStyle(fontSize: 16, color: emeraldGreen),
                ),
              )
            : Column(
                children: [
                  // Navigation controls
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: goldColor.withAlpha(77),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: darkGreen.withAlpha(25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          // Previous button
                          _buildNavButton(
                            icon: Icons.chevron_left,
                            onTap: currentSura > 1 ? _goToPreviousSura : null,
                            tooltip: 'Önceki Sure',
                          ),

                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Ayet Sayısı: ${currentSuraAyahs.length}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: emeraldGreen,
                                    ),
                                  ),
                                  Text(
                                    '$currentSura / 114',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: emeraldGreen.withAlpha(153),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Next button
                          _buildNavButton(
                            icon: Icons.chevron_right,
                            onTap: currentSura < 114 ? _goToNextSura : null,
                            tooltip: 'Sonraki Sure',
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quran content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFFFDF7), Color(0xFFF5F3E8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: goldColor.withAlpha(77),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: darkGreen.withAlpha(25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: ScrollbarTheme(
                          data: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(goldColor),
                            trackColor: WidgetStateProperty.all(goldColor),
                            trackBorderColor: WidgetStateProperty.all(
                              goldColor,
                            ),
                          ),
                          child: Scrollbar(
                            thumbVisibility: true,
                            controller: suraListScrollController,
                            child: ListView.builder(
                              controller: suraListScrollController,
                              padding: const EdgeInsets.all(8),
                              itemCount: currentSuraAyahs.length,
                              itemBuilder: (context, index) {
                                final ayah = currentSuraAyahs[index];
                                return _buildAyahCard(ayah, index);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    final isEnabled = onTap != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isEnabled
                  ? const RadialGradient(colors: [lightGold, goldColor])
                  : RadialGradient(
                      colors: [
                        lightGold.withAlpha(51),
                        goldColor.withAlpha(51),
                      ],
                    ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled
                    ? emeraldGreen.withAlpha(77)
                    : emeraldGreen.withAlpha(25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isEnabled ? emeraldGreen : emeraldGreen.withAlpha(102),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard(Map<String, dynamic> ayah, int index) {
    // Responsive card sizing calculation
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 32; // Account for margins
    
    // Dynamic height based on text length and font size
    final textLength = ayah['text'].toString().length;
    final baseHeight = 120.0;
    final additionalHeight = (textLength / 50) * ayahFontSize * 0.8;
    final calculatedHeight = baseHeight + additionalHeight;
    final cardHeight = calculatedHeight.clamp(120.0, 400.0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CustomPaint(
        size: Size(cardWidth, cardHeight),
        painter: AyahCardPainter(
          ayahNumber: ayah['ayah'],
          isEvenCard: index % 2 == 0,
        ),
        child: SizedBox(
          width: cardWidth,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ayah number header with premium design
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      // Premium ayah number circle
                      SizedBox(width: 35),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFFD700), // Royal gold center
                              Color(0xFFF7E7CE), // Champagne gold
                              Color(0xFF0D4F3C), // Deep teal edge
                            ],
                            stops: [0.3, 0.7, 1.0],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD700),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkGreen.withAlpha(77),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFFFFD700).withAlpha(51),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            ayah['ayah'].toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D4F3C),
                              shadows: [
                                Shadow(
                                  color: Colors.white,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Decorative line
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withAlpha(200),
                                const Color(0xFFFFD700).withAlpha(100),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic text with enhanced styling
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    ayah['text'],
                    style: TextStyle(
                      fontSize: ayahFontSize,
                      height: 2.2,
                      color: const Color(0xFF0A2818), // Darker green for better contrast
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Amiri',
                      shadows: [
                        Shadow(
                          color: Colors.white.withAlpha(128),
                          offset: const Offset(0, 1),
                          blurRadius: 1,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AyahCardPainter extends CustomPainter {
  final int ayahNumber;
  final bool isEvenCard;


  AyahCardPainter({
    required this.ayahNumber,
    required this.isEvenCard,

  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final radius = 16.0;

    // Pro İslami renk paleti - Counter button ile aynı
    const royalGold = Color(0xFFFFD700);
    const champagneGold = Color(0xFFF7E7CE);
    const darkForest = Color(0xFF0A2818);

    // Outer shadow for depth
    final shadowPaint = Paint()
      ..color = darkForest.withAlpha(77)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    
    final shadowRect = RRect.fromRectAndRadius(
      rect.translate(0, 6),
      Radius.circular(radius),
    );
    canvas.drawRRect(shadowRect, shadowPaint);

    // Main card background with premium gradient
    final gradientColors = isEvenCard
        ? [
            const Color(0xFFFFFDF7), // Beyaz krem
            const Color(0xFFF8F6F0), // Açık krem
            const Color(0xFFF0E9D2), // Altın krem
            const Color(0xFFE8DCC0), // Daha koyu altın krem
          ]
        : [
            const Color(0xFFF8F6F0), // Açık krem
            const Color(0xFFF0E9D2), // Altın krem  
            const Color(0xFFE8DCC0), // Koyu altın krem
            const Color(0xFFE0D4B8), // En koyu krem
          ];

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
      stops: const [0.0, 0.3, 0.7, 1.0],
    );

    final cardPaint = Paint()
      ..shader = gradient.createShader(rect);

    final cardRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(cardRect, cardPaint);

    // İslami geometrik desenler
    _drawIslamicCardPattern(canvas, size);

    // Premium border
    final borderPaint = Paint()
      ..color = royalGold.withAlpha(isEvenCard ? 179 : 128)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(cardRect, borderPaint);

    // Inner subtle border
    final innerBorderPaint = Paint()
      ..color = champagneGold.withAlpha(102)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final innerRect = RRect.fromRectAndRadius(
      rect.deflate(4),
      Radius.circular(radius - 2),
    );
    canvas.drawRRect(innerRect, innerBorderPaint);

    // Corner decorative elements
    _drawCornerDecorations(canvas, size);
  }

  void _drawIslamicCardPattern(Canvas canvas, Size size) {

    const royalGold = Color(0xFFFFD700);
    
    final center = Offset(size.width / 2, size.height / 2);
    
    // Subtle radial lines from corners
    final linePaint = Paint()
      ..color = const Color.fromARGB(255, 216, 187, 143)
      ..strokeWidth = 1;

    // Top-left corner lines
    for (int i = 0; i < 6; i++) {
      final angle = (i * 15.0) * (math.pi / 180); // Convert to radians
      final startX = 20.0;
      final startY = 20.0;
      final endX = startX + 20 * math.cos(angle);
      final endY = startY + 20 * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }

    // Bottom-right corner lines
    for (int i = 0; i < 6; i++) {
      final angle = (180 + i * 15.0) * (math.pi / 180);
      final startX = size.width - 20.0;
      final startY = size.height - 20.0;
      final endX = startX + 20 * math.cos(angle);
      final endY = startY + 20 * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        linePaint,
      );
    }

    // Central geometric pattern
    final patternPaint = Paint()
      ..color = royalGold.withAlpha(25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        i * 15.0,
        patternPaint,
      );
    }

    // Geometric diamond in center
    final diamondPath = Path();
    final diamondSize = 8.0;
    diamondPath.moveTo(center.dx, center.dy - diamondSize);
    diamondPath.lineTo(center.dx + diamondSize, center.dy);
    diamondPath.lineTo(center.dx, center.dy + diamondSize);
    diamondPath.lineTo(center.dx - diamondSize, center.dy);
    diamondPath.close();

    final diamondPaint = Paint()
      ..color = royalGold.withAlpha(40)
      ..style = PaintingStyle.fill;

    canvas.drawPath(diamondPath, diamondPaint);
  }

  void _drawCornerDecorations(Canvas canvas, Size size) {

    // Corner arc decorations
    final cornerPaint = Paint()
      ..color = const Color.fromARGB(255, 156, 152, 132)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Top-left corner arc
    canvas.drawArc(
      Rect.fromLTWH(8, 8, 24, 24),
      math.pi, // π (180 degrees)
      math.pi / 2, // π/2 (90 degrees)
      false,
      cornerPaint,
    );

    // Bottom-right corner arc
    canvas.drawArc(
      Rect.fromLTWH(size.width - 32, size.height - 32, 24, 24),
      0, // 0 degrees
      math.pi / 2, // π/2 (90 degrees)
      false,
      cornerPaint,
    );

    // Small decorative dots
    final dotPaint = Paint()
      ..color = const Color.fromARGB(255, 138, 135, 113)
      ..style = PaintingStyle.fill;

    // Top-right dots
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width - 16 - (i * 8), 16),
        1.5,
        dotPaint,
      );
    }

    // Bottom-left dots
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(16 + (i * 8), size.height - 16),
        1.5,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(AyahCardPainter oldDelegate) {
    return oldDelegate.ayahNumber != ayahNumber ||
           oldDelegate.isEvenCard != isEvenCard;
            
  }
}


