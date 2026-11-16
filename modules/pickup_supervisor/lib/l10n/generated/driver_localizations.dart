import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'driver_localizations_en.dart';
import 'driver_localizations_gu.dart';
import 'driver_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DriverLocalizations
/// returned by `DriverLocalizations.of(context)`.
///
/// Applications need to include `DriverLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/driver_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DriverLocalizations.localizationsDelegates,
///   supportedLocales: DriverLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the DriverLocalizations.supportedLocales
/// property.
abstract class DriverLocalizations {
  DriverLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DriverLocalizations of(BuildContext context) {
    return Localizations.of<DriverLocalizations>(context, DriverLocalizations)!;
  }

  static const LocalizationsDelegate<DriverLocalizations> delegate =
      _DriverLocalizationsDelegate();

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

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @homeDateAndZone.
  ///
  /// In en, this message translates to:
  /// **'Wed, 22 Jul · Surat Zone'**
  String get homeDateAndZone;

  /// No description provided for @warehouseName.
  ///
  /// In en, this message translates to:
  /// **'Magdalla Warehouse'**
  String get warehouseName;

  /// No description provided for @onlineStatus.
  ///
  /// In en, this message translates to:
  /// **'You’re Online'**
  String get onlineStatus;

  /// No description provided for @pendingCollections.
  ///
  /// In en, this message translates to:
  /// **'{count} collection Pending'**
  String pendingCollections(int count);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get syncNow;

  /// No description provided for @todaysSummary.
  ///
  /// In en, this message translates to:
  /// **'Todays Summary'**
  String get todaysSummary;

  /// No description provided for @pendingStops.
  ///
  /// In en, this message translates to:
  /// **'Pending Stops'**
  String get pendingStops;

  /// No description provided for @pendingStopsCount.
  ///
  /// In en, this message translates to:
  /// **'05'**
  String get pendingStopsCount;

  /// No description provided for @collected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collected;

  /// No description provided for @collectedCount.
  ///
  /// In en, this message translates to:
  /// **'03'**
  String get collectedCount;

  /// No description provided for @todaysTrip.
  ///
  /// In en, this message translates to:
  /// **'Today’s Trip'**
  String get todaysTrip;

  /// No description provided for @vehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'GJ-XX-1234'**
  String get vehicleRegistration;

  /// No description provided for @stopsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} stops completed'**
  String stopsCompleted(int completed, int total);

  /// No description provided for @tripProgress.
  ///
  /// In en, this message translates to:
  /// **'37%'**
  String get tripProgress;

  /// No description provided for @completedTripProgress.
  ///
  /// In en, this message translates to:
  /// **'100%'**
  String get completedTripProgress;

  /// No description provided for @openMyStops.
  ///
  /// In en, this message translates to:
  /// **'Open my stops'**
  String get openMyStops;

  /// No description provided for @quickAction.
  ///
  /// In en, this message translates to:
  /// **'Quick Action'**
  String get quickAction;

  /// No description provided for @raiseAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Raise an Issue'**
  String get raiseAnIssue;

  /// No description provided for @issueDescription.
  ///
  /// In en, this message translates to:
  /// **'Report a vehicle, source, or team issue'**
  String get issueDescription;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTab;

  /// No description provided for @stopsTab.
  ///
  /// In en, this message translates to:
  /// **'My Stops'**
  String get stopsTab;

  /// No description provided for @issuesTab.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get issuesTab;

  /// No description provided for @profileTab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTab;

  /// No description provided for @driverPageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This driver page is not available yet'**
  String get driverPageUnavailable;

  /// No description provided for @pendingPickupStops.
  ///
  /// In en, this message translates to:
  /// **'Pending Pickup Stops'**
  String get pendingPickupStops;

  /// No description provided for @stopCardTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {material}'**
  String stopCardTitle(String name, String material);

  /// No description provided for @abcTextileMills.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills'**
  String get abcTextileMills;

  /// No description provided for @shreeSaiDairy.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy'**
  String get shreeSaiDairy;

