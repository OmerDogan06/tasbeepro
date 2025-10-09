import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IslamicSnackbar {
  // İslami renk paleti
  static const emeraldGreen = Color(0xFF2D5016);
  static const goldColor = Color(0xFFD4AF37);
  static const lightGold = Color(0xFFF5E6A8);
  static const darkGreen = Color(0xFF1A3409);
  static const creamBackground = Color(0xFFF8F6F0);

  /// Başarı mesajı için İslami temalı snackbar
  static void showSuccess(String title, String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: _buildTitleText(title, Icons.check_circle, Colors.green.shade700),
        messageText: _buildMessageText(message),
        backgroundColor: Colors.white,
        duration: duration ?? const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 5,
        snackPosition: SnackPosition.TOP,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationCurve: Curves.easeInOut,
        forwardAnimationCurve: Curves.easeInOut,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8F5E8),
            Color(0xFFF0F9F0),
          ],
        ),
        boxShadows: [
          BoxShadow(
            color: emeraldGreen.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderColor: goldColor.withAlpha(102),
        borderWidth: 1.5,
        leftBarIndicatorColor: Colors.green.shade600,
      ),
    );
  }

  /// Hata mesajı için İslami temalı snackbar
  static void showError(String title, String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: _buildTitleText(title, Icons.error, Colors.red.shade700),
        messageText: _buildMessageText(message),
        backgroundColor: Colors.white,
        duration: duration ?? const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 5,
        snackPosition: SnackPosition.TOP,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationCurve: Curves.easeInOut,
        forwardAnimationCurve: Curves.easeInOut,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF5F5),
            Color(0xFFFFF0F0),
          ],
        ),
        boxShadows: [
          BoxShadow(
            color: emeraldGreen.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderColor: goldColor.withAlpha(102),
        borderWidth: 1.5,
        leftBarIndicatorColor: Colors.red.shade600,
      ),
    );
  }

  /// Bilgi mesajı için İslami temalı snackbar
  static void showInfo(String title, String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: _buildTitleText(title, Icons.info, Colors.blue.shade700),
        messageText: _buildMessageText(message),
        backgroundColor: Colors.white,
        duration: duration ?? const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 5,
        snackPosition: SnackPosition.TOP,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationCurve: Curves.easeInOut,
        forwardAnimationCurve: Curves.easeInOut,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF0F8FF),
            Color(0xFFF8FBFF),
          ],
        ),
        boxShadows: [
          BoxShadow(
            color: emeraldGreen.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderColor: goldColor.withAlpha(102),
        borderWidth: 1.5,
        leftBarIndicatorColor: Colors.blue.shade600,
      ),
    );
  }

  /// Uyarı mesajı için İslami temalı snackbar
  static void showWarning(String title, String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: _buildTitleText(title, Icons.warning, Colors.orange.shade700),
        messageText: _buildMessageText(message),
        backgroundColor: Colors.white,
        duration: duration ?? const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 5,
        snackPosition: SnackPosition.TOP,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationCurve: Curves.easeInOut,
        forwardAnimationCurve: Curves.easeInOut,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8F0),
            Color(0xFFFFFAF5),
          ],
        ),
        boxShadows: [
          BoxShadow(
            color: emeraldGreen.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderColor: goldColor.withAlpha(102),
        borderWidth: 1.5,
        leftBarIndicatorColor: Colors.orange.shade600,
      ),
    );
  }

  /// Genel kullanım için özelleştirilebilir İslami temalı snackbar
  static void showCustom({
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    List<Color>? backgroundColors,
    Color? leftBarColor,
    Duration? duration,
    SnackPosition position = SnackPosition.TOP,
  }) {
    Get.showSnackbar(
      GetSnackBar(
        titleText: _buildTitleText(
          title, 
          icon ?? Icons.info, 
          iconColor ?? emeraldGreen
        ),
        messageText: _buildMessageText(message),
        backgroundColor: Colors.white,
        duration: duration ?? const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        borderRadius: 5,
        snackPosition: position,
        animationDuration: const Duration(milliseconds: 500),
        reverseAnimationCurve: Curves.easeInOut,
        forwardAnimationCurve: Curves.easeInOut,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        backgroundGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backgroundColors ?? [
            lightGold.withAlpha(230),
            creamBackground,
          ],
        ),
        boxShadows: [
          BoxShadow(
            color: emeraldGreen.withAlpha(51),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
        borderColor: goldColor.withAlpha(102),
        borderWidth: 1.5,
        leftBarIndicatorColor: leftBarColor ?? goldColor,
      ),
    );
  }

  /// Title text widget'ı oluşturur
  static Widget _buildTitleText(String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [lightGold, goldColor.withAlpha(204)],
              center: const Alignment(-0.2, -0.2),
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: darkGreen.withAlpha(26),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: emeraldGreen,
              shadows: [
                Shadow(
                  color: Colors.black12,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Message text widget'ı oluşturur
  static Widget _buildMessageText(String message) {
    return Padding(
      padding: const EdgeInsets.only(left: 42, top: 4),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: emeraldGreen.withAlpha(230),
          fontWeight: FontWeight.w500,
          height: 1.3,
        ),
      ),
    );
  }
}