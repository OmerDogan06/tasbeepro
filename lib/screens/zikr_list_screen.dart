import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tasbeepro/models/zikr.dart';
import '../controllers/counter_controller.dart';
import '../widgets/zikr_card.dart';
import '../widgets/islamic_snackbar.dart';
import '../widgets/banner_ad_widget.dart';
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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF2D5016),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0), // Açık krem arka plan
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: SafeArea(
            child: AppBar(
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
            ),
          ),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Banner Ad - normal widget olarak
              const SliverToBoxAdapter(
                child: BannerAdWidget(),
              ),
              
              // Scrollable content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                        color: darkGreen.withAlpha(77),
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
                        AppLocalizations.of(context)?.zikirListProSelection ??
                            'Pro Zikir Seçimi',
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
                        AppLocalizations.of(context)?.zikirListDescription ??
                            'Geniş zikir koleksiyonu ve özel zikir oluşturma',
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
                    onPressed: () => Get.to(
                      () => AddCustomZikrScreen(
                        onBack: (value) {
                          final successTitle =
                              AppLocalizations.of(
                                context,
                              )?.customZikirAddedTitle ??
                              'Başarılı! 🎉';
                          final successMessage =
                              AppLocalizations.of(
                                context,
                              )?.customZikirAddedMessage ??
                              'Özel zikir eklendi';
                          IslamicSnackbar.showSuccess(
                            successTitle,
                            successMessage,
                          );

                          controller.getAllZikrs();
                        },
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 300),
                    ),
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
                      AppLocalizations.of(context)?.zikirListAddCustom ??
                          'Özel Zikir Ekle',
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
                    controller.getAllZikrs();
                    return Obx(() => 
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.allZikrs.length,
                        itemBuilder: (context, index) {
                          Rx<Zikr> zikr = controller.allZikrs[index].obs;
                          final isSelected = controller.currentZikr.id == zikr.value.id;

                          return ZikrCard(
                            zikr: zikr.value,
                            isSelected: isSelected,
                            onTap: () async {
                              await controller.selectZikr(zikr.value);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                IslamicSnackbar.showSuccess(
                                  AppLocalizations.of(
                                        context,
                                      )?.zikirListSelectionSuccess ??
                                      'Başarılı',
                                  '${zikr.value.name} ${AppLocalizations.of(context)?.zikirListSelected ?? 'seçildi'}',
                                  duration: const Duration(seconds: 1),
                                );
                              }
                            },
                            onDelete: zikr.value.isCustom == true ? () async {
                              _showDeleteDialog(context, zikr.value, controller);
                            } : null,
                          );
                        },
                      ),
                    );
                  },
                ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Zikr zikr, CounterController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: goldColor.withAlpha(102), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(51),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          colors: [Color(0xFFFFB3B3), Color(0xFFFF6B6B)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.deleteZikirTitle ?? 'Zikir Sil',
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
                  children: [
                    // Zikir bilgisi
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mosque,
                            color: emeraldGreen,
                            size: 24,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            zikr.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: emeraldGreen,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (zikr.meaning != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              zikr.meaning!,
                              style: TextStyle(
                                fontSize: 12,
                                color: emeraldGreen.withAlpha(179),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Onay mesajı
                    Text(
                      AppLocalizations.of(context)?.deleteZikirMessage ?? 
                          'Bu zikiri silmek istediğinizden emin misiniz?',
                      style: TextStyle(
                        fontSize: 14,
                        color: emeraldGreen.withAlpha(204),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // Butonlar
                    Row(
                      children: [
                        // İptal butonu
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              backgroundColor: lightGold.withAlpha(77),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: goldColor.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.deleteZikirCancel ?? 'İptal',
                              style: const TextStyle(
                                color: emeraldGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Sil butonu
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await controller.deleteCustomZikr(zikr.id);
                              IslamicSnackbar.showSuccess(
                                AppLocalizations.of(context.mounted ? context : Get.context!)?.deleteZikirSuccess ?? 'Silindi! 🗑️',
                                '${zikr.name} ${AppLocalizations.of(context.mounted ? context : Get.context!)?.zikirListSelected ?? 'silindi'}',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.deleteZikirConfirm ?? 'Sil',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}
