// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EERL App';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get details => 'Details';

  @override
  String get welcomeMessage => 'Welcome to EERL';

  @override
  String get welcomeSubtitle => 'Your production-ready Flutter application';

  @override
  String get exploreFeatures => 'Explore Features';

  @override
  String get localization => 'Localization';

  @override
  String get localizationDesc =>
      'Multi-language support with English and Hindi';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDesc => 'Seamless light and dark theme switching';

  @override
  String get theming => 'Theming';

  @override
  String get themingDesc => 'Centralized color and style management';

  @override
  String get navigation => 'Navigation';

  @override
  String get navigationDesc => 'Declarative routing with GoRouter';

  @override
  String get viewDetails => 'View Details';

  @override
  String get featureDetail => 'Feature Detail';

  @override
  String get featureDetailBody =>
      'This screen demonstrates route navigation with arguments. The feature you selected is displayed below.';

  @override
  String featureName(String name) {
    return 'Feature: $name';
  }

  @override
  String get goBack => 'Go Back';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileName => 'EERL User';

  @override
  String get profileEmail => 'user@eerl.app';

  @override
  String get profileBio => 'A Flutter developer building amazing applications.';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get memberSince => 'Member Since';

  @override
  String get memberSinceDate => 'January 2025';

  @override
  String get appVersion => 'App Version';

  @override
  String get appVersionNumber => '1.0.0';

  @override
  String get status => 'Status';

  @override
  String get activeStatus => 'Active';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System Default';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkThemeOption => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get general => 'General';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDesc => 'Receive push notifications';

  @override
  String get about => 'About';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get licenses => 'Open Source Licenses';

  @override
  String get showBottomSheet => 'Show Bottom Sheet';

  @override
  String get showDialog => 'Show Dialog';

  @override
  String get showSnackbar => 'Show Snackbar';

  @override
  String get sampleBottomSheetTitle => 'Bottom Sheet';

  @override
  String get sampleBottomSheetMessage =>
      'This is a themed bottom sheet that adapts to light and dark modes with localized text.';

  @override
  String get sampleDialogTitle => 'Confirmation';

  @override
  String get sampleDialogMessage =>
      'This dialog adapts to both light and dark themes. All text is localized.';

  @override
  String get sampleSnackbarMessage => 'This is a themed snackbar message! ✨';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get error => 'Error';

  @override
  String get pageNotFound => 'Page Not Found';

  @override
  String get pageNotFoundMessage =>
      'The page you\'re looking for doesn\'t exist.';

  @override
  String get returnHome => 'Return Home';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get loginWelcome => 'Welcome!';

  @override
  String get loginSubtitle => 'Login with your phone number';

  @override
  String get mobileNumberLabel => 'Enter Your Mobile Number';

  @override
  String get mobileNumberHint => 'Enter your number';

  @override
  String get invalidMobileNumber => 'Please Enter Valid Mobile Number';

  @override
  String get continueBtn => 'Continue';

  @override
  String get otpTitle => 'Enter OTP Code';

  @override
  String otpDescription(String phone) {
    return 'We sent a security code to your Reporting Manager for approval ($phone)';
  }

  @override
  String get invalidOtp => 'This Code has expired, Please Request New One.';

  @override
  String get otpVerified => 'OTP Verified Successfully!';

  @override
  String get didntGetOtp => 'Didn\'t get OTP?';

  @override
  String get resendOtp => 'Resend';

  @override
  String get verifyBtn => 'Verify';
}
