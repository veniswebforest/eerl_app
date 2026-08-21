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
  String get gujarati => 'ગુજરાતી';

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

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get homeDateZone => 'Wed, 22 Jul · Surat Zone';

  @override
  String get zoneName => 'EERL - Surat Zone';

  @override
  String get onlineStatus => 'You’re Online';

  @override
  String pendingCollections(int count) {
    return '$count collection pending';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get todaysSummary => 'Today\'s Summary';

  @override
  String get collectedToday => 'Collected Today';

  @override
  String weightKg(int value) {
    return '$value KG';
  }

  @override
  String get verifiedEntries => 'Verified Entries';

  @override
  String get transferRequests => 'Transfer Requests';

  @override
  String get walletBalance => 'Wallet Balance';

  @override
  String walletAmount(String amount) {
    return '₹$amount';
  }

  @override
  String get startCollection => 'Start Collection';

  @override
  String get recordWeightProof => 'Record weight & upload proof.';

  @override
  String get addCollection => 'Add Collection';

  @override
  String get walletLogExpense => 'Wallet & Log Expense';

  @override
  String get trackFieldSpending => 'Track field spending.';

  @override
  String get logExpense => 'Log Expense';

  @override
  String get collectionTypes => 'Collection types';

  @override
  String get d2d => 'D2D';

  @override
  String get smcVehicle => 'SMC Vehicle';

  @override
  String get mrfStation => 'MRF Station';

  @override
  String get materialRecoveryFacility => 'Material Recovery Facility';

  @override
  String get ramp => 'Ramp';

  @override
  String get retailDealer => 'Retail Dealer';

  @override
  String get collectionDrafts => 'Collection Drafts';

  @override
  String get viewAll => 'View All';

  @override
  String get pendingSubmission => 'Pending Submission';

  @override
  String get draftStationName => 'MRF Station Aanjana';

  @override
  String get draftLocation => 'Udhna, Sardar Market, Surat';

  @override
  String get continueCollection => 'Continue Collection';

  @override
  String get dayClosure => 'Day Closure';

  @override
  String get endMyDay => 'End My Day';

  @override
  String get reviewCloseDay =>
      'Review today\'s work, sync data and close your day.';

  @override
  String get reports => 'Reports';

  @override
  String get collections => 'Collections';

  @override
  String otpExpiresIn(String time) {
    return 'Code will expire in $time';
  }

  @override
  String resendOtpCountdown(String label, int seconds) {
    return '$label (${seconds}s)';
  }

  @override
  String get plasticWasteManagement => 'PLASTIC WASTE MANAGEMENT';

  @override
  String get walletTab => 'Wallet';

  @override
  String get records => 'Records';

  @override
  String get dashboardEmptyMessage => 'No dashboard pages are available.';

  @override
  String get walletFieldExpenses => 'Wallet & Field Expenses';

  @override
  String get availableCashBalance => 'Available Cash Balance';

  @override
  String get availableCashBalanceValue => '₹50,000';

  @override
  String get todaysSpent => 'Today\'s Spent';

  @override
  String get todaysSpentValue => '₹4,500';

  @override
  String get fieldSpendingPrompt => 'Need to log field spending?';

  @override
  String get fieldSpendingDescription =>
      'Upload receipt and request approval for fuel or operational costs.';

  @override
  String get recentExpenseClaims => 'Recent Expense Claims';

  @override
  String get expenseSearchHint => 'Search By Receipt Number, Name, Date...';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterClosed => 'Closed';

  @override
  String get expenseFuelDiesel => 'Fuel / Diesel';

  @override
  String get expenseFuelDate => 'Today • 08:15 AM';

  @override
  String get expenseFuelAmount => '-₹350';

  @override
  String get expensePendingSupervisor => 'Pending by Supervisor';

  @override
  String get expenseScaleFee => 'Scale Fee / Weighbridge Fee';

  @override
  String get expenseScaleDate => 'Yesterday • 10:15 AM';

  @override
  String get expenseScaleAmount => '-₹720';

  @override
  String get expenseVerified => 'Verified';

  @override
  String get expenseVehicleMaintenance => 'Vehicle Maintenance';

  @override
  String get expenseVehicleDate => '20 July 2026 • 01:15 PM';

  @override
  String get expenseVehicleAmount => '-₹1500';

  @override
  String get expenseFlagged => 'Flagged';

  @override
  String get drawerUserName => 'Rahul Patel';

  @override
  String get drawerUserRole => 'Collection Agent';

  @override
  String get drawerCollection => 'Collection';

  @override
  String get drawerReceipts => 'Receipts';

  @override
  String get drawerConfigureMaterials => 'Configure Material List';

  @override
  String get drawerSyncStatus => 'Sync Status';

  @override
  String get drawerHelpSupport => 'Help & Support';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get drawerPoweredBy => 'Powered by Eco Vision';

  @override
  String get expenseCategoryLabel => 'Expense Category';

  @override
  String get selectExpenseCategory => 'Select Expense Category';

  @override
  String get expenseAmountLabel => 'Expense Amount (₹)';

  @override
  String get expenseAmountHint => '₹ Enter Expense Amount';

  @override
  String get uploadReceiptLabel => 'Upload Receipt';

  @override
  String get capturePhoto => 'Capture Photo';

  @override
  String get receiptSupportMessage =>
      'Supported: JPG, PNG (Max 5MB). Receipt must be clearly visible for supervisor review.';

  @override
  String get expenseDescriptionLabel => 'Description';

  @override
  String get expenseDescriptionHint => 'Add Description';

  @override
  String get expenseDescriptionCounter => 'Max 150 Characters';

  @override
  String get submitExpenseClaim => 'Submit Expense Claim';

  @override
  String get expensePendingPrefix => 'This entry will be marked as ';

  @override
  String get expensePendingStatus => 'PENDING';

  @override
  String get expensePendingSuffix => ' until reviewed by a supervisor.';

  @override
  String get expenseCategoryLabour => 'Labour';

  @override
  String get expenseCategoryFuel => 'Fuel / Diesel';

  @override
  String get expenseCategoryVehicle => 'Vehicle Maintenance';

  @override
  String get expenseCategoryFood => 'Food / Refreshment';

  @override
  String get expenseCategorySupplies => 'Supplies / Loading Material';

  @override
  String get expenseCategoryOther => 'Other expense types';

  @override
  String get expenseClaimReference => '#EXP-2026-089';

  @override
  String get expenseDetailCategory => 'Expense Category';

  @override
  String get expenseDetailAmount => 'Amount';

  @override
  String get expenseDetailAmountValue => '₹350';

  @override
  String get expenseRequestedBy => 'Requested By';

  @override
  String get expenseRequestedByValue => 'Rahul Patel';

  @override
  String get expenseDateTime => 'Date & Time';

  @override
  String get expenseRequestStatus => 'Request Status';

  @override
  String get expenseWaitingSupervisor => 'Waiting for Supervisor';

  @override
  String get expenseVerifiedSupervisor => 'Verified by Supervisor';

  @override
  String get expenseRejectedSupervisor => 'Rejected by Supervisor';

  @override
  String get expenseUploadedPhoto => 'Uploaded Photo';

  @override
  String get expenseDetailDescription =>
      'Please state the purpose of this expense and any relevant details needed for supervisor approval.';

  @override
  String get expenseRejectReasonTitle => 'Reason for Reject';

  @override
  String get expenseRejectReasonLabel => 'Reason';

  @override
  String get expenseRejectReasonValue =>
      'Invalid / Clear Bill Missing\nPolicy Violation / Personal Expense';

  @override
  String get expenseRejectRemarksLabel => 'Remarks';

  @override
  String get expenseRejectRemarksValue =>
      'This request violates company policy as a duplicate receipt was submitted. Expense rejected.';

  @override
  String get startYourCollections => 'Start your collections';

  @override
  String get recentCollections => 'Recent Collections';

  @override
  String get collectionReceipt248 => 'RC-000248';

  @override
  String get collectionReceipt247 => 'RC-000247';

  @override
  String get collectionReceipt246 => 'RC-000246';

  @override
  String get collectionWeight245 => '245 kg';

  @override
  String get collectionWeight115 => '115 kg';

  @override
  String get collectionWeight320 => '320 kg';

  @override
  String get collectionRejectedSupervisor => 'Rejected by Supervisor';

  @override
  String get recordsCollectionsTitle => 'Collections';

  @override
  String get recordsCollectionsSubtitle => 'Manage all your collections';

  @override
  String get recordsHistory => 'History';

  @override
  String get recordsDrafts => 'Drafts';

  @override
  String get recordsSearchHint => 'Search Here...';

  @override
  String get recordsTodayCollections => 'Today\'s Collections';

  @override
  String get recordsYesterdayCollections => 'Yesterday’s Collections';

  @override
  String get recordsOctoberCollections => '22 October Collections';

  @override
  String get recordsCollectionDrafts => 'Collection Drafts';

  @override
  String get recordsTodayTime => 'Today • 08:15 AM';

  @override
  String get recordsOctober22Time => '22 October • 11:15 AM';

  @override
  String get recordsOctober21Time => '21 October • 03:15 PM';

  @override
  String get recordsFiveItemsSelected => '5 Items Selected';

  @override
  String get recordsDiscard => 'Discard';

  @override
  String get recordsContinue => 'Continue';

  @override
  String get recordsAreYouSure => 'Are you sure?';

  @override
  String get recordsDiscardConfirmation =>
      'Are you sure you want to discard this collection draft';

  @override
  String get recordsCancel => 'Cancel';

  @override
  String get recordsNoDrafts => 'No drafts for now';

  @override
  String get profileUserProfile => 'User Profile';

  @override
  String get profileSubtitle => 'Account details & info';

  @override
  String get profileAccountInformation => 'Account Information';

  @override
  String get profileAssignedFacility => 'Assigned Facility';

  @override
  String get profileFacilityValue => 'EERL – Surat South';

  @override
  String get profileMobileNumber => 'Mobile Number';

  @override
  String get profileMobileValue => '+91 98765 43210';

  @override
  String get profileRole => 'Role';

  @override
  String get profileSessionExpires => 'Session Expires';

  @override
  String get profileSessionExpiryValue => '29 July';

  @override
  String get profileActions => 'Actions';

  @override
  String get profileSyncData => 'Sync Data';

  @override
  String get profileSyncSubtitle => 'Sync your offline data';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileLogoutSubtitle => 'Sign out from your account';

  @override
  String get collectionDetailPending => 'Pending Supervisor Verification';

  @override
  String get collectionDetailApproved => 'Verified & Approved';

  @override
  String get collectionDetailReasonForReject => 'Reason for Reject';

  @override
  String get collectionDetailReasonLabel => 'Reason';

  @override
  String get collectionDetailReasonValue => 'No Vehicle Available';

  @override
  String get collectionDetailRemarksLabel => 'Remarks';

  @override
  String get collectionDetailRemarksValue =>
      'All yard trucks are currently out. Try after 2PM.';

  @override
  String get collectionDetailId => 'Collection ID:';

  @override
  String get collectionDetailDateTime => 'Date & Time';

  @override
  String get collectionDetailDateValue => '24 Oct 2026, 03:45 PM';

  @override
  String get collectionDetailType => 'Collection type';

  @override
  String get collectionDetailAgent => 'Collection Agent';

  @override
  String get collectionDetailReceivedItems => 'Received Items';

  @override
  String get collectionDetailPetBottles => 'PET Bottles';

  @override
  String get collectionDetailHdpeRigid => 'HDPE Rigid';

  @override
  String get collectionDetailPpHardPlastics => 'PP Hard Plastics';

  @override
  String get collectionDetailCollectionWeight => 'Collection Weight *';

  @override
  String get collectionDetailVerifiedWeight => 'Verified Weight';

  @override
  String get collectionDetailRate => 'Rate: ₹45.00/KG';

  @override
  String get collectionDetailMaterialTotal => 'Total: ₹12,150.00';

  @override
  String get collectionDetailRampPersonPhoto => 'Ramp Person Photo';

  @override
  String get collectionDetailTotalCollectionWeight => 'Total Collection Weight';

  @override
  String get collectionDetailTotalVerifiedWeight => 'Total Verified Weight';

  @override
  String get collectionDetailWeightComparison => 'Weight Comparison';

  @override
  String get collectionDetailComparisonHint =>
      '(0.00 KG Difference if exact match)';

  @override
  String get collectionDetailTotalPrice => 'Total Price';

  @override
  String get collectionDetailPreviewSlip => 'Preview Slip';

  @override
  String get syncOfflineDataTitle => 'Sync Offline Data';

  @override
  String get syncPendingCollections => '3 collection Pending';

  @override
  String get syncAlreadySyncedTitle => 'Data Already Synced';

  @override
  String get syncBack => 'Back';

  @override
  String get logoutConfirmationTitle => 'Are you sure you want to log out?';

  @override
  String get logoutConfirmationMessage =>
      'Any unsynced offline data will remain on this device until your next sign-in.';

  @override
  String get logoutUnsyncedTripsPending => '3 Unsynced Trips Pending';

  @override
  String get logoutNo => 'No';

  @override
  String get logoutYes => 'Yes';
}
