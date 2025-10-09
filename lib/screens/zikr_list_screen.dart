import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../widgets/zikr_card.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'add_custom_zikr_screen.dart';

class ZikrListScreen extends StatelessWidget {
  const ZikrListScreen({super.key});

  // İslami renk paleti - home_screen ile aynı
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
             
      systemNavigationBarColor: Color(0xFF2D5016),
      systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0), // Açık krem arka plan
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)?.zikirListTitle ?? 'Zikir Seç',
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
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık bölümü - İslami tasarım
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D5016), Color(0xFF1A3409)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
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
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)?.zikirListProSelection ?? 'Pro Zikir Seçimi',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: lightGold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)?.zikirListDescription ?? 'Geniş zikir koleksiyonu ve özel zikir oluşturma',
                        style: const TextStyle(
                          color: lightGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Custom Zikr Ekleme Butonu
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const AddCustomZikrScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: emeraldGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(
                      AppLocalizations.of(context)?.zikirListAddCustom ?? 'Özel Zikir Ekle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Zikr listesi
                Builder(
                  builder: (context) {
                    final allZikrs = controller.getAllZikrs();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allZikrs.length,
                      itemBuilder: (context, index) {
                        final zikr = allZikrs[index];
                        final isSelected = controller.currentZikr.id == zikr.id;
                        
                        return ZikrCard(
                          zikr: zikr,
                          isSelected: isSelected,
                          onTap: () async {
                            await controller.selectZikr(zikr);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              IslamicSnackbar.showSuccess(
                                AppLocalizations.of(context)?.zikirListSelectionSuccess ?? 'Başarılı',
                                '${zikr.name} ${AppLocalizations.of(context)?.zikirListSelected ?? 'seçildi'}',
                                duration: const Duration(seconds: 1),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}