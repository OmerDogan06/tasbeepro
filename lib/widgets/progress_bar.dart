import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key});

  // İslami renk paleti - counter_button ile aynı
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CounterController>();
    
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F6F0), // Açık krem
              Color(0xFFF0E9D2), // Biraz daha koyu krem
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: goldColor.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: darkGreen.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Sayı ve yüzde bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: lightGold.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: goldColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${controller.count}/${controller.target}',
                    style: const TextStyle(
                      color: emeraldGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [lightGold, goldColor],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: darkGreen.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    '${(controller.progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: emeraldGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // İslami progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: lightGold.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: goldColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: controller.progress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goldColor,
                  ),
                  minHeight: 8,
                ),
              ),
            ),
            
            // Hedef tamamlandı mesajı - İslami stil
            if (controller.isCompleted) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [lightGold, goldColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: emeraldGreen.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: darkGreen.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: emeraldGreen,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: lightGold,
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Masha\'Allah! Hedef Tamamlandı',
                      style: TextStyle(
                        color: emeraldGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}