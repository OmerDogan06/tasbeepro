import 'package:flutter/material.dart';
import '../models/zikr.dart';
import '../l10n/app_localizations.dart';

class ZikrCard extends StatelessWidget {
  final Zikr zikr;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onDelete; // Silme callback'i (custom zikirler için)
  
  const ZikrCard({
    super.key,
    required this.zikr,
    required this.isSelected,
    required this.onTap,
    this.onDelete, // Custom zikirler için silme butonu
  });

  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [lightGold, goldColor],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8F6F0), Color(0xFFF0E9D2)],
              ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected 
              ? emeraldGreen.withAlpha(127)
              : goldColor.withAlpha(77),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? darkGreen.withAlpha(77)
                : darkGreen.withAlpha(26),
            blurRadius: isSelected ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: zikr.isCustom ? 90 : 80,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        zikr.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? emeraldGreen : emeraldGreen,
                          shadows: isSelected
                              ? [
                                  const Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    // Silme butonu (sadece custom zikirler için)
                    if (onDelete != null && !isSelected)
                      Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
                          ),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: onDelete,
                        ),
                      ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: emeraldGreen,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: darkGreen.withAlpha(77),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check,
                          color: lightGold,
                          size: 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Zikir anlamı
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? emeraldGreen.withAlpha(26)
                          : lightGold.withAlpha(77),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isSelected 
                            ? emeraldGreen.withAlpha(77)
                            : goldColor.withAlpha(51),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: zikr.meaning != null 
                          ? Text(
                              zikr.meaning!,
                              style: TextStyle(
                                fontSize: 11,
                                color: emeraldGreen.withAlpha(204),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.mosque,
                                  color: emeraldGreen.withAlpha(153),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context)!.zikirCardSelectText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: emeraldGreen.withAlpha(179),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.mosque,
                                  color: emeraldGreen.withAlpha(153),
                                  size: 16,
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
      ),
    );
  }
}