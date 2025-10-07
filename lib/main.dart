import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'screens/home_screen.dart';
import 'controllers/theme_controller.dart';
import 'controllers/counter_controller.dart';
import 'controllers/widget_stats_controller.dart';
import 'services/storage_service.dart';
import 'services/sound_service.dart';
import 'services/vibration_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
          statusBarColor: Color(0xFF2D5016),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2D5016),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Services'leri başlat
  await Get.putAsync(() => StorageService().init());
  Get.put(SoundService());
  Get.put(VibrationService());
  Get.put(NotificationService());
  Get.put(WidgetService());

  // Controllers'ları başlat
  Get.put(ThemeController());
  Get.put(CounterController());
  Get.put(WidgetStatsController());

  runApp(const TasbeeApp());
}

class TasbeeApp extends StatelessWidget {
  const TasbeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Tasbee Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Color(0xFF2D5016),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF2D5016),
      systemNavigationBarIconBrightness: Brightness.light,
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,

        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      themeMode: Get.find<ThemeController>().themeMode,
      home: const HomeScreen(),
    );
  }
}
