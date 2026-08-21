import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
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
    Locale('gu'),
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

  /// Gujarati language name
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી'**
  String get gujarati;

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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @homeDateZone.
  ///
  /// In en, this message translates to:
  /// **'Wed, 22 Jul · Surat Zone'**
  String get homeDateZone;

  /// No description provided for @zoneName.
  ///
  /// In en, this message translates to:
  /// **'EERL - Surat Zone'**
  String get zoneName;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'You’re Online'**
  String get onlineStatus;

  /// No description provided for @pendingCollections.
  ///
  /// In en, this message translates to:
  /// **'{count} collection pending'**
  String pendingCollections(int count);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Summary'**
  String get todaysSummary;

  /// No description provided for @collectedToday.
  ///
  /// In en, this message translates to:
  /// **'Collected Today'**
  String get collectedToday;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'{value} KG'**
  String weightKg(int value);

  /// No description provided for @verifiedEntries.
  ///
  /// In en, this message translates to:
  /// **'Verified Entries'**
  String get verifiedEntries;

  /// No description provided for @transferRequests.
  ///
  /// In en, this message translates to:
  /// **'Transfer Requests'**
  String get transferRequests;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get walletBalance;

  /// No description provided for @walletAmount.
  ///
  /// In en, this message translates to:
  /// **'₹{amount}'**
  String walletAmount(String amount);

  /// No description provided for @startCollection.
  ///
  /// In en, this message translates to:
  /// **'Start Collection'**
  String get startCollection;

  /// No description provided for @recordWeightProof.
  ///
  /// In en, this message translates to:
  /// **'Record weight & upload proof.'**
  String get recordWeightProof;

  /// No description provided for @addCollection.
  ///
  /// In en, this message translates to:
  /// **'Add Collection'**
  String get addCollection;

  /// No description provided for @walletLogExpense.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Log Expense'**
  String get walletLogExpense;

  /// No description provided for @trackFieldSpending.
  ///
  /// In en, this message translates to:
  /// **'Track field spending.'**
  String get trackFieldSpending;

  /// No description provided for @logExpense.
  ///
  /// In en, this message translates to:
  /// **'Log Expense'**
  String get logExpense;

  /// No description provided for @collectionTypes.
  ///
  /// In en, this message translates to:
  /// **'Collection types'**
  String get collectionTypes;

  /// No description provided for @d2d.
  ///
  /// In en, this message translates to:
  /// **'D2D'**
  String get d2d;

  /// No description provided for @smcVehicle.
  ///
  /// In en, this message translates to:
  /// **'SMC Vehicle'**
  String get smcVehicle;

  /// No description provided for @mrfStation.
  ///
  /// In en, this message translates to:
  /// **'MRF Station'**
  String get mrfStation;

  /// No description provided for @materialRecoveryFacility.
  ///
  /// In en, this message translates to:
  /// **'Material Recovery Facility'**
  String get materialRecoveryFacility;

  /// No description provided for @ramp.
  ///
  /// In en, this message translates to:
  /// **'Ramp'**
  String get ramp;

  /// No description provided for @retailDealer.
  ///
  /// In en, this message translates to:
  /// **'Retail Dealer'**
  String get retailDealer;

  /// No description provided for @collectionDrafts.
  ///
  /// In en, this message translates to:
  /// **'Collection Drafts'**
  String get collectionDrafts;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @pendingSubmission.
  ///
  /// In en, this message translates to:
  /// **'Pending Submission'**
  String get pendingSubmission;

  /// No description provided for @draftStationName.
  ///
  /// In en, this message translates to:
  /// **'MRF Station Aanjana'**
  String get draftStationName;

  /// No description provided for @draftLocation.
  ///
  /// In en, this message translates to:
  /// **'Udhna, Sardar Market, Surat'**
  String get draftLocation;

  /// No description provided for @continueCollection.
  ///
  /// In en, this message translates to:
  /// **'Continue Collection'**
  String get continueCollection;

  /// No description provided for @dayClosure.
  ///
  /// In en, this message translates to:
  /// **'Day Closure'**
  String get dayClosure;

  /// No description provided for @endMyDay.
  ///
  /// In en, this message translates to:
  /// **'End My Day'**
  String get endMyDay;

  /// No description provided for @reviewCloseDay.
  ///
  /// In en, this message translates to:
  /// **'Review today\'s work, sync data and close your day.'**
  String get reviewCloseDay;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @collections.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get collections;

  /// No description provided for @otpExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code will expire in {time}'**
  String otpExpiresIn(String time);

  /// No description provided for @resendOtpCountdown.
  ///
  /// In en, this message translates to:
  /// **'{label} ({seconds}s)'**
  String resendOtpCountdown(String label, int seconds);

  /// No description provided for @plasticWasteManagement.
  ///
  /// In en, this message translates to:
  /// **'PLASTIC WASTE MANAGEMENT'**
  String get plasticWasteManagement;

  /// No description provided for @walletTab.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTab;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @dashboardEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No dashboard pages are available.'**
  String get dashboardEmptyMessage;

  /// No description provided for @walletFieldExpenses.
  ///
  /// In en, this message translates to:
  /// **'Wallet & Field Expenses'**
  String get walletFieldExpenses;

  /// No description provided for @availableCashBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Cash Balance'**
  String get availableCashBalance;

  /// No description provided for @availableCashBalanceValue.
  ///
  /// In en, this message translates to:
  /// **'₹50,000'**
  String get availableCashBalanceValue;

  /// No description provided for @todaysSpent.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Spent'**
  String get todaysSpent;

  /// No description provided for @todaysSpentValue.
  ///
  /// In en, this message translates to:
  /// **'₹4,500'**
  String get todaysSpentValue;

  /// No description provided for @fieldSpendingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Need to log field spending?'**
  String get fieldSpendingPrompt;

  /// No description provided for @fieldSpendingDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload receipt and request approval for fuel or operational costs.'**
  String get fieldSpendingDescription;

  /// No description provided for @recentExpenseClaims.
  ///
  /// In en, this message translates to:
  /// **'Recent Expense Claims'**
  String get recentExpenseClaims;

  /// No description provided for @expenseSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search By Receipt Number, Name, Date...'**
  String get expenseSearchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get filterClosed;

  /// No description provided for @expenseFuelDiesel.
  ///
  /// In en, this message translates to:
  /// **'Fuel / Diesel'**
  String get expenseFuelDiesel;

  /// No description provided for @expenseFuelDate.
  ///
  /// In en, this message translates to:
  /// **'Today • 08:15 AM'**
  String get expenseFuelDate;

  /// No description provided for @expenseFuelAmount.
  ///
  /// In en, this message translates to:
  /// **'-₹350'**
  String get expenseFuelAmount;

  /// No description provided for @expensePendingSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Pending by Supervisor'**
  String get expensePendingSupervisor;

  /// No description provided for @expenseScaleFee.
  ///
  /// In en, this message translates to:
  /// **'Scale Fee / Weighbridge Fee'**
  String get expenseScaleFee;

  /// No description provided for @expenseScaleDate.
  ///
  /// In en, this message translates to:
  /// **'Yesterday • 10:15 AM'**
  String get expenseScaleDate;

  /// No description provided for @expenseScaleAmount.
  ///
  /// In en, this message translates to:
  /// **'-₹720'**
  String get expenseScaleAmount;

  /// No description provided for @expenseVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get expenseVerified;

  /// No description provided for @expenseVehicleMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Maintenance'**
  String get expenseVehicleMaintenance;

  /// No description provided for @expenseVehicleDate.
  ///
  /// In en, this message translates to:
  /// **'20 July 2026 • 01:15 PM'**
  String get expenseVehicleDate;

  /// No description provided for @expenseVehicleAmount.
  ///
  /// In en, this message translates to:
  /// **'-₹1500'**
  String get expenseVehicleAmount;

  /// No description provided for @expenseFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get expenseFlagged;

  /// No description provided for @drawerUserName.
  ///
  /// In en, this message translates to:
  /// **'Rahul Patel'**
  String get drawerUserName;

  /// No description provided for @drawerUserRole.
  ///
  /// In en, this message translates to:
  /// **'Collection Agent'**
  String get drawerUserRole;

  /// No description provided for @drawerCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get drawerCollection;

  /// No description provided for @drawerReceipts.
  ///
  /// In en, this message translates to:
  /// **'Receipts'**
  String get drawerReceipts;

  /// No description provided for @drawerConfigureMaterials.
  ///
  /// In en, this message translates to:
  /// **'Configure Material List'**
  String get drawerConfigureMaterials;

  /// No description provided for @drawerSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get drawerSyncStatus;

  /// No description provided for @drawerHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get drawerHelpSupport;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @drawerPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by Eco Vision'**
  String get drawerPoweredBy;

  /// No description provided for @expenseCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseCategoryLabel;

  /// No description provided for @selectExpenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Expense Category'**
  String get selectExpenseCategory;

  /// No description provided for @expenseAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense Amount (₹)'**
  String get expenseAmountLabel;

  /// No description provided for @expenseAmountHint.
  ///
  /// In en, this message translates to:
  /// **'₹ Enter Expense Amount'**
  String get expenseAmountHint;

  /// No description provided for @uploadReceiptLabel.
  ///
  /// In en, this message translates to:
  /// **'Upload Receipt'**
  String get uploadReceiptLabel;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @receiptSupportMessage.
  ///
  /// In en, this message translates to:
  /// **'Supported: JPG, PNG (Max 5MB). Receipt must be clearly visible for supervisor review.'**
  String get receiptSupportMessage;

  /// No description provided for @expenseDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseDescriptionLabel;

  /// No description provided for @expenseDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add Description'**
  String get expenseDescriptionHint;

  /// No description provided for @expenseDescriptionCounter.
  ///
  /// In en, this message translates to:
  /// **'Max 150 Characters'**
  String get expenseDescriptionCounter;

  /// No description provided for @submitExpenseClaim.
  ///
  /// In en, this message translates to:
  /// **'Submit Expense Claim'**
  String get submitExpenseClaim;

  /// No description provided for @expensePendingPrefix.
  ///
  /// In en, this message translates to:
  /// **'This entry will be marked as '**
  String get expensePendingPrefix;

  /// No description provided for @expensePendingStatus.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get expensePendingStatus;

  /// No description provided for @expensePendingSuffix.
  ///
  /// In en, this message translates to:
  /// **' until reviewed by a supervisor.'**
  String get expensePendingSuffix;

  /// No description provided for @expenseCategoryLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get expenseCategoryLabour;

  /// No description provided for @expenseCategoryFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel / Diesel'**
  String get expenseCategoryFuel;

  /// No description provided for @expenseCategoryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Maintenance'**
  String get expenseCategoryVehicle;

  /// No description provided for @expenseCategoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food / Refreshment'**
  String get expenseCategoryFood;

  /// No description provided for @expenseCategorySupplies.
  ///
  /// In en, this message translates to:
  /// **'Supplies / Loading Material'**
  String get expenseCategorySupplies;

  /// No description provided for @expenseCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other expense types'**
  String get expenseCategoryOther;

  /// No description provided for @expenseClaimReference.
  ///
  /// In en, this message translates to:
  /// **'#EXP-2026-089'**
  String get expenseClaimReference;

  /// No description provided for @expenseDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Expense Category'**
  String get expenseDetailCategory;

  /// No description provided for @expenseDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseDetailAmount;

  /// No description provided for @expenseDetailAmountValue.
  ///
  /// In en, this message translates to:
  /// **'₹350'**
  String get expenseDetailAmountValue;

  /// No description provided for @expenseRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested By'**
  String get expenseRequestedBy;

  /// No description provided for @expenseRequestedByValue.
  ///
  /// In en, this message translates to:
  /// **'Rahul Patel'**
  String get expenseRequestedByValue;

  /// No description provided for @expenseDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get expenseDateTime;

  /// No description provided for @expenseRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get expenseRequestStatus;

  /// No description provided for @expenseWaitingSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Supervisor'**
  String get expenseWaitingSupervisor;

  /// No description provided for @expenseVerifiedSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Verified by Supervisor'**
  String get expenseVerifiedSupervisor;

  /// No description provided for @expenseRejectedSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Supervisor'**
  String get expenseRejectedSupervisor;

  /// No description provided for @expenseUploadedPhoto.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Photo'**
  String get expenseUploadedPhoto;

  /// No description provided for @expenseDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Please state the purpose of this expense and any relevant details needed for supervisor approval.'**
  String get expenseDetailDescription;

  /// No description provided for @expenseRejectReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason for Reject'**
  String get expenseRejectReasonTitle;

  /// No description provided for @expenseRejectReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get expenseRejectReasonLabel;

  /// No description provided for @expenseRejectReasonValue.
  ///
  /// In en, this message translates to:
  /// **'Invalid / Clear Bill Missing\nPolicy Violation / Personal Expense'**
  String get expenseRejectReasonValue;

  /// No description provided for @expenseRejectRemarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get expenseRejectRemarksLabel;

  /// No description provided for @expenseRejectRemarksValue.
  ///
  /// In en, this message translates to:
  /// **'This request violates company policy as a duplicate receipt was submitted. Expense rejected.'**
  String get expenseRejectRemarksValue;

  /// No description provided for @startYourCollections.
  ///
  /// In en, this message translates to:
  /// **'Start your collections'**
  String get startYourCollections;

  /// No description provided for @recentCollections.
  ///
  /// In en, this message translates to:
  /// **'Recent Collections'**
  String get recentCollections;

  /// No description provided for @collectionReceipt248.
  ///
  /// In en, this message translates to:
  /// **'RC-000248'**
  String get collectionReceipt248;

  /// No description provided for @collectionReceipt247.
  ///
  /// In en, this message translates to:
  /// **'RC-000247'**
  String get collectionReceipt247;

  /// No description provided for @collectionReceipt246.
  ///
  /// In en, this message translates to:
  /// **'RC-000246'**
  String get collectionReceipt246;

  /// No description provided for @collectionWeight245.
  ///
  /// In en, this message translates to:
  /// **'245 kg'**
  String get collectionWeight245;

  /// No description provided for @collectionWeight115.
  ///
  /// In en, this message translates to:
  /// **'115 kg'**
  String get collectionWeight115;

  /// No description provided for @collectionWeight320.
  ///
  /// In en, this message translates to:
  /// **'320 kg'**
  String get collectionWeight320;

  /// No description provided for @collectionRejectedSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Rejected by Supervisor'**
  String get collectionRejectedSupervisor;

  /// No description provided for @recordsCollectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get recordsCollectionsTitle;

  /// No description provided for @recordsCollectionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage all your collections'**
  String get recordsCollectionsSubtitle;

  /// No description provided for @recordsHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get recordsHistory;

  /// No description provided for @recordsDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get recordsDrafts;

  /// No description provided for @recordsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get recordsSearchHint;

  /// No description provided for @recordsTodayCollections.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Collections'**
  String get recordsTodayCollections;

  /// No description provided for @recordsYesterdayCollections.
  ///
  /// In en, this message translates to:
  /// **'Yesterday’s Collections'**
  String get recordsYesterdayCollections;

  /// No description provided for @recordsOctoberCollections.
  ///
  /// In en, this message translates to:
  /// **'22 October Collections'**
  String get recordsOctoberCollections;

  /// No description provided for @recordsCollectionDrafts.
  ///
  /// In en, this message translates to:
  /// **'Collection Drafts'**
  String get recordsCollectionDrafts;

  /// No description provided for @recordsTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Today • 08:15 AM'**
  String get recordsTodayTime;

  /// No description provided for @recordsOctober22Time.
  ///
  /// In en, this message translates to:
  /// **'22 October • 11:15 AM'**
  String get recordsOctober22Time;

  /// No description provided for @recordsOctober21Time.
  ///
  /// In en, this message translates to:
  /// **'21 October • 03:15 PM'**
  String get recordsOctober21Time;

  /// No description provided for @recordsFiveItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'5 Items Selected'**
  String get recordsFiveItemsSelected;

  /// No description provided for @recordsDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get recordsDiscard;

  /// No description provided for @recordsContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get recordsContinue;

  /// No description provided for @recordsAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get recordsAreYouSure;

  /// No description provided for @recordsDiscardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard this collection draft'**
  String get recordsDiscardConfirmation;

  /// No description provided for @recordsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get recordsCancel;

  /// No description provided for @recordsNoDrafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts for now'**
  String get recordsNoDrafts;

  /// No description provided for @profileUserProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileUserProfile;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account details & info'**
  String get profileSubtitle;

  /// No description provided for @profileAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get profileAccountInformation;

  /// No description provided for @profileAssignedFacility.
  ///
  /// In en, this message translates to:
  /// **'Assigned Facility'**
  String get profileAssignedFacility;

  /// No description provided for @profileFacilityValue.
  ///
  /// In en, this message translates to:
  /// **'EERL – Surat South'**
  String get profileFacilityValue;

  /// No description provided for @profileMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get profileMobileNumber;

  /// No description provided for @profileMobileValue.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43210'**
  String get profileMobileValue;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRole;

  /// No description provided for @profileSessionExpires.
  ///
  /// In en, this message translates to:
  /// **'Session Expires'**
  String get profileSessionExpires;

  /// No description provided for @profileSessionExpiryValue.
  ///
  /// In en, this message translates to:
  /// **'29 July'**
  String get profileSessionExpiryValue;

  /// No description provided for @profileActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get profileActions;

  /// No description provided for @profileSyncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get profileSyncData;

  /// No description provided for @profileSyncSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your offline data'**
  String get profileSyncSubtitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get profileLogoutSubtitle;

  /// No description provided for @collectionDetailPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Supervisor Verification'**
  String get collectionDetailPending;

  /// No description provided for @collectionDetailApproved.
  ///
  /// In en, this message translates to:
  /// **'Verified & Approved'**
  String get collectionDetailApproved;

  /// No description provided for @collectionDetailReasonForReject.
  ///
  /// In en, this message translates to:
  /// **'Reason for Reject'**
  String get collectionDetailReasonForReject;

  /// No description provided for @collectionDetailReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get collectionDetailReasonLabel;

  /// No description provided for @collectionDetailReasonValue.
  ///
  /// In en, this message translates to:
  /// **'No Vehicle Available'**
  String get collectionDetailReasonValue;

  /// No description provided for @collectionDetailRemarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get collectionDetailRemarksLabel;

  /// No description provided for @collectionDetailRemarksValue.
  ///
  /// In en, this message translates to:
  /// **'All yard trucks are currently out. Try after 2PM.'**
  String get collectionDetailRemarksValue;

  /// No description provided for @collectionDetailId.
  ///
  /// In en, this message translates to:
  /// **'Collection ID:'**
  String get collectionDetailId;

  /// No description provided for @collectionDetailDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get collectionDetailDateTime;

  /// No description provided for @collectionDetailDateValue.
  ///
  /// In en, this message translates to:
  /// **'24 Oct 2026, 03:45 PM'**
  String get collectionDetailDateValue;

  /// No description provided for @collectionDetailType.
  ///
  /// In en, this message translates to:
  /// **'Collection type'**
  String get collectionDetailType;

  /// No description provided for @collectionDetailAgent.
  ///
  /// In en, this message translates to:
  /// **'Collection Agent'**
  String get collectionDetailAgent;

  /// No description provided for @collectionDetailReceivedItems.
  ///
  /// In en, this message translates to:
  /// **'Received Items'**
  String get collectionDetailReceivedItems;

  /// No description provided for @collectionDetailPetBottles.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles'**
  String get collectionDetailPetBottles;

  /// No description provided for @collectionDetailHdpeRigid.
  ///
  /// In en, this message translates to:
  /// **'HDPE Rigid'**
  String get collectionDetailHdpeRigid;

  /// No description provided for @collectionDetailPpHardPlastics.
  ///
  /// In en, this message translates to:
  /// **'PP Hard Plastics'**
  String get collectionDetailPpHardPlastics;

  /// No description provided for @collectionDetailCollectionWeight.
  ///
  /// In en, this message translates to:
  /// **'Collection Weight *'**
  String get collectionDetailCollectionWeight;

  /// No description provided for @collectionDetailVerifiedWeight.
  ///
  /// In en, this message translates to:
  /// **'Verified Weight'**
  String get collectionDetailVerifiedWeight;

  /// No description provided for @collectionDetailRate.
  ///
  /// In en, this message translates to:
  /// **'Rate: ₹45.00/KG'**
  String get collectionDetailRate;

  /// No description provided for @collectionDetailMaterialTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: ₹12,150.00'**
  String get collectionDetailMaterialTotal;

  /// No description provided for @collectionDetailRampPersonPhoto.
  ///
  /// In en, this message translates to:
  /// **'Ramp Person Photo'**
  String get collectionDetailRampPersonPhoto;

  /// No description provided for @collectionDetailTotalCollectionWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Collection Weight'**
  String get collectionDetailTotalCollectionWeight;

  /// No description provided for @collectionDetailTotalVerifiedWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Verified Weight'**
  String get collectionDetailTotalVerifiedWeight;

  /// No description provided for @collectionDetailWeightComparison.
  ///
  /// In en, this message translates to:
  /// **'Weight Comparison'**
  String get collectionDetailWeightComparison;

  /// No description provided for @collectionDetailComparisonHint.
  ///
  /// In en, this message translates to:
  /// **'(0.00 KG Difference if exact match)'**
  String get collectionDetailComparisonHint;

  /// No description provided for @collectionDetailTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get collectionDetailTotalPrice;

  /// No description provided for @collectionDetailPreviewSlip.
  ///
  /// In en, this message translates to:
  /// **'Preview Slip'**
  String get collectionDetailPreviewSlip;

  /// No description provided for @syncOfflineDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Offline Data'**
  String get syncOfflineDataTitle;

  /// No description provided for @syncPendingCollections.
  ///
  /// In en, this message translates to:
  /// **'3 collection Pending'**
  String get syncPendingCollections;

  /// No description provided for @syncAlreadySyncedTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Already Synced'**
  String get syncAlreadySyncedTitle;

  /// No description provided for @syncBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get syncBack;

  /// No description provided for @logoutConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmationTitle;

  /// No description provided for @logoutConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Any unsynced offline data will remain on this device until your next sign-in.'**
  String get logoutConfirmationMessage;

  /// No description provided for @logoutUnsyncedTripsPending.
  ///
  /// In en, this message translates to:
  /// **'3 Unsynced Trips Pending'**
  String get logoutUnsyncedTripsPending;

  /// No description provided for @logoutNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get logoutNo;

  /// No description provided for @logoutYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get logoutYes;
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
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
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
