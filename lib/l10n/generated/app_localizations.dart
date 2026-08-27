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

  /// No description provided for @transferSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get transferSearchHint;

  /// No description provided for @transferFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transferFilterAll;

  /// No description provided for @transferFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transferFilterPending;

  /// No description provided for @transferFilterDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get transferFilterDispatch;

  /// No description provided for @transferFilterClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get transferFilterClosed;

  /// No description provided for @transferDestination.
  ///
  /// In en, this message translates to:
  /// **'To: City Processing Hub - Sector 4'**
  String get transferDestination;

  /// No description provided for @transferFromCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'(From Current Location)'**
  String get transferFromCurrentLocation;

  /// No description provided for @transferEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No Transfer Request Found'**
  String get transferEmptyMessage;

  /// No description provided for @transferStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transferStatusPending;

  /// No description provided for @transferStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get transferStatusApproved;

  /// No description provided for @transferStatusDispatch.
  ///
  /// In en, this message translates to:
  /// **'Dispatch'**
  String get transferStatusDispatch;

  /// No description provided for @transferStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get transferStatusRejected;

  /// No description provided for @transferTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total : {weight}'**
  String transferTotalWeight(String weight);

  /// No description provided for @transferDateTime.
  ///
  /// In en, this message translates to:
  /// **'{date} • {time}'**
  String transferDateTime(String date, String time);

  /// No description provided for @transferSelectItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Items to Transfer'**
  String get transferSelectItemsTitle;

  /// No description provided for @transferSelectItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose items and enter the quantity you want to transfer.'**
  String get transferSelectItemsSubtitle;

  /// No description provided for @transferPlasticWaste.
  ///
  /// In en, this message translates to:
  /// **'Plastic Waste'**
  String get transferPlasticWaste;

  /// No description provided for @transferToyWaste.
  ///
  /// In en, this message translates to:
  /// **'Toy Waste'**
  String get transferToyWaste;

  /// No description provided for @transferCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity {weight}'**
  String transferCapacity(String weight);

  /// No description provided for @transferTotalKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Total KG *'**
  String get transferTotalKgLabel;

  /// No description provided for @transferTotalKgHint.
  ///
  /// In en, this message translates to:
  /// **'Enter total KG'**
  String get transferTotalKgHint;

  /// No description provided for @transferKgPrefix.
  ///
  /// In en, this message translates to:
  /// **'KG  '**
  String get transferKgPrefix;

  /// No description provided for @transferStockValidation.
  ///
  /// In en, this message translates to:
  /// **'Cannot enter more than available stock'**
  String get transferStockValidation;

  /// No description provided for @transferVehiclePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number Plate *'**
  String get transferVehiclePlateLabel;

  /// No description provided for @transferVehiclePlateHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Number Plate'**
  String get transferVehiclePlateHint;

  /// No description provided for @transferVehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get transferVehicleTypeLabel;

  /// No description provided for @transferVehicleTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select vehicle type'**
  String get transferVehicleTypeHint;

  /// No description provided for @transferVehicleCapacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Capacity'**
  String get transferVehicleCapacityLabel;

  /// No description provided for @transferVehicleCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Vehicle Capacity'**
  String get transferVehicleCapacityHint;

  /// No description provided for @transferManagerArrangeVehicle.
  ///
  /// In en, this message translates to:
  /// **'I will let my Manager arrange the vehicle'**
  String get transferManagerArrangeVehicle;

  /// No description provided for @transferVehicleTruck.
  ///
  /// In en, this message translates to:
  /// **'Truck'**
  String get transferVehicleTruck;

  /// No description provided for @transferVehicleMiniTruck.
  ///
  /// In en, this message translates to:
  /// **'Mini Truck'**
  String get transferVehicleMiniTruck;

  /// No description provided for @transferVehiclePickupTruck.
  ///
  /// In en, this message translates to:
  /// **'Pickup Truck'**
  String get transferVehiclePickupTruck;

  /// No description provided for @transferVehicleTempo.
  ///
  /// In en, this message translates to:
  /// **'Tempo / Light Commercial Vehicle'**
  String get transferVehicleTempo;

  /// No description provided for @transferVehicleTrailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer / Heavy Truck'**
  String get transferVehicleTrailer;

  /// No description provided for @transferVehicleOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get transferVehicleOther;

  /// No description provided for @transferSelectedSummary.
  ///
  /// In en, this message translates to:
  /// **'✓  540.00 KG                                  ₹1960'**
  String get transferSelectedSummary;

  /// No description provided for @transferSelectedWeight.
  ///
  /// In en, this message translates to:
  /// **'540.00 KG'**
  String get transferSelectedWeight;

  /// No description provided for @transferSelectedPrice.
  ///
  /// In en, this message translates to:
  /// **'₹1960'**
  String get transferSelectedPrice;

  /// No description provided for @transferContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue  →'**
  String get transferContinue;

  /// No description provided for @transferSelectDestination.
  ///
  /// In en, this message translates to:
  /// **'Select Destination'**
  String get transferSelectDestination;

  /// No description provided for @transferCurrentFacility.
  ///
  /// In en, this message translates to:
  /// **'Central MRF Yard'**
  String get transferCurrentFacility;

  /// No description provided for @transferDestinationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where should this stock be transferred?'**
  String get transferDestinationQuestion;

  /// No description provided for @transferDestinationCityHub.
  ///
  /// In en, this message translates to:
  /// **'City Processing Hub - Sector 4'**
  String get transferDestinationCityHub;

  /// No description provided for @transferDestinationCityAddress.
  ///
  /// In en, this message translates to:
  /// **'Industrial Zone, 12 KM away'**
  String get transferDestinationCityAddress;

  /// No description provided for @transferDestinationHighway.
  ///
  /// In en, this message translates to:
  /// **'Highway Yard Warehouse'**
  String get transferDestinationHighway;

  /// No description provided for @transferDestinationHighwayAddress.
  ///
  /// In en, this message translates to:
  /// **'National Highway 8, 24 KM away'**
  String get transferDestinationHighwayAddress;

  /// No description provided for @transferDestinationApex.
  ///
  /// In en, this message translates to:
  /// **'Apex Recycling Hub'**
  String get transferDestinationApex;

  /// No description provided for @transferDestinationApexAddress.
  ///
  /// In en, this message translates to:
  /// **'GIDC Industrial Estate, 35 KM away'**
  String get transferDestinationApexAddress;

  /// No description provided for @transferDestinationSouthside.
  ///
  /// In en, this message translates to:
  /// **'Southside Sorting Point'**
  String get transferDestinationSouthside;

  /// No description provided for @transferDestinationSouthsideAddress.
  ///
  /// In en, this message translates to:
  /// **'Green Valley, 48 KM away'**
  String get transferDestinationSouthsideAddress;

  /// No description provided for @transferManagerApprovalNote.
  ///
  /// In en, this message translates to:
  /// **'Note: This request will be sent to Manager for vehicle dispatch approval.'**
  String get transferManagerApprovalNote;

  /// No description provided for @transferSubmitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request  →'**
  String get transferSubmitRequest;

  /// No description provided for @transferSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Your request submitted Successfully!'**
  String get transferSuccessTitle;

  /// No description provided for @transferSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We will notify you once a vehicle is assigned by the Admin team.'**
  String get transferSuccessSubtitle;

  /// No description provided for @transferBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to Transfer List'**
  String get transferBackToList;

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

  /// No description provided for @drawerTasksRequests.
  ///
  /// In en, this message translates to:
  /// **'Tasks & Requests'**
  String get drawerTasksRequests;

  /// No description provided for @drawerTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get drawerTasks;

  /// No description provided for @drawerRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get drawerRequests;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @taskOpenCount.
  ///
  /// In en, this message translates to:
  /// **'Open ({count})'**
  String taskOpenCount(int count);

  /// No description provided for @taskClosedCount.
  ///
  /// In en, this message translates to:
  /// **'Closed ({count})'**
  String taskClosedCount(int count);

  /// No description provided for @taskSupervisorName.
  ///
  /// In en, this message translates to:
  /// **'Bhavesh Shah (Supervisor)'**
  String get taskSupervisorName;

  /// No description provided for @taskDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and verify the latest collection entry submitted by the field agent...'**
  String get taskDescription;

  /// No description provided for @taskPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'{count} Photo attached'**
  String taskPhotoAttached(int count);

  /// No description provided for @taskDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today, 5:00 PM'**
  String get taskDueToday;

  /// No description provided for @taskDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Due Tomorrow, 2:00 PM'**
  String get taskDueTomorrow;

  /// No description provided for @taskDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due 25 Aug 2026'**
  String get taskDueDate;

  /// No description provided for @taskCompletedTime.
  ///
  /// In en, this message translates to:
  /// **'Completed: Today, 11:30 AM'**
  String get taskCompletedTime;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get taskPriorityHigh;

  /// No description provided for @taskPriorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get taskPriorityNormal;

  /// No description provided for @taskPriorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get taskPriorityLow;

  /// No description provided for @taskEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No Tasks for now'**
  String get taskEmptyMessage;

  /// No description provided for @configureMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get configureMaterialsTitle;

  /// No description provided for @configureMaterialsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag handle to reorder materials.'**
  String get configureMaterialsSubtitle;

  /// No description provided for @configurePlasticCount.
  ///
  /// In en, this message translates to:
  /// **'Plastic ({count})'**
  String configurePlasticCount(int count);

  /// No description provided for @configureNonPlasticCount.
  ///
  /// In en, this message translates to:
  /// **'Non-Plastic ({count})'**
  String configureNonPlasticCount(int count);

  /// No description provided for @configureSaveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save Order'**
  String get configureSaveOrder;

  /// No description provided for @configureSequenceSaved.
  ///
  /// In en, this message translates to:
  /// **'Sequence saved successfully'**
  String get configureSequenceSaved;

  /// No description provided for @configurePetBottles.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles'**
  String get configurePetBottles;

  /// No description provided for @configureHdpeRigid.
  ///
  /// In en, this message translates to:
  /// **'HDPE Rigid'**
  String get configureHdpeRigid;

  /// No description provided for @configureMilkPouch.
  ///
  /// In en, this message translates to:
  /// **'Milk Pouch / Soft Plastic'**
  String get configureMilkPouch;

  /// No description provided for @configurePpHardPlastics.
  ///
  /// In en, this message translates to:
  /// **'PP Hard Plastics'**
  String get configurePpHardPlastics;

  /// No description provided for @configureMultiLayerPackaging.
  ///
  /// In en, this message translates to:
  /// **'Multi-Layer Packaging'**
  String get configureMultiLayerPackaging;

  /// No description provided for @configurePvcPlastic.
  ///
  /// In en, this message translates to:
  /// **'PVC Plastic'**
  String get configurePvcPlastic;

  /// No description provided for @configureMixedGarbage.
  ///
  /// In en, this message translates to:
  /// **'Mixed Garbage'**
  String get configureMixedGarbage;

  /// No description provided for @configureMetals.
  ///
  /// In en, this message translates to:
  /// **'Metals'**
  String get configureMetals;

  /// No description provided for @configureGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass'**
  String get configureGlass;

  /// No description provided for @configurePaperCardboard.
  ///
  /// In en, this message translates to:
  /// **'Paper & Cardboard'**
  String get configurePaperCardboard;

  /// No description provided for @configureOrganicWood.
  ///
  /// In en, this message translates to:
  /// **'Organic & Wood'**
  String get configureOrganicWood;

  /// No description provided for @configureConcreteMasonry.
  ///
  /// In en, this message translates to:
  /// **'Concrete, Brick & Masonry'**
  String get configureConcreteMasonry;

  /// No description provided for @configureCeramicsPorcelain.
  ///
  /// In en, this message translates to:
  /// **'Ceramics & Porcelain'**
  String get configureCeramicsPorcelain;

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
  /// **'Collections Records'**
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

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get profileDeleteAccountSubtitle;

  /// No description provided for @profileLanguageEnglishShort.
  ///
  /// In en, this message translates to:
  /// **'ENG'**
  String get profileLanguageEnglishShort;

  /// No description provided for @profileLanguageGujaratiShort.
  ///
  /// In en, this message translates to:
  /// **'GUJ'**
  String get profileLanguageGujaratiShort;

  /// No description provided for @profileLanguageHindiShort.
  ///
  /// In en, this message translates to:
  /// **'HIN'**
  String get profileLanguageHindiShort;

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

  /// No description provided for @helpCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get helpCallSupport;

  /// No description provided for @helpCallSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available 24/7 for field issues'**
  String get helpCallSupportSubtitle;

  /// No description provided for @helpInstantHelp.
  ///
  /// In en, this message translates to:
  /// **'Instant Help'**
  String get helpInstantHelp;

  /// No description provided for @helpInstantHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with a support agent'**
  String get helpInstantHelpSubtitle;

  /// No description provided for @helpFrequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFrequentlyAskedQuestions;

  /// No description provided for @helpPrinterQuestion.
  ///
  /// In en, this message translates to:
  /// **'Printer is not printing receipts?'**
  String get helpPrinterQuestion;

  /// No description provided for @helpPrinterAnswer.
  ///
  /// In en, this message translates to:
  /// **'1. Turn Bluetooth OFF and ON.\n2. Restart thermal printer.\n3. Go to App Settings > Printer and run \'Test Print\'.'**
  String get helpPrinterAnswer;

  /// No description provided for @helpAddExpenseQuestion.
  ///
  /// In en, this message translates to:
  /// **'How to Add Expense?'**
  String get helpAddExpenseQuestion;

  /// No description provided for @helpAddExpenseAnswer.
  ///
  /// In en, this message translates to:
  /// **'1. Open Wallet & Log Expense.\n2. Tap Log Expense.\n3. Enter the details and add a receipt.'**
  String get helpAddExpenseAnswer;

  /// No description provided for @helpTransferQuestion.
  ///
  /// In en, this message translates to:
  /// **'How to Transfer Requests'**
  String get helpTransferQuestion;

  /// No description provided for @helpTransferAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open Transfer Requests from the menu and follow the on-screen instructions.'**
  String get helpTransferAnswer;

  /// No description provided for @helpSyncQuestion.
  ///
  /// In en, this message translates to:
  /// **'How to do Sync Backup?'**
  String get helpSyncQuestion;

  /// No description provided for @helpSyncAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open Sync Status from the menu and tap Sync Now.'**
  String get helpSyncAnswer;

  /// No description provided for @helpBluetoothQuestion.
  ///
  /// In en, this message translates to:
  /// **'What should I do if my Bluetooth printer won\'t connect?'**
  String get helpBluetoothQuestion;

  /// No description provided for @helpBluetoothAnswer.
  ///
  /// In en, this message translates to:
  /// **'Make sure Bluetooth is enabled, restart the printer, then reconnect it from App Settings > Printer.'**
  String get helpBluetoothAnswer;

  /// No description provided for @collectionItemsReceived.
  ///
  /// In en, this message translates to:
  /// **'Items Received'**
  String get collectionItemsReceived;

  /// No description provided for @collectionItemsReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the items received from this Collection types and enter the quantity.'**
  String get collectionItemsReceivedSubtitle;

  /// No description provided for @collectionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Collection types'**
  String get collectionTypeLabel;

  /// No description provided for @collectionSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Collection type'**
  String get collectionSelectType;

  /// No description provided for @collectionAddItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get collectionAddItemLabel;

  /// No description provided for @collectionSelectWasteItem.
  ///
  /// In en, this message translates to:
  /// **'Select Waste Item'**
  String get collectionSelectWasteItem;

  /// No description provided for @collectionItemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} Items Selected'**
  String collectionItemsSelected(int count);

  /// No description provided for @collectionVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Number Plate'**
  String get collectionVehicleNumber;

  /// No description provided for @collectionMrfAgentName.
  ///
  /// In en, this message translates to:
  /// **'MRF Agent Name'**
  String get collectionMrfAgentName;

  /// No description provided for @collectionPersonName.
  ///
  /// In en, this message translates to:
  /// **'Select Person Name'**
  String get collectionPersonName;

  /// No description provided for @collectionPlasticCount.
  ///
  /// In en, this message translates to:
  /// **'Plastic (12)'**
  String get collectionPlasticCount;

  /// No description provided for @collectionNonPlasticCount.
  ///
  /// In en, this message translates to:
  /// **'Non-Plastic (10)'**
  String get collectionNonPlasticCount;

  /// No description provided for @collectionMilkPouch.
  ///
  /// In en, this message translates to:
  /// **'Milk Pouch / Soft Plastic'**
  String get collectionMilkPouch;

  /// No description provided for @collectionMultiLayer.
  ///
  /// In en, this message translates to:
  /// **'Multi-Layer Packaging'**
  String get collectionMultiLayer;

  /// No description provided for @collectionMixedGarbage.
  ///
  /// In en, this message translates to:
  /// **'Mixed Garbage'**
  String get collectionMixedGarbage;

  /// No description provided for @collectionCaptureInstruction.
  ///
  /// In en, this message translates to:
  /// **'Capture all collection photos for review (JPG/PNG, under 5MB).'**
  String get collectionCaptureInstruction;

  /// No description provided for @collectionWeight.
  ///
  /// In en, this message translates to:
  /// **'Collection Weight'**
  String get collectionWeight;

  /// No description provided for @collectionVerifiedWeight.
  ///
  /// In en, this message translates to:
  /// **'Verified Weight'**
  String get collectionVerifiedWeight;

  /// No description provided for @collectionCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get collectionCapturePhoto;

  /// No description provided for @collectionRampPersonPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Ramp Person Photo'**
  String get collectionRampPersonPhoto;

  /// No description provided for @collectionTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total Collection Weight'**
  String get collectionTotalWeight;

  /// No description provided for @collectionWeightDifference.
  ///
  /// In en, this message translates to:
  /// **'Weight Comparison'**
  String get collectionWeightDifference;

  /// No description provided for @collectionTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get collectionTotalPrice;

  /// No description provided for @collectionSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get collectionSaveDraft;

  /// No description provided for @collectionSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get collectionSubmit;

  /// No description provided for @collectionSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Collection Submitted'**
  String get collectionSubmitted;

  /// No description provided for @collectionSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully!'**
  String get collectionSuccessfully;

  /// No description provided for @collectionSubmissionId.
  ///
  /// In en, this message translates to:
  /// **'Collection ID TRP-542586-04'**
  String get collectionSubmissionId;

  /// No description provided for @collectionPreviewSlip.
  ///
  /// In en, this message translates to:
  /// **'Preview Slip'**
  String get collectionPreviewSlip;

  /// No description provided for @collectionAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Collection'**
  String get collectionAddNew;

  /// No description provided for @collectionCollectedItems.
  ///
  /// In en, this message translates to:
  /// **'Collected Items'**
  String get collectionCollectedItems;

  /// No description provided for @collectionThankYou.
  ///
  /// In en, this message translates to:
  /// **'Thank You'**
  String get collectionThankYou;

  /// No description provided for @collectionShareSlip.
  ///
  /// In en, this message translates to:
  /// **'Share Slip'**
  String get collectionShareSlip;

  /// No description provided for @collectionPrintSlip.
  ///
  /// In en, this message translates to:
  /// **'Print Slip'**
  String get collectionPrintSlip;

  /// No description provided for @collectionSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle Number Plate'**
  String get collectionSelectVehicle;

  /// No description provided for @collectionSelectPerson.
  ///
  /// In en, this message translates to:
  /// **'Select Person Name'**
  String get collectionSelectPerson;

  /// No description provided for @collectionSelectMrfAgent.
  ///
  /// In en, this message translates to:
  /// **'Select MRF Agent Name'**
  String get collectionSelectMrfAgent;

  /// No description provided for @collectionChoosePhotoSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Photo Source'**
  String get collectionChoosePhotoSource;

  /// No description provided for @collectionCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get collectionCamera;

  /// No description provided for @collectionGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get collectionGallery;

  /// No description provided for @collectionRampPhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo to record and verify person details.'**
  String get collectionRampPhotoHint;

  /// No description provided for @collectionReceiptDate.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get collectionReceiptDate;

  /// No description provided for @collectionReceiptTime.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get collectionReceiptTime;

  /// No description provided for @collectionReceiptTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get collectionReceiptTotal;

  /// No description provided for @collectionReceiptAgent.
  ///
  /// In en, this message translates to:
  /// **'Collection Agent'**
  String get collectionReceiptAgent;

  /// No description provided for @collectionSystemGeneratedSlip.
  ///
  /// In en, this message translates to:
  /// **'System Generated Slip'**
  String get collectionSystemGeneratedSlip;

  /// No description provided for @collectionPrinterHint.
  ///
  /// In en, this message translates to:
  /// **'Ensure your Bluetooth thermal printer is switched on and connected.'**
  String get collectionPrinterHint;

  /// No description provided for @collectionPetReceiptDetail.
  ///
  /// In en, this message translates to:
  /// **'120 KG × ₹12.00/KG'**
  String get collectionPetReceiptDetail;

  /// No description provided for @collectionHdpeReceiptDetail.
  ///
  /// In en, this message translates to:
  /// **'85.5 KG × ₹8.50/KG'**
  String get collectionHdpeReceiptDetail;

  /// No description provided for @collectionPpReceiptDetail.
  ///
  /// In en, this message translates to:
  /// **'12 KG × ₹45.00/KG'**
  String get collectionPpReceiptDetail;

  /// No description provided for @taskResolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve Task'**
  String get taskResolveTitle;

  /// No description provided for @taskOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify Collection Details'**
  String get taskOverviewTitle;

  /// No description provided for @taskOverviewDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and verify the latest collection entry submitted by the field agent. Cross-check the reported collection weight against the verified weight.'**
  String get taskOverviewDescription;

  /// No description provided for @taskAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment from Supervisor'**
  String get taskAttachmentTitle;

  /// No description provided for @taskCompletionProof.
  ///
  /// In en, this message translates to:
  /// **'Task Completion Proof *'**
  String get taskCompletionProof;

  /// No description provided for @taskProofSupported.
  ///
  /// In en, this message translates to:
  /// **'Supported: JPG, PNG (Max 5MB).'**
  String get taskProofSupported;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get taskDescriptionLabel;

  /// No description provided for @taskDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add Description'**
  String get taskDescriptionHint;

  /// No description provided for @taskDescriptionMinimum.
  ///
  /// In en, this message translates to:
  /// **'Min 150 Characters'**
  String get taskDescriptionMinimum;

  /// No description provided for @taskFilledDescription.
  ///
  /// In en, this message translates to:
  /// **'Weight scale calibrated using 10kg standard test weight. Zero-error verified.'**
  String get taskFilledDescription;

  /// No description provided for @taskMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as Completed'**
  String get taskMarkCompleted;

  /// No description provided for @taskDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Details'**
  String get taskDetailsTitle;

  /// No description provided for @taskCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Completed!'**
  String get taskCompletedTitle;

  /// No description provided for @taskCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The task assigned by supervisor has been completed.'**
  String get taskCompletedMessage;

  /// No description provided for @taskBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get taskBackToList;

  /// No description provided for @taskSupervisorDetails.
  ///
  /// In en, this message translates to:
  /// **'Supervisor Details'**
  String get taskSupervisorDetails;

  /// No description provided for @taskCompletionProofPlain.
  ///
  /// In en, this message translates to:
  /// **'Task Completion Proof'**
  String get taskCompletionProofPlain;

  /// No description provided for @taskDescriptionPlain.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get taskDescriptionPlain;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationTitle;

  /// No description provided for @notificationToday.
  ///
  /// In en, this message translates to:
  /// **'Today,'**
  String get notificationToday;

  /// No description provided for @notificationEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier,'**
  String get notificationEarlier;

  /// No description provided for @notificationEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'All Caught Up!'**
  String get notificationEmptyTitle;

  /// No description provided for @notificationEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up! Check back later for updates, task status, and system alerts.'**
  String get notificationEmptyMessage;

  /// No description provided for @notificationOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get notificationOfflineTitle;

  /// No description provided for @notificationOfflineMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Data will sync automatically when Connection Restored.'**
  String get notificationOfflineMessage;

  /// No description provided for @notificationTransferRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Reject'**
  String get notificationTransferRejectedTitle;

  /// No description provided for @notificationTransferRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Transfer entry requires your attention.'**
  String get notificationTransferRejectedMessage;

  /// No description provided for @notificationReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Receipt Print'**
  String get notificationReceiptTitle;

  /// No description provided for @notificationReceiptMessage.
  ///
  /// In en, this message translates to:
  /// **'The receipt printing process completed successfully.'**
  String get notificationReceiptMessage;

  /// No description provided for @notificationCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection Submitted'**
  String get notificationCollectionTitle;

  /// No description provided for @notificationCollectionMessage.
  ///
  /// In en, this message translates to:
  /// **'Your collection entry has been verified by the Collection Supervisor.'**
  String get notificationCollectionMessage;

  /// No description provided for @notificationExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense added'**
  String get notificationExpenseTitle;

  /// No description provided for @notificationExpenseMessage.
  ///
  /// In en, this message translates to:
  /// **'Your expense bill has been rejected by supervisor'**
  String get notificationExpenseMessage;

  /// No description provided for @notificationSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Complete'**
  String get notificationSyncTitle;

  /// No description provided for @notificationSyncMessage.
  ///
  /// In en, this message translates to:
  /// **'All pending data has been synced successfully.'**
  String get notificationSyncMessage;

  /// No description provided for @notificationJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationJustNow;

  /// No description provided for @notificationTenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 Mins ago'**
  String get notificationTenMinutes;

  /// No description provided for @notificationFiveHours.
  ///
  /// In en, this message translates to:
  /// **'5 Hours ago'**
  String get notificationFiveHours;

  /// No description provided for @notificationSevenHours.
  ///
  /// In en, this message translates to:
  /// **'7 Hours ago'**
  String get notificationSevenHours;

  /// No description provided for @notificationYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, 11:30 AM'**
  String get notificationYesterday;

  /// No description provided for @notificationPreviousDate.
  ///
  /// In en, this message translates to:
  /// **'24 Oct, 08:00 AM'**
  String get notificationPreviousDate;

  /// No description provided for @homePendingTask.
  ///
  /// In en, this message translates to:
  /// **'Pending Task'**
  String get homePendingTask;

  /// No description provided for @homePendingTaskSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View tasks assigned to you.'**
  String get homePendingTaskSubtitle;

  /// No description provided for @homeSuratEastZone.
  ///
  /// In en, this message translates to:
  /// **'EERL - Surat East Zone'**
  String get homeSuratEastZone;

  /// No description provided for @homeSuratNorthZone.
  ///
  /// In en, this message translates to:
  /// **'EERL - Surat North Zone'**
  String get homeSuratNorthZone;

  /// No description provided for @homeSuratSouthZone.
  ///
  /// In en, this message translates to:
  /// **'EERL - Surat South Zone'**
  String get homeSuratSouthZone;

  /// Button label to view pending tasks
  ///
  /// In en, this message translates to:
  /// **'View Task'**
  String get viewTask;

  /// No description provided for @endDayOpeningBalance.
  ///
  /// In en, this message translates to:
  /// **'Opening Balance'**
  String get endDayOpeningBalance;

  /// No description provided for @endDayOpeningBalanceValue.
  ///
  /// In en, this message translates to:
  /// **'₹ 5,000.00'**
  String get endDayOpeningBalanceValue;

  /// No description provided for @endDayExpensesLogged.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses Logged'**
  String get endDayExpensesLogged;

  /// No description provided for @endDayExpensesValue.
  ///
  /// In en, this message translates to:
  /// **'₹ 720.00'**
  String get endDayExpensesValue;

  /// No description provided for @endDayTotalPurchase.
  ///
  /// In en, this message translates to:
  /// **'Total Purchase (Money given at collection)'**
  String get endDayTotalPurchase;

  /// No description provided for @endDayPurchaseValue.
  ///
  /// In en, this message translates to:
  /// **'₹ 6000.00'**
  String get endDayPurchaseValue;

  /// No description provided for @endDayClosingBalance.
  ///
  /// In en, this message translates to:
  /// **'Closing Balance'**
  String get endDayClosingBalance;

  /// No description provided for @endDayClosingBalanceValue.
  ///
  /// In en, this message translates to:
  /// **'₹ 11,720.00'**
  String get endDayClosingBalanceValue;

  /// No description provided for @endDayBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Calculated from recorded transactions.\nNon-verified collection not included.'**
  String get endDayBalanceHint;

  /// No description provided for @endDayActivitySummary.
  ///
  /// In en, this message translates to:
  /// **'Today’s Activity Summary'**
  String get endDayActivitySummary;

  /// No description provided for @endDayCompletedCollections.
  ///
  /// In en, this message translates to:
  /// **'Completed Collections'**
  String get endDayCompletedCollections;

  /// No description provided for @endDayPendingCollections.
  ///
  /// In en, this message translates to:
  /// **'Pending Collections'**
  String get endDayPendingCollections;

  /// No description provided for @endDayWasteCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Waste Collected'**
  String get endDayWasteCollected;

  /// No description provided for @endDayWasteValue.
  ///
  /// In en, this message translates to:
  /// **'876 KG'**
  String get endDayWasteValue;

  /// No description provided for @endDayVerificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get endDayVerificationPending;

  /// No description provided for @endDayOfflineSync.
  ///
  /// In en, this message translates to:
  /// **'Offline Pending Sync'**
  String get endDayOfflineSync;

  /// No description provided for @endDayPendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get endDayPendingStatus;

  /// No description provided for @endDayCompletedValue.
  ///
  /// In en, this message translates to:
  /// **'07'**
  String get endDayCompletedValue;

  /// No description provided for @endDayPendingValue.
  ///
  /// In en, this message translates to:
  /// **'01'**
  String get endDayPendingValue;

  /// No description provided for @endDayExpensesCount.
  ///
  /// In en, this message translates to:
  /// **'02'**
  String get endDayExpensesCount;

  /// No description provided for @endDayWarning.
  ///
  /// In en, this message translates to:
  /// **'Once you close the day, you won’t be able to\nadd or edit any entries.'**
  String get endDayWarning;

  /// Title of end-day confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'End Your Day?'**
  String get endDayConfirmTitle;

  /// Body message of end-day confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Once you close the day, all entries will be locked. Make sure all collections and expenses are logged before closing.'**
  String get endDayConfirmMessage;

  /// Confirm button in end-day dialog
  ///
  /// In en, this message translates to:
  /// **'Yes, End My Day'**
  String get endDayConfirmYes;

  /// Cancel button in end-day dialog
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get endDayConfirmNo;

  /// Success title after day is closed
  ///
  /// In en, this message translates to:
  /// **'Day Closed!'**
  String get endDaySuccessTitle;

  /// Success message after day is closed
  ///
  /// In en, this message translates to:
  /// **'Your day has been closed successfully. All data has been synced.'**
  String get endDaySuccessMessage;

  /// No description provided for @requestTitle.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requestTitle;

  /// No description provided for @requestOpenCount.
  ///
  /// In en, this message translates to:
  /// **'Open ({count})'**
  String requestOpenCount(int count);

  /// No description provided for @requestClosedCount.
  ///
  /// In en, this message translates to:
  /// **'Closed ({count})'**
  String requestClosedCount(int count);

  /// No description provided for @requestSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get requestSearchHint;

  /// No description provided for @requestSupervisorName.
  ///
  /// In en, this message translates to:
  /// **'Bhavesh Shah (Supervisor)'**
  String get requestSupervisorName;

  /// No description provided for @requestOpenDescriptionOne.
  ///
  /// In en, this message translates to:
  /// **'Ramp B weighing scale is showing zero error and flickering constantly during calibration...'**
  String get requestOpenDescriptionOne;

  /// No description provided for @requestOpenDescriptionTwo.
  ///
  /// In en, this message translates to:
  /// **'Calibrate bin weighing scale at main Surat collection center.'**
  String get requestOpenDescriptionTwo;

  /// No description provided for @requestOpenDescriptionThree.
  ///
  /// In en, this message translates to:
  /// **'Review and verify the latest collection entry submitted by the agent.'**
  String get requestOpenDescriptionThree;

  /// No description provided for @requestClosedDescriptionOne.
  ///
  /// In en, this message translates to:
  /// **'Technician sent, scale repaired.'**
  String get requestClosedDescriptionOne;

  /// No description provided for @requestClosedDescriptionTwo.
  ///
  /// In en, this message translates to:
  /// **'Review and verify the latest collection entry submitted by the agent.'**
  String get requestClosedDescriptionTwo;

  /// No description provided for @requestPhotoAttached.
  ///
  /// In en, this message translates to:
  /// **'1 Photo attached'**
  String get requestPhotoAttached;

  /// No description provided for @requestAwaitingResponse.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Response'**
  String get requestAwaitingResponse;

  /// No description provided for @requestClosedBySupervisor.
  ///
  /// In en, this message translates to:
  /// **'Closed by Supervisor'**
  String get requestClosedBySupervisor;

  /// No description provided for @requestTodayTime.
  ///
  /// In en, this message translates to:
  /// **'Today, {time}'**
  String requestTodayTime(String time);

  /// No description provided for @requestEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No Requests for now'**
  String get requestEmptyMessage;

  /// No description provided for @requestRaiseButton.
  ///
  /// In en, this message translates to:
  /// **'Raise Request'**
  String get requestRaiseButton;

  /// No description provided for @requestRaiseTitle.
  ///
  /// In en, this message translates to:
  /// **'Raise Request'**
  String get requestRaiseTitle;

  /// No description provided for @requestAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo *'**
  String get requestAddPhoto;

  /// No description provided for @requestCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get requestCapturePhoto;

  /// No description provided for @requestPhotoSupport.
  ///
  /// In en, this message translates to:
  /// **'Supported: JPG, PNG (Max 5MB).'**
  String get requestPhotoSupport;

  /// No description provided for @requestDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description *'**
  String get requestDescriptionLabel;

  /// No description provided for @requestDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add Description'**
  String get requestDescriptionHint;

  /// No description provided for @requestDescriptionCounter.
  ///
  /// In en, this message translates to:
  /// **'Max 150 Characters'**
  String get requestDescriptionCounter;

  /// No description provided for @requestSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get requestSubmitButton;

  /// No description provided for @requestFilledDescription.
  ///
  /// In en, this message translates to:
  /// **'Weight scale calibrated using 10kg standard test weight. Zero-error verified.'**
  String get requestFilledDescription;

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get requestSentTitle;

  /// No description provided for @requestSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your request has been forwarded to your supervisor.'**
  String get requestSentMessage;

  /// No description provided for @requestBackToList.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get requestBackToList;

  /// No description provided for @requestDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetailsTitle;

  /// No description provided for @requestCompletedDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Task Detail'**
  String get requestCompletedDetailsTitle;

  /// No description provided for @requestAssignTo.
  ///
  /// In en, this message translates to:
  /// **'Assign To'**
  String get requestAssignTo;

  /// No description provided for @requestVerifyCollectionDetails.
  ///
  /// In en, this message translates to:
  /// **'Verify Collection Details'**
  String get requestVerifyCollectionDetails;

  /// No description provided for @requestAttachmentByYou.
  ///
  /// In en, this message translates to:
  /// **'Attachment By you'**
  String get requestAttachmentByYou;

  /// No description provided for @requestResolveDetails.
  ///
  /// In en, this message translates to:
  /// **'Resolve Request Details'**
  String get requestResolveDetails;

  /// No description provided for @requestCompletionProof.
  ///
  /// In en, this message translates to:
  /// **'Task Completion Proof'**
  String get requestCompletionProof;

  /// No description provided for @requestCollectionAgentDetails.
  ///
  /// In en, this message translates to:
  /// **'Collection agent Details'**
  String get requestCollectionAgentDetails;

  /// No description provided for @requestAttachmentFromSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Attachment from Supervisor'**
  String get requestAttachmentFromSupervisor;

  /// No description provided for @requestDescriptionPlain.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get requestDescriptionPlain;

  /// No description provided for @requestAgentName.
  ///
  /// In en, this message translates to:
  /// **'Rahul Patel'**
  String get requestAgentName;

  /// No description provided for @requestCompletedStatus.
  ///
  /// In en, this message translates to:
  /// **'Completed: Today, 11:30 AM'**
  String get requestCompletedStatus;

  /// No description provided for @requestDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Review and verify the latest collection entry submitted by the field agent. Cross-check the reported collection weight against the verified weight, inspect all uploaded item photos (before and after verification), and ensure customer details and material categories match the system records before final approval.'**
  String get requestDetailDescription;

  /// No description provided for @transferDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer Request Details'**
  String get transferDetailTitle;

  /// No description provided for @transferDetailRequestId.
  ///
  /// In en, this message translates to:
  /// **'#TRF-2026-089'**
  String get transferDetailRequestId;

  /// No description provided for @transferRejectReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason for Reject'**
  String get transferRejectReasonTitle;

  /// No description provided for @transferRejectReason.
  ///
  /// In en, this message translates to:
  /// **'Reason : No Vehicle Available'**
  String get transferRejectReason;

  /// No description provided for @transferRejectRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks : All yard trucks are currently out. Try after 2 PM.'**
  String get transferRejectRemarks;

  /// No description provided for @transferRequestInformation.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get transferRequestInformation;

  /// No description provided for @transferDetailVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get transferDetailVehicle;

  /// No description provided for @transferDetailVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-1234'**
  String get transferDetailVehicleNumber;

  /// No description provided for @transferDetailVehicleUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Not Available (Agent)'**
  String get transferDetailVehicleUnavailable;

  /// No description provided for @transferDetailVehicleCapacity.
  ///
  /// In en, this message translates to:
  /// **'Truck (Capacity 3000 KG)'**
  String get transferDetailVehicleCapacity;

  /// No description provided for @transferDetailFromLocation.
  ///
  /// In en, this message translates to:
  /// **'From Location'**
  String get transferDetailFromLocation;

  /// No description provided for @transferDetailFromLocationValue.
  ///
  /// In en, this message translates to:
  /// **'National Highway 8, 24 KM away'**
  String get transferDetailFromLocationValue;

  /// No description provided for @transferDetailToLocation.
  ///
  /// In en, this message translates to:
  /// **'To Location'**
  String get transferDetailToLocation;

  /// No description provided for @transferDetailToLocationValue.
  ///
  /// In en, this message translates to:
  /// **'EERL - Surat Main Warehouse'**
  String get transferDetailToLocationValue;

  /// No description provided for @transferDetailAvailableStock.
  ///
  /// In en, this message translates to:
  /// **'Available Stock'**
  String get transferDetailAvailableStock;

  /// No description provided for @transferDetailAvailableStockValue.
  ///
  /// In en, this message translates to:
  /// **'1200.60 KG'**
  String get transferDetailAvailableStockValue;

  /// No description provided for @transferDetailDateTime.
  ///
  /// In en, this message translates to:
  /// **'Request Date & Time'**
  String get transferDetailDateTime;

  /// No description provided for @transferDetailDateTimeValue.
  ///
  /// In en, this message translates to:
  /// **'06 Aug 2026, 10:45 AM'**
  String get transferDetailDateTimeValue;

  /// No description provided for @transferDetailRequestedBy.
  ///
  /// In en, this message translates to:
  /// **'Requested By'**
  String get transferDetailRequestedBy;

  /// No description provided for @transferDetailRequestedByValue.
  ///
  /// In en, this message translates to:
  /// **'Rahul Patel'**
  String get transferDetailRequestedByValue;

  /// No description provided for @transferDetailRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get transferDetailRequestStatus;

  /// No description provided for @transferDetailWaitingManager.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Collection Manager'**
  String get transferDetailWaitingManager;

  /// No description provided for @transferDetailWaitingLoading.
  ///
  /// In en, this message translates to:
  /// **'Waiting for loading'**
  String get transferDetailWaitingLoading;

  /// No description provided for @transferDetailRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected By Collection Manager'**
  String get transferDetailRejected;

  /// No description provided for @transferDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer Completed'**
  String get transferDetailCompleted;

  /// No description provided for @transferItemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Items to Transfer'**
  String get transferItemsTitle;

  /// No description provided for @transferItemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get transferItemName;

  /// No description provided for @transferItemQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get transferItemQuantity;

  /// No description provided for @transferDetailPetBottles.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles'**
  String get transferDetailPetBottles;

  /// No description provided for @transferDetailQuantityValue.
  ///
  /// In en, this message translates to:
  /// **'270.00 KG'**
  String get transferDetailQuantityValue;

  /// No description provided for @transferStatusTimeline.
  ///
  /// In en, this message translates to:
  /// **'Status Timeline'**
  String get transferStatusTimeline;

  /// No description provided for @transferTimelineCreated.
  ///
  /// In en, this message translates to:
  /// **'Request Created'**
  String get transferTimelineCreated;

  /// No description provided for @transferTimelinePendingVerification.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get transferTimelinePendingVerification;

  /// No description provided for @transferTimelineWaitingVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for Supervisor verification'**
  String get transferTimelineWaitingVerification;

  /// No description provided for @transferTimelineVerificationCompleted.
  ///
  /// In en, this message translates to:
  /// **'Supervisor verification completed'**
  String get transferTimelineVerificationCompleted;

  /// No description provided for @transferTimelineRejected.
  ///
  /// In en, this message translates to:
  /// **'Pending Verification'**
  String get transferTimelineRejected;

  /// No description provided for @transferTimelineRejectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle unavailable or rejected'**
  String get transferTimelineRejectedSubtitle;

  /// No description provided for @transferTimelinePendingLoading.
  ///
  /// In en, this message translates to:
  /// **'Pending loading'**
  String get transferTimelinePendingLoading;

  /// No description provided for @transferTimelineWaitingLoading.
  ///
  /// In en, this message translates to:
  /// **'Waiting for loading'**
  String get transferTimelineWaitingLoading;

  /// No description provided for @transferTimelineLoadingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Vehicle loaded successfully'**
  String get transferTimelineLoadingCompleted;

  /// No description provided for @transferTimelineVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get transferTimelineVerified;

  /// No description provided for @transferTimelineVerifiedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Will be updated after verification'**
  String get transferTimelineVerifiedSubtitle;

  /// No description provided for @transferTimelineCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get transferTimelineCompletedSubtitle;
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
