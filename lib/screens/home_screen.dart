import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../widgets/counter_button.dart';
import '../widgets/progress_bar.dart';
import '../widgets/islamic_snackbar.dart';
import '../l10n/app_localizations.dart';
import 'zikr_list_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // İslami renk paleti
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
        appBar:PreferredSize(preferredSize: Size.fromHeight(56), child:  SafeArea(
          child: AppBar(
            title: Text(
              AppLocalizations.of(context)?.homeTitle ?? 'Tasbee Pro',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: emeraldGreen,
                fontSize: 20,
              ),
            ),
            centerTitle: false,
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
            actions: [
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
                  icon: const Icon(Icons.settings, color: emeraldGreen, size: 22),
                  onPressed: () => Get.to (() => const SettingsScreen(), transition: Transition.rightToLeft,duration: Duration(milliseconds: 300)),
                ),
              ),
            ],
          ),
        )),
        body: SafeArea(
          child: Stack(
            children: [
            
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    // Daily stats - İslami tasarım
                    Obx(
                      () => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFE8E0C7), Color(0xFFF0E9D2)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: goldColor.withAlpha(77),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: darkGreen.withAlpha(26),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: emeraldGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppLocalizations.of(context)?.homeDailyTotal ?? 'Bugünkü Toplam Zikir',
                                      maxLines:2,
                                      style: const TextStyle(
                                        color: emeraldGreen,
                                        fontSize: 14,
                                        
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              constraints: const BoxConstraints(
                                maxWidth: 140,
                                minWidth: 50,
                                minHeight: 40,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const RadialGradient(
                                  colors: [lightGold, goldColor],
                                  center: Alignment(-0.2, -0.2),
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: darkGreen.withAlpha(51),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${controller.dailyTotal}',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: emeraldGreen,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 10),
      
                    // Current zikr - İslami kart tasarımı
                    Obx(
                      () => GestureDetector(
                        onTap: () => Get.to (() => const ZikrListScreen(), transition: Transition.rightToLeft,duration: Duration(milliseconds: 300)),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2D5016), Color(0xFF1A3409)],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: darkGreen.withAlpha(77),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  controller.currentZikr.name,
                                  style: const TextStyle(
                                    fontSize: 18,
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
                              ),
      
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: lightGold,
                                size: 18,
                              ),
                             
                            ],
                          ),
                        ),
                      ),
                    ),
      
                    const Spacer(),
      
                    // Counter button (zaten mükemmel)
                    const CounterButton(),
      
                    const Spacer(),
      
                    // Progress bar (İslami tema ile)
                    const ProgressBar(),
      
                    const SizedBox(height: 10),
      
                    // Action buttons - İslami tasarım
                    _buildActionButtons(context, controller),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    CounterController controller,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          // Geniş ekranlarda 3 buton yan yana
          return Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.flag,
                  label: '${AppLocalizations.of(context)?.homeTarget ?? 'Hedef'}: ${controller.target}',
                  onTap: () => _showTargetDialog(context, controller),
                  isObx: true,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.refresh,
                  label: AppLocalizations.of(context)?.homeReset ?? 'Sıfırla',
                  onTap: () => _showResetDialog(context, controller),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.bar_chart,
                  label: AppLocalizations.of(context)?.homeStatistics ?? 'İstatistik',
                  onTap: () => Get.to (() => const StatsScreen(), transition: Transition.rightToLeft,duration: Duration(milliseconds: 300)),
                ),
              ),
            ],
          );
        } else {
          // Dar ekranlarda 2+1 düzeni
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.flag,
                      label: '${AppLocalizations.of(context)?.homeTarget ?? 'Hedef'}: ${controller.target}',
                      onTap: () => _showTargetDialog(context, controller),
                      isObx: true,
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      context,
                      icon: Icons.refresh,
                      label: AppLocalizations.of(context)?.homeReset ?? 'Sıfırla',
                      onTap: () => _showResetDialog(context, controller),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _buildActionButton(
                  context,
                  icon: Icons.bar_chart,
                  label: AppLocalizations.of(context)?.homeStatistics ?? 'İstatistikler',
                  onTap: () => Get.to (() => const StatsScreen(), transition: Transition.rightToLeft,duration: Duration(milliseconds: 300)),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isObx = false,
    CounterController? controller,
  }) {
    Widget buttonContent = Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5E6A8), Color(0xFFD4AF37)],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: emeraldGreen.withAlpha(51), width: 1),
        boxShadow: [
          BoxShadow(
            color: darkGreen.withAlpha(38),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: emeraldGreen, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: emeraldGreen,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );

    if (isObx && controller != null) {
      buttonContent = Obx(
        () => Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5E6A8), Color(0xFFD4AF37)],
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: emeraldGreen.withAlpha(51), width: 1),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(38),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: emeraldGreen, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${AppLocalizations.of(context)?.homeTarget ?? 'Hedef'}: ${controller.target}',
                  style: const TextStyle(
                    color: emeraldGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: buttonContent);
  }

  void _showTargetDialog(BuildContext context, CounterController controller) {
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
              color: goldColor.withAlpha(102),
              width: 1.5,
            ),
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
              // Minimal header
              Padding(
                padding: const EdgeInsets.all(12),
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
                        Icons.flag,
                        color: emeraldGreen,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)?.homeTargetDialogTitle ?? 'Hedef Seç',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: emeraldGreen,
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
              
              // Compact options
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ...controller.targetOptions.map((target) {
                      final isSelected = controller.target == target;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? goldColor.withAlpha(38)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected 
                                ? goldColor.withAlpha(128)
                                : goldColor.withAlpha(51),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            overlayColor: WidgetStateProperty.all(Color(0xFFD4AF37).withAlpha(26)),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              controller.setTarget(target);
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelected ? goldColor : emeraldGreen.withAlpha(102),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      '$target',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: emeraldGreen,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: goldColor,
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 12),
                    
                    // Minimal close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: lightGold.withAlpha(77),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          overlayColor: Color(0xFFD4AF37).withAlpha(26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: goldColor.withAlpha(77),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.close ?? 'Kapat',
                          style: const TextStyle(
                            color: emeraldGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
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

  void _showResetDialog(BuildContext context, CounterController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFFF8F6F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: goldColor.withAlpha(77)),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const RadialGradient(colors: [lightGold, goldColor]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.refresh, color: emeraldGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              AppLocalizations.of(context)?.homeResetConfirmTitle ?? 'Sıfırla',
              style: const TextStyle(
                color: emeraldGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          AppLocalizations.of(context)?.homeResetConfirmMessage ?? 'Sayacı sıfırlamak istediğinizden emin misiniz?',
          style: const TextStyle(color: emeraldGreen),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: goldColor.withAlpha(128)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'İptal', style: const TextStyle(color: emeraldGreen)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [lightGold, goldColor]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextButton(
              onPressed: () {
                controller.reset();
                Navigator.of(context).pop();
                IslamicSnackbar.showSuccess(
                  AppLocalizations.of(context)?.homeResetSuccess ?? 'Başarılı',
                  AppLocalizations.of(context)?.homeResetSuccessMessage ?? 'Sayaç sıfırlandı',
                  duration: const Duration(seconds: 1),
                );
              },
              child: Text(
                AppLocalizations.of(context)?.homeReset ?? 'Sıfırla',
                style: const TextStyle(
                  color: emeraldGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




