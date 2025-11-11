import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
      print('Error loading Quran data: $e');
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goldColor.withAlpha(51), width: 1),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah number header
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [lightGold, goldColor],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ayah['ayah'].toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Arabic text
            Text(
              ayah['text'],
              style: TextStyle(
                fontSize: ayahFontSize,
                height: 2.0,
                color: emeraldGreen,
                fontWeight: FontWeight.w500,
                fontFamily: 'Amiri',
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
