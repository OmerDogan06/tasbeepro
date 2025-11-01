import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_uz.dart';

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
    Locale('tr'),
    Locale('en'),
    Locale('ar'),
    Locale('id'),
    Locale('ur'),
    Locale('ms'),
    Locale('fr'),
    Locale('hi'),
    Locale('bn'),
    Locale('de'),
    Locale('es'),
    Locale('fa'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('uz'),
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

  /// No description provided for @settingsReminderWarning.
  ///
  /// In en, this message translates to:
  /// **'Android may block notifications sent too frequently. Choose reasonable intervals for your reminders to work properly.'**
  String get settingsReminderWarning;

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

  /// Sound volume settings title
  ///
  /// In en, this message translates to:
  /// **'Sound Volume'**
  String get soundVolumeTitle;

  /// Low sound volume option
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get soundVolumeLow;

  /// Medium sound volume option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get soundVolumeMedium;

  /// High sound volume option
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get soundVolumeHigh;

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
  /// **'Tasbee Pro'**
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

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'Tasbee Pro'**
  String get homeTitle;

  /// Daily total counter label
  ///
  /// In en, this message translates to:
  /// **'Today\'s Total Zikr'**
  String get homeDailyTotal;

  /// Target button label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get homeTarget;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get homeReset;

  /// Statistics button label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get homeStatistics;

  /// Reset confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get homeResetConfirmTitle;

  /// Reset confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the counter?'**
  String get homeResetConfirmMessage;

  /// Reset success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get homeResetSuccess;

  /// Reset success message
  ///
  /// In en, this message translates to:
  /// **'Counter has been reset'**
  String get homeResetSuccessMessage;

  /// Target selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Target'**
  String get homeTargetDialogTitle;

  /// Add custom target button text
  ///
  /// In en, this message translates to:
  /// **'Add Target'**
  String get addCustomTarget;

  /// Custom target bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Add Custom Target'**
  String get customTargetTitle;

  /// Custom target input field hint
  ///
  /// In en, this message translates to:
  /// **'Enter a target greater than 1000'**
  String get customTargetHint;

  /// Custom target error title
  ///
  /// In en, this message translates to:
  /// **'Invalid Target'**
  String get customTargetError;

  /// Custom target error message
  ///
  /// In en, this message translates to:
  /// **'Target must be greater than 1000 and unique'**
  String get customTargetErrorMessage;

  /// Custom target success title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get customTargetSuccess;

  /// Custom target success message
  ///
  /// In en, this message translates to:
  /// **'Custom target added'**
  String get customTargetSuccessMessage;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Delete target dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Target'**
  String get deleteTargetTitle;

  /// Delete target dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the target {target}?'**
  String deleteTargetMessage(int target);

  /// Delete target success message
  ///
  /// In en, this message translates to:
  /// **'Target deleted'**
  String get deleteTargetSuccess;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Zikr list screen title
  ///
  /// In en, this message translates to:
  /// **'Select Zikr'**
  String get zikirListTitle;

  /// Pro zikr selection header title
  ///
  /// In en, this message translates to:
  /// **'Pro Zikr Selection'**
  String get zikirListProSelection;

  /// Zikr list screen description
  ///
  /// In en, this message translates to:
  /// **'Wide zikr collection and custom zikr creation'**
  String get zikirListDescription;

  /// Add custom zikr button text
  ///
  /// In en, this message translates to:
  /// **'Add Custom Zikr'**
  String get zikirListAddCustom;

  /// Zikr selection success message title
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get zikirListSelectionSuccess;

  /// Zikr selected message
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get zikirListSelected;

  /// Subhanallah zikr name
  ///
  /// In en, this message translates to:
  /// **'Subhanallah'**
  String get zikirSubhanallah;

  /// Subhanallah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Glory be to Allah'**
  String get zikirSubhanallahMeaning;

  /// Alhamdulillah zikr name
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get zikirAlhamdulillah;

  /// Alhamdulillah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'All praise belongs to Allah'**
  String get zikirAlhamdulillahMeaning;

  /// Allahu Akbar zikr name
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get zikirAllahuAkbar;

  /// Allahu Akbar zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Allah is the Greatest'**
  String get zikirAllahuAkbarMeaning;

  /// La ilaha illAllah zikr name
  ///
  /// In en, this message translates to:
  /// **'La ilaha illAllah'**
  String get zikirLaIlaheIllallah;

  /// La ilaha illAllah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'There is no deity but Allah'**
  String get zikirLaIlaheIllallahMeaning;

  /// Astaghfirullah zikr name
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get zikirEstaghfirullah;

  /// Astaghfirullah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah'**
  String get zikirEstaghfirullahMeaning;

  /// La hawla wa la quwwata illa billah zikr name
  ///
  /// In en, this message translates to:
  /// **'La hawla wa la quwwata illa billah'**
  String get zikirLaHawleWelaKuvvete;

  /// La hawla wa la quwwata illa billah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'There is no power except with Allah'**
  String get zikirLaHawleWelaKuvveteMeaning;

  /// HasbiyAllahu wa ni’mal wakeel zikr name
  ///
  /// In en, this message translates to:
  /// **'HasbiyAllahu wa ni’mal wakeel'**
  String get zikirHasbiyallahu;

  /// HasbiyAllahu wa ni’mal wakeel zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Allah is sufficient for me, and He is the best Disposer of affairs'**
  String get zikirHasbiyallahuMeaning;

  /// Rabbana Atina zikr name
  ///
  /// In en, this message translates to:
  /// **'Rabbana Atina'**
  String get zikirRabbenaAtina;

  /// Rabbana Atina zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Our Lord! Give us good in this world'**
  String get zikirRabbenaAtinaMeaning;

  /// Allahumma Salli zikr name
  ///
  /// In en, this message translates to:
  /// **'Allahumma Salli'**
  String get zikirAllahummeSalli;

  /// Allahumma Salli zikr meaning
  ///
  /// In en, this message translates to:
  /// **'O Allah, send blessings upon Muhammad'**
  String get zikirAllahummeCalliMeaning;

  /// Rabbi Zidni Ilm zikr name
  ///
  /// In en, this message translates to:
  /// **'Rabbi Zidni Ilm'**
  String get zikirRabbiZidniIlmen;

  /// Rabbi Zidni Ilm zikr meaning
  ///
  /// In en, this message translates to:
  /// **'My Lord! Increase me in knowledge'**
  String get zikirRabbiZidniIlmenMeaning;

  /// Bismillah zikr name
  ///
  /// In en, this message translates to:
  /// **'Bismillah'**
  String get zikirBismillah;

  /// Bismillah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'In the name of Allah, the Most Gracious, the Most Merciful'**
  String get zikirBismillahMeaning;

  /// Innalaha ma’as sabirin zikr name
  ///
  /// In en, this message translates to:
  /// **'Innalaha ma’as sabirin'**
  String get zikirInnallahaMaasSabirin;

  /// Innalaha ma’as sabirin zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Indeed, Allah is with the patient'**
  String get zikirInnallahaMaasSabirinMeaning;

  /// Allahu Latif zikr name
  ///
  /// In en, this message translates to:
  /// **'Allahu Latif'**
  String get zikirAllahuLatif;

  /// Allahu Latif zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Allah is Kind to His servants'**
  String get zikirAllahuLatifMeaning;

  /// Ya Rahman Ya Rahim zikr name
  ///
  /// In en, this message translates to:
  /// **'Ya Rahman Ya Rahim'**
  String get zikirYaRahman;

  /// Ya Rahman Ya Rahim zikr meaning
  ///
  /// In en, this message translates to:
  /// **'O Most Gracious, O Most Merciful'**
  String get zikirYaRahmanMeaning;

  /// Tabarak Allah zikr name
  ///
  /// In en, this message translates to:
  /// **'Tabarak Allah'**
  String get zikirTabarakAllah;

  /// Tabarak Allah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'Blessed is Allah'**
  String get zikirTabarakAllahMeaning;

  /// MashaAllah zikr name
  ///
  /// In en, this message translates to:
  /// **'MashaAllah'**
  String get zikirMashallah;

  /// MashaAllah zikr meaning
  ///
  /// In en, this message translates to:
  /// **'What Allah has willed has happened'**
  String get zikirMashallahMeaning;

  /// Add custom zikr screen title
  ///
  /// In en, this message translates to:
  /// **'Add Custom Zikr'**
  String get addCustomZikirTitle;

  /// Add custom zikr screen description
  ///
  /// In en, this message translates to:
  /// **'Create your own custom zikrs and add them to the list'**
  String get addCustomZikirDescription;

  /// Zikr name input label
  ///
  /// In en, this message translates to:
  /// **'Zikr Name'**
  String get addCustomZikirNameLabel;

  /// Zikr name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. Allahu Akbar'**
  String get addCustomZikirNameHint;

  /// Zikr meaning input label
  ///
  /// In en, this message translates to:
  /// **'Meaning (Optional)'**
  String get addCustomZikirMeaningLabel;

  /// Zikr meaning input hint
  ///
  /// In en, this message translates to:
  /// **'You can write the meaning of the zikr'**
  String get addCustomZikirMeaningHint;

  /// Add zikr button text
  ///
  /// In en, this message translates to:
  /// **'Add Zikr'**
  String get addCustomZikirButton;

  /// Zikr name required validation message
  ///
  /// In en, this message translates to:
  /// **'Zikr name is required'**
  String get addCustomZikirNameRequired;

  /// Zikr name minimum length validation message
  ///
  /// In en, this message translates to:
  /// **'Zikr name must be at least 2 characters'**
  String get addCustomZikirNameMinLength;

  /// Stats screen title
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics 💎'**
  String get statsTitle;

  /// Widget stats screen title
  ///
  /// In en, this message translates to:
  /// **'Widget Statistics 📱'**
  String get widgetStatsTitle;

  /// Daily tab label
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get statsDaily;

  /// Weekly tab label
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get statsWeekly;

  /// Monthly tab label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get statsMonthly;

  /// Yearly tab label
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get statsYearly;

  /// Daily stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed today'**
  String get statsDailyInfo;

  /// Weekly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed this week'**
  String get statsWeeklyInfo;

  /// Monthly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed this month'**
  String get statsMonthlyInfo;

  /// Yearly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed this year'**
  String get statsYearlyInfo;

  /// Widget daily stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed from widget today'**
  String get widgetStatsDailyInfo;

  /// Widget weekly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed from widget this week'**
  String get widgetStatsWeeklyInfo;

  /// Widget monthly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed from widget this month'**
  String get widgetStatsMonthlyInfo;

  /// Widget yearly stats info
  ///
  /// In en, this message translates to:
  /// **'Details of zikrs performed from widget this year'**
  String get widgetStatsYearlyInfo;

  /// Total zikr stat label
  ///
  /// In en, this message translates to:
  /// **'Total Zikr'**
  String get statsTotal;

  /// Most used zikr stat label
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get statsMostUsed;

  /// Active zikrs stat label
  ///
  /// In en, this message translates to:
  /// **'Active Zikrs'**
  String get statsActiveZikrs;

  /// Average stat label
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statsAverage;

  /// Zikr distribution chart title
  ///
  /// In en, this message translates to:
  /// **'Zikr Distribution'**
  String get statsDistribution;

  /// Zikr details section title
  ///
  /// In en, this message translates to:
  /// **'Zikr Details'**
  String get statsDetails;

  /// Widget zikr distribution chart title
  ///
  /// In en, this message translates to:
  /// **'Widget Zikr Distribution'**
  String get widgetStatsDistribution;

  /// Widget zikr details section title
  ///
  /// In en, this message translates to:
  /// **'Widget Zikr Details'**
  String get widgetStatsDetails;

  /// No data message title
  ///
  /// In en, this message translates to:
  /// **'No data yet'**
  String get statsNoData;

  /// No data message description
  ///
  /// In en, this message translates to:
  /// **'No zikrs have been performed in this period yet'**
  String get statsNoDataMessage;

  /// Data loading error message
  ///
  /// In en, this message translates to:
  /// **'Error occurred while loading data'**
  String get statsLoadingError;

  /// Title format for period statistics, where {period} is replaced with the time period
  ///
  /// In en, this message translates to:
  /// **'{period} Statistics'**
  String statsPeriodStatsFor(Object period);

  /// PDF error dialog title
  ///
  /// In en, this message translates to:
  /// **'PDF Error'**
  String get statsPdfError;

  /// PDF save error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save PDF'**
  String get statsPdfSaveError;

  /// PDF creation error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while creating PDF'**
  String get statsPdfCreateError;

  /// PDF open error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while opening PDF'**
  String get statsPdfOpenError;

  /// PDF share error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while sharing PDF'**
  String get statsPdfShareError;

  /// General error dialog title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statsError;

  /// Text shown when sharing PDF report
  ///
  /// In en, this message translates to:
  /// **'My Tasbee Pro Statistics Report'**
  String get statsPdfShareText;

  /// Subject line when sharing PDF report
  ///
  /// In en, this message translates to:
  /// **'Tasbee Pro - Statistics Report'**
  String get statsPdfShareSubject;

  /// Title format for widget period statistics, where {period} is replaced with the time period
  ///
  /// In en, this message translates to:
  /// **'{period} Widget Statistics'**
  String widgetStatsPeriodTitle(Object period);

  /// Widget total zikr count label
  ///
  /// In en, this message translates to:
  /// **'Total Zikr'**
  String get widgetStatsTotal;

  /// Widget active zikr count label
  ///
  /// In en, this message translates to:
  /// **'Active Zikr'**
  String get widgetStatsActive;

  /// Widget most used zikr label
  ///
  /// In en, this message translates to:
  /// **'Most Performed'**
  String get widgetStatsMostUsed;

  /// Widget total records count label
  ///
  /// In en, this message translates to:
  /// **'Total Records'**
  String get widgetStatsTotalRecords;

  /// No widget data available message
  ///
  /// In en, this message translates to:
  /// **'No widget data yet'**
  String get widgetStatsNoData;

  /// No widget zikr performed message
  ///
  /// In en, this message translates to:
  /// **'No widget zikr performed yet'**
  String get widgetStatsNoZikr;

  /// No widget zikr data for specific period message
  ///
  /// In en, this message translates to:
  /// **'No zikr performed through widget in this period yet'**
  String get widgetStatsNoPeriodData;

  /// PDF creation success dialog title
  ///
  /// In en, this message translates to:
  /// **'PDF Successfully Created! 📄'**
  String get pdfSuccessTitle;

  /// PDF dialog open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get pdfButtonOpen;

  /// PDF dialog share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get pdfButtonShare;

  /// PDF dialog close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get pdfButtonClose;

  /// PDF report main title
  ///
  /// In en, this message translates to:
  /// **'Tasbee Pro - Detailed Statistics Report'**
  String get pdfReportTitle;

  /// PDF period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get pdfPeriodLabel;

  /// PDF date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfDateLabel;

  /// PDF total zikr card title
  ///
  /// In en, this message translates to:
  /// **'Total Zikr'**
  String get pdfTotalZikrCard;

  /// PDF most used zikr card title
  ///
  /// In en, this message translates to:
  /// **'Most Performed'**
  String get pdfMostUsedCard;

  /// PDF active zikr card title
  ///
  /// In en, this message translates to:
  /// **'Active Zikr Types'**
  String get pdfActiveZikrCard;

  /// PDF zikr details section title
  ///
  /// In en, this message translates to:
  /// **'Zikr Details'**
  String get pdfZikrDetailsTitle;

  /// Bismillah text in Arabic
  ///
  /// In en, this message translates to:
  /// **'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم'**
  String get pdfBismillah;

  /// PDF date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get pdfDate;

  /// PDF period label
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get pdfPeriod;

  /// PDF daily average label
  ///
  /// In en, this message translates to:
  /// **'Daily Average'**
  String get pdfDailyAverage;

  /// PDF active zikr ratio label
  ///
  /// In en, this message translates to:
  /// **'Active Zikr'**
  String get pdfActiveZikrRatio;

  /// PDF most used zikrs section title
  ///
  /// In en, this message translates to:
  /// **'Most Used Zikrs'**
  String get pdfMostUsedZikrs;

  /// PDF no zikr message
  ///
  /// In en, this message translates to:
  /// **'No zikr performed yet'**
  String get pdfNoZikrYet;

  /// Quran verse in Arabic
  ///
  /// In en, this message translates to:
  /// **'وَاذْكُرُوا اللَّهَ كَثِيرًا لَعَلَّكُمْ تُفْلِحُونَ'**
  String get pdfQuranVerse;

  /// Quran verse translation
  ///
  /// In en, this message translates to:
  /// **'\"Remember Allah frequently so that you may be successful.\" (Al-Anfal: 45)'**
  String get pdfQuranTranslation;

  /// PDF app credit text
  ///
  /// In en, this message translates to:
  /// **'This report was generated by Tasbee Pro application'**
  String get pdfAppCredit;

  /// PDF file open error message
  ///
  /// In en, this message translates to:
  /// **'PDF file could not be opened. Make sure a PDF reader app is installed'**
  String get pdfFileNotOpen;

  /// PDF file open error title
  ///
  /// In en, this message translates to:
  /// **'File Cannot Open'**
  String get pdfFileCannotOpen;

  /// External storage error message
  ///
  /// In en, this message translates to:
  /// **'External storage not available'**
  String get pdfExternalStorageError;

  /// Main storage path description
  ///
  /// In en, this message translates to:
  /// **'Main storage/TasbeePro'**
  String get pdfMainStoragePath;

  /// App-specific storage path description
  ///
  /// In en, this message translates to:
  /// **'App-specific folder/TasbeePro_Reports'**
  String get pdfAppSpecificPath;

  /// Documents folder path description
  ///
  /// In en, this message translates to:
  /// **'Application documents folder'**
  String get pdfDocumentsPath;

  /// Widget statistics report title in PDF
  ///
  /// In en, this message translates to:
  /// **'Tasbee Pro - Widget Statistics Report'**
  String get pdfWidgetReportTitle;

  /// Widget statistics section title in PDF
  ///
  /// In en, this message translates to:
  /// **'Widget Zikr Details'**
  String get pdfWidgetStatsSection;

  /// Total widget zikr count card title in PDF
  ///
  /// In en, this message translates to:
  /// **'Total Widget Zikr'**
  String get pdfWidgetTotalZikrCard;

  /// Most used zikr card title in PDF
  ///
  /// In en, this message translates to:
  /// **'Most Used'**
  String get pdfWidgetMostUsedCard;

  /// Active zikr types card title in PDF
  ///
  /// In en, this message translates to:
  /// **'Active Zikr Types'**
  String get pdfWidgetActiveTypesCard;

  /// Widget period statistics text in PDF
  ///
  /// In en, this message translates to:
  /// **'In this period, a total of {count} zikr were performed through the widget'**
  String pdfWidgetPeriodText(int count);

  /// Widget types statistics text in PDF
  ///
  /// In en, this message translates to:
  /// **'A total of {count} different zikr types were used'**
  String pdfWidgetTypesText(int count);

  /// Widget most used zikr text in PDF
  ///
  /// In en, this message translates to:
  /// **'Most used zikr: {name}'**
  String pdfWidgetMostUsedText(String name);

  /// Widget no zikr message in PDF
  ///
  /// In en, this message translates to:
  /// **'No zikr has been performed through the widget in this period yet'**
  String get pdfWidgetNoZikrText;

  /// Widget info section title in PDF
  ///
  /// In en, this message translates to:
  /// **'About Widget'**
  String get pdfWidgetInfoTitle;

  /// Widget info description text in PDF
  ///
  /// In en, this message translates to:
  /// **'Zikr performed through the widget are permanently saved and never deleted. This way you can track the history of your widget zikr'**
  String get pdfWidgetInfoText;

  /// Reminder screen title
  ///
  /// In en, this message translates to:
  /// **'Zikr Reminders'**
  String get reminderScreenTitle;

  /// Reminder screen description
  ///
  /// In en, this message translates to:
  /// **'Receive reminder notifications to remember zikr at your specified date and time'**
  String get reminderScreenDescription;

  /// Add reminder button text
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get reminderScreenAddButton;

  /// Empty state title for reminders
  ///
  /// In en, this message translates to:
  /// **'No reminders yet'**
  String get reminderScreenEmpty;

  /// Empty state message for reminders
  ///
  /// In en, this message translates to:
  /// **'Add reminders so you don\'t forget to do zikr'**
  String get reminderScreenEmptyMessage;

  /// Reminder delete success title
  ///
  /// In en, this message translates to:
  /// **'Deleted 🗑️'**
  String get reminderDeleteSuccess;

  /// Reminder delete success message
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted successfully'**
  String get reminderDeleteMessage;

  /// Default reminder title
  ///
  /// In en, this message translates to:
  /// **'Zikr Time'**
  String get reminderDefaultTitle;

  /// Add reminder screen title
  ///
  /// In en, this message translates to:
  /// **'New Reminder'**
  String get addReminderTitle;

  /// Add reminder screen description
  ///
  /// In en, this message translates to:
  /// **'Receive reminder notifications to remember zikr at your specified date and time'**
  String get addReminderDescription;

  /// Title input label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addReminderTitleLabel;

  /// Title input hint
  ///
  /// In en, this message translates to:
  /// **'Zikr Time'**
  String get addReminderTitleHint;

  /// Message input label
  ///
  /// In en, this message translates to:
  /// **'Message (Optional)'**
  String get addReminderMessageLabel;

  /// Message input hint
  ///
  /// In en, this message translates to:
  /// **'Time for zikr!'**
  String get addReminderMessageHint;

  /// Date time section label
  ///
  /// In en, this message translates to:
  /// **'Date and Time'**
  String get addReminderDateTimeLabel;

  /// Select date button text
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get addReminderSelectDate;

  /// Select time button text
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get addReminderSelectTime;

  /// Date picker title
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get addReminderDatePickerTitle;

  /// Time picker title
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get addReminderTimePickerTitle;

  /// Submit button text
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderSubmitButton;

  /// Invalid date error title
  ///
  /// In en, this message translates to:
  /// **'Invalid Date'**
  String get addReminderInvalidDate;

  /// Invalid date error message
  ///
  /// In en, this message translates to:
  /// **'You cannot select a past date'**
  String get addReminderInvalidDateMessage;

  /// Default reminder message
  ///
  /// In en, this message translates to:
  /// **'Time for zikr!'**
  String get addReminderDefaultMessage;

  /// Success notification title
  ///
  /// In en, this message translates to:
  /// **'Reminder Added 🔔'**
  String get addReminderSuccess;

  /// Success notification message
  ///
  /// In en, this message translates to:
  /// **'Notification will come at the specified time'**
  String get addReminderSuccessMessage;

  /// Error notification title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get addReminderError;

  /// Error notification message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while adding reminder'**
  String get addReminderErrorMessage;

  /// Permission dialog title
  ///
  /// In en, this message translates to:
  /// **'Notification Permission Required'**
  String get addReminderPermissionTitle;

  /// Permission dialog message
  ///
  /// In en, this message translates to:
  /// **'You need to grant notification permission for reminders to work.'**
  String get addReminderPermissionMessage;

  /// Permission dialog cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addReminderPermissionCancel;

  /// Permission dialog settings button
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get addReminderPermissionSettings;

  /// Custom reminder times screen title
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get customTimesTitle;

  /// Add time button text
  ///
  /// In en, this message translates to:
  /// **'Add Time'**
  String get customTimesAddButton;

  /// Custom times screen description
  ///
  /// In en, this message translates to:
  /// **'Receive daily zikr reminders at custom times. Added times repeat every day.'**
  String get customTimesDescription;

  /// Empty state title for custom times
  ///
  /// In en, this message translates to:
  /// **'No custom times added yet'**
  String get customTimesEmptyTitle;

  /// Empty state message for custom times
  ///
  /// In en, this message translates to:
  /// **'You can add custom times for daily reminders'**
  String get customTimesEmptyMessage;

  /// Active time status text
  ///
  /// In en, this message translates to:
  /// **'Daily reminder active'**
  String get customTimesActiveStatus;

  /// Inactive time status text
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get customTimesInactiveStatus;

  /// Time picker title
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get customTimesPickerTitle;

  /// Duplicate time error title
  ///
  /// In en, this message translates to:
  /// **'Already Exists'**
  String get customTimesAlreadyExists;

  /// Duplicate time error message
  ///
  /// In en, this message translates to:
  /// **'This time has already been added'**
  String get customTimesAlreadyExistsMessage;

  /// Add time success title
  ///
  /// In en, this message translates to:
  /// **'Time Added 🕐'**
  String get customTimesAddSuccess;

  /// Add time success message
  ///
  /// In en, this message translates to:
  /// **'Daily reminder active at {time}'**
  String customTimesAddSuccessMessage(String time);

  /// Time activation title
  ///
  /// In en, this message translates to:
  /// **'Activated'**
  String get customTimesToggleActive;

  /// Time deactivation title
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get customTimesToggleInactive;

  /// Time activation message
  ///
  /// In en, this message translates to:
  /// **'Reminder active'**
  String get customTimesToggleActiveMessage;

  /// Time deactivation message
  ///
  /// In en, this message translates to:
  /// **'Reminder disabled'**
  String get customTimesToggleInactiveMessage;

  /// Delete time dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Time?'**
  String get customTimesDeleteTitle;

  /// Delete time dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the reminder at {time}?'**
  String customTimesDeleteMessage(String time);

  /// Delete dialog cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customTimesDeleteCancel;

  /// Delete dialog confirm button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get customTimesDeleteConfirm;

  /// Delete success title
  ///
  /// In en, this message translates to:
  /// **'Deleted 🗑️'**
  String get customTimesDeleteSuccess;

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'{time} time deleted successfully'**
  String customTimesDeleteSuccessMessage(String time);

  /// Counter button tap text
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get counterButtonText;

  /// Message shown when the zikr target is reached
  ///
  /// In en, this message translates to:
  /// **'Masha\'Allah! Goal Completed'**
  String get progressBarCompleted;

  /// Text shown in zikr card when no meaning is available
  ///
  /// In en, this message translates to:
  /// **'Select Zikr'**
  String get zikirCardSelectText;

  /// Picker select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get pickerSelectButton;

  /// Date picker title
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get pickerDateTitle;

  /// Time picker title
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get pickerTimeTitle;

  /// Day picker label
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get pickerDay;

  /// Month picker label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get pickerMonth;

  /// Year picker label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get pickerYear;

  /// Hour picker label
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get pickerHour;

  /// Minute picker label
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get pickerMinute;

  /// January month name
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get pickerMonthJanuary;

  /// February month name
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get pickerMonthFebruary;

  /// March month name
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get pickerMonthMarch;

  /// April month name
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get pickerMonthApril;

  /// May month name
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get pickerMonthMay;

  /// June month name
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get pickerMonthJune;

  /// July month name
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get pickerMonthJuly;

  /// August month name
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get pickerMonthAugust;

  /// September month name
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get pickerMonthSeptember;

  /// October month name
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get pickerMonthOctober;

  /// November month name
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get pickerMonthNovember;

  /// December month name
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get pickerMonthDecember;

  /// Notification channel title for zikr reminders
  ///
  /// In en, this message translates to:
  /// **'Zikr Reminders'**
  String get notificationChannelTitle;

  /// Notification channel description for zikr reminders
  ///
  /// In en, this message translates to:
  /// **'Reminds you to do zikr'**
  String get notificationChannelDescription;

  /// Notification channel title for daily reminders
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get notificationDailyChannelTitle;

  /// Notification channel description for daily reminders
  ///
  /// In en, this message translates to:
  /// **'Daily zikr reminders at set times'**
  String get notificationDailyChannelDescription;

  /// Error message when notification permission is required
  ///
  /// In en, this message translates to:
  /// **'Notification permission required'**
  String get notificationPermissionRequired;

  /// Notification title for zikr time
  ///
  /// In en, this message translates to:
  /// **'Zikr Time 🕌'**
  String get notificationZikirTime;

  /// Daily zikr notification message
  ///
  /// In en, this message translates to:
  /// **'Daily zikr time has come!'**
  String get notificationDailyZikirMessage;

  /// Zikr reminder notification ticker text
  ///
  /// In en, this message translates to:
  /// **'Zikr Reminder'**
  String get notificationZikirReminder;

  /// Detailed zikr reminder notification message
  ///
  /// In en, this message translates to:
  /// **'Daily zikr time has come! SubhanAllah, Alhamdulillah, Allahu Akbar'**
  String get notificationDetailedMessage;

  /// Settings permissions section title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsPermissions;

  /// Settings permissions title
  ///
  /// In en, this message translates to:
  /// **'App Permissions'**
  String get settingsPermissionsTitle;

  /// Settings permissions subtitle
  ///
  /// In en, this message translates to:
  /// **'View and manage app permissions'**
  String get settingsPermissionsSubtitle;

  /// Permissions screen title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// Permissions info title
  ///
  /// In en, this message translates to:
  /// **'Permission Information'**
  String get permissionsInfoTitle;

  /// Permissions info description
  ///
  /// In en, this message translates to:
  /// **'On this page, you can view and manage the permissions required for the app to function properly. Tap on the relevant permission card to grant permissions.'**
  String get permissionsInfoDescription;

  /// Required permissions section title
  ///
  /// In en, this message translates to:
  /// **'Required Permissions'**
  String get permissionsRequired;

  /// Request all permissions button
  ///
  /// In en, this message translates to:
  /// **'Request All Permissions'**
  String get permissionsRequestAll;

  /// Open app settings button
  ///
  /// In en, this message translates to:
  /// **'Open App Settings'**
  String get permissionsOpenSettings;

  /// Permission granted status
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionGranted;

  /// Permission denied status
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionDenied;

  /// Permission permanently denied status (short)
  ///
  /// In en, this message translates to:
  /// **'Permanently Denied'**
  String get permissionPermanentlyDeniedShort;

  /// Permission restricted status
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get permissionRestricted;

  /// Permission unknown status
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get permissionUnknown;

  /// Permission permanently denied warning message
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. You need to enable it manually from settings.'**
  String get permissionPermanentlyDenied;

  /// Notification permission title
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get permissionNotificationTitle;

  /// Alarm permission title
  ///
  /// In en, this message translates to:
  /// **'Alarm Permission'**
  String get permissionAlarmTitle;

  /// Unknown permission title
  ///
  /// In en, this message translates to:
  /// **'Unknown Permission'**
  String get permissionUnknownTitle;

  /// Notification permission description
  ///
  /// In en, this message translates to:
  /// **'Required for zikr reminders and notifications'**
  String get permissionNotificationDescription;

  /// Alarm permission description
  ///
  /// In en, this message translates to:
  /// **'Required for timely reminders (Android 12+)'**
  String get permissionAlarmDescription;

  /// Unknown permission description
  ///
  /// In en, this message translates to:
  /// **'No information available about this permission'**
  String get permissionUnknownDescription;

  /// Permission already granted title
  ///
  /// In en, this message translates to:
  /// **'Permission Already Granted'**
  String get permissionAlreadyGranted;

  /// Permission already granted message
  ///
  /// In en, this message translates to:
  /// **'This permission is already granted.'**
  String get permissionAlreadyGrantedMessage;

  /// Permission granted success message
  ///
  /// In en, this message translates to:
  /// **'Permission granted successfully!'**
  String get permissionGrantedMessage;

  /// Permission permanently denied message
  ///
  /// In en, this message translates to:
  /// **'Permission permanently denied. You can enable it manually from settings.'**
  String get permissionPermanentlyDeniedMessage;

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'Permission denied. You can try again.'**
  String get permissionDeniedMessage;

  /// Permission request error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while requesting permission.'**
  String get permissionRequestError;

  /// All permissions granted title
  ///
  /// In en, this message translates to:
  /// **'All Permissions Granted'**
  String get permissionsAllGranted;

  /// All permissions granted message
  ///
  /// In en, this message translates to:
  /// **'All required permissions have been granted successfully!'**
  String get permissionsAllGrantedMessage;

  /// Some permissions granted title
  ///
  /// In en, this message translates to:
  /// **'Some Permissions Granted'**
  String get permissionsSomeGranted;

  /// Some permissions granted message
  ///
  /// In en, this message translates to:
  /// **'Some permissions granted. You can grant missing permissions manually.'**
  String get permissionsSomeGrantedMessage;

  /// Permissions request error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred while requesting permissions.'**
  String get permissionsRequestError;

  /// Manual permission required dialog title
  ///
  /// In en, this message translates to:
  /// **'Manual Permission Required'**
  String get permissionManualTitle;

  /// Manual permission required dialog message
  ///
  /// In en, this message translates to:
  /// **'This permission has been permanently denied. You need to enable it manually from the settings page.'**
  String get permissionManualMessage;

  /// Battery optimization permission title
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization'**
  String get permissionBatteryTitle;

  /// Battery optimization permission description
  ///
  /// In en, this message translates to:
  /// **'Required for reliable background notifications'**
  String get permissionBatteryDescription;

  /// Error message for generic errors
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Title shown when user completes their target
  ///
  /// In en, this message translates to:
  /// **'Congratulations! 🎉'**
  String get targetCompletionTitle;

  /// Message shown when user completes their target
  ///
  /// In en, this message translates to:
  /// **'You\'ve completed your target!'**
  String get targetCompletionMessage;

  /// Title shown when custom zikr is successfully added
  ///
  /// In en, this message translates to:
  /// **'Success! 🎉'**
  String get customZikirAddedTitle;

  /// No description provided for @customZikirAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'Custom zikr added'**
  String get customZikirAddedMessage;

  /// Title for delete zikr confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Zikr'**
  String get deleteZikirTitle;

  /// Message for delete zikr confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this zikr?'**
  String get deleteZikirMessage;

  /// Confirm button text for delete zikr dialog
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteZikirConfirm;

  /// Cancel button text for delete zikr dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteZikirCancel;

  /// Success message when zikr is deleted
  ///
  /// In en, this message translates to:
  /// **'Deleted! 🗑️'**
  String get deleteZikirSuccess;

  /// Message shown when device is in landscape mode
  ///
  /// In en, this message translates to:
  /// **'📱 Please rotate your device to portrait mode'**
  String get rotateDeviceMessage;

  /// Notification settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Notification Settings Help 🔔'**
  String get notificationSettingsDialogTitle;

  /// Notification settings dialog main message
  ///
  /// In en, this message translates to:
  /// **'For Tasbee Pro to remind you at the right time, some permissions need to be enabled in device settings.\nPlease check the following:'**
  String get notificationSettingsDialogMessage;

  /// Notification permission label
  ///
  /// In en, this message translates to:
  /// **'Notification permission: Make sure app notifications are allowed.'**
  String get notificationSettingsPermission;

  /// Battery and background settings label
  ///
  /// In en, this message translates to:
  /// **'Battery and background settings: Allow Tasbee Pro to run in the background.'**
  String get notificationSettingsBattery;

  /// Do not disturb optional setting
  ///
  /// In en, this message translates to:
  /// **'Allow interruptions (optional): Enable this option for reminders to appear even in silent mode.'**
  String get notificationSettingsDoNotDisturb;

  /// Lock screen notification setting
  ///
  /// In en, this message translates to:
  /// **'Show on lock screen: Allow notifications to appear on the lock screen. (Notifications may be hidden on some devices.)'**
  String get notificationSettingsLockScreen;

  /// Device restart tip
  ///
  /// In en, this message translates to:
  /// **'Opening the app once after device restart refreshes the notification system.'**
  String get notificationSettingsRestart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bn',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'hi',
    'id',
    'it',
    'ms',
    'pt',
    'ru',
    'tr',
    'ur',
    'uz',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ms':
      return AppLocalizationsMs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
