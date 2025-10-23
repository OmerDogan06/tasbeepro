import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/splash_screen.dart';
import 'controllers/counter_controller.dart';
import 'controllers/widget_stats_controller.dart';
import 'services/storage_service.dart';
import 'services/sound_service.dart';
import 'services/vibration_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'services/language_service.dart';
import 'services/permission_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize timezone
  tz.initializeTimeZones();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      systemNavigationBarColor: Color(0xFF2D5016),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Services'leri başlat
  await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => LanguageService().init());
  Get.put(SoundService());
  Get.put(VibrationService());
  Get.put(NotificationService());
  Get.put(WidgetService());
  Get.put(PermissionService());

  // Controllers'ları başlat
  Get.put(CounterController());
  Get.put(WidgetStatsController());

  // Widget verilerini güncelle (custom zikir ve target'lar için)
  final widgetService = Get.find<WidgetService>();
  await widgetService.updateWidgetData();

  runApp(const OrientationGuardApp());
}

class OrientationGuardApp extends StatelessWidget {
  const OrientationGuardApp({super.key});

  Locale _getDeviceLocale() {
    // Cihazın dilini kontrol et
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;

    // Eğer Türkçe ise TR, değilse EN döndür
    if (deviceLocale.languageCode == 'tr') {
      return const Locale('tr');
    }
    return const Locale('en');
  }

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          // Ana uygulama burada
          return const TasbeeApp();
        } else {
          // Yatay modda gösterilecek ekran
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: languageService.currentLocale,
            supportedLocales: const [
              Locale('tr', 'TR'),
              Locale('en', 'GB'),
              Locale('ar', 'SA'),
              Locale('id', 'ID'),
              Locale('ur', 'PK'),
              Locale('ms', 'MY'),
              Locale('bn', 'BD'),
              Locale('fr', 'FR'),
              Locale('hi', 'IN'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                systemOverlayStyle: SystemUiOverlayStyle(
                  systemNavigationBarColor: Color(0xFF2D5016),
                  systemNavigationBarIconBrightness: Brightness.light,
                ),
              ),
            ),
            darkTheme: ThemeData(useMaterial3: true),
            themeMode: ThemeMode.light,
            home: Builder(
              builder: (context) => Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.screen_rotation,
                        color: Colors.white,
                        size: 80,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "📱 Please rotate your device to portrait mode",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class TasbeeApp extends StatelessWidget {
  const TasbeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Get.find<LanguageService>();

    return Obx(
      () => GetMaterialApp(
        title: 'Tasbee Pro',
        debugShowCheckedModeBanner: false,
        locale: languageService.currentLocale,
        supportedLocales: const [
          Locale('tr', 'TR'),
          Locale('en', 'GB'),
          Locale('ar', 'SA'),
          Locale('id', 'ID'),
          Locale('ur', 'PK'),
          Locale('ms', 'MY'),
          Locale('bn', 'BD'),
          Locale('fr', 'FR'),
          Locale('hi', 'IN'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle(
              systemNavigationBarColor: Color(0xFF2D5016),
              systemNavigationBarIconBrightness: Brightness.light,
            ),
          ),
        ),
        darkTheme: ThemeData(useMaterial3: true),
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}