  /// No description provided for @xyzTextileMills.
  ///
  /// In en, this message translates to:
  /// **'XYZ Textile Mills'**
  String get xyzTextileMills;

  /// No description provided for @sortedMaterial.
  ///
  /// In en, this message translates to:
  /// **'Sorted'**
  String get sortedMaterial;

  /// No description provided for @mixedMaterial.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixedMaterial;

  /// No description provided for @industrialAreaSurat.
  ///
  /// In en, this message translates to:
  /// **'Industrial Area, Surat'**
  String get industrialAreaSurat;

  /// No description provided for @lpSavaniRoadSurat.
  ///
  /// In en, this message translates to:
  /// **'L.P Savani Road, Surat'**
  String get lpSavaniRoadSurat;

  /// No description provided for @pickupSchedule.
  ///
  /// In en, this message translates to:
  /// **'Thu · 8:00–10:00 am'**
  String get pickupSchedule;

  /// No description provided for @noSchedule.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get noSchedule;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @skippedStatus.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedStatus;

  /// No description provided for @stopDetail.
  ///
  /// In en, this message translates to:
  /// **'Stop Detail'**
  String get stopDetail;

  /// No description provided for @driverPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 432145'**
  String get driverPhoneNumber;

  /// No description provided for @call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// No description provided for @requestInformation.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get requestInformation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @pickupAddress.
  ///
  /// In en, this message translates to:
  /// **'U 9, 10, Siddhgiri Tower, B/H Navyug College Rd, Navyug Society, Sangana Society, Adajan, Surat, Gujarat 395009'**
  String get pickupAddress;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @material.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get material;

  /// No description provided for @materialItems.
  ///
  /// In en, this message translates to:
  /// **'Milk Pouch, Card Board'**
  String get materialItems;

  /// No description provided for @expectedWeight.
  ///
  /// In en, this message translates to:
  /// **'Expected Weight'**
  String get expectedWeight;

  /// No description provided for @expectedWeightValue.
  ///
  /// In en, this message translates to:
  /// **'450 KG'**
  String get expectedWeightValue;

  /// No description provided for @requestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pickupDescription.
  ///
  /// In en, this message translates to:
  /// **'I’ve attached a Google Maps location link for easy navigation. Please ensure that any waste photos uploaded are clear and easy to read.'**
  String get pickupDescription;

  /// No description provided for @startPickup.
  ///
  /// In en, this message translates to:
  /// **'Start Pickup'**
  String get startPickup;

  /// No description provided for @mixedDriverPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'+91 1234567890'**
  String get mixedDriverPhoneNumber;

  /// No description provided for @mixedExpectedWeightValue.
  ///
  /// In en, this message translates to:
  /// **'200 KG'**
  String get mixedExpectedWeightValue;

  /// No description provided for @sortedWasteForm.
  ///
  /// In en, this message translates to:
  /// **'Sorted Waste Form'**
  String get sortedWasteForm;

  /// No description provided for @captureMaterialScalePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Material & Scale Photo'**
  String get captureMaterialScalePhoto;

  /// No description provided for @petBottles.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles'**
  String get petBottles;

  /// No description provided for @hdpeRigid.
  ///
  /// In en, this message translates to:
  /// **'HDPE Rigid'**
  String get hdpeRigid;

  /// No description provided for @eWaste.
  ///
  /// In en, this message translates to:
  /// **'E-Waste'**
  String get eWaste;

  /// No description provided for @kgUnit.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get kgUnit;

  /// No description provided for @pcsUnit.
  ///
  /// In en, this message translates to:
  /// **'PCS'**
  String get pcsUnit;

  /// No description provided for @collectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get collectedLabel;

  /// No description provided for @exampleWeight.
  ///
  /// In en, this message translates to:
  /// **'ex 123.00'**
  String get exampleWeight;

  /// No description provided for @capturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get capturePhoto;

  /// No description provided for @petCollectedWeight.
  ///
  /// In en, this message translates to:
  /// **'270.00'**
  String get petCollectedWeight;

  /// No description provided for @hdpeCollectedWeight.
  ///
  /// In en, this message translates to:
  /// **'270.00'**
  String get hdpeCollectedWeight;

  /// No description provided for @eWasteCollectedCount.
  ///
  /// In en, this message translates to:
  /// **'25'**
  String get eWasteCollectedCount;

  /// No description provided for @savePickup.
  ///
  /// In en, this message translates to:
  /// **'Save Pickup'**
  String get savePickup;

  /// No description provided for @mixedWasteForm.
  ///
  /// In en, this message translates to:
  /// **'Mixed Waste Form'**
  String get mixedWasteForm;

  /// No description provided for @enterWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Enter Weight (KG)'**
  String get enterWeightKg;

  /// No description provided for @mixedWeightValue.
  ///
  /// In en, this message translates to:
  /// **'300.00'**
  String get mixedWeightValue;

  /// No description provided for @materialAndScalePhoto.
  ///
  /// In en, this message translates to:
  /// **'Material & Material & Scale Photo'**
  String get materialAndScalePhoto;

  /// No description provided for @supportedPhotoFormats.
  ///
  /// In en, this message translates to:
  /// **'Supported: JPG, PNG (Max 5MB).'**
  String get supportedPhotoFormats;

  /// No description provided for @sortedPickupForm.
  ///
  /// In en, this message translates to:
  /// **'Sorted Pickup Form'**
  String get sortedPickupForm;

  /// No description provided for @successWeightValue.
  ///
  /// In en, this message translates to:
  /// **'240.51'**
  String get successWeightValue;

  /// No description provided for @materialAndWeighbridgePhoto.
  ///
  /// In en, this message translates to:
  /// **'Material & Weighbridge Photo'**
  String get materialAndWeighbridgePhoto;

  /// No description provided for @pickupRecorded.
  ///
  /// In en, this message translates to:
  /// **'Pickup Recorded'**
  String get pickupRecorded;

  /// No description provided for @successfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully!'**
  String get successfully;

  /// No description provided for @pickupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'The pickup has been successfully saved. The status will be updated in your trip.'**
  String get pickupSuccessMessage;

  /// No description provided for @backToList.
  ///
  /// In en, this message translates to:
  /// **'Back to List'**
  String get backToList;

  /// No description provided for @selectProblemsStruggling.
  ///
  /// In en, this message translates to:
  /// **'Select Problems You Struggling With'**
  String get selectProblemsStruggling;

  /// No description provided for @vehicleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Vehicle breakdown'**
  String get vehicleBreakdown;

  /// No description provided for @accident.
  ///
  /// In en, this message translates to:
  /// **'Accident'**
  String get accident;

  /// No description provided for @sourceProblem.
  ///
  /// In en, this message translates to:
  /// **'Source problem'**
  String get sourceProblem;

  /// No description provided for @otherIssue.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherIssue;

  /// No description provided for @remarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarks;

  /// No description provided for @addYourRemarks.
  ///
  /// In en, this message translates to:
  /// **'Add your remarks...'**
  String get addYourRemarks;

  /// No description provided for @max150Characters.
  ///
  /// In en, this message translates to:
  /// **'Max 150 Characters'**
  String get max150Characters;

  /// No description provided for @submitIssue.
  ///
  /// In en, this message translates to:
  /// **'Submit Issue'**
  String get submitIssue;
}

class _DriverLocalizationsDelegate
    extends LocalizationsDelegate<DriverLocalizations> {
  const _DriverLocalizationsDelegate();

  @override
  Future<DriverLocalizations> load(Locale locale) {
    return SynchronousFuture<DriverLocalizations>(
      lookupDriverLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_DriverLocalizationsDelegate old) => false;
}

DriverLocalizations lookupDriverLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return DriverLocalizationsEn();
    case 'gu':
      return DriverLocalizationsGu();
    case 'hi':
      return DriverLocalizationsHi();
  }

  throw FlutterError(
    'DriverLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
