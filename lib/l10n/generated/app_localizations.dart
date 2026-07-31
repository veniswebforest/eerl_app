import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('hi'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'EERL App'**
  String get appTitle;

  /// Home tab label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Profile tab label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings tab label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Details screen title
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// Welcome greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to EERL'**
  String get welcomeMessage;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Your production-ready Flutter application'**
  String get welcomeSubtitle;

  /// Section title for feature cards
  ///
  /// In en, this message translates to:
  /// **'Explore Features'**
  String get exploreFeatures;

  /// Localization feature name
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localization;

  /// Description of localization feature
  ///
  /// In en, this message translates to:
  /// **'Multi-language support with English and Hindi'**
  String get localizationDesc;

  /// Dark mode feature name
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Description of dark mode feature
  ///
  /// In en, this message translates to:
  /// **'Seamless light and dark theme switching'**
  String get darkModeDesc;

  /// Theming feature name
  ///
  /// In en, this message translates to:
  /// **'Theming'**
  String get theming;

  /// Description of theming feature
  ///
  /// In en, this message translates to:
  /// **'Centralized color and style management'**
  String get themingDesc;

  /// Navigation feature name
  ///
  /// In en, this message translates to:
  /// **'Navigation'**
  String get navigation;

  /// Description of navigation feature
  ///
  /// In en, this message translates to:
  /// **'Declarative routing with GoRouter'**
  String get navigationDesc;

  /// Button text to view details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Title for feature detail screen
  ///
  /// In en, this message translates to:
  /// **'Feature Detail'**
  String get featureDetail;

  /// Body text for feature detail screen
  ///
  /// In en, this message translates to:
  /// **'This screen demonstrates route navigation with arguments. The feature you selected is displayed below.'**
  String get featureDetailBody;

  /// Displays feature name with label
  ///
  /// In en, this message translates to:
  /// **'Feature: {name}'**
  String featureName(String name);

  /// Button text to navigate back
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// Default profile name
  ///
  /// In en, this message translates to:
  /// **'EERL User'**
  String get profileName;

  /// Default profile email
  ///
  /// In en, this message translates to:
  /// **'user@eerl.app'**
  String get profileEmail;

  /// Default profile bio
  ///
  /// In en, this message translates to:
  /// **'A Flutter developer building amazing applications.'**
  String get profileBio;

  /// Button text to edit profile
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Section title for account info
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// Label for member since date
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// Default member since date
  ///
  /// In en, this message translates to:
  /// **'January 2025'**
  String get memberSinceDate;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Current app version number
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersionNumber;

  /// Label for account status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Active status text
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkThemeOption;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get hindi;

  /// General section title
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// Notifications setting label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Notifications setting description
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get notificationsDesc;

  /// About section title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Privacy policy label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Licenses label
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get licenses;

  /// Button text to show bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Show Bottom Sheet'**
  String get showBottomSheet;

  /// Button text to show dialog
  ///
  /// In en, this message translates to:
  /// **'Show Dialog'**
  String get showDialog;

  /// Button text to show snackbar
  ///
  /// In en, this message translates to:
  /// **'Show Snackbar'**
  String get showSnackbar;

  /// Title for sample bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Bottom Sheet'**
  String get sampleBottomSheetTitle;

  /// Message in sample bottom sheet
  ///
  /// In en, this message translates to:
  /// **'This is a themed bottom sheet that adapts to light and dark modes with localized text.'**
  String get sampleBottomSheetMessage;

  /// Title for sample dialog
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get sampleDialogTitle;

  /// Message in sample dialog
  ///
  /// In en, this message translates to:
  /// **'This dialog adapts to both light and dark themes. All text is localized.'**
  String get sampleDialogMessage;

  /// Message in sample snackbar
  ///
  /// In en, this message translates to:
  /// **'This is a themed snackbar message! ✨'**
  String get sampleSnackbarMessage;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// 404 error title
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get pageNotFound;

  /// 404 error message
  ///
  /// In en, this message translates to:
  /// **'The page you\'re looking for doesn\'t exist.'**
  String get pageNotFoundMessage;

  /// Button text to return to home
  ///
  /// In en, this message translates to:
  /// **'Return Home'**
  String get returnHome;

  /// Section title for quick actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Title for theme selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Title for language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Welcome title on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get loginWelcome;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Login with your phone number'**
  String get loginSubtitle;

  /// Label for mobile input
  ///
  /// In en, this message translates to:
  /// **'Enter Your Mobile Number'**
  String get mobileNumberLabel;

  /// Hint for mobile input
  ///
  /// In en, this message translates to:
  /// **'Enter your number'**
  String get mobileNumberHint;

  /// Error message for invalid mobile number
  ///
  /// In en, this message translates to:
  /// **'Please Enter Valid Mobile Number'**
  String get invalidMobileNumber;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// Title on OTP screen
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get otpTitle;

  /// Description on OTP screen
  ///
  /// In en, this message translates to:
  /// **'We sent a security code to your Reporting Manager for approval ({phone})'**
  String otpDescription(String phone);

  /// Error message for invalid OTP
  ///
  /// In en, this message translates to:
  /// **'This Code has expired, Please Request New One.'**
  String get invalidOtp;

  /// Success message for OTP verification
  ///
  /// In en, this message translates to:
  /// **'OTP Verified Successfully!'**
  String get otpVerified;

  /// Prompt for resending OTP
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get OTP?'**
  String get didntGetOtp;

  /// Resend OTP button text
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendOtp;

  /// Verify button text
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyBtn;
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
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
