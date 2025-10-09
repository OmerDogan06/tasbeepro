import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// The title of the application shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Tasbee Pro'**
  String get splashAppTitle;

  /// Arabic Bismillah text on splash screen
  ///
  /// In en, this message translates to:
  /// **'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ'**
  String get splashSubtitleArabic;

  /// App description on splash screen
  ///
  /// In en, this message translates to:
  /// **'Digital Prayer Counter App'**
  String get splashSubtitleTurkish;

  /// Loading text on splash screen
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Sound and vibration section header
  ///
  /// In en, this message translates to:
  /// **'Sound & Vibration'**
  String get settingsSoundVibration;

  /// Sound effect setting title
  ///
  /// In en, this message translates to:
  /// **'Sound Effect'**
  String get settingsSoundEffect;

  /// Sound effect setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Turn on/off touch sound'**
  String get settingsSoundSubtitle;

  /// Vibration setting title
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get settingsVibration;

  /// Reminders section header
  ///
  /// In en, this message translates to:
  /// **'Reminders 💎'**
  String get settingsReminders;

  /// Zikr reminder setting title
  ///
  /// In en, this message translates to:
  /// **'Zikr Reminder'**
  String get settingsZikirReminder;

  /// Reminder setting subtitle
  ///
  /// In en, this message translates to:
  /// **'View and manage reminders'**
  String get settingsReminderSubtitle;

  /// Reminder times setting title
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get settingsReminderTimes;

  /// Reminder times setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily recurring notifications'**
  String get settingsReminderTimesSubtitle;

  /// Widget section header
  ///
  /// In en, this message translates to:
  /// **'Widget 📱'**
  String get settingsWidget;

  /// Widget statistics setting title
  ///
  /// In en, this message translates to:
  /// **'Widget Statistics'**
  String get settingsWidgetStats;

  /// Widget statistics setting subtitle
  ///
  /// In en, this message translates to:
  /// **'View all your zikrs from widget'**
  String get settingsWidgetStatsSubtitle;

  /// Widget info setting title
  ///
  /// In en, this message translates to:
  /// **'About Widget'**
  String get settingsWidgetInfo;

  /// Widget info setting subtitle
  ///
  /// In en, this message translates to:
  /// **'How to use widget and add to home screen'**
  String get settingsWidgetInfoSubtitle;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// App info setting title
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get settingsAppInfo;

  /// Rate app setting title
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get settingsRateApp;

  /// Rate app setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Rate on Play Store'**
  String get settingsRateSubtitle;

  /// Language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get settingsLanguageSubtitle;

  /// Vibration off option
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get vibrationOff;

  /// Light vibration option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get vibrationLight;

  /// Medium vibration option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get vibrationMedium;

  /// High vibration option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get vibrationHigh;

  /// Vibration dialog title
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibrationTitle;

  /// OK button in vibration dialog
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get vibrationOk;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelectionTitle;

  /// Language selection dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Select app language'**
  String get languageSelectionSubtitle;

  /// Language changed notification title
  ///
  /// In en, this message translates to:
  /// **'Language Changed'**
  String get languageChanged;

  /// Language changed notification message
  ///
  /// In en, this message translates to:
  /// **'App language changed successfully'**
  String get languageChangedMessage;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Loading text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Thanks text
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get thanks;

  /// Success text
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Rate app snackbar message
  ///
  /// In en, this message translates to:
  /// **'Your review is very important to us!'**
  String get rateAppMessage;

  /// Add widget button text
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get widgetAddTitle;

  /// Widget info dialog title
  ///
  /// In en, this message translates to:
  /// **'Tasbee Widget Info 📱'**
  String get widgetInfoTitle;

  /// Widget features section title
  ///
  /// In en, this message translates to:
  /// **'✨ Widget Features:'**
  String get widgetFeatures;

  /// Widget feature 1
  ///
  /// In en, this message translates to:
  /// **'Easily count zikr on your home screen'**
  String get widgetFeature1;

  /// Widget feature 2
  ///
  /// In en, this message translates to:
  /// **'All your zikrs are permanently saved'**
  String get widgetFeature2;

  /// Widget feature 3
  ///
  /// In en, this message translates to:
  /// **'You can track widget statistics'**
  String get widgetFeature3;

  /// Widget feature 4
  ///
  /// In en, this message translates to:
  /// **'You can set target numbers'**
  String get widgetFeature4;

  /// Widget feature 5
  ///
  /// In en, this message translates to:
  /// **'You can choose different zikr types'**
  String get widgetFeature5;

  /// Widget add instructions
  ///
  /// In en, this message translates to:
  /// **'Long press on an empty area on your home screen and select \"Widgets\". Then find and add the \"Tasbee Pro\" widget.'**
  String get widgetAddInstructions;

  /// About app dialog title
  ///
  /// In en, this message translates to:
  /// **'Tasbee Free'**
  String get appInfoTitle;

  /// App description in about dialog
  ///
  /// In en, this message translates to:
  /// **'Offline digital prayer counter app.'**
  String get appInfoDescription;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Widget add success message title
  ///
  /// In en, this message translates to:
  /// **'Widget Added'**
  String get widgetAddSuccess;

  /// Widget add success message
  ///
  /// In en, this message translates to:
  /// **'Long press on an empty area on your home screen and select \'Widgets\'. Then find and add the \'Tasbee Pro\' widget.'**
  String get widgetAddSuccessMessage;

  /// Version label in about dialog
  ///
  /// In en, this message translates to:
  /// **'Version: '**
  String get appInfoVersionLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
