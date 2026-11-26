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
  /// **'Collected ({count})'**
  String collectedCount(int count);

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

  /// No description provided for @yourPickupSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Your Pickup Supervisor'**
  String get yourPickupSupervisor;

  /// No description provided for @supervisorName.
  ///
  /// In en, this message translates to:
  /// **'Kiran Shah'**
  String get supervisorName;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @collectedToday.
  ///
  /// In en, this message translates to:
  /// **'Collected today'**
  String get collectedToday;

  /// No description provided for @collectedWeight420.
  ///
  /// In en, this message translates to:
  /// **'420 kg so far'**
  String get collectedWeight420;

  /// No description provided for @collectedWeightZero.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get collectedWeightZero;

  /// No description provided for @zeroKg.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get zeroKg;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @todaysTripsCount.
  ///
  /// In en, this message translates to:
  /// **'Today’s Trips ({count})'**
  String todaysTripsCount(int count);

  /// No description provided for @todaysTrips.
  ///
  /// In en, this message translates to:
  /// **'Today’s Trips'**
  String get todaysTrips;

  /// No description provided for @tripMorning.
  ///
  /// In en, this message translates to:
  /// **'Trip 1 · Morning'**
  String get tripMorning;

  /// No description provided for @tripAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Trip 2 · Afternoon'**
  String get tripAfternoon;

  /// No description provided for @morningTripTime.
  ///
  /// In en, this message translates to:
  /// **'7:00 – 11:00 am · 7 stops'**
  String get morningTripTime;

  /// No description provided for @afternoonTripTime.
  ///
  /// In en, this message translates to:
  /// **'2:00 – 5:00 pm · 6 stops'**
  String get afternoonTripTime;

  /// No description provided for @afternoonStartTime.
  ///
  /// In en, this message translates to:
  /// **'2:00 pm'**
  String get afternoonStartTime;

  /// No description provided for @onTheWay.
  ///
  /// In en, this message translates to:
  /// **'On the way'**
  String get onTheWay;

  /// No description provided for @startsAt.
  ///
  /// In en, this message translates to:
  /// **'Starts {time}'**
  String startsAt(String time);

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @vehicleCrew.
  ///
  /// In en, this message translates to:
  /// **'GJ-XX-1234 · Suresh, Mahesh'**
  String get vehicleCrew;

  /// No description provided for @dropMagdalla.
  ///
  /// In en, this message translates to:
  /// **'Drop at Magdalla Warehouse'**
  String get dropMagdalla;

  /// No description provided for @dropSachin.
  ///
  /// In en, this message translates to:
  /// **'Drop at Sachin Warehouse'**
  String get dropSachin;

  /// No description provided for @collectedOnTrip.
  ///
  /// In en, this message translates to:
  /// **'Collected on this trip'**
  String get collectedOnTrip;

  /// No description provided for @weight420Kg.
  ///
  /// In en, this message translates to:
  /// **'420 kg'**
  String get weight420Kg;

  /// No description provided for @weight180Kg.
  ///
  /// In en, this message translates to:
  /// **'180 kg'**
  String get weight180Kg;

  /// No description provided for @stopsDone.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} stops done'**
  String stopsDone(int completed, int total);

  /// No description provided for @seeAllStops.
  ///
  /// In en, this message translates to:
  /// **'See all {count} stops'**
  String seeAllStops(int count);

  /// No description provided for @nextStopOnTrip.
  ///
  /// In en, this message translates to:
  /// **'Next stop on Trip {trip}'**
  String nextStopOnTrip(int trip);

  /// No description provided for @afterThat.
  ///
  /// In en, this message translates to:
  /// **'After that ({count})'**
  String afterThat(int count);

  /// No description provided for @laterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get laterToday;

  /// No description provided for @earlierToday.
  ///
  /// In en, this message translates to:
  /// **'Earlier today'**
  String get earlierToday;

  /// No description provided for @stopPosition.
  ///
  /// In en, this message translates to:
  /// **'Stop {current} of {total}'**
  String stopPosition(int current, int total);

  /// No description provided for @nextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get nextStop;

  /// No description provided for @enterCollection.
  ///
  /// In en, this message translates to:
  /// **'Enter collection'**
  String get enterCollection;

  /// No description provided for @opensAfterStop.
  ///
  /// In en, this message translates to:
  /// **'Opens after stop {stop}'**
  String opensAfterStop(int stop);

  /// No description provided for @unlockAfterStop.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when stop {stop} is done, or when you reach this stop (GPS). Tap to check your location.'**
  String unlockAfterStop(int stop);

  /// No description provided for @handedOverWeight.
  ///
  /// In en, this message translates to:
  /// **'Handed over · 1,240 kg net'**
  String get handedOverWeight;

  /// No description provided for @royalResidency.
  ///
  /// In en, this message translates to:
  /// **'Royal Residency'**
  String get royalResidency;

  /// No description provided for @shantiNagar.
  ///
  /// In en, this message translates to:
  /// **'Shanti Nagar'**
  String get shantiNagar;

  /// No description provided for @ghodDodRoadSurat.
  ///
  /// In en, this message translates to:
  /// **'Ghod Dod Road, Surat'**
  String get ghodDodRoadSurat;

  /// No description provided for @citylightRoadSurat.
  ///
  /// In en, this message translates to:
  /// **'Citylight Road, Surat'**
  String get citylightRoadSurat;

  /// No description provided for @rakeshStoreManager.
  ///
  /// In en, this message translates to:
  /// **'Rakesh Shah · Store manager'**
  String get rakeshStoreManager;

  /// No description provided for @maheshOwner.
  ///
  /// In en, this message translates to:
  /// **'Mahesh Desai · Owner'**
  String get maheshOwner;

  /// No description provided for @priyaSecretary.
  ///
  /// In en, this message translates to:
  /// **'Priya Patel · Secretary'**
  String get priyaSecretary;

  /// No description provided for @meenaSecretary.
  ///
  /// In en, this message translates to:
  /// **'Meena Desai · Secretary'**
  String get meenaSecretary;

  /// No description provided for @pickupSchedule9to11.
  ///
  /// In en, this message translates to:
  /// **'Thu · 9:00–11:00 am'**
  String get pickupSchedule9to11;

  /// No description provided for @pickupSchedule3to330.
  ///
  /// In en, this message translates to:
  /// **'Thu · 3:00–3:30 pm'**
  String get pickupSchedule3to330;

  /// No description provided for @pickupSchedule330to4.
  ///
  /// In en, this message translates to:
  /// **'Thu · 3:30–4:00 pm'**
  String get pickupSchedule330to4;

  /// No description provided for @noTripToday.
  ///
  /// In en, this message translates to:
  /// **'No trip today'**
  String get noTripToday;

  /// No description provided for @noTripMessage.
  ///
  /// In en, this message translates to:
  /// **'Kiran Shah hasn’t put you on a trip today. You’ll get a message when one is added.'**
  String get noTripMessage;

  /// No description provided for @tripOneStops.
  ///
  /// In en, this message translates to:
  /// **'Trip 1 stops'**
  String get tripOneStops;

  /// No description provided for @morningTripWindow.
  ///
  /// In en, this message translates to:
  /// **'Morning · 7:00 – 11:00 am'**
  String get morningTripWindow;

  /// No description provided for @fiveOfSevenDone.
  ///
  /// In en, this message translates to:
  /// **'5 of 7 done'**
  String get fiveOfSevenDone;

  /// No description provided for @stillToCollect.
  ///
  /// In en, this message translates to:
  /// **'Still to collect ({count})'**
  String stillToCollect(int count);

  /// No description provided for @doneStops.
  ///
  /// In en, this message translates to:
  /// **'Done ({count})'**
  String doneStops(int count);

  /// No description provided for @stopNumber.
  ///
  /// In en, this message translates to:
  /// **'Stop {number}'**
  String stopNumber(int number);

  /// No description provided for @hotelRajdhani.
  ///
  /// In en, this message translates to:
  /// **'Hotel Rajdhani'**
  String get hotelRajdhani;

  /// No description provided for @greenParkSociety.
  ///
  /// In en, this message translates to:
  /// **'Green Park Society'**
  String get greenParkSociety;

  /// No description provided for @navratriGroundEvent.
  ///
  /// In en, this message translates to:
  /// **'Navratri Ground (event)'**
  String get navratriGroundEvent;

  /// No description provided for @cityBakery.
  ///
  /// In en, this message translates to:
  /// **'City Bakery'**
  String get cityBakery;

  /// No description provided for @hotelRajdhaniWeight.
  ///
  /// In en, this message translates to:
  /// **'85 kg'**
  String get hotelRajdhaniWeight;

  /// No description provided for @greenParkWeight.
  ///
  /// In en, this message translates to:
  /// **'120 kg'**
  String get greenParkWeight;

  /// No description provided for @navratriGroundWeight.
  ///
  /// In en, this message translates to:
  /// **'215 kg'**
  String get navratriGroundWeight;

  /// No description provided for @noMaterialToday.
  ///
  /// In en, this message translates to:
  /// **'No material today'**
  String get noMaterialToday;

  /// No description provided for @cancelledBySource.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by source'**
  String get cancelledBySource;

  /// No description provided for @stockTakingReason.
  ///
  /// In en, this message translates to:
  /// **'Closed for stock-taking'**
  String get stockTakingReason;

  /// No description provided for @unlockStopMessage.
  ///
  /// In en, this message translates to:
  /// **'Unlocks when stop 6 is done, or when you reach this stop (GPS). Tap to check your location.'**
  String get unlockStopMessage;

  /// No description provided for @stopTwoCollection.
  ///
  /// In en, this message translates to:
  /// **'Stop 2 · collection'**
  String get stopTwoCollection;

  /// No description provided for @savedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved at 7:52 am · Thu 22 Jul'**
  String get savedAt;

  /// No description provided for @whatYouSaved.
  ///
  /// In en, this message translates to:
  /// **'What you saved'**
  String get whatYouSaved;

  /// No description provided for @cardboard.
  ///
  /// In en, this message translates to:
  /// **'Cardboard'**
  String get cardboard;

  /// No description provided for @petBottlesWeight.
  ///
  /// In en, this message translates to:
  /// **'50 kg'**
  String get petBottlesWeight;

  /// No description provided for @cardboardWeight.
  ///
  /// In en, this message translates to:
  /// **'35 kg'**
  String get cardboardWeight;

  /// No description provided for @photosMaterialScale.
  ///
  /// In en, this message translates to:
  /// **'Photos (material and scale)'**
  String get photosMaterialScale;

  /// No description provided for @askSupervisorToCorrect.
  ///
  /// In en, this message translates to:
  /// **'Ask supervisor to correct'**
  String get askSupervisorToCorrect;

  /// No description provided for @savedCollectionReadonlyMessage.
  ///
  /// In en, this message translates to:
  /// **'You can only view a saved collection. If something is wrong, ask your supervisor: they check it against the photos and correct it.'**
  String get savedCollectionReadonlyMessage;

  /// No description provided for @askToCorrect.
  ///
  /// In en, this message translates to:
  /// **'Ask to correct'**
  String get askToCorrect;

  /// No description provided for @whatIsWrongAtStop.
  ///
  /// In en, this message translates to:
  /// **'What is wrong? Hotel Rajdhani · stop 2'**
  String get whatIsWrongAtStop;

  /// No description provided for @correctionWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get correctionWeight;

  /// No description provided for @correctionItem.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get correctionItem;

  /// No description provided for @correctionPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get correctionPhoto;

  /// No description provided for @correctionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get correctionOther;

  /// No description provided for @rightValueAndNote.
  ///
  /// In en, this message translates to:
  /// **'Right value and note'**
  String get rightValueAndNote;

  /// No description provided for @correctionNoteExample.
  ///
  /// In en, this message translates to:
  /// **'Example: PET Bottles was 60 kg, not 50 kg. The scale photo shows 60 kg.'**
  String get correctionNoteExample;

  /// No description provided for @sendToSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Send to supervisor'**
  String get sendToSupervisor;

  /// No description provided for @requestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get requestSent;

  /// No description provided for @toYourSupervisor.
  ///
  /// In en, this message translates to:
  /// **'to your supervisor'**
  String get toYourSupervisor;

  /// No description provided for @correctionRequestSummary.
  ///
  /// In en, this message translates to:
  /// **'Hotel Rajdhani · weight · 50 kg → 60 kg'**
  String get correctionRequestSummary;

  /// No description provided for @whatHappensNext.
  ///
  /// In en, this message translates to:
  /// **'WHAT HAPPENS NEXT'**
  String get whatHappensNext;

  /// No description provided for @supervisorChecksPhotos.
  ///
  /// In en, this message translates to:
  /// **'Kiran Shah checks it against your photos'**
  String get supervisorChecksPhotos;

  /// No description provided for @correctionRequestedUntil.
  ///
  /// In en, this message translates to:
  /// **'The stop shows “Correction requested” until then'**
  String get correctionRequestedUntil;

  /// No description provided for @correctionNotification.
  ///
  /// In en, this message translates to:
  /// **'You get a notification when it is corrected'**
  String get correctionNotification;

  /// No description provided for @backToMyStops.
  ///
  /// In en, this message translates to:
  /// **'Back to my stops'**
  String get backToMyStops;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @stopTripPosition.
  ///
  /// In en, this message translates to:
  /// **'Stop 6 of 7 · Trip 1'**
  String get stopTripPosition;

  /// No description provided for @personAtPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Person at the pickup point'**
  String get personAtPickupPoint;

  /// No description provided for @rakeshShah.
  ///
  /// In en, this message translates to:
  /// **'Rakesh Shah'**
  String get rakeshShah;

  /// No description provided for @storeManager.
  ///
  /// In en, this message translates to:
  /// **'Store manager'**
  String get storeManager;

  /// No description provided for @pickupContactPhone.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43214'**
  String get pickupContactPhone;

  /// No description provided for @nothingToCollectWeight.
  ///
  /// In en, this message translates to:
  /// **'Nothing to collect (0 kg)'**
  String get nothingToCollectWeight;

  /// No description provided for @nothingToCollect.
  ///
  /// In en, this message translates to:
  /// **'Nothing to collect'**
  String get nothingToCollect;

  /// No description provided for @abcStopSixOfSeven.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills · Stop 6 of 7'**
  String get abcStopSixOfSeven;

  /// No description provided for @savedAsZeroKgMessage.
  ///
  /// In en, this message translates to:
  /// **'This stop will be saved as 0 kg.'**
  String get savedAsZeroKgMessage;

  /// No description provided for @whyNothingCollected.
  ///
  /// In en, this message translates to:
  /// **'Why was nothing collected?'**
  String get whyNothingCollected;

  /// No description provided for @reasonClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get reasonClosed;

  /// No description provided for @reasonRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused to give'**
  String get reasonRefused;

  /// No description provided for @reasonNotReachable.
  ///
  /// In en, this message translates to:
  /// **'Not reachable'**
  String get reasonNotReachable;

  /// No description provided for @reasonVehicleFull.
  ///
  /// In en, this message translates to:
  /// **'Vehicle full'**
  String get reasonVehicleFull;

  /// No description provided for @photoOptional.
  ///
  /// In en, this message translates to:
  /// **'Photo (optional)'**
  String get photoOptional;

  /// No description provided for @noteForSupervisorOptional.
  ///
  /// In en, this message translates to:
  /// **'Note for supervisor (optional)'**
  String get noteForSupervisorOptional;

  /// No description provided for @typeANote.
  ///
  /// In en, this message translates to:
  /// **'Type a note…'**
  String get typeANote;

  /// No description provided for @holdToRecordVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Hold to record a voice note'**
  String get holdToRecordVoiceNote;

  /// No description provided for @upToOneMinute.
  ///
  /// In en, this message translates to:
  /// **'Up to 1 minute'**
  String get upToOneMinute;

  /// No description provided for @voiceNoteZeroTime.
  ///
  /// In en, this message translates to:
  /// **'0:00'**
  String get voiceNoteZeroTime;

  /// No description provided for @recordingVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Recording voice note…'**
  String get recordingVoiceNote;

  /// No description provided for @voiceNoteRecorded.
  ///
  /// In en, this message translates to:
  /// **'Voice note recorded'**
  String get voiceNoteRecorded;

  /// No description provided for @playVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Play voice note'**
  String get playVoiceNote;

  /// No description provided for @pauseVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Pause voice note'**
  String get pauseVoiceNote;

  /// No description provided for @removeVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Remove voice note'**
  String get removeVoiceNote;

  /// No description provided for @voiceNotePlaybackFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not play the voice note. Please try again.'**
  String get voiceNotePlaybackFailed;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is required to record a voice note.'**
  String get microphonePermissionRequired;

  /// No description provided for @voiceNoteRecordingFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not record the voice note. Please try again.'**
  String get voiceNoteRecordingFailed;

  /// No description provided for @locationMatched.
  ///
  /// In en, this message translates to:
  /// **'Location matched'**
  String get locationMatched;

  /// No description provided for @locationNotMatched.
  ///
  /// In en, this message translates to:
  /// **'Location not matched'**
  String get locationNotMatched;

  /// No description provided for @sortedStopSixOfSeven.
  ///
  /// In en, this message translates to:
  /// **'Stop 6 of 7 · Sorted'**
  String get sortedStopSixOfSeven;

  /// No description provided for @mixedStopSevenOfSeven.
  ///
  /// In en, this message translates to:
  /// **'Stop 7 of 7 · Mixed'**
  String get mixedStopSevenOfSeven;

  /// No description provided for @recordedLaterWarning.
  ///
  /// In en, this message translates to:
  /// **'Recorded later: you are not at this stop now. The supervisor and the gate see this note.'**
  String get recordedLaterWarning;

  /// No description provided for @saveAsZeroKg.
  ///
  /// In en, this message translates to:
  /// **'Save as 0 kg'**
  String get saveAsZeroKg;

  /// No description provided for @orderedPickupStops.
  ///
  /// In en, this message translates to:
  /// **'Ordered Pickup Stops'**
  String get orderedPickupStops;

  /// No description provided for @startYourCollections.
  ///
  /// In en, this message translates to:
  /// **'Start your collections'**
  String get startYourCollections;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get searchHere;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending ({count})'**
  String pendingCount(int count);

  /// No description provided for @yashTextileHub.
  ///
  /// In en, this message translates to:
  /// **'Yash Textile Hub'**
  String get yashTextileHub;

  /// No description provided for @anjanaFarmAreaSurat.
  ///
  /// In en, this message translates to:
  /// **'Anjana Farm Area, Surat'**
  String get anjanaFarmAreaSurat;

  /// No description provided for @collectionWindowNineToTen.
  ///
  /// In en, this message translates to:
  /// **'09:00 AM - 10:00 AM'**
  String get collectionWindowNineToTen;

  /// No description provided for @materialSortedLabel.
  ///
  /// In en, this message translates to:
  /// **'Material : Sorted'**
  String get materialSortedLabel;

  /// No description provided for @findingYourLocationStatus.
  ///
  /// In en, this message translates to:
  /// **'Finding your location…'**
  String get findingYourLocationStatus;

  /// No description provided for @findingYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Finding your location'**
  String get findingYourLocation;

  /// No description provided for @findingLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'Stand near the pickup point. This takes a few seconds.'**
  String get findingLocationMessage;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @locationDetected.
  ///
  /// In en, this message translates to:
  /// **'Location detected'**
  String get locationDetected;

  /// No description provided for @notHere.
  ///
  /// In en, this message translates to:
  /// **'Not Here'**
  String get notHere;

  /// No description provided for @startCollection.
  ///
  /// In en, this message translates to:
  /// **'Start collection'**
  String get startCollection;

  /// No description provided for @stopsNearby.
  ///
  /// In en, this message translates to:
  /// **'{count} stops nearby'**
  String stopsNearby(int count);

  /// No description provided for @whichStopAreYouAt.
  ///
  /// In en, this message translates to:
  /// **'Which stop are you at?'**
  String get whichStopAreYouAt;

  /// No description provided for @twoStopsCloseMessage.
  ///
  /// In en, this message translates to:
  /// **'Two stops on your trip are close to you.'**
  String get twoStopsCloseMessage;

  /// No description provided for @distanceStopSeven.
  ///
  /// In en, this message translates to:
  /// **'40 m away · Stop 7'**
  String get distanceStopSeven;

  /// No description provided for @distanceAlreadyCollected.
  ///
  /// In en, this message translates to:
  /// **'85 m away · already collected'**
  String get distanceAlreadyCollected;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @noStopFoundHere.
  ///
  /// In en, this message translates to:
  /// **'No stop found here'**
  String get noStopFoundHere;

  /// No description provided for @notAtTripStop.
  ///
  /// In en, this message translates to:
  /// **'You’re not at a stop on this trip'**
  String get notAtTripStop;

  /// No description provided for @notAtStopMessage.
  ///
  /// In en, this message translates to:
  /// **'Move closer and try again, choose the stop yourself, or leave it for the gate team.'**
  String get notAtStopMessage;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @chooseStopMyself.
  ///
  /// In en, this message translates to:
  /// **'Choose the stop myself'**
  String get chooseStopMyself;

  /// No description provided for @gateTeamWillEnter.
  ///
  /// In en, this message translates to:
  /// **'Gate team will enter'**
  String get gateTeamWillEnter;

  /// No description provided for @locationIsOff.
  ///
  /// In en, this message translates to:
  /// **'Location is off'**
  String get locationIsOff;

  /// No description provided for @turnOnLocation.
  ///
  /// In en, this message translates to:
  /// **'Turn on location'**
  String get turnOnLocation;

  /// No description provided for @locationOffMessage.
  ///
  /// In en, this message translates to:
  /// **'The app finds your stop from your location. Turn it on to record pickups.'**
  String get locationOffMessage;

  /// No description provided for @shreeSaiStopSeven.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy · Stop 7 of 7'**
  String get shreeSaiStopSeven;

  /// No description provided for @gateTeamEntryMessage.
  ///
  /// In en, this message translates to:
  /// **'The back office enters this pickup at the warehouse gate.'**
  String get gateTeamEntryMessage;

  /// No description provided for @weightYouNotedOptional.
  ///
  /// In en, this message translates to:
  /// **'Weight you noted (optional)'**
  String get weightYouNotedOptional;

  /// No description provided for @aboutThreeHundred.
  ///
  /// In en, this message translates to:
  /// **'about 300'**
  String get aboutThreeHundred;

  /// No description provided for @gateWeightHelp.
  ///
  /// In en, this message translates to:
  /// **'A rough figure helps the gate team. They weigh it again at the gate.'**
  String get gateWeightHelp;

  /// No description provided for @markForGateTeam.
  ///
  /// In en, this message translates to:
  /// **'Mark for the gate team'**
  String get markForGateTeam;

  /// No description provided for @nextPickupSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills · 540 kg + 25 pcs saved.'**
  String get nextPickupSavedMessage;

  /// No description provided for @lastPickupSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy · 300 kg saved.'**
  String get lastPickupSavedMessage;

  /// No description provided for @nextStopSevenOfSeven.
  ///
  /// In en, this message translates to:
  /// **'NEXT STOP · 7 OF 7'**
  String get nextStopSevenOfSeven;

  /// No description provided for @nextStopDistance.
  ///
  /// In en, this message translates to:
  /// **'L.P Savani Road, Surat · 1.2 km'**
  String get nextStopDistance;

  /// No description provided for @goToNextStop.
  ///
  /// In en, this message translates to:
  /// **'Go to next stop'**
  String get goToNextStop;

  /// No description provided for @allTripStopsDone.
  ///
  /// In en, this message translates to:
  /// **'ALL 7 STOPS OF TRIP 1 DONE'**
  String get allTripStopsDone;

  /// No description provided for @takeLoadToWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Take the load to Magdalla Warehouse'**
  String get takeLoadToWarehouse;

  /// No description provided for @vehicleLoadTotal.
  ///
  /// In en, this message translates to:
  /// **'1,260 kg + 25 pcs on the vehicle'**
  String get vehicleLoadTotal;

  /// No description provided for @warehouseDistance.
  ///
  /// In en, this message translates to:
  /// **'Magdalla, Surat · 6.4 km'**
  String get warehouseDistance;

  /// No description provided for @viewTripSummary.
  ///
  /// In en, this message translates to:
  /// **'View trip summary'**
  String get viewTripSummary;

  /// No description provided for @tripOneSummary.
  ///
  /// In en, this message translates to:
  /// **'Trip 1 summary'**
  String get tripOneSummary;

  /// No description provided for @allStopsDone.
  ///
  /// In en, this message translates to:
  /// **'All stops done'**
  String get allStopsDone;

  /// No description provided for @tripCollectedTotal.
  ///
  /// In en, this message translates to:
  /// **'1,260 kg + 25 pcs'**
  String get tripCollectedTotal;

  /// No description provided for @mixedWaste.
  ///
  /// In en, this message translates to:
  /// **'Mixed waste'**
  String get mixedWaste;

  /// No description provided for @weight635Kg.
  ///
  /// In en, this message translates to:
  /// **'635 kg'**
  String get weight635Kg;

  /// No description provided for @weight270Kg.
  ///
  /// In en, this message translates to:
  /// **'270 kg'**
  String get weight270Kg;

  /// No description provided for @weight85Kg.
  ///
  /// In en, this message translates to:
  /// **'85 kg'**
  String get weight85Kg;

  /// No description provided for @count25Pcs.
  ///
  /// In en, this message translates to:
  /// **'25 pcs'**
  String get count25Pcs;

  /// No description provided for @dropAt.
  ///
  /// In en, this message translates to:
  /// **'DROP AT'**
  String get dropAt;

  /// No description provided for @warehouseAddressDistance.
  ///
  /// In en, this message translates to:
  /// **'Magdalla Port Road, Surat · 6.4 km'**
  String get warehouseAddressDistance;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @callWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Call warehouse'**
  String get callWarehouse;

  /// No description provided for @notCollectedTwo.
  ///
  /// In en, this message translates to:
  /// **'Not collected (2)'**
  String get notCollectedTwo;

  /// No description provided for @closedForStockTaking.
  ///
  /// In en, this message translates to:
  /// **'Closed for stock-taking'**
  String get closedForStockTaking;

  /// No description provided for @handOverAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Hand over at the warehouse'**
  String get handOverAtWarehouse;

  /// No description provided for @warehouseGateInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap at the warehouse gate. You enter the number of bags; the Warehouse Incharge weighs the vehicle.'**
  String get warehouseGateInstruction;

  /// No description provided for @handOverTripOne.
  ///
  /// In en, this message translates to:
  /// **'Hand over · Trip 1'**
  String get handOverTripOne;

  /// No description provided for @yourCountFromStops.
  ///
  /// In en, this message translates to:
  /// **'Your count (from the stops)'**
  String get yourCountFromStops;

  /// No description provided for @numberOfBags.
  ///
  /// In en, this message translates to:
  /// **'Number of bags'**
  String get numberOfBags;

  /// No description provided for @bagsUnit.
  ///
  /// In en, this message translates to:
  /// **'BAGS'**
  String get bagsUnit;

  /// No description provided for @bagsCount.
  ///
  /// In en, this message translates to:
  /// **'42'**
  String get bagsCount;

  /// No description provided for @bagsHelp.
  ///
  /// In en, this message translates to:
  /// **'Count the bags you unload. Loose items such as e-waste are counted in pieces.'**
  String get bagsHelp;

  /// No description provided for @handOver.
  ///
  /// In en, this message translates to:
  /// **'Hand over'**
  String get handOver;

  /// No description provided for @warehouseWeighInstruction.
  ///
  /// In en, this message translates to:
  /// **'The Warehouse Incharge checks the load and weighs the vehicle on the weighbridge. You see the weight here when they save it.'**
  String get warehouseWeighInstruction;

  /// No description provided for @tripAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Trip 1 · at the warehouse'**
  String get tripAtWarehouse;

  /// No description provided for @waitingStatus.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waitingStatus;

  /// No description provided for @vehicleAtWarehouseSince.
  ///
  /// In en, this message translates to:
  /// **'GJ-XX-1234 · at Magdalla since 11:20 am'**
  String get vehicleAtWarehouseSince;

  /// No description provided for @youHandedOver.
  ///
  /// In en, this message translates to:
  /// **'You handed over'**
  String get youHandedOver;

  /// No description provided for @handedOverTotal.
  ///
  /// In en, this message translates to:
  /// **'1,260 kg + 25 pcs · 42 bags'**
  String get handedOverTotal;

  /// No description provided for @waitingWarehouseInstruction.
  ///
  /// In en, this message translates to:
  /// **'Handed over at 11:20 am. The Warehouse Incharge is weighing the vehicle; the weighbridge weight shows here when they save it.'**
  String get waitingWarehouseInstruction;

  /// No description provided for @tripReceived.
  ///
  /// In en, this message translates to:
  /// **'Trip 1 · received'**
  String get tripReceived;

  /// No description provided for @receivedStatus.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedStatus;

  /// No description provided for @vehicleAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'GJ-XX-1234 · Magdalla Warehouse'**
  String get vehicleAtWarehouse;

  /// No description provided for @weighbridgeEnteredByWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Weighbridge · entered by the warehouse'**
  String get weighbridgeEnteredByWarehouse;

  /// No description provided for @warehouseReceivedTotal.
  ///
  /// In en, this message translates to:
  /// **'1,240 kg net + 25 pcs'**
  String get warehouseReceivedTotal;

  /// No description provided for @withLoadGross.
  ///
  /// In en, this message translates to:
  /// **'With load (gross)'**
  String get withLoadGross;

  /// No description provided for @weight8940Kg.
  ///
  /// In en, this message translates to:
  /// **'8,940 kg'**
  String get weight8940Kg;

  /// No description provided for @emptyVehicle.
  ///
  /// In en, this message translates to:
  /// **'Empty vehicle'**
  String get emptyVehicle;

  /// No description provided for @weight7700Kg.
  ///
  /// In en, this message translates to:
  /// **'7,700 kg'**
  String get weight7700Kg;

  /// No description provided for @netWeight.
  ///
  /// In en, this message translates to:
  /// **'Net weight'**
  String get netWeight;

  /// No description provided for @weight1240Kg.
  ///
  /// In en, this message translates to:
  /// **'1,240 kg'**
  String get weight1240Kg;

  /// No description provided for @bagsReceived.
  ///
  /// In en, this message translates to:
  /// **'Bags received'**
  String get bagsReceived;

  /// No description provided for @eWasteCounted.
  ///
  /// In en, this message translates to:
  /// **'E-Waste (counted)'**
  String get eWasteCounted;

  /// No description provided for @yourCountVsWeighbridge.
  ///
  /// In en, this message translates to:
  /// **'Your count vs the weighbridge'**
  String get yourCountVsWeighbridge;

  /// No description provided for @yourCount.
  ///
  /// In en, this message translates to:
  /// **'Your count'**
  String get yourCount;

  /// No description provided for @weight1260Kg.
  ///
  /// In en, this message translates to:
  /// **'1,260 kg'**
  String get weight1260Kg;

  /// No description provided for @weighbridgeNet.
  ///
  /// In en, this message translates to:
  /// **'Weighbridge net'**
  String get weighbridgeNet;

  /// No description provided for @difference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get difference;

  /// No description provided for @weightDifference.
  ///
  /// In en, this message translates to:
  /// **'−20 kg (1.6% less)'**
  String get weightDifference;

  /// No description provided for @receivedWarehouseInstruction.
  ///
  /// In en, this message translates to:
  /// **'Received at 11:42 am by Ramesh Patel, Warehouse Incharge. If the difference looks wrong, raise an issue.'**
  String get receivedWarehouseInstruction;

  /// No description provided for @supervisorWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get supervisorWelcomeBack;

  /// No description provided for @supervisorHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Thu 22 Oct 2026 · Adajan, Vesu, Pal'**
  String get supervisorHeaderSubtitle;

  /// No description provided for @supervisorOnline.
  ///
  /// In en, this message translates to:
  /// **'You’re Online'**
  String get supervisorOnline;

  /// No description provided for @supervisorLastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced 2 min ago'**
  String get supervisorLastSynced;

  /// No description provided for @supervisorSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get supervisorSyncNow;

  /// No description provided for @supervisorNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs your attention'**
  String get supervisorNeedsAttention;

  /// No description provided for @supervisorAttentionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve, sort out or check these first'**
  String get supervisorAttentionSubtitle;

  /// No description provided for @supervisorApprovals.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get supervisorApprovals;

  /// No description provided for @supervisorIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get supervisorIssues;

  /// No description provided for @supervisorMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get supervisorMyRequests;

  /// No description provided for @supervisorFlags.
  ///
  /// In en, this message translates to:
  /// **'Flags'**
  String get supervisorFlags;

  /// No description provided for @supervisorCollectionSummary.
  ///
  /// In en, this message translates to:
  /// **'Collection summary'**
  String get supervisorCollectionSummary;

  /// No description provided for @supervisorToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get supervisorToday;

  /// No description provided for @supervisorYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get supervisorYesterday;

  /// No description provided for @supervisorWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get supervisorWeek;

  /// No description provided for @supervisorMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get supervisorMonth;

  /// No description provided for @supervisorCollectedToday.
  ///
  /// In en, this message translates to:
  /// **'Collected today · 12 of 16 stops'**
  String get supervisorCollectedToday;

  /// No description provided for @supervisorCollectedTotal.
  ///
  /// In en, this message translates to:
  /// **'320 kg + 125 pcs'**
  String get supervisorCollectedTotal;

  /// No description provided for @supervisorCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get supervisorCollected;

  /// No description provided for @supervisorKg.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get supervisorKg;

  /// No description provided for @supervisorMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get supervisorMissed;

  /// No description provided for @supervisorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get supervisorCancelled;

  /// No description provided for @supervisorTripsClosed.
  ///
  /// In en, this message translates to:
  /// **'Trips closed'**
  String get supervisorTripsClosed;

  /// No description provided for @supervisorViewFullReport.
  ///
  /// In en, this message translates to:
  /// **'View full report'**
  String get supervisorViewFullReport;

  /// No description provided for @supervisorTodaysTrips.
  ///
  /// In en, this message translates to:
  /// **'Today’s trips'**
  String get supervisorTodaysTrips;

  /// No description provided for @supervisorTripsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'5 trips today · the next 2 are below'**
  String get supervisorTripsSubtitle;

  /// No description provided for @supervisorAdajanMorning.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning'**
  String get supervisorAdajanMorning;

  /// No description provided for @supervisorVikramProgress.
  ///
  /// In en, this message translates to:
  /// **'Vikram Singh  •  3 of 8 collected'**
  String get supervisorVikramProgress;

  /// No description provided for @supervisorOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle'**
  String get supervisorOwnVehicle;

  /// No description provided for @supervisorDailyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Daily 5 · Weekly 3'**
  String get supervisorDailyWeekly;

  /// No description provided for @supervisorCallDriver.
  ///
  /// In en, this message translates to:
  /// **'Call driver'**
  String get supervisorCallDriver;

  /// No description provided for @supervisorPalGamMorning.
  ///
  /// In en, this message translates to:
  /// **'Pal Gam Morning'**
  String get supervisorPalGamMorning;

  /// No description provided for @supervisorAmitProgress.
  ///
  /// In en, this message translates to:
  /// **'Amit Patel  •  0 of 8 recorded in the app'**
  String get supervisorAmitProgress;

  /// No description provided for @supervisorDriverNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Driver not using app'**
  String get supervisorDriverNotSetUp;

  /// No description provided for @supervisorSeeTripsPlan.
  ///
  /// In en, this message translates to:
  /// **'See trips plan'**
  String get supervisorSeeTripsPlan;

  /// No description provided for @supervisorPickupPoints.
  ///
  /// In en, this message translates to:
  /// **'My pickup points'**
  String get supervisorPickupPoints;

  /// No description provided for @supervisorPickupPointsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'79 in Adajan, Vesu, Pal · by category'**
  String get supervisorPickupPointsSubtitle;

  /// No description provided for @supervisorDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get supervisorDaily;

  /// No description provided for @supervisorWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get supervisorWeekly;

  /// No description provided for @supervisorBiWeekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly'**
  String get supervisorBiWeekly;

  /// No description provided for @supervisorMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get supervisorMonthly;

  /// No description provided for @supervisorOnCall.
  ///
  /// In en, this message translates to:
  /// **'On call'**
  String get supervisorOnCall;

  /// No description provided for @supervisorQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get supervisorQuickActions;

  /// No description provided for @supervisorUnassignedSources.
  ///
  /// In en, this message translates to:
  /// **'Unassigned sources'**
  String get supervisorUnassignedSources;

  /// No description provided for @supervisorManageUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Pickup points with no route yet'**
  String get supervisorManageUnassigned;

  /// No description provided for @supervisorViewSource.
  ///
  /// In en, this message translates to:
  /// **'View sources'**
  String get supervisorViewSource;

  /// No description provided for @supervisorExtraPickupRequests.
  ///
  /// In en, this message translates to:
  /// **'Extra pickups requests'**
  String get supervisorExtraPickupRequests;

  /// No description provided for @supervisorManageExtraPickup.
  ///
  /// In en, this message translates to:
  /// **'Manage Extra Pickup Sources'**
  String get supervisorManageExtraPickup;

  /// No description provided for @supervisorViewPickups.
  ///
  /// In en, this message translates to:
  /// **'View Pickups'**
  String get supervisorViewPickups;

  /// No description provided for @supervisorAskCollectionHead.
  ///
  /// In en, this message translates to:
  /// **'Ask the Collection Head'**
  String get supervisorAskCollectionHead;

  /// No description provided for @supervisorAskCollectionHeadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle, labour or pickup point changes'**
  String get supervisorAskCollectionHeadSubtitle;

  /// No description provided for @supervisorNewRequest.
  ///
  /// In en, this message translates to:
  /// **'New request'**
  String get supervisorNewRequest;

  /// No description provided for @supervisorSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get supervisorSuggestions;

  /// No description provided for @supervisorSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ways to save distance and time (concept)'**
  String get supervisorSuggestionsSubtitle;

  /// No description provided for @supervisorSeeSuggestions.
  ///
  /// In en, this message translates to:
  /// **'See suggestions'**
  String get supervisorSeeSuggestions;

  /// No description provided for @supervisorHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get supervisorHome;

  /// No description provided for @attentionApprovalRequests.
  ///
  /// In en, this message translates to:
  /// **'Approval requests'**
  String get attentionApprovalRequests;

  /// No description provided for @attentionApprovalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'From your drivers and IEC Executives'**
  String get attentionApprovalSubtitle;

  /// No description provided for @attentionToApproveCount.
  ///
  /// In en, this message translates to:
  /// **'To approve 3'**
  String get attentionToApproveCount;

  /// No description provided for @attentionDoneCount.
  ///
  /// In en, this message translates to:
  /// **'Done 12'**
  String get attentionDoneCount;

  /// No description provided for @attentionCorrectionFromDriver.
  ///
  /// In en, this message translates to:
  /// **'Correction · from driver'**
  String get attentionCorrectionFromDriver;

  /// No description provided for @attentionWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get attentionWaiting;

  /// No description provided for @attentionHotelRajdhaniStop.
  ///
  /// In en, this message translates to:
  /// **'Hotel Rajdhani · Adajan Morning, stop 2'**
  String get attentionHotelRajdhaniStop;

  /// No description provided for @attentionDriverCorrectionDetail.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles 50 kg → 60 kg. Vikram Singh: “The scale photo shows 60 kg.”'**
  String get attentionDriverCorrectionDetail;

  /// No description provided for @attentionSentToday.
  ///
  /// In en, this message translates to:
  /// **'Sent today, 10:05 am'**
  String get attentionSentToday;

  /// No description provided for @attentionDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get attentionDecline;

  /// No description provided for @attentionApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get attentionApprove;

  /// No description provided for @attentionExtraPickup.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup'**
  String get attentionExtraPickup;

  /// No description provided for @attentionAbcPlastic.
  ///
  /// In en, this message translates to:
  /// **'ABC Plastic Manufacture'**
  String get attentionAbcPlastic;

  /// No description provided for @attentionExtraPickupDetail.
  ///
  /// In en, this message translates to:
  /// **'Sat 25 Oct, 10 am – 12 pm · about 40 kg · fits Adajan Morning'**
  String get attentionExtraPickupDetail;

  /// No description provided for @attentionSent21Oct.
  ///
  /// In en, this message translates to:
  /// **'Sent 21 Oct'**
  String get attentionSent21Oct;

  /// No description provided for @attentionCorrectionFromPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Correction · from pickup point'**
  String get attentionCorrectionFromPickupPoint;

  /// No description provided for @attentionGreenParkSociety.
  ///
  /// In en, this message translates to:
  /// **'Green Park Society'**
  String get attentionGreenParkSociety;

  /// No description provided for @attentionPickupPointCorrectionDetail.
  ///
  /// In en, this message translates to:
  /// **'Cardboard 20 kg → 25 kg on the 19 Oct pickup'**
  String get attentionPickupPointCorrectionDetail;

  /// No description provided for @attentionSent20Oct.
  ///
  /// In en, this message translates to:
  /// **'Sent 20 Oct'**
  String get attentionSent20Oct;

  /// No description provided for @attentionCorrectionApproved.
  ///
  /// In en, this message translates to:
  /// **'Correction approved'**
  String get attentionCorrectionApproved;

  /// No description provided for @attentionCorrectionApprovedMessage.
  ///
  /// In en, this message translates to:
  /// **'Hotel Rajdhani’s record now shows PET Bottles 60 kg. Vikram Singh is told.'**
  String get attentionCorrectionApprovedMessage;

  /// No description provided for @attentionBackToApprovals.
  ///
  /// In en, this message translates to:
  /// **'Back to approval requests'**
  String get attentionBackToApprovals;

  /// No description provided for @attentionBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get attentionBackToHome;

  /// No description provided for @attentionMyRequests.
  ///
  /// In en, this message translates to:
  /// **'My requests'**
  String get attentionMyRequests;

  /// No description provided for @attentionToCollectionHead.
  ///
  /// In en, this message translates to:
  /// **'To the Collection Head'**
  String get attentionToCollectionHead;

  /// No description provided for @attentionAll4.
  ///
  /// In en, this message translates to:
  /// **'All 4'**
  String get attentionAll4;

  /// No description provided for @attentionWaiting1.
  ///
  /// In en, this message translates to:
  /// **'Waiting 1'**
  String get attentionWaiting1;

  /// No description provided for @attentionApproved2.
  ///
  /// In en, this message translates to:
  /// **'Approved 2'**
  String get attentionApproved2;

  /// No description provided for @attentionDeclined1.
  ///
  /// In en, this message translates to:
  /// **'Declined 1'**
  String get attentionDeclined1;

  /// No description provided for @attentionVehicleAdajan.
  ///
  /// In en, this message translates to:
  /// **'Vehicle · Adajan Morning'**
  String get attentionVehicleAdajan;

  /// No description provided for @attentionVehicleRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'A second vehicle on Sat 25 and Sun 26 Oct: Navratri Ground expects about 2 tonnes'**
  String get attentionVehicleRequestDescription;

  /// No description provided for @attentionVehicleRequestResponse.
  ///
  /// In en, this message translates to:
  /// **'With Arvind Desai (Collection Head)'**
  String get attentionVehicleRequestResponse;

  /// No description provided for @attentionSentTodayShort.
  ///
  /// In en, this message translates to:
  /// **'Sent today'**
  String get attentionSentTodayShort;

  /// No description provided for @attentionLabourPalGam.
  ///
  /// In en, this message translates to:
  /// **'Labour · Pal Gam Morning'**
  String get attentionLabourPalGam;

  /// No description provided for @attentionLabourRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'One more loader for 3 days (20–22 Oct)'**
  String get attentionLabourRequestDescription;

  /// No description provided for @attentionLabourRequestResponse.
  ///
  /// In en, this message translates to:
  /// **'Arvind Desai: “Ramesh Yadav joins from tomorrow.”'**
  String get attentionLabourRequestResponse;

  /// No description provided for @attentionSent19Oct.
  ///
  /// In en, this message translates to:
  /// **'Sent 19 Oct'**
  String get attentionSent19Oct;

  /// No description provided for @attentionPauseHotelShivam.
  ///
  /// In en, this message translates to:
  /// **'Pause pickup point · Hotel Shivam'**
  String get attentionPauseHotelShivam;

  /// No description provided for @attentionPauseRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'1 – 10 Nov · closed for renovation'**
  String get attentionPauseRequestDescription;

  /// No description provided for @attentionPauseRequestResponse.
  ///
  /// In en, this message translates to:
  /// **'Arvind Desai: “Approved. The IEC Executive is told.”'**
  String get attentionPauseRequestResponse;

  /// No description provided for @attentionSent18Oct.
  ///
  /// In en, this message translates to:
  /// **'Sent 18 Oct'**
  String get attentionSent18Oct;

  /// No description provided for @attentionStartSunriseSchool.
  ///
  /// In en, this message translates to:
  /// **'Start pickup point · Sunrise School'**
  String get attentionStartSunriseSchool;

  /// No description provided for @attentionStartRequestDescription.
  ///
  /// In en, this message translates to:
  /// **'Daily from 1 Nov on Punagam FullDay'**
  String get attentionStartRequestDescription;

  /// No description provided for @attentionStartRequestResponse.
  ///
  /// In en, this message translates to:
  /// **'Arvind Desai: “No room on that trip. Try Rander Evening.”'**
  String get attentionStartRequestResponse;

  /// No description provided for @attentionSent16Oct.
  ///
  /// In en, this message translates to:
  /// **'Sent 16 Oct'**
  String get attentionSent16Oct;

  /// No description provided for @attentionApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get attentionApproved;

  /// No description provided for @attentionDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get attentionDeclined;

  /// No description provided for @attentionSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get attentionSuggestions;

  /// No description provided for @attentionSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Concept · ideas from GPS, routes and areas'**
  String get attentionSuggestionsSubtitle;

  /// No description provided for @attentionAll3.
  ///
  /// In en, this message translates to:
  /// **'All 3'**
  String get attentionAll3;

  /// No description provided for @attentionMoveHotelRajdhani.
  ///
  /// In en, this message translates to:
  /// **'Move Hotel Rajdhani to Pal Gam Morning'**
  String get attentionMoveHotelRajdhani;

  /// No description provided for @attentionMoveHotelDescription.
  ///
  /// In en, this message translates to:
  /// **'It is 3.1 km off Adajan Morning; Pal Gam Morning passes its gate'**
  String get attentionMoveHotelDescription;

  /// No description provided for @attentionMoveHotelRoute.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning → Pal Gam Morning'**
  String get attentionMoveHotelRoute;

  /// No description provided for @attentionSaving31Km.
  ///
  /// In en, this message translates to:
  /// **'Less 3.1 km a day'**
  String get attentionSaving31Km;

  /// No description provided for @attentionReorderAdajan.
  ///
  /// In en, this message translates to:
  /// **'Reorder Adajan Morning'**
  String get attentionReorderAdajan;

  /// No description provided for @attentionReorderDescription.
  ///
  /// In en, this message translates to:
  /// **'Visit Om Sweets before Green Park Society'**
  String get attentionReorderDescription;

  /// No description provided for @attentionReorderSecondary.
  ///
  /// In en, this message translates to:
  /// **'Same stops, shorter path'**
  String get attentionReorderSecondary;

  /// No description provided for @attentionSaving12Min.
  ///
  /// In en, this message translates to:
  /// **'Less 12 min a day'**
  String get attentionSaving12Min;

  /// No description provided for @attentionCombineFridayRoutes.
  ///
  /// In en, this message translates to:
  /// **'Rander and Vesu Evening on Fridays: one vehicle'**
  String get attentionCombineFridayRoutes;

  /// No description provided for @attentionCombineDescription.
  ///
  /// In en, this message translates to:
  /// **'Both run under half full on Fridays (310 kg and 280 kg)'**
  String get attentionCombineDescription;

  /// No description provided for @attentionCombineSecondary.
  ///
  /// In en, this message translates to:
  /// **'Frees GJ-05-EE-1001 on Fridays'**
  String get attentionCombineSecondary;

  /// No description provided for @attentionSavingOneVehicle.
  ///
  /// In en, this message translates to:
  /// **'One vehicle less on Fri'**
  String get attentionSavingOneVehicle;

  /// No description provided for @attentionLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days of GPS'**
  String get attentionLast30Days;

  /// No description provided for @attentionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get attentionDismiss;

  /// No description provided for @attentionApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get attentionApply;

  /// No description provided for @attentionIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get attentionIssues;

  /// No description provided for @attentionVehicleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Vehicle breakdown'**
  String get attentionVehicleBreakdown;

  /// No description provided for @attentionSourceClosed.
  ///
  /// In en, this message translates to:
  /// **'Source closed'**
  String get attentionSourceClosed;

  /// No description provided for @attentionRameshDriver.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Ahir (Driver)'**
  String get attentionRameshDriver;

  /// No description provided for @attentionMohanDriver.
  ///
  /// In en, this message translates to:
  /// **'Mohan laal (Driver)'**
  String get attentionMohanDriver;

  /// No description provided for @attentionPrakashDriver.
  ///
  /// In en, this message translates to:
  /// **'Prakash Jadav (Driver)'**
  String get attentionPrakashDriver;

  /// No description provided for @attentionVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-1234'**
  String get attentionVehicleNumber;

  /// No description provided for @attentionDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get attentionDriver;

  /// No description provided for @attentionRameshAhir.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Ahir'**
  String get attentionRameshAhir;

  /// No description provided for @attentionContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get attentionContactNumber;

  /// No description provided for @attentionPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'9876543210'**
  String get attentionPhoneNumber;

  /// No description provided for @attentionRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get attentionRoute;

  /// No description provided for @attentionAdajanMorning.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning'**
  String get attentionAdajanMorning;

  /// No description provided for @attentionReasonFor.
  ///
  /// In en, this message translates to:
  /// **'Reason for '**
  String get attentionReasonFor;

  /// No description provided for @attentionIssueWord.
  ///
  /// In en, this message translates to:
  /// **'Issue'**
  String get attentionIssueWord;

  /// No description provided for @attentionIssueReason.
  ///
  /// In en, this message translates to:
  /// **'Reason : No Vehicle Available'**
  String get attentionIssueReason;

  /// No description provided for @attentionIssueRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks : All yard trucks are currently out. Try after 2 PM.'**
  String get attentionIssueRemarks;

  /// No description provided for @flagNothingToCheck.
  ///
  /// In en, this message translates to:
  /// **'Nothing to check'**
  String get flagNothingToCheck;

  /// No description provided for @flagOctober.
  ///
  /// In en, this message translates to:
  /// **'october'**
  String get flagOctober;

  /// No description provided for @flagNothingToCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No flags right now. Schedule changes, pauses and pickup points without a route show up here.'**
  String get flagNothingToCheckSubtitle;

  /// No description provided for @flagMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get flagMarkDone;

  /// No description provided for @sourcesNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesNavLabel;

  /// No description provided for @sourcesRoutesNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get sourcesRoutesNavLabel;

  /// No description provided for @sourcesProfileNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get sourcesProfileNavLabel;

  /// No description provided for @routesTitle.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get routesTitle;

  /// No description provided for @routesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trips are made from them every day'**
  String get routesSubtitle;

  /// No description provided for @routesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get routesSearchHint;

  /// No description provided for @routesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No routes yet. Tap + to make your first route'**
  String get routesEmptyMessage;

  /// No description provided for @routesFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All 4'**
  String get routesFilterAll;

  /// No description provided for @routesFilterOwn.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle 2'**
  String get routesFilterOwn;

  /// No description provided for @routesFilterContract.
  ///
  /// In en, this message translates to:
  /// **'Contract vehicle 2'**
  String get routesFilterContract;

  /// No description provided for @routesPalGamMorning.
  ///
  /// In en, this message translates to:
  /// **'Pal Gam Morning'**
  String get routesPalGamMorning;

  /// No description provided for @routesOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle'**
  String get routesOwnVehicle;

  /// No description provided for @routesDriverNotUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Driver not using app'**
  String get routesDriverNotUsingApp;

  /// No description provided for @routesVehicle5678.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-5678'**
  String get routesVehicle5678;

  /// No description provided for @routesPalGamTime.
  ///
  /// In en, this message translates to:
  /// **'Morning (12:00 PM – 05:00 PM)'**
  String get routesPalGamTime;

  /// No description provided for @routesOnRoute.
  ///
  /// In en, this message translates to:
  /// **'On route'**
  String get routesOnRoute;

  /// No description provided for @routesRecordedZero.
  ///
  /// In en, this message translates to:
  /// **'0 of 8 recorded in the app'**
  String get routesRecordedZero;

  /// No description provided for @routesAdajanMorning.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning'**
  String get routesAdajanMorning;

  /// No description provided for @routesDailyWeekly.
  ///
  /// In en, this message translates to:
  /// **'Daily 5 · Weekly 3'**
  String get routesDailyWeekly;

  /// No description provided for @routesVehicle1234.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-1234'**
  String get routesVehicle1234;

  /// No description provided for @routesAdajanTime.
  ///
  /// In en, this message translates to:
  /// **'Morning (08:00 AM – 02:00 PM)'**
  String get routesAdajanTime;

  /// No description provided for @routesPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get routesPlanned;

  /// No description provided for @routesCollectedZero.
  ///
  /// In en, this message translates to:
  /// **'0 of 8 collected'**
  String get routesCollectedZero;

  /// No description provided for @routesPunagamFullDay.
  ///
  /// In en, this message translates to:
  /// **'Punagam FullDay'**
  String get routesPunagamFullDay;

  /// No description provided for @routesContractVehicle.
  ///
  /// In en, this message translates to:
  /// **'Contract vehicle'**
  String get routesContractVehicle;

  /// No description provided for @routesDailyMonthly.
  ///
  /// In en, this message translates to:
  /// **'Daily 6 · Monthly 2'**
  String get routesDailyMonthly;

  /// No description provided for @routesFullDayTime.
  ///
  /// In en, this message translates to:
  /// **'Full Day (08:00 AM – 12:00 PM)'**
  String get routesFullDayTime;

  /// No description provided for @routesApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get routesApproved;

  /// No description provided for @routesCollectedEight.
  ///
  /// In en, this message translates to:
  /// **'8 of 8 collected'**
  String get routesCollectedEight;

  /// No description provided for @routesRanderEvening.
  ///
  /// In en, this message translates to:
  /// **'Rander Evening'**
  String get routesRanderEvening;

  /// No description provided for @routesWeeklyBiWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly 6 · Bi-weekly 2'**
  String get routesWeeklyBiWeekly;

  /// No description provided for @routesVehicle9012.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-9012'**
  String get routesVehicle9012;

  /// No description provided for @routesEveningTime.
  ///
  /// In en, this message translates to:
  /// **'Evening (8 am–8 pm)'**
  String get routesEveningTime;

  /// No description provided for @routesSwitchOff.
  ///
  /// In en, this message translates to:
  /// **'Switch Off'**
  String get routesSwitchOff;

  /// No description provided for @supervisorDrawerUserName.
  ///
  /// In en, this message translates to:
  /// **'Kiran Shah'**
  String get supervisorDrawerUserName;

  /// No description provided for @supervisorDrawerRole.
  ///
  /// In en, this message translates to:
  /// **'Pickup Supervisor'**
  String get supervisorDrawerRole;

  /// No description provided for @supervisorDrawerUnassignedSources.
  ///
  /// In en, this message translates to:
  /// **'Unassigned sources'**
  String get supervisorDrawerUnassignedSources;

  /// No description provided for @supervisorDrawerRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get supervisorDrawerRoutes;

  /// No description provided for @supervisorDrawerDriversLabour.
  ///
  /// In en, this message translates to:
  /// **'Drivers and labour'**
  String get supervisorDrawerDriversLabour;

  /// No description provided for @supervisorDrawerIssues.
  ///
  /// In en, this message translates to:
  /// **'Issues'**
  String get supervisorDrawerIssues;

  /// No description provided for @supervisorDrawerExtraPickupRequests.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup requests'**
  String get supervisorDrawerExtraPickupRequests;

  /// No description provided for @supervisorDrawerSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Sync Status'**
  String get supervisorDrawerSyncStatus;

  /// No description provided for @supervisorDrawerNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get supervisorDrawerNotifications;

  /// No description provided for @supervisorDrawerHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get supervisorDrawerHelpSupport;

  /// No description provided for @supervisorDrawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get supervisorDrawerLogout;

  /// No description provided for @supervisorDrawerPoweredBy.
  ///
  /// In en, this message translates to:
  /// **'Powered by Eco Vision'**
  String get supervisorDrawerPoweredBy;

  /// No description provided for @addRouteStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2'**
  String get addRouteStep1;

  /// No description provided for @addRouteStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2'**
  String get addRouteStep2;

  /// No description provided for @addRouteRouteName.
  ///
  /// In en, this message translates to:
  /// **'Route name'**
  String get addRouteRouteName;

  /// No description provided for @addRouteRouteNameHint.
  ///
  /// In en, this message translates to:
  /// **'For example, Adajan Morning'**
  String get addRouteRouteNameHint;

  /// No description provided for @addRouteWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get addRouteWarehouse;

  /// No description provided for @addRouteSelectWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Select warehouse'**
  String get addRouteSelectWarehouse;

  /// No description provided for @addRouteShift.
  ///
  /// In en, this message translates to:
  /// **'Shift'**
  String get addRouteShift;

  /// No description provided for @addRouteSelectShift.
  ///
  /// In en, this message translates to:
  /// **'Select Shift'**
  String get addRouteSelectShift;

  /// No description provided for @addRouteContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get addRouteContinue;

  /// No description provided for @addRouteWarehouseAdajan.
  ///
  /// In en, this message translates to:
  /// **'Adajan Central Warehouse'**
  String get addRouteWarehouseAdajan;

  /// No description provided for @addRouteWarehouseVesu.
  ///
  /// In en, this message translates to:
  /// **'Vesu Storage Hub'**
  String get addRouteWarehouseVesu;

  /// No description provided for @addRouteWarehouseKatargam.
  ///
  /// In en, this message translates to:
  /// **'Katargam Depot'**
  String get addRouteWarehouseKatargam;

  /// No description provided for @addRouteWarehousePal.
  ///
  /// In en, this message translates to:
  /// **'Pal Sorting Facility'**
  String get addRouteWarehousePal;

  /// No description provided for @addRouteWarehouseUdhna.
  ///
  /// In en, this message translates to:
  /// **'Udhna Industrial Warehouse'**
  String get addRouteWarehouseUdhna;

  /// No description provided for @addRouteShiftMorningEarly.
  ///
  /// In en, this message translates to:
  /// **'Morning · 7 am–3 pm'**
  String get addRouteShiftMorningEarly;

  /// No description provided for @addRouteShiftMorningLate.
  ///
  /// In en, this message translates to:
  /// **'Morning · 2 pm–8 pm'**
  String get addRouteShiftMorningLate;

  /// No description provided for @addRouteShiftFullDay.
  ///
  /// In en, this message translates to:
  /// **'Full Day (8 am–8 pm)'**
  String get addRouteShiftFullDay;

  /// No description provided for @addRouteSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get addRouteSelectVehicle;

  /// No description provided for @addRouteVehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get addRouteVehicleLabel;

  /// No description provided for @addRouteVehicleHint.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle for Pickup'**
  String get addRouteVehicleHint;

  /// No description provided for @addRouteSelectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get addRouteSelectDriver;

  /// No description provided for @addRouteDriverHint.
  ///
  /// In en, this message translates to:
  /// **'Select Driver for Pickup'**
  String get addRouteDriverHint;

  /// No description provided for @addRouteSelectLabour.
  ///
  /// In en, this message translates to:
  /// **'Select Labour'**
  String get addRouteSelectLabour;

  /// No description provided for @addRouteLabourHint.
  ///
  /// In en, this message translates to:
  /// **'Select Labour'**
  String get addRouteLabourHint;

  /// No description provided for @addRouteDriverNotFound.
  ///
  /// In en, this message translates to:
  /// **'Driver Not Found'**
  String get addRouteDriverNotFound;

  /// No description provided for @addRouteDriverNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'No driver added yet. Tap below to add.'**
  String get addRouteDriverNotFoundHint;

  /// No description provided for @addRouteLabourNotFound.
  ///
  /// In en, this message translates to:
  /// **'Labour Not Found'**
  String get addRouteLabourNotFound;

  /// No description provided for @addRouteLabourNotFoundHint.
  ///
  /// In en, this message translates to:
  /// **'No labour added yet. Tap below to add.'**
  String get addRouteLabourNotFoundHint;

  /// No description provided for @addRouteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addRouteAdd;

  /// No description provided for @addRouteVehicleCompany1001.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-EE-1001'**
  String get addRouteVehicleCompany1001;

  /// No description provided for @addRouteVehicleCompany1234.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-BX-1234'**
  String get addRouteVehicleCompany1234;

  /// No description provided for @addRouteCompanyTruck.
  ///
  /// In en, this message translates to:
  /// **'Company truck'**
  String get addRouteCompanyTruck;

  /// No description provided for @addRouteCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity 3000 KG'**
  String get addRouteCapacity;

  /// No description provided for @addRouteDriverVikram.
  ///
  /// In en, this message translates to:
  /// **'Vikram Singh (••• 4321)'**
  String get addRouteDriverVikram;

  /// No description provided for @addRouteDriverSuresh.
  ///
  /// In en, this message translates to:
  /// **'Suresh Kumar (••• 5847)'**
  String get addRouteDriverSuresh;

  /// No description provided for @addRouteDriverMahesh.
  ///
  /// In en, this message translates to:
  /// **'Mahesh Parmar (••• 2282)'**
  String get addRouteDriverMahesh;

  /// No description provided for @addRouteDriverRakesh.
  ///
  /// In en, this message translates to:
  /// **'Rakesh Sharma (••• 2458)'**
  String get addRouteDriverRakesh;

  /// No description provided for @addRouteDriverAmit.
  ///
  /// In en, this message translates to:
  /// **'Amit Patel (••• 9510)'**
  String get addRouteDriverAmit;

  /// No description provided for @addRouteLabourRavi.
  ///
  /// In en, this message translates to:
  /// **'Ravi Bisht (••• 5847)'**
  String get addRouteLabourRavi;

  /// No description provided for @addRouteLabourRam.
  ///
  /// In en, this message translates to:
  /// **'Ram Singh (••• 2282)'**
  String get addRouteLabourRam;

  /// No description provided for @addRouteLabourRamesh.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Yadav (••• 2458)'**
  String get addRouteLabourRamesh;

  /// No description provided for @addRouteLabourArjun.
  ///
  /// In en, this message translates to:
  /// **'Arjun Jatav (••• 9510)'**
  String get addRouteLabourArjun;

  /// No description provided for @addRouteDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get addRouteDeactivate;

  /// No description provided for @addRouteDeactivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate?'**
  String get addRouteDeactivateTitle;

  /// No description provided for @addRouteDeactivateMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to deactivate this person?'**
  String get addRouteDeactivateMessage;

  /// No description provided for @addRouteCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get addRouteCancel;

  /// No description provided for @addRouteYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get addRouteYes;

  /// No description provided for @addRouteAddNewDriverPrefix.
  ///
  /// In en, this message translates to:
  /// **'Add New '**
  String get addRouteAddNewDriverPrefix;

  /// No description provided for @addRouteDriverWord.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get addRouteDriverWord;

  /// No description provided for @addRouteLabourWord.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get addRouteLabourWord;

  /// No description provided for @addRouteFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get addRouteFullName;

  /// No description provided for @addRouteFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get addRouteFullNameHint;

  /// No description provided for @addRouteMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get addRouteMobileNumber;

  /// No description provided for @addRouteMobileNumberHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile number'**
  String get addRouteMobileNumberHint;

  /// No description provided for @addRouteCountryCode.
  ///
  /// In en, this message translates to:
  /// **'+91'**
  String get addRouteCountryCode;

  /// No description provided for @addRouteAadhaarNumber.
  ///
  /// In en, this message translates to:
  /// **'Aadhar card Number'**
  String get addRouteAadhaarNumber;

  /// No description provided for @addRouteAadhaarHint.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar / Voter ID'**
  String get addRouteAadhaarHint;

  /// No description provided for @addRouteProfileProof.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo / ID Proof'**
  String get addRouteProfileProof;

  /// No description provided for @addRouteCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get addRouteCapturePhoto;

  /// No description provided for @addRoutePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a photo to record and verify details.'**
  String get addRoutePhotoHint;

  /// No description provided for @addRouteSaveSelect.
  ///
  /// In en, this message translates to:
  /// **'Save & Select'**
  String get addRouteSaveSelect;

  /// No description provided for @addRouteFullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the full name.'**
  String get addRouteFullNameRequired;

  /// No description provided for @addRouteFullNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters.'**
  String get addRouteFullNameMinLength;

  /// No description provided for @addRouteMobileRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the mobile number.'**
  String get addRouteMobileRequired;

  /// No description provided for @addRouteMobileInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number starting with 6–9.'**
  String get addRouteMobileInvalid;

  /// No description provided for @addRouteReviewShift.
  ///
  /// In en, this message translates to:
  /// **'Morning (8 am–2 pm)'**
  String get addRouteReviewShift;

  /// No description provided for @addRouteReviewVehicle.
  ///
  /// In en, this message translates to:
  /// **'GJ-05-EE-1001'**
  String get addRouteReviewVehicle;

  /// No description provided for @addRouteReviewCompany.
  ///
  /// In en, this message translates to:
  /// **'(Company Truck)'**
  String get addRouteReviewCompany;

  /// No description provided for @addRouteReviewDriver.
  ///
  /// In en, this message translates to:
  /// **'Vikram Singh (12345 43210)'**
  String get addRouteReviewDriver;

  /// No description provided for @addRouteReviewLabour.
  ///
  /// In en, this message translates to:
  /// **'Ravi Bisht (23456 58492)'**
  String get addRouteReviewLabour;

  /// No description provided for @addRouteAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to route'**
  String get addRouteAddToRoute;

  /// No description provided for @addRouteSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Successfully Saved!'**
  String get addRouteSavedTitle;

  /// No description provided for @addRouteSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning Route Saved'**
  String get addRouteSavedSubtitle;

  /// No description provided for @sourcesUnassignedTitle.
  ///
  /// In en, this message translates to:
  /// **'Unassigned sources'**
  String get sourcesUnassignedTitle;

  /// No description provided for @sourcesManageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage collection sources'**
  String get sourcesManageSubtitle;

  /// No description provided for @sourcesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search sources'**
  String get sourcesSearchHint;

  /// No description provided for @sourcesTabCount.
  ///
  /// In en, this message translates to:
  /// **'Sources (3)'**
  String get sourcesTabCount;

  /// No description provided for @sourcesExtraTabCount.
  ///
  /// In en, this message translates to:
  /// **'Extra Pickups (1)'**
  String get sourcesExtraTabCount;

  /// No description provided for @sourcesAdajanTextileSorted.
  ///
  /// In en, this message translates to:
  /// **'Adajan Textile Mill · Sorted'**
  String get sourcesAdajanTextileSorted;

  /// No description provided for @sourcesAddressShort.
  ///
  /// In en, this message translates to:
  /// **'U 9, 10, Siddhgiri Tower, B/H Navyug...'**
  String get sourcesAddressShort;

  /// No description provided for @sourcesMonThuSchedule.
  ///
  /// In en, this message translates to:
  /// **'Mon, Thu · 8–10 am'**
  String get sourcesMonThuSchedule;

  /// No description provided for @sourcesUnassignedStatus.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get sourcesUnassignedStatus;

  /// No description provided for @sourcesShreeSaiMixed.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy · Mixed'**
  String get sourcesShreeSaiMixed;

  /// No description provided for @sourcesEmbraneAddress.
  ///
  /// In en, this message translates to:
  /// **'X 3, 10, Embrane Zone, navyug plus...'**
  String get sourcesEmbraneAddress;

  /// No description provided for @sourcesExceptSunSchedule.
  ///
  /// In en, this message translates to:
  /// **'Except Sun · 9–11 am'**
  String get sourcesExceptSunSchedule;

  /// No description provided for @sourcesShreeSaiSorted.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy · Sorted'**
  String get sourcesShreeSaiSorted;

  /// No description provided for @sourcesSecondWedSchedule.
  ///
  /// In en, this message translates to:
  /// **'2nd Wed of the month · 10–11 am'**
  String get sourcesSecondWedSchedule;

  /// No description provided for @sourcesMahavirSorted.
  ///
  /// In en, this message translates to:
  /// **'Mahavir Paper Mill · Sorted'**
  String get sourcesMahavirSorted;

  /// No description provided for @sourcesExtraPickupSchedule.
  ///
  /// In en, this message translates to:
  /// **'Sat 24 Oct · 11 am–12 pm'**
  String get sourcesExtraPickupSchedule;

  /// No description provided for @sourcesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No Unassigned trips available'**
  String get sourcesEmptyMessage;

  /// No description provided for @sourcesAbcTextileMills.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills'**
  String get sourcesAbcTextileMills;

  /// No description provided for @sourcesShreeSaiDairy.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy'**
  String get sourcesShreeSaiDairy;

  /// No description provided for @sourcesMahavirPaperMill.
  ///
  /// In en, this message translates to:
  /// **'Mahavir Paper Mill'**
  String get sourcesMahavirPaperMill;

  /// No description provided for @sourcesAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sourcesAddress;

  /// No description provided for @sourcesFullAddress.
  ///
  /// In en, this message translates to:
  /// **'U 9, 10, Siddhgiri Tower, B/H Navyug College Rd, Navyug Society, Sangana Society, Adajan, Surat, Gujarat 395009'**
  String get sourcesFullAddress;

  /// No description provided for @sourcesOpenMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get sourcesOpenMaps;

  /// No description provided for @sourcesSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sourcesSchedule;

  /// No description provided for @sourcesContactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get sourcesContactNumber;

  /// No description provided for @sourcesPhone.
  ///
  /// In en, this message translates to:
  /// **'9876543210'**
  String get sourcesPhone;

  /// No description provided for @sourcesMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get sourcesMaterial;

  /// No description provided for @sourcesSorted.
  ///
  /// In en, this message translates to:
  /// **'Sorted'**
  String get sourcesSorted;

  /// No description provided for @sourcesMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get sourcesMixed;

  /// No description provided for @sourcesMaterialsList.
  ///
  /// In en, this message translates to:
  /// **'Milk Pouch, Card Board'**
  String get sourcesMaterialsList;

  /// No description provided for @sourcesPickupStatus.
  ///
  /// In en, this message translates to:
  /// **'Pickup Status'**
  String get sourcesPickupStatus;

  /// No description provided for @sourcesAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to route'**
  String get sourcesAddToRoute;

  /// No description provided for @sourcesAdajanMorning.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning'**
  String get sourcesAdajanMorning;

  /// No description provided for @sourcesVehicleGj051824.
  ///
  /// In en, this message translates to:
  /// **'GJ 05 1824'**
  String get sourcesVehicleGj051824;

  /// No description provided for @sourcesMorningTime.
  ///
  /// In en, this message translates to:
  /// **'Morning (08:00 AM – 02:00 PM)'**
  String get sourcesMorningTime;

  /// No description provided for @sourcesAssignedCount.
  ///
  /// In en, this message translates to:
  /// **'Assigned Sources : 2'**
  String get sourcesAssignedCount;

  /// No description provided for @sourcesPalGamMorning.
  ///
  /// In en, this message translates to:
  /// **'Pal Gam Morning'**
  String get sourcesPalGamMorning;

  /// No description provided for @sourcesVehicleGj052564.
  ///
  /// In en, this message translates to:
  /// **'GJ 05 2564'**
  String get sourcesVehicleGj052564;

  /// No description provided for @sourcesPalGamTime.
  ///
  /// In en, this message translates to:
  /// **'Morning Shift (10:00 AM – 12:00 PM)'**
  String get sourcesPalGamTime;

  /// No description provided for @sourcesVesuEvening.
  ///
  /// In en, this message translates to:
  /// **'Vesu Evening'**
  String get sourcesVesuEvening;

  /// No description provided for @sourcesTimeClashWarning.
  ///
  /// In en, this message translates to:
  /// **'Time clash: Adajan Morning reaches here at about 1:30 pm, but the pickup window is 9–11 am.\n4.2 km off the route: about 20 min more on each trip.\nPal Gam Morning passes nearby at 9:40 am.'**
  String get sourcesTimeClashWarning;

  /// No description provided for @sourcesAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get sourcesAddNew;

  /// No description provided for @sourcesAssignAnyway.
  ///
  /// In en, this message translates to:
  /// **'Assign anyway'**
  String get sourcesAssignAnyway;

  /// No description provided for @sourcesAddedToRoute.
  ///
  /// In en, this message translates to:
  /// **'Source Added to Route'**
  String get sourcesAddedToRoute;

  /// No description provided for @sourcesAddedMessage.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills is now assigned to GJ 05 1824 (Morning Shift).'**
  String get sourcesAddedMessage;

  /// No description provided for @sourcesBackToRequests.
  ///
  /// In en, this message translates to:
  /// **'Back to Requests'**
  String get sourcesBackToRequests;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account details & info'**
  String get profileSubtitle;

  /// No description provided for @profileLanguageCode.
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get profileLanguageCode;

  /// No description provided for @profileUserName.
  ///
  /// In en, this message translates to:
  /// **'Kiran Shah'**
  String get profileUserName;

  /// No description provided for @profileRole.
  ///
  /// In en, this message translates to:
  /// **'Pickup Supervisor'**
  String get profileRole;

  /// No description provided for @profileAccountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get profileAccountInformation;

  /// No description provided for @profileMyAreas.
  ///
  /// In en, this message translates to:
  /// **'My areas'**
  String get profileMyAreas;

  /// No description provided for @profileAreasValue.
  ///
  /// In en, this message translates to:
  /// **'Adajan, Vesu, Pal'**
  String get profileAreasValue;

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

  /// No description provided for @profileRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get profileRoleLabel;

  /// No description provided for @profileSessionExpires.
  ///
  /// In en, this message translates to:
  /// **'Session Expires'**
  String get profileSessionExpires;

  /// No description provided for @profileSessionValue.
  ///
  /// In en, this message translates to:
  /// **'Expires in 6h 24m'**
  String get profileSessionValue;

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

  /// No description provided for @profileSyncDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sync your offline data'**
  String get profileSyncDataSubtitle;

  /// No description provided for @profileAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get profileAccount;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @profileLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your account'**
  String get profileLogoutSubtitle;

  /// No description provided for @profileSyncOfflineData.
  ///
  /// In en, this message translates to:
  /// **'Sync Offline Data'**
  String get profileSyncOfflineData;

  /// No description provided for @profileChangesNotSent.
  ///
  /// In en, this message translates to:
  /// **'3 changes not sent yet'**
  String get profileChangesNotSent;

  /// No description provided for @profileSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync Now'**
  String get profileSyncNow;

  /// No description provided for @profileDataAlreadySynced.
  ///
  /// In en, this message translates to:
  /// **'Data Already Synced'**
  String get profileDataAlreadySynced;

  /// No description provided for @profileBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get profileBack;

  /// No description provided for @profileLogoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutQuestion;

  /// No description provided for @profileLogoutMessage.
  ///
  /// In en, this message translates to:
  /// **'Any unsynced offline data will remain on this device until your next sign-in.'**
  String get profileLogoutMessage;

  /// No description provided for @profileSendChangesWarning.
  ///
  /// In en, this message translates to:
  /// **'Send changes to notify drivers'**
  String get profileSendChangesWarning;

  /// No description provided for @profileNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get profileNo;

  /// No description provided for @profileYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get profileYes;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get profileToday;

  /// No description provided for @profileEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get profileEarlier;

  /// No description provided for @profileOfflineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get profileOfflineMode;

  /// No description provided for @profileOfflineModeMessage.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Data will sync automatically when Connection Restored.'**
  String get profileOfflineModeMessage;

  /// No description provided for @profileJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get profileJustNow;

  /// No description provided for @profileNewSourceUnassigned.
  ///
  /// In en, this message translates to:
  /// **'New Source Unassigned'**
  String get profileNewSourceUnassigned;

  /// No description provided for @profileNewSourceMessage.
  ///
  /// In en, this message translates to:
  /// **'Global Garments (Adajan) needs a route assignment.'**
  String get profileNewSourceMessage;

  /// No description provided for @profileTenMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'10 Mins ago'**
  String get profileTenMinutesAgo;

  /// No description provided for @profileDriverEscalation.
  ///
  /// In en, this message translates to:
  /// **'Driver Escalation'**
  String get profileDriverEscalation;

  /// No description provided for @profileDriverEscalationMessage.
  ///
  /// In en, this message translates to:
  /// **'Driver Ramesh reported gate entry delay at Pal spot.'**
  String get profileDriverEscalationMessage;

  /// No description provided for @profileYesterdayTime.
  ///
  /// In en, this message translates to:
  /// **'Yesterday, 11:30 AM'**
  String get profileYesterdayTime;

  /// No description provided for @profilePickupSkipped.
  ///
  /// In en, this message translates to:
  /// **'Pickup Skipped'**
  String get profilePickupSkipped;

  /// No description provided for @profilePickupSkippedMessage.
  ///
  /// In en, this message translates to:
  /// **'Siddhgiri Traders Skipped collection.'**
  String get profilePickupSkippedMessage;

  /// No description provided for @profilePickupSkippedTime.
  ///
  /// In en, this message translates to:
  /// **'24 Oct, 08:00 AM'**
  String get profilePickupSkippedTime;

  /// No description provided for @profileAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All Caught Up!'**
  String get profileAllCaughtUp;

  /// No description provided for @profileNoNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications. Check back later for system alerts and Admin updates.'**
  String get profileNoNotifications;

  /// No description provided for @profileHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profileHelpSupport;

  /// No description provided for @profileCallSupport.
  ///
  /// In en, this message translates to:
  /// **'Call Support'**
  String get profileCallSupport;

  /// No description provided for @profileCallSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available 24/7 for field issues'**
  String get profileCallSupportSubtitle;

  /// No description provided for @profileInstantHelp.
  ///
  /// In en, this message translates to:
  /// **'Instant Help'**
  String get profileInstantHelp;

  /// No description provided for @profileInstantHelpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with a support agent'**
  String get profileInstantHelpSubtitle;

  /// No description provided for @profileFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get profileFaqTitle;

  /// No description provided for @profileFaqDailyTrips.
  ///
  /// In en, this message translates to:
  /// **'How do daily trips work?'**
  String get profileFaqDailyTrips;

  /// No description provided for @profileFaqDailyTripsAnswer.
  ///
  /// In en, this message translates to:
  /// **'Generated automatically each morning from your Master Routes.'**
  String get profileFaqDailyTripsAnswer;

  /// No description provided for @profileFaqSwapDriver.
  ///
  /// In en, this message translates to:
  /// **'How to swap a driver for today?'**
  String get profileFaqSwapDriver;

  /// No description provided for @profileFaqSwapDriverAnswer.
  ///
  /// In en, this message translates to:
  /// **'Open today\'s route and use the driver edit action.'**
  String get profileFaqSwapDriverAnswer;

  /// No description provided for @profileFaqUnassigned.
  ///
  /// In en, this message translates to:
  /// **'What is the unassigned sources?'**
  String get profileFaqUnassigned;

  /// No description provided for @profileFaqUnassignedAnswer.
  ///
  /// In en, this message translates to:
  /// **'Sources that are not currently attached to a route.'**
  String get profileFaqUnassignedAnswer;

  /// No description provided for @profileFaqSkipping.
  ///
  /// In en, this message translates to:
  /// **'What does Skipping a stop do?'**
  String get profileFaqSkipping;

  /// No description provided for @profileFaqSkippingAnswer.
  ///
  /// In en, this message translates to:
  /// **'It records the stop as skipped for the current trip.'**
  String get profileFaqSkippingAnswer;

  /// No description provided for @profileClosedDayArtwork.
  ///
  /// In en, this message translates to:
  /// **'Now Time to\nCLOSED The Day'**
  String get profileClosedDayArtwork;

  /// No description provided for @driverProfileUserName.
  ///
  /// In en, this message translates to:
  /// **'Ramesh Kumar'**
  String get driverProfileUserName;

  /// No description provided for @driverProfileWarehouseLabel.
  ///
  /// In en, this message translates to:
  /// **'My warehouse'**
  String get driverProfileWarehouseLabel;

  /// No description provided for @driverProfileWarehouseValue.
  ///
  /// In en, this message translates to:
  /// **'Magdalla Warehouse'**
  String get driverProfileWarehouseValue;

  /// No description provided for @driverProfileDriverCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver code'**
  String get driverProfileDriverCodeLabel;

  /// No description provided for @driverProfileDriverCodeValue.
  ///
  /// In en, this message translates to:
  /// **'SUR-DRV-0007'**
  String get driverProfileDriverCodeValue;

  /// No description provided for @driverProfileMobileValue.
  ///
  /// In en, this message translates to:
  /// **'+91 98765 43226'**
  String get driverProfileMobileValue;

  /// No description provided for @driverProfileRoleValue.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get driverProfileRoleValue;

  /// No description provided for @driverProfileLogoutWarning.
  ///
  /// In en, this message translates to:
  /// **'3 collections not sent yet: sync first'**
  String get driverProfileLogoutWarning;

  /// No description provided for @dlDriverDirectory.
  ///
  /// In en, this message translates to:
  /// **'Driver Directory'**
  String get dlDriverDirectory;

  /// No description provided for @dlLabourDirectory.
  ///
  /// In en, this message translates to:
  /// **'Labour Directory'**
  String get dlLabourDirectory;

  /// No description provided for @dlFilterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get dlFilterActive;

  /// No description provided for @dlFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get dlFilterInactive;

  /// No description provided for @dlTabDrivers.
  ///
  /// In en, this message translates to:
  /// **'Driver ({count})'**
  String dlTabDrivers(int count);

  /// No description provided for @dlTabLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour ({count})'**
  String dlTabLabour(int count);

  /// No description provided for @dlSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Here...'**
  String get dlSearchHint;

  /// No description provided for @dlAddDriver.
  ///
  /// In en, this message translates to:
  /// **'Add Driver'**
  String get dlAddDriver;

  /// No description provided for @dlAddLabour.
  ///
  /// In en, this message translates to:
  /// **'Add Labour'**
  String get dlAddLabour;

  /// No description provided for @dlAddLabourer.
  ///
  /// In en, this message translates to:
  /// **'Add labour'**
  String get dlAddLabourer;

  /// No description provided for @dlNoDetailsFound.
  ///
  /// In en, this message translates to:
  /// **'No Details Found'**
  String get dlNoDetailsFound;

  /// No description provided for @dlNoPhone.
  ///
  /// In en, this message translates to:
  /// **'--'**
  String get dlNoPhone;

  /// No description provided for @dlAddNewDriver.
  ///
  /// In en, this message translates to:
  /// **'Add New Driver'**
  String get dlAddNewDriver;

  /// No description provided for @dlAddNewLabour.
  ///
  /// In en, this message translates to:
  /// **'Add New Labour'**
  String get dlAddNewLabour;

  /// No description provided for @dlEditDriver.
  ///
  /// In en, this message translates to:
  /// **'Edit Driver'**
  String get dlEditDriver;

  /// No description provided for @dlEditLabour.
  ///
  /// In en, this message translates to:
  /// **'Edit Labour'**
  String get dlEditLabour;

  /// No description provided for @dlFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get dlFullName;

  /// No description provided for @dlEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter Full Name'**
  String get dlEnterFullName;

  /// No description provided for @dlMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get dlMobileNumber;

  /// No description provided for @dlEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile number'**
  String get dlEnterMobileNumber;

  /// No description provided for @dlCountryCode.
  ///
  /// In en, this message translates to:
  /// **'+91'**
  String get dlCountryCode;

  /// No description provided for @dlProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo / ID Proof'**
  String get dlProfilePhoto;

  /// No description provided for @dlCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get dlCapturePhoto;

  /// No description provided for @dlCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dlCancel;

  /// No description provided for @dlDeactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get dlDeactivate;

  /// No description provided for @dlEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dlEdit;

  /// No description provided for @supervisorTripsToday.
  ///
  /// In en, this message translates to:
  /// **'Trips today'**
  String get supervisorTripsToday;

  /// No description provided for @tpTitle.
  ///
  /// In en, this message translates to:
  /// **'Trips plan'**
  String get tpTitle;

  /// No description provided for @tpAreas.
  ///
  /// In en, this message translates to:
  /// **'Adajan, Vesu, Pal'**
  String get tpAreas;

  /// No description provided for @tpChoiceToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tpChoiceToday;

  /// No description provided for @tpChoiceTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tpChoiceTomorrow;

  /// No description provided for @tpChoiceWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get tpChoiceWeek;

  /// No description provided for @tpDateToday.
  ///
  /// In en, this message translates to:
  /// **'Thu 22 Oct 2026'**
  String get tpDateToday;

  /// No description provided for @tpDateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Fri 23 Oct 2026'**
  String get tpDateTomorrow;

  /// No description provided for @tpDateNoTrips.
  ///
  /// In en, this message translates to:
  /// **'Sun 8 Nov 2026'**
  String get tpDateNoTrips;

  /// No description provided for @tpTripsStops.
  ///
  /// In en, this message translates to:
  /// **'{trips} trips · {stops} stops'**
  String tpTripsStops(int trips, int stops);

  /// No description provided for @tpExtraPickups.
  ///
  /// In en, this message translates to:
  /// **'{count} extra pickups'**
  String tpExtraPickups(int count);

  /// No description provided for @tpSourcePaused.
  ///
  /// In en, this message translates to:
  /// **'{count} source paused'**
  String tpSourcePaused(int count);

  /// No description provided for @tpNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips'**
  String get tpNoTrips;

  /// No description provided for @tpStatusOnRoute.
  ///
  /// In en, this message translates to:
  /// **'On route'**
  String get tpStatusOnRoute;

  /// No description provided for @tpStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get tpStatusApproved;

  /// No description provided for @tpStatusPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get tpStatusPlanned;

  /// No description provided for @tpOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle'**
  String get tpOwnVehicle;

  /// No description provided for @tpContractVehicle.
  ///
  /// In en, this message translates to:
  /// **'Contract vehicle'**
  String get tpContractVehicle;

  /// No description provided for @tpVehicleTag.
  ///
  /// In en, this message translates to:
  /// **'{plate} · {vehicle}'**
  String tpVehicleTag(String plate, String vehicle);

  /// No description provided for @tpChangedForToday.
  ///
  /// In en, this message translates to:
  /// **'Changed for today'**
  String get tpChangedForToday;

  /// No description provided for @tpDriverNotUsingApp.
  ///
  /// In en, this message translates to:
  /// **'Driver not using app'**
  String get tpDriverNotUsingApp;

  /// No description provided for @tpCoverFor.
  ///
  /// In en, this message translates to:
  /// **'{substitute} (for {original})'**
  String tpCoverFor(String substitute, String original);

  /// No description provided for @tpTransporterDriver.
  ///
  /// In en, this message translates to:
  /// **'{transporter} · Driver {driver}'**
  String tpTransporterDriver(String transporter, String driver);

  /// No description provided for @tpStops.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String tpStops(int count);

  /// No description provided for @tpDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily {count}'**
  String tpDaily(int count);

  /// No description provided for @tpWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly {count}'**
  String tpWeekly(int count);

  /// No description provided for @tpMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly {count}'**
  String tpMonthly(int count);

  /// No description provided for @tpBiWeekly.
  ///
  /// In en, this message translates to:
  /// **'Bi-weekly {count}'**
  String tpBiWeekly(int count);

  /// No description provided for @tpOnCall.
  ///
  /// In en, this message translates to:
  /// **'On call {count}'**
  String tpOnCall(int count);

  /// No description provided for @tpPaused.
  ///
  /// In en, this message translates to:
  /// **'{count} paused'**
  String tpPaused(int count);

  /// No description provided for @tpCollectedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} collected'**
  String tpCollectedOf(int done, int total);

  /// No description provided for @tpRecordedOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} recorded in the app'**
  String tpRecordedOf(int done, int total);

  /// No description provided for @tpCollectedMissed.
  ///
  /// In en, this message translates to:
  /// **'{collected} collected · {missed} missed'**
  String tpCollectedMissed(int collected, int missed);

  /// No description provided for @tpWeightKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg'**
  String tpWeightKg(String kg);

  /// No description provided for @tpCallDriver.
  ///
  /// In en, this message translates to:
  /// **'Call driver'**
  String get tpCallDriver;

  /// No description provided for @tpOwnVehicleCount.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle {count}'**
  String tpOwnVehicleCount(int count);

  /// No description provided for @tpContractCount.
  ///
  /// In en, this message translates to:
  /// **'Contract {count}'**
  String tpContractCount(int count);

  /// No description provided for @tpDay0.
  ///
  /// In en, this message translates to:
  /// **'Thu 22 Oct · Today'**
  String get tpDay0;

  /// No description provided for @tpDay1.
  ///
  /// In en, this message translates to:
  /// **'Fri 23 Oct'**
  String get tpDay1;

  /// No description provided for @tpDay2.
  ///
  /// In en, this message translates to:
  /// **'Sat 24 Oct'**
  String get tpDay2;

  /// No description provided for @tpDay3.
  ///
  /// In en, this message translates to:
  /// **'Sun 25 Oct'**
  String get tpDay3;

  /// No description provided for @tpDay4.
  ///
  /// In en, this message translates to:
  /// **'Mon 26 Oct'**
  String get tpDay4;

  /// No description provided for @tpDay5.
  ///
  /// In en, this message translates to:
  /// **'Tue 27 Oct'**
  String get tpDay5;

  /// No description provided for @tpDay6.
  ///
  /// In en, this message translates to:
  /// **'Wed 28 Oct'**
  String get tpDay6;

  /// No description provided for @tpEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips on this day'**
  String get tpEmptyTitle;

  /// No description provided for @tpEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The warehouse is closed that day (holiday). Pickups due that day move to the next working day or are skipped, as each pickup point’s holiday rule says.'**
  String get tpEmptyMessage;

  /// No description provided for @rdNext7Days.
  ///
  /// In en, this message translates to:
  /// **'Next 7 Days'**
  String get rdNext7Days;

  /// No description provided for @rdDateToday.
  ///
  /// In en, this message translates to:
  /// **'Thu, 22 Oct 2026'**
  String get rdDateToday;

  /// No description provided for @rdDateRange.
  ///
  /// In en, this message translates to:
  /// **'Fri 23 Oct – Thu 29 Oct'**
  String get rdDateRange;

  /// No description provided for @rdShift.
  ///
  /// In en, this message translates to:
  /// **'Morning ({time})'**
  String rdShift(String time);

  /// No description provided for @rdAssignedSources.
  ///
  /// In en, this message translates to:
  /// **'Assigned Sources : {count}'**
  String rdAssignedSources(int count);

  /// No description provided for @rdAssignedSourcesPaused.
  ///
  /// In en, this message translates to:
  /// **'Assigned Sources : {count} ({paused} paused)'**
  String rdAssignedSourcesPaused(int count, int paused);

  /// No description provided for @rdDriverLine.
  ///
  /// In en, this message translates to:
  /// **'Driver : {name} ({phone})'**
  String rdDriverLine(String name, String phone);

  /// No description provided for @rdLabourLine.
  ///
  /// In en, this message translates to:
  /// **'Labour : {name}'**
  String rdLabourLine(String name);

  /// No description provided for @rdList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get rdList;

  /// No description provided for @rdMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get rdMap;

  /// No description provided for @rdFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get rdFilterAll;

  /// No description provided for @rdFilterCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get rdFilterCollected;

  /// No description provided for @rdFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rdFilterPending;

  /// No description provided for @rdFilterZeroKg.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get rdFilterZeroKg;

  /// No description provided for @rdFilterMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get rdFilterMissed;

  /// No description provided for @rdFilterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rdFilterCancelled;

  /// No description provided for @rdFilterInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get rdFilterInactive;

  /// No description provided for @rdFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get rdFreqDaily;

  /// No description provided for @rdFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get rdFreqWeekly;

  /// No description provided for @rdTypeSorted.
  ///
  /// In en, this message translates to:
  /// **'Sorted'**
  String get rdTypeSorted;

  /// No description provided for @rdTypeMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get rdTypeMixed;

  /// No description provided for @rdStopTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {type}'**
  String rdStopTitle(String name, String type);

  /// No description provided for @rdSchedEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day · {time}'**
  String rdSchedEveryDay(String time);

  /// No description provided for @rdSchedDays.
  ///
  /// In en, this message translates to:
  /// **'{days} · {time}'**
  String rdSchedDays(String days, String time);

  /// No description provided for @rdSchedExceptSun.
  ///
  /// In en, this message translates to:
  /// **'Except Sun, {time}'**
  String rdSchedExceptSun(String time);

  /// No description provided for @rdSchedSecondWed.
  ///
  /// In en, this message translates to:
  /// **'Second Wed, {time}'**
  String rdSchedSecondWed(String time);

  /// No description provided for @rdSchedOnce.
  ///
  /// In en, this message translates to:
  /// **'(Once) {date}, {time}'**
  String rdSchedOnce(String date, String time);

  /// No description provided for @rdSchedPausedTill.
  ///
  /// In en, this message translates to:
  /// **'Paused till {date}'**
  String rdSchedPausedTill(String date);

  /// No description provided for @rdWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get rdWeekdayMon;

  /// No description provided for @rdWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get rdWeekdayThu;

  /// No description provided for @rdStatusCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get rdStatusCollected;

  /// No description provided for @rdStatusZeroKg.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get rdStatusZeroKg;

  /// No description provided for @rdStatusCancelledBySource.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by source'**
  String get rdStatusCancelledBySource;

  /// No description provided for @rdStatusNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get rdStatusNextStop;

  /// No description provided for @rdStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rdStatusPending;

  /// No description provided for @rdStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get rdStatusInactive;

  /// No description provided for @rdAmountKgPcs.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg + {pcs} pcs'**
  String rdAmountKgPcs(String kg, String pcs);

  /// No description provided for @rdNoteNoMaterial.
  ///
  /// In en, this message translates to:
  /// **'No material today'**
  String get rdNoteNoMaterial;

  /// No description provided for @rdNoteClosedStocktaking.
  ///
  /// In en, this message translates to:
  /// **'Closed for stock-taking'**
  String get rdNoteClosedStocktaking;

  /// No description provided for @rdNotePausedRenovation.
  ///
  /// In en, this message translates to:
  /// **'Source paused (renovation)'**
  String get rdNotePausedRenovation;

  /// No description provided for @rdTagCollectedAt.
  ///
  /// In en, this message translates to:
  /// **'Collected {time}'**
  String rdTagCollectedAt(String time);

  /// No description provided for @rdTagVisitedAt.
  ///
  /// In en, this message translates to:
  /// **'Visited {time}'**
  String rdTagVisitedAt(String time);

  /// No description provided for @rdTagNoteFromDriver.
  ///
  /// In en, this message translates to:
  /// **'Note from driver'**
  String get rdTagNoteFromDriver;

  /// No description provided for @rdTagVoiceNote.
  ///
  /// In en, this message translates to:
  /// **'Voice note {duration}'**
  String rdTagVoiceNote(String duration);

  /// No description provided for @rdLegendCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get rdLegendCollected;

  /// No description provided for @rdLegendZeroKg.
  ///
  /// In en, this message translates to:
  /// **'0 kg'**
  String get rdLegendZeroKg;

  /// No description provided for @rdLegendCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rdLegendCancelled;

  /// No description provided for @rdLegendNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop'**
  String get rdLegendNextStop;

  /// No description provided for @rdLegendPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rdLegendPending;

  /// No description provided for @rdLegendPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get rdLegendPaused;

  /// No description provided for @rdLegendWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get rdLegendWarehouse;

  /// No description provided for @rdMapNext.
  ///
  /// In en, this message translates to:
  /// **'Next: {number} · {name} · {time} · {distance} away'**
  String rdMapNext(int number, String name, String time, String distance);

  /// No description provided for @rdMapHint.
  ///
  /// In en, this message translates to:
  /// **'Stops in visiting order. The solid line is done; the dashed line is still to go, back to the warehouse. Tap a stop to open it.'**
  String get rdMapHint;

  /// No description provided for @rdAddedLastHint.
  ///
  /// In en, this message translates to:
  /// **'It is added as the last stop. You can change the order on the route\'s page.'**
  String get rdAddedLastHint;

  /// No description provided for @rdAddSources.
  ///
  /// In en, this message translates to:
  /// **'Add sources'**
  String get rdAddSources;

  /// No description provided for @sdAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get sdAddress;

  /// No description provided for @sdSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get sdSchedule;

  /// No description provided for @sdPersonAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Person at the pickup point'**
  String get sdPersonAtPickup;

  /// No description provided for @sdIecExecutive.
  ///
  /// In en, this message translates to:
  /// **'IEC Executive'**
  String get sdIecExecutive;

  /// No description provided for @sdRoleManager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get sdRoleManager;

  /// No description provided for @sdContactLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {role} · {phone}'**
  String sdContactLine(String name, String role, String phone);

  /// No description provided for @sdIecLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {phone}'**
  String sdIecLine(String name, String phone);

  /// No description provided for @skTitle.
  ///
  /// In en, this message translates to:
  /// **'Skip this pickup'**
  String get skTitle;

  /// No description provided for @skReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason for Skip'**
  String get skReasonLabel;

  /// No description provided for @skReasonClosed.
  ///
  /// In en, this message translates to:
  /// **'Source closed'**
  String get skReasonClosed;

  /// No description provided for @skReasonHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get skReasonHoliday;

  /// No description provided for @skReasonVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle unavailable'**
  String get skReasonVehicle;

  /// No description provided for @skReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get skReasonOther;

  /// No description provided for @skRemarks.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get skRemarks;

  /// No description provided for @skMaxChars.
  ///
  /// In en, this message translates to:
  /// **'Max 150 Characters'**
  String get skMaxChars;

  /// No description provided for @skConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Skip'**
  String get skConfirm;

  /// No description provided for @apToApprove.
  ///
  /// In en, this message translates to:
  /// **'To approve'**
  String get apToApprove;

  /// No description provided for @apDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get apDone;

  /// No description provided for @apCorrectionDoneDetail.
  ///
  /// In en, this message translates to:
  /// **'PET Bottles 50 kg → 60 kg. The stop’s record is changed; Vikram Singh is told.'**
  String get apCorrectionDoneDetail;

  /// No description provided for @apApprovedToday.
  ///
  /// In en, this message translates to:
  /// **'Approved by you today, 10:20 am'**
  String get apApprovedToday;

  /// No description provided for @apExtraPickupDoneDetail.
  ///
  /// In en, this message translates to:
  /// **'Sat 25 Oct, 10 am – 12 pm · about 40 kg · added to Adajan Morning'**
  String get apExtraPickupDoneDetail;

  /// No description provided for @apApproved21Oct.
  ///
  /// In en, this message translates to:
  /// **'Approved by you 21 Oct'**
  String get apApproved21Oct;

  /// No description provided for @apStartPickupsFromIec.
  ///
  /// In en, this message translates to:
  /// **'Start pickups · from IEC'**
  String get apStartPickupsFromIec;

  /// No description provided for @apGreenLeafNisha.
  ///
  /// In en, this message translates to:
  /// **'Green Leaf Hotel · Nisha Mehta'**
  String get apGreenLeafNisha;

  /// No description provided for @apDeclineReplyDetail.
  ///
  /// In en, this message translates to:
  /// **'Your reply: “No room on Adajan Morning until 1 Dec. Ask again then.”'**
  String get apDeclineReplyDetail;

  /// No description provided for @apDeclined20Oct.
  ///
  /// In en, this message translates to:
  /// **'Declined by you 20 Oct'**
  String get apDeclined20Oct;

  /// No description provided for @apDeclineCorrectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline the correction'**
  String get apDeclineCorrectionTitle;

  /// No description provided for @apDeclineCorrectionBody.
  ///
  /// In en, this message translates to:
  /// **'Vikram Singh sees your reply. The stop stays as recorded.'**
  String get apDeclineCorrectionBody;

  /// No description provided for @apDeclineCorrectionReply.
  ///
  /// In en, this message translates to:
  /// **'The scale photo shows 50 kg. If it was more, ask the gate team to weigh it again.'**
  String get apDeclineCorrectionReply;

  /// No description provided for @apDeclineExtraTitle.
  ///
  /// In en, this message translates to:
  /// **'Decline the extra pickup'**
  String get apDeclineExtraTitle;

  /// No description provided for @apDeclineExtraBody.
  ///
  /// In en, this message translates to:
  /// **'ABC Plastic Manufacture sees your reply. No pickup is added.'**
  String get apDeclineExtraBody;

  /// No description provided for @apReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write your reply'**
  String get apReplyHint;

  /// No description provided for @apDeclineAndReply.
  ///
  /// In en, this message translates to:
  /// **'Decline and reply'**
  String get apDeclineAndReply;

  /// No description provided for @apCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get apCancel;

  /// No description provided for @apExtraApprovedTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup approved'**
  String get apExtraApprovedTitle;

  /// No description provided for @apExtraApprovedBody.
  ///
  /// In en, this message translates to:
  /// **'ABC Plastic Manufacture is added to Adajan Morning on Sat 25 Oct.'**
  String get apExtraApprovedBody;

  /// No description provided for @rpTitle.
  ///
  /// In en, this message translates to:
  /// **'Collection report'**
  String get rpTitle;

  /// No description provided for @rpShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get rpShare;

  /// No description provided for @rpCollectedToday.
  ///
  /// In en, this message translates to:
  /// **'Collected today'**
  String get rpCollectedToday;

  /// No description provided for @rpCollectedYesterday.
  ///
  /// In en, this message translates to:
  /// **'Collected yesterday'**
  String get rpCollectedYesterday;

  /// No description provided for @rpCollectedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Collected this week'**
  String get rpCollectedThisWeek;

  /// No description provided for @rpCollectedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Collected this month'**
  String get rpCollectedThisMonth;

  /// No description provided for @rpCollectedTheseDates.
  ///
  /// In en, this message translates to:
  /// **'Collected on these dates'**
  String get rpCollectedTheseDates;

  /// No description provided for @rpTotal.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg + {pcs} pcs'**
  String rpTotal(String kg, String pcs);

  /// No description provided for @rpKg.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg'**
  String rpKg(String kg);

  /// No description provided for @rpStopsDue.
  ///
  /// In en, this message translates to:
  /// **'{count} stops due'**
  String rpStopsDue(String count);

  /// No description provided for @rpByRoute.
  ///
  /// In en, this message translates to:
  /// **'By route'**
  String get rpByRoute;

  /// No description provided for @rpByCategory.
  ///
  /// In en, this message translates to:
  /// **'By pickup category'**
  String get rpByCategory;

  /// No description provided for @rpStopsToLook.
  ///
  /// In en, this message translates to:
  /// **'Stops to look at'**
  String get rpStopsToLook;

  /// No description provided for @rpOfStops.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} stops'**
  String rpOfStops(String done, String total);

  /// No description provided for @rpStops.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String rpStops(String count);

  /// No description provided for @rpOwn.
  ///
  /// In en, this message translates to:
  /// **'Own'**
  String get rpOwn;

  /// No description provided for @rpContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get rpContract;

  /// No description provided for @rpCancelledBySource.
  ///
  /// In en, this message translates to:
  /// **'Cancelled by source'**
  String get rpCancelledBySource;

  /// No description provided for @rpNamesMore.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second} and {count} more'**
  String rpNamesMore(String first, String second, String count);

  /// No description provided for @rpNamesPlus.
  ///
  /// In en, this message translates to:
  /// **'{first}, {second} +{count}'**
  String rpNamesPlus(String first, String second, String count);

  /// No description provided for @rpCollectedStops.
  ///
  /// In en, this message translates to:
  /// **'{label} · {done} of {total} stops'**
  String rpCollectedStops(String label, String done, String total);

  /// No description provided for @rpPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Report PDF'**
  String get rpPdfTitle;

  /// No description provided for @rpPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Collection report · {range}'**
  String rpPdfSubtitle(String range);

  /// No description provided for @rpCompany.
  ///
  /// In en, this message translates to:
  /// **'Ecovision Environmental Resources LLP'**
  String get rpCompany;

  /// No description provided for @rpPdfSupervisor.
  ///
  /// In en, this message translates to:
  /// **'Pickup Supervisor: {name} · {period}, {range}'**
  String rpPdfSupervisor(String name, String period, String range);

  /// No description provided for @rpPeriodToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get rpPeriodToday;

  /// No description provided for @rpPeriodYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get rpPeriodYesterday;

  /// No description provided for @rpPeriodThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get rpPeriodThisWeek;

  /// No description provided for @rpPeriodThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get rpPeriodThisMonth;

  /// No description provided for @rpPeriodDates.
  ///
  /// In en, this message translates to:
  /// **'Selected dates'**
  String get rpPeriodDates;

  /// No description provided for @rpPdfSummary.
  ///
  /// In en, this message translates to:
  /// **'{due} stops due · Collected {collected} · 0 kg {zero} · Missed {missed} · Cancelled {cancelled}'**
  String rpPdfSummary(
    String due,
    String collected,
    String zero,
    String missed,
    String cancelled,
  );

  /// No description provided for @rpColRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get rpColRoute;

  /// No description provided for @rpColVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get rpColVehicle;

  /// No description provided for @rpColStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get rpColStops;

  /// No description provided for @rpColCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get rpColCollected;

  /// No description provided for @rpColCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get rpColCategory;

  /// No description provided for @rpColOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get rpColOutcome;

  /// No description provided for @rpColPickupPoints.
  ///
  /// In en, this message translates to:
  /// **'Pickup points'**
  String get rpColPickupPoints;

  /// No description provided for @rpOf.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String rpOf(String done, String total);

  /// No description provided for @rpPdfMade.
  ///
  /// In en, this message translates to:
  /// **'Made {date}, {time} · Page 1 of 1'**
  String rpPdfMade(String date, String time);

  /// No description provided for @rpPdfPageHint.
  ///
  /// In en, this message translates to:
  /// **'Page 1 of 1 · pinch to zoom'**
  String get rpPdfPageHint;

  /// No description provided for @rpSharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get rpSharePdf;

  /// No description provided for @calClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get calClear;

  /// No description provided for @calApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get calApply;

  /// No description provided for @calPrevMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calPrevMonth;

  /// No description provided for @calNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calNextMonth;

  /// No description provided for @calSelection.
  ///
  /// In en, this message translates to:
  /// **'{range} · {days}'**
  String calSelection(String range, String days);

  /// No description provided for @calDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String calDays(int count);

  /// No description provided for @calPickDates.
  ///
  /// In en, this message translates to:
  /// **'Pick dates'**
  String get calPickDates;

  /// No description provided for @calMonthLong.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{January} 2{February} 3{March} 4{April} 5{May} 6{June} 7{July} 8{August} 9{September} 10{October} 11{November} 12{December} other{}}'**
  String calMonthLong(String month);

  /// No description provided for @calMonthShort.
  ///
  /// In en, this message translates to:
  /// **'{month, select, 1{Jan} 2{Feb} 3{Mar} 4{Apr} 5{May} 6{Jun} 7{Jul} 8{Aug} 9{Sep} 10{Oct} 11{Nov} 12{Dec} other{}}'**
  String calMonthShort(String month);

  /// No description provided for @calWeekday.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{M} 2{T} 3{W} 4{T} 5{F} 6{S} 7{S} other{}}'**
  String calWeekday(String day);

  /// No description provided for @supervisorDrawerCashPayments.
  ///
  /// In en, this message translates to:
  /// **'Cash & payments'**
  String get supervisorDrawerCashPayments;

  /// No description provided for @lkRouteDate.
  ///
  /// In en, this message translates to:
  /// **'{route} · {date}'**
  String lkRouteDate(String route, String date);

  /// No description provided for @lkNotOnRoute.
  ///
  /// In en, this message translates to:
  /// **'Not on a route'**
  String get lkNotOnRoute;

  /// No description provided for @lkContractVehicle.
  ///
  /// In en, this message translates to:
  /// **'Contract vehicle · {plate}'**
  String lkContractVehicle(String plate);

  /// No description provided for @lkOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'Own vehicle · driver {name}'**
  String lkOwnVehicle(String name);

  /// No description provided for @lkExtraPickup.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup'**
  String get lkExtraPickup;

  /// No description provided for @lkCalledOffIec.
  ///
  /// In en, this message translates to:
  /// **'Called off by the IEC ahead of time'**
  String get lkCalledOffIec;

  /// No description provided for @lkCalledOffAtStop.
  ///
  /// In en, this message translates to:
  /// **'Called off at the stop · driver {name}'**
  String lkCalledOffAtStop(String name);

  /// No description provided for @lkCalledOffByYou.
  ///
  /// In en, this message translates to:
  /// **'Called off by you'**
  String get lkCalledOffByYou;

  /// No description provided for @lkReasonNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded by the driver or the gate'**
  String get lkReasonNotRecorded;

  /// No description provided for @lkReasonTripCancelled.
  ///
  /// In en, this message translates to:
  /// **'Its trip was cancelled'**
  String get lkReasonTripCancelled;

  /// No description provided for @lkReasonNoRoute.
  ///
  /// In en, this message translates to:
  /// **'No route that day'**
  String get lkReasonNoRoute;

  /// No description provided for @lkReasonTakenOff.
  ///
  /// In en, this message translates to:
  /// **'Taken off the trip and not put on another'**
  String get lkReasonTakenOff;

  /// No description provided for @lkReasonClosedToday.
  ///
  /// In en, this message translates to:
  /// **'Closed today'**
  String get lkReasonClosedToday;

  /// No description provided for @lkReasonHoliday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get lkReasonHoliday;

  /// No description provided for @lkReasonShifted.
  ///
  /// In en, this message translates to:
  /// **'Shifted to another day'**
  String get lkReasonShifted;

  /// No description provided for @lkReasonNoMaterial.
  ///
  /// In en, this message translates to:
  /// **'No material'**
  String get lkReasonNoMaterial;

  /// No description provided for @lkReasonNoMaterialToday.
  ///
  /// In en, this message translates to:
  /// **'No material today'**
  String get lkReasonNoMaterialToday;

  /// No description provided for @lkReasonClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get lkReasonClosed;

  /// No description provided for @lkReasonRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused to give'**
  String get lkReasonRefused;

  /// No description provided for @lkReasonVehicleFull.
  ///
  /// In en, this message translates to:
  /// **'Vehicle full'**
  String get lkReasonVehicleFull;

  /// No description provided for @lkEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to look at for these dates'**
  String get lkEmpty;

  /// No description provided for @calWeekdayShort.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Mon} 2{Tue} 3{Wed} 4{Thu} 5{Fri} 6{Sat} 7{Sun} other{}}'**
  String calWeekdayShort(String day);

  /// No description provided for @isTypeSourceProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem at the source'**
  String get isTypeSourceProblem;

  /// No description provided for @isDriverRole.
  ///
  /// In en, this message translates to:
  /// **'{name} (Driver)'**
  String isDriverRole(String name);

  /// No description provided for @isRaised.
  ///
  /// In en, this message translates to:
  /// **'Raised {time}'**
  String isRaised(String time);

  /// No description provided for @isOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get isOpen;

  /// No description provided for @isEscalated.
  ///
  /// In en, this message translates to:
  /// **'Escalated'**
  String get isEscalated;

  /// No description provided for @isResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get isResolved;

  /// No description provided for @isTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type :'**
  String get isTypeLabel;

  /// No description provided for @isDriverNote.
  ///
  /// In en, this message translates to:
  /// **'Driver’s note :'**
  String get isDriverNote;

  /// No description provided for @isBy.
  ///
  /// In en, this message translates to:
  /// **'By :'**
  String get isBy;

  /// No description provided for @isByValue.
  ///
  /// In en, this message translates to:
  /// **'{name} · {time}'**
  String isByValue(String name, String time);

  /// No description provided for @isWhatWasDone.
  ///
  /// In en, this message translates to:
  /// **'What was done :'**
  String get isWhatWasDone;

  /// No description provided for @isTold.
  ///
  /// In en, this message translates to:
  /// **'Told :'**
  String get isTold;

  /// No description provided for @isToldValue.
  ///
  /// In en, this message translates to:
  /// **'The office and {name} (IEC).'**
  String isToldValue(String name);

  /// No description provided for @isEscalate.
  ///
  /// In en, this message translates to:
  /// **'Escalate'**
  String get isEscalate;

  /// No description provided for @isMarkResolved.
  ///
  /// In en, this message translates to:
  /// **'Mark resolved'**
  String get isMarkResolved;

  /// No description provided for @isSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as resolved'**
  String get isSheetTitle;

  /// No description provided for @isSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Say what was done. The driver and the office see it.'**
  String get isSheetBody;

  /// No description provided for @isWhatWasDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'What was done'**
  String get isWhatWasDoneLabel;

  /// No description provided for @isEscalateTitle.
  ///
  /// In en, this message translates to:
  /// **'Escalate this issue?'**
  String get isEscalateTitle;

  /// No description provided for @isEscalateBody.
  ///
  /// In en, this message translates to:
  /// **'The office and the source’s IEC are told, and it shows as Escalated. Use it when you cannot sort it out yourself.'**
  String get isEscalateBody;

  /// No description provided for @isResolvedToastTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Resolved!'**
  String get isResolvedToastTitle;

  /// No description provided for @isResolvedToastBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is told.'**
  String isResolvedToastBody(String name);

  /// No description provided for @isEscalatedToastTitle.
  ///
  /// In en, this message translates to:
  /// **'Issue Escalated!'**
  String get isEscalatedToastTitle;

  /// No description provided for @isEscalatedToastBody.
  ///
  /// In en, this message translates to:
  /// **'The office and the source’s IEC are told.'**
  String get isEscalatedToastBody;

  /// No description provided for @tpStatusExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get tpStatusExpected;

  /// No description provided for @tpExpectedInfo.
  ///
  /// In en, this message translates to:
  /// **'Trips are made the day before. This is what the routes and the pickups due that day add up to; the team can still change.'**
  String get tpExpectedInfo;

  /// No description provided for @tpExtra.
  ///
  /// In en, this message translates to:
  /// **'Extra {count}'**
  String tpExtra(int count);

  /// No description provided for @tpTodaySuffix.
  ///
  /// In en, this message translates to:
  /// **'{date} · Today'**
  String tpTodaySuffix(String date);

  /// No description provided for @tpWarehouseClosed.
  ///
  /// In en, this message translates to:
  /// **'{date} · Warehouse closed'**
  String tpWarehouseClosed(String date);

  /// No description provided for @tpNoTripsHoliday.
  ///
  /// In en, this message translates to:
  /// **'No trips · warehouse holiday'**
  String get tpNoTripsHoliday;

  /// No description provided for @rdTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip details'**
  String get rdTripDetails;

  /// No description provided for @rdThisTrip.
  ///
  /// In en, this message translates to:
  /// **'This trip'**
  String get rdThisTrip;

  /// No description provided for @rdStarted.
  ///
  /// In en, this message translates to:
  /// **'Started {time} (Start trip)'**
  String rdStarted(String time);

  /// No description provided for @rdLabourNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get rdLabourNone;

  /// No description provided for @rdAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'At the warehouse'**
  String get rdAtWarehouse;

  /// No description provided for @rdWeighbridge.
  ///
  /// In en, this message translates to:
  /// **'Weighbridge net :'**
  String get rdWeighbridge;

  /// No description provided for @rdDriversTotal.
  ///
  /// In en, this message translates to:
  /// **'Driver’s total :'**
  String get rdDriversTotal;

  /// No description provided for @rdBagsReceived.
  ///
  /// In en, this message translates to:
  /// **'Bags received :'**
  String get rdBagsReceived;

  /// No description provided for @rdApprovedBy.
  ///
  /// In en, this message translates to:
  /// **'Approved by :'**
  String get rdApprovedBy;

  /// No description provided for @rdDriversTotalValue.
  ///
  /// In en, this message translates to:
  /// **'{kg} kg · difference {diff} kg ({pct}%)'**
  String rdDriversTotalValue(String kg, String diff, String pct);

  /// No description provided for @rdApprovedByValue.
  ///
  /// In en, this message translates to:
  /// **'{name} · {time}'**
  String rdApprovedByValue(String name, String time);

  /// No description provided for @rdTagGate.
  ///
  /// In en, this message translates to:
  /// **'Entered at gate · {time}'**
  String rdTagGate(String time);

  /// No description provided for @rdStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get rdStatusMissed;

  /// No description provided for @rdNoteNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded by the driver'**
  String get rdNoteNotRecorded;

  /// No description provided for @rdNoteNoMaterialDriver.
  ///
  /// In en, this message translates to:
  /// **'No material, per the driver'**
  String get rdNoteNoMaterialDriver;

  /// No description provided for @rdNoteAskedToSkip.
  ///
  /// In en, this message translates to:
  /// **'Asked to skip today'**
  String get rdNoteAskedToSkip;

  /// No description provided for @rdNextVisits.
  ///
  /// In en, this message translates to:
  /// **'Next: {dates}'**
  String rdNextVisits(String dates);

  /// No description provided for @rdEveryDayVisits.
  ///
  /// In en, this message translates to:
  /// **'Every day · {count} visits'**
  String rdEveryDayVisits(String count);

  /// No description provided for @rdStatusApprovedTrip.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get rdStatusApprovedTrip;

  /// No description provided for @raOnRouteTitle.
  ///
  /// In en, this message translates to:
  /// **'{route} · on route'**
  String raOnRouteTitle(String route);

  /// No description provided for @raOnRouteBody.
  ///
  /// In en, this message translates to:
  /// **'The trip has started, so its team and stops can’t change.'**
  String get raOnRouteBody;

  /// No description provided for @raCompleteTrip.
  ///
  /// In en, this message translates to:
  /// **'Complete trip for the driver'**
  String get raCompleteTrip;

  /// No description provided for @raCompleteTripBody.
  ///
  /// In en, this message translates to:
  /// **'The driver can’t finish it in the app'**
  String get raCompleteTripBody;

  /// No description provided for @raAskHeadBody.
  ///
  /// In en, this message translates to:
  /// **'Need another vehicle or more labour'**
  String get raAskHeadBody;

  /// No description provided for @raPlannedTitle.
  ///
  /// In en, this message translates to:
  /// **'{route} · planned'**
  String raPlannedTitle(String route);

  /// No description provided for @raPlannedBody.
  ///
  /// In en, this message translates to:
  /// **'The trip hasn’t started, so you can still change it.'**
  String get raPlannedBody;

  /// No description provided for @raChangeTeam.
  ///
  /// In en, this message translates to:
  /// **'Change driver or labour'**
  String get raChangeTeam;

  /// No description provided for @raChangeTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Pick another driver or labourer for this trip'**
  String get raChangeTeamBody;

  /// No description provided for @raMoveStops.
  ///
  /// In en, this message translates to:
  /// **'Move stops to another trip'**
  String get raMoveStops;

  /// No description provided for @raMoveStopsBody.
  ///
  /// In en, this message translates to:
  /// **'Send some pickups to a different trip'**
  String get raMoveStopsBody;

  /// No description provided for @raSwitchOff.
  ///
  /// In en, this message translates to:
  /// **'Switch off this trip'**
  String get raSwitchOff;

  /// No description provided for @raSwitchOffBody.
  ///
  /// In en, this message translates to:
  /// **'No trip that day; its pickups are skipped'**
  String get raSwitchOffBody;

  /// No description provided for @sdTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop detail'**
  String get sdTitle;

  /// No description provided for @sdRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get sdRoute;

  /// No description provided for @sdDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get sdDue;

  /// No description provided for @sdOnTrip.
  ///
  /// In en, this message translates to:
  /// **'On the trip'**
  String get sdOnTrip;

  /// No description provided for @sdStopOf.
  ///
  /// In en, this message translates to:
  /// **'Stop {number} of {total}'**
  String sdStopOf(String number, String total);

  /// No description provided for @sdStopOfDistance.
  ///
  /// In en, this message translates to:
  /// **'Stop {number} of {total} · {km} km from the last stop'**
  String sdStopOfDistance(String number, String total, String km);

  /// No description provided for @sdDueToday.
  ///
  /// In en, this message translates to:
  /// **'Today · {time}'**
  String sdDueToday(String time);

  /// No description provided for @sdDueOn.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time}'**
  String sdDueOn(String date, String time);

  /// No description provided for @sdCallPerson.
  ///
  /// In en, this message translates to:
  /// **'Call the person at the pickup point'**
  String get sdCallPerson;

  /// No description provided for @sdTripStartedNote.
  ///
  /// In en, this message translates to:
  /// **'The trip has started. The driver records what happens at this stop.'**
  String get sdTripStartedNote;

  /// No description provided for @sdSkipThisPickup.
  ///
  /// In en, this message translates to:
  /// **'Skip this pickup'**
  String get sdSkipThisPickup;

  /// No description provided for @sdRouteVehicle.
  ///
  /// In en, this message translates to:
  /// **'{route} · {plate} · {vehicle}'**
  String sdRouteVehicle(String route, String plate, String vehicle);

  /// No description provided for @sdRoutePlanned.
  ///
  /// In en, this message translates to:
  /// **'{route} · {date} · {plate}'**
  String sdRoutePlanned(String route, String date, String plate);

  /// No description provided for @sdOwnVehicleLower.
  ///
  /// In en, this message translates to:
  /// **'own vehicle'**
  String get sdOwnVehicleLower;

  /// No description provided for @sdContractVehicleLower.
  ///
  /// In en, this message translates to:
  /// **'contract vehicle'**
  String get sdContractVehicleLower;

  /// No description provided for @sdRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get sdRoleOwner;

  /// No description provided for @skReasonSourceAsked.
  ///
  /// In en, this message translates to:
  /// **'Source asked'**
  String get skReasonSourceAsked;

  /// No description provided for @skReasonCapacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity full at warehouse'**
  String get skReasonCapacity;

  /// No description provided for @skReasonShift.
  ///
  /// In en, this message translates to:
  /// **'Not enough time in shift'**
  String get skReasonShift;

  /// No description provided for @skPickupSkippedTitle.
  ///
  /// In en, this message translates to:
  /// **'Pickup Skipped!'**
  String get skPickupSkippedTitle;

  /// No description provided for @skPickupSkippedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is off {date}’s trip. Next visit: {next}.'**
  String skPickupSkippedBody(String name, String date, String next);

  /// No description provided for @rdDateTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Fri, 23 Oct 2026'**
  String get rdDateTomorrow;

  /// No description provided for @rdFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get rdFreqMonthly;

  /// No description provided for @rdSchedFirstOfMonth.
  ///
  /// In en, this message translates to:
  /// **'1st of the month · {time}'**
  String rdSchedFirstOfMonth(String time);

  /// No description provided for @sdRoleStoreManager.
  ///
  /// In en, this message translates to:
  /// **'Store manager'**
  String get sdRoleStoreManager;

  /// No description provided for @sdRoleOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get sdRoleOffice;

  /// No description provided for @sdRouteVehicleTransport.
  ///
  /// In en, this message translates to:
  /// **'{route} · {plate} · {vehicle} ({transport})'**
  String sdRouteVehicleTransport(
    String route,
    String plate,
    String vehicle,
    String transport,
  );

  /// No description provided for @sxCollectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Collected · {amount}'**
  String sxCollectedTitle(String amount);

  /// No description provided for @sxCollectedAt.
  ///
  /// In en, this message translates to:
  /// **'Collected at'**
  String get sxCollectedAt;

  /// No description provided for @sxVisitedAt.
  ///
  /// In en, this message translates to:
  /// **'Visited at'**
  String get sxVisitedAt;

  /// No description provided for @sxAtDate.
  ///
  /// In en, this message translates to:
  /// **'{time} · {date}'**
  String sxAtDate(String time, String date);

  /// No description provided for @sxFromSlip.
  ///
  /// In en, this message translates to:
  /// **'{time} · {date} (from the driver’s slip)'**
  String sxFromSlip(String time, String date);

  /// No description provided for @sxDataEntry.
  ///
  /// In en, this message translates to:
  /// **'Data entry'**
  String get sxDataEntry;

  /// No description provided for @sxByDriverApp.
  ///
  /// In en, this message translates to:
  /// **'By {name} (driver), in the app · {time}'**
  String sxByDriverApp(String name, String time);

  /// No description provided for @sxByGate.
  ///
  /// In en, this message translates to:
  /// **'By {name} (back office), at the gate · {time}'**
  String sxByGate(String name, String time);

  /// No description provided for @sxEnteredApp.
  ///
  /// In en, this message translates to:
  /// **'Entered in the app'**
  String get sxEnteredApp;

  /// No description provided for @sxEnteredGate.
  ///
  /// In en, this message translates to:
  /// **'Entered at gate'**
  String get sxEnteredGate;

  /// No description provided for @sxGps.
  ///
  /// In en, this message translates to:
  /// **'GPS location'**
  String get sxGps;

  /// No description provided for @sxGpsValue.
  ///
  /// In en, this message translates to:
  /// **'{coords} · {meters} m from the pickup point'**
  String sxGpsValue(String coords, String meters);

  /// No description provided for @sxGpsNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded (entered at the gate, not at the source)'**
  String get sxGpsNotRecorded;

  /// No description provided for @sxLocationMatched.
  ///
  /// In en, this message translates to:
  /// **'Location matched'**
  String get sxLocationMatched;

  /// No description provided for @sxViewOnMap.
  ///
  /// In en, this message translates to:
  /// **'View on map'**
  String get sxViewOnMap;

  /// No description provided for @sxNoteFromDriver.
  ///
  /// In en, this message translates to:
  /// **'Note from driver'**
  String get sxNoteFromDriver;

  /// No description provided for @sxQuoted.
  ///
  /// In en, this message translates to:
  /// **'“{text}”'**
  String sxQuoted(String text);

  /// No description provided for @sxCollectedItems.
  ///
  /// In en, this message translates to:
  /// **'Collected items'**
  String get sxCollectedItems;

  /// No description provided for @sxCollected.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get sxCollected;

  /// No description provided for @sxKg.
  ///
  /// In en, this message translates to:
  /// **'KG'**
  String get sxKg;

  /// No description provided for @sxPcs.
  ///
  /// In en, this message translates to:
  /// **'PCS'**
  String get sxPcs;

  /// No description provided for @sxKgBlock.
  ///
  /// In en, this message translates to:
  /// **'KG Block'**
  String get sxKgBlock;

  /// No description provided for @sxPcsBlock.
  ///
  /// In en, this message translates to:
  /// **'PCS Block'**
  String get sxPcsBlock;

  /// No description provided for @sxTotalCollected.
  ///
  /// In en, this message translates to:
  /// **'Total Collected'**
  String get sxTotalCollected;

  /// No description provided for @sxTotalKg.
  ///
  /// In en, this message translates to:
  /// **'{amount} KG.'**
  String sxTotalKg(String amount);

  /// No description provided for @sxTotalPcs.
  ///
  /// In en, this message translates to:
  /// **'{amount} PCS'**
  String sxTotalPcs(String amount);

  /// No description provided for @sxZeroTitle.
  ///
  /// In en, this message translates to:
  /// **'0 kg · No material today'**
  String get sxZeroTitle;

  /// No description provided for @sxPhotoFromDriver.
  ///
  /// In en, this message translates to:
  /// **'Photo from the driver'**
  String get sxPhotoFromDriver;

  /// No description provided for @sxAddExtra.
  ///
  /// In en, this message translates to:
  /// **'Add an extra pickup'**
  String get sxAddExtra;

  /// No description provided for @sxAddExtraTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Add an extra pickup tomorrow'**
  String get sxAddExtraTomorrow;

  /// No description provided for @sxCallDriver.
  ///
  /// In en, this message translates to:
  /// **'Call the driver'**
  String get sxCallDriver;

  /// No description provided for @sxMissedTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed · not recorded'**
  String get sxMissedTitle;

  /// No description provided for @sxWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'What happened'**
  String get sxWhatHappened;

  /// No description provided for @sxMissedBody.
  ///
  /// In en, this message translates to:
  /// **'The trip reached {warehouse} at {time} and the gate entered every other stop, but not this one.'**
  String sxMissedBody(String warehouse, String time);

  /// No description provided for @sxVehicleDriver.
  ///
  /// In en, this message translates to:
  /// **'Vehicle and driver'**
  String get sxVehicleDriver;

  /// No description provided for @sxVehicleDriverValue.
  ///
  /// In en, this message translates to:
  /// **'{plate} · {driver} ({transport}) · {phone}'**
  String sxVehicleDriverValue(
    String plate,
    String driver,
    String transport,
    String phone,
  );

  /// No description provided for @sxReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get sxReason;

  /// No description provided for @sxCalledOffBy.
  ///
  /// In en, this message translates to:
  /// **'Called off by'**
  String get sxCalledOffBy;

  /// No description provided for @sxCalledOffValue.
  ///
  /// In en, this message translates to:
  /// **'{source} (source), through {iec} (IEC) · {when}'**
  String sxCalledOffValue(String source, String iec, String when);

  /// No description provided for @sxNextPickup.
  ///
  /// In en, this message translates to:
  /// **'Next pickup'**
  String get sxNextPickup;

  /// No description provided for @sxPausedTitle.
  ///
  /// In en, this message translates to:
  /// **'Paused {range}'**
  String sxPausedTitle(String range);

  /// No description provided for @sxReasonRenovation.
  ///
  /// In en, this message translates to:
  /// **'Renovation'**
  String get sxReasonRenovation;

  /// No description provided for @sxAskedBy.
  ///
  /// In en, this message translates to:
  /// **'Asked by'**
  String get sxAskedBy;

  /// No description provided for @sxAskedByValue.
  ///
  /// In en, this message translates to:
  /// **'The source, on {date} · approved by {iec} (IEC)'**
  String sxAskedByValue(String date, String iec);

  /// No description provided for @sxWhatHappens.
  ///
  /// In en, this message translates to:
  /// **'What happens'**
  String get sxWhatHappens;

  /// No description provided for @sxPausedBody.
  ///
  /// In en, this message translates to:
  /// **'Not on any trip until the pause ends. The next pickup is {date}.'**
  String sxPausedBody(String date);

  /// No description provided for @sxAskRestart.
  ///
  /// In en, this message translates to:
  /// **'Ask to restart pickups'**
  String get sxAskRestart;

  /// No description provided for @exIntro.
  ///
  /// In en, this message translates to:
  /// **'{name} · {address}. It joins the trip that covers that day, or waits in Unassigned.'**
  String exIntro(String name, String address);

  /// No description provided for @exDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Pickup date and time'**
  String get exDateLabel;

  /// No description provided for @exAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'About how much? (kg)'**
  String get exAmountLabel;

  /// No description provided for @exSubmit.
  ///
  /// In en, this message translates to:
  /// **'Add extra pickup'**
  String get exSubmit;

  /// No description provided for @exAddedTitle.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup added'**
  String get exAddedTitle;

  /// No description provided for @exAddedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} on {date}, {time}. It joins tomorrow’s {route} trip, and the driver sees it there.'**
  String exAddedBody(String name, String date, String time, String route);

  /// No description provided for @exBackToStop.
  ///
  /// In en, this message translates to:
  /// **'Back to the stop'**
  String get exBackToStop;

  /// No description provided for @taSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'{route} · {date}'**
  String taSheetTitle(String route, String date);

  /// No description provided for @taSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Changes here are for this trip only. The route stays as it is.'**
  String get taSheetBody;

  /// No description provided for @taChangeTeamBody.
  ///
  /// In en, this message translates to:
  /// **'Someone is absent today'**
  String get taChangeTeamBody;

  /// No description provided for @taMoveStops.
  ///
  /// In en, this message translates to:
  /// **'Move stops to another vehicle'**
  String get taMoveStops;

  /// No description provided for @taMoveStopsBody.
  ///
  /// In en, this message translates to:
  /// **'Breakdown, or the vehicle isn’t available'**
  String get taMoveStopsBody;

  /// No description provided for @taCancelTrip.
  ///
  /// In en, this message translates to:
  /// **'Cancel this trip'**
  String get taCancelTrip;

  /// No description provided for @taCancelTripBody.
  ///
  /// In en, this message translates to:
  /// **'No trip on {date}. The route stays on.'**
  String taCancelTripBody(String date);

  /// No description provided for @taSwitchOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Switch off the route'**
  String get taSwitchOffRoute;

  /// No description provided for @taSwitchOffRouteBody.
  ///
  /// In en, this message translates to:
  /// **'No trips until you switch it on'**
  String get taSwitchOffRouteBody;

  /// No description provided for @ctTitle.
  ///
  /// In en, this message translates to:
  /// **'Change for this trip'**
  String get ctTitle;

  /// No description provided for @ctInfo.
  ///
  /// In en, this message translates to:
  /// **'Only this trip changes. The route keeps its own team. To change the team for good, edit the route.'**
  String get ctInfo;

  /// No description provided for @ctOnRoute.
  ///
  /// In en, this message translates to:
  /// **'On the route'**
  String get ctOnRoute;

  /// No description provided for @ctDriver.
  ///
  /// In en, this message translates to:
  /// **'Driver'**
  String get ctDriver;

  /// No description provided for @ctLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get ctLabour;

  /// No description provided for @ctAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get ctAbsent;

  /// No description provided for @ctPerson.
  ///
  /// In en, this message translates to:
  /// **'{name} (••• {tail})'**
  String ctPerson(String name, String tail);

  /// No description provided for @ctPersonNote.
  ///
  /// In en, this message translates to:
  /// **'{person} · {note}'**
  String ctPersonNote(String person, String note);

  /// No description provided for @ctDriverForTrip.
  ///
  /// In en, this message translates to:
  /// **'Driver for this trip'**
  String get ctDriverForTrip;

  /// No description provided for @ctLabourForTrip.
  ///
  /// In en, this message translates to:
  /// **'Labour for this trip'**
  String get ctLabourForTrip;

  /// No description provided for @ctReplaces.
  ///
  /// In en, this message translates to:
  /// **'Replaces {name} (absent)'**
  String ctReplaces(String name);

  /// No description provided for @ctNoChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get ctNoChange;

  /// No description provided for @ctFreeToday.
  ///
  /// In en, this message translates to:
  /// **'Free today'**
  String get ctFreeToday;

  /// No description provided for @ctReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get ctReason;

  /// No description provided for @ctOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get ctOther;

  /// No description provided for @ctSave.
  ///
  /// In en, this message translates to:
  /// **'Save for this trip'**
  String get ctSave;

  /// No description provided for @ctFreeOn.
  ///
  /// In en, this message translates to:
  /// **'Free on {date}, {time}'**
  String ctFreeOn(String date, String time);

  /// No description provided for @ctBusyAtTime.
  ///
  /// In en, this message translates to:
  /// **'Busy at this time'**
  String get ctBusyAtTime;

  /// No description provided for @ctFreeUntil.
  ///
  /// In en, this message translates to:
  /// **'{route}, {time}: free until then'**
  String ctFreeUntil(String route, String time);

  /// No description provided for @ctBusy.
  ///
  /// In en, this message translates to:
  /// **'Busy: {route}, {time}'**
  String ctBusy(String route, String time);

  /// No description provided for @ctBusyDriverNote.
  ///
  /// In en, this message translates to:
  /// **'You can still choose a busy driver. The app warns you about the clash.'**
  String get ctBusyDriverNote;

  /// No description provided for @ctBusyLabourNote.
  ///
  /// In en, this message translates to:
  /// **'You can still choose a busy labour. The app warns you about the clash.'**
  String get ctBusyLabourNote;

  /// No description provided for @ctSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved for this trip!'**
  String get ctSavedTitle;

  /// No description provided for @ctSavedBody.
  ///
  /// In en, this message translates to:
  /// **'{name} drives on {date}. Both drivers are told.'**
  String ctSavedBody(String name, String date);

  /// No description provided for @rdChangedOnlyTrip.
  ///
  /// In en, this message translates to:
  /// **'Driver: {driver} for {absent} (absent). Only this trip.'**
  String rdChangedOnlyTrip(String driver, String absent);

  /// No description provided for @rdChangedTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Driver: {driver} for {absent} (absent). Tomorrow the route’s own team is back.'**
  String rdChangedTomorrow(String driver, String absent);

  /// No description provided for @rdForPerson.
  ///
  /// In en, this message translates to:
  /// **'for {name}'**
  String rdForPerson(String name);

  /// No description provided for @rdTodayForPerson.
  ///
  /// In en, this message translates to:
  /// **'today, for {name}'**
  String rdTodayForPerson(String name);

  /// No description provided for @rdStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get rdStatusCancelled;

  /// No description provided for @rdStatusSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'Switched off'**
  String get rdStatusSwitchedOff;

  /// No description provided for @rdShiftEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening ({time})'**
  String rdShiftEvening(String time);

  /// No description provided for @msTitle.
  ///
  /// In en, this message translates to:
  /// **'Move stops'**
  String get msTitle;

  /// No description provided for @msWhy.
  ///
  /// In en, this message translates to:
  /// **'Why?'**
  String get msWhy;

  /// No description provided for @msBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Breakdown'**
  String get msBreakdown;

  /// No description provided for @msVehicleNa.
  ///
  /// In en, this message translates to:
  /// **'Vehicle not available'**
  String get msVehicleNa;

  /// No description provided for @msDriverAbsent.
  ///
  /// In en, this message translates to:
  /// **'Driver absent'**
  String get msDriverAbsent;

  /// No description provided for @msMoveTo.
  ///
  /// In en, this message translates to:
  /// **'Move to'**
  String get msMoveTo;

  /// No description provided for @msTripLine.
  ///
  /// In en, this message translates to:
  /// **'{plate} · {driver} · {time}'**
  String msTripLine(String plate, String driver, String time);

  /// No description provided for @msContract.
  ///
  /// In en, this message translates to:
  /// **'Contract'**
  String get msContract;

  /// No description provided for @msStopsToMove.
  ///
  /// In en, this message translates to:
  /// **'Stops to move ({count} ticked)'**
  String msStopsToMove(int count);

  /// No description provided for @msStopLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {frequency} · {time}'**
  String msStopLine(String name, String frequency, String time);

  /// No description provided for @msHint.
  ///
  /// In en, this message translates to:
  /// **'The stops join the end of the chosen trip. Moving every stop cancels this trip.'**
  String get msHint;

  /// No description provided for @msMove.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 stop} other{Move {count} stops}}'**
  String msMove(int count);

  /// No description provided for @msMovedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Stop Moved} other{{count} Stops Moved}}'**
  String msMovedTitle(int count);

  /// No description provided for @msMovedBody.
  ///
  /// In en, this message translates to:
  /// **'{names} are now at the end of {trip} ({date}). Both drivers are told.'**
  String msMovedBody(String names, String trip, String date);

  /// No description provided for @msAnd.
  ///
  /// In en, this message translates to:
  /// **'{first} and {last}'**
  String msAnd(String first, String last);

  /// No description provided for @msOpenTrip.
  ///
  /// In en, this message translates to:
  /// **'Open {trip}’s trip'**
  String msOpenTrip(String trip);

  /// No description provided for @msBackToTrip.
  ///
  /// In en, this message translates to:
  /// **'Back to the trip'**
  String get msBackToTrip;

  /// No description provided for @ahSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing changes until they approve'**
  String get ahSubtitle;

  /// No description provided for @ahWhat.
  ///
  /// In en, this message translates to:
  /// **'What do you need?'**
  String get ahWhat;

  /// No description provided for @ahForTrip.
  ///
  /// In en, this message translates to:
  /// **'For a trip'**
  String get ahForTrip;

  /// No description provided for @ahVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get ahVehicle;

  /// No description provided for @ahLabour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get ahLabour;

  /// No description provided for @ahForPoint.
  ///
  /// In en, this message translates to:
  /// **'For a pickup point'**
  String get ahForPoint;

  /// No description provided for @ahChangeDetails.
  ///
  /// In en, this message translates to:
  /// **'Change details'**
  String get ahChangeDetails;

  /// No description provided for @ahStartPickups.
  ///
  /// In en, this message translates to:
  /// **'Start pickups'**
  String get ahStartPickups;

  /// No description provided for @ahStopPickups.
  ///
  /// In en, this message translates to:
  /// **'Stop pickups'**
  String get ahStopPickups;

  /// No description provided for @ahPausePickups.
  ///
  /// In en, this message translates to:
  /// **'Pause pickups'**
  String get ahPausePickups;

  /// No description provided for @ahFor.
  ///
  /// In en, this message translates to:
  /// **'For'**
  String get ahFor;

  /// No description provided for @ahDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get ahDates;

  /// No description provided for @ahDetails.
  ///
  /// In en, this message translates to:
  /// **'Details and reason'**
  String get ahDetails;

  /// No description provided for @ahRouteLine.
  ///
  /// In en, this message translates to:
  /// **'{route} · {plate}'**
  String ahRouteLine(String route, String plate);

  /// No description provided for @ahInfo.
  ///
  /// In en, this message translates to:
  /// **'Goes to Arvind Desai (Collection Head). They answer in the web panel; you see the reply in My requests.'**
  String get ahInfo;

  /// No description provided for @ahSend.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get ahSend;

  /// No description provided for @ahWhich.
  ///
  /// In en, this message translates to:
  /// **'Which trip or route?'**
  String get ahWhich;

  /// No description provided for @ahWhichPoint.
  ///
  /// In en, this message translates to:
  /// **'Which pickup point?'**
  String get ahWhichPoint;

  /// No description provided for @ahYourRoutes.
  ///
  /// In en, this message translates to:
  /// **'Your routes'**
  String get ahYourRoutes;

  /// No description provided for @ahYourPoints.
  ///
  /// In en, this message translates to:
  /// **'Your pickup points'**
  String get ahYourPoints;

  /// No description provided for @ahRouteOption.
  ///
  /// In en, this message translates to:
  /// **'{plate} · {vehicle} · {time}'**
  String ahRouteOption(String plate, String vehicle, String time);

  /// No description provided for @ahSheetNote.
  ///
  /// In en, this message translates to:
  /// **'For a pickup point request, this list shows your pickup points instead.'**
  String get ahSheetNote;

  /// No description provided for @ahSheetNotePoint.
  ///
  /// In en, this message translates to:
  /// **'For a trip request, this list shows your routes instead.'**
  String get ahSheetNotePoint;

  /// No description provided for @ahSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get ahSentTitle;

  /// No description provided for @ahSentBody.
  ///
  /// In en, this message translates to:
  /// **'Arvind Desai (Collection Head) answers in the web panel. You see the reply in My requests.'**
  String get ahSentBody;

  /// No description provided for @ahSeeRequests.
  ///
  /// In en, this message translates to:
  /// **'See my requests'**
  String get ahSeeRequests;

  /// No description provided for @ahBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get ahBackHome;

  /// No description provided for @ahDayRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String ahDayRange(String start, String end);

  /// No description provided for @cxTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this trip?'**
  String get cxTitle;

  /// No description provided for @cxBody.
  ///
  /// In en, this message translates to:
  /// **'{route} won’t run on {date}. Its {count} stops go to Unassigned for that day.'**
  String cxBody(String route, String date, int count);

  /// No description provided for @cxKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep the trip'**
  String get cxKeep;

  /// No description provided for @cxConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel trip'**
  String get cxConfirm;

  /// No description provided for @cxDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip Cancelled!'**
  String get cxDoneTitle;

  /// No description provided for @cxDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{route} won’t run on {date}. {driver} is told.'**
  String cxDoneBody(String route, String date, String driver);

  /// No description provided for @cxNote.
  ///
  /// In en, this message translates to:
  /// **'This trip is cancelled ({reason}). Its {count} stops are in Unassigned for {date}.'**
  String cxNote(String reason, int count, String date);

  /// No description provided for @soTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch off the route?'**
  String get soTitle;

  /// No description provided for @soBody.
  ///
  /// In en, this message translates to:
  /// **'{route} makes no trips until you switch it on. Its {count} pickup points go to Unassigned.'**
  String soBody(String route, int count);

  /// No description provided for @soConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch off'**
  String get soConfirm;

  /// No description provided for @soDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Switched Off!'**
  String get soDoneTitle;

  /// No description provided for @soDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{route} makes no trips until you switch it on.'**
  String soDoneBody(String route);

  /// No description provided for @soEmpty.
  ///
  /// In en, this message translates to:
  /// **'Switched off. No trips are made; its {count} pickup points show in Unassigned until you switch it on.'**
  String soEmpty(int count);

  /// No description provided for @soNoTrips.
  ///
  /// In en, this message translates to:
  /// **'No trips'**
  String get soNoTrips;

  /// No description provided for @soSwitchOn.
  ///
  /// In en, this message translates to:
  /// **'Switch on this route'**
  String get soSwitchOn;

  /// No description provided for @onTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch on the route?'**
  String get onTitle;

  /// No description provided for @onBody.
  ///
  /// In en, this message translates to:
  /// **'{route} makes trips again from its pickups. The team is checked first.'**
  String onBody(String route);

  /// No description provided for @onConfirm.
  ///
  /// In en, this message translates to:
  /// **'Switch on'**
  String get onConfirm;

  /// No description provided for @onDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Route Switched On!'**
  String get onDoneTitle;

  /// No description provided for @onDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{route} makes trips again from today.'**
  String onDoneBody(String route);

  /// No description provided for @routesSwitchedOff.
  ///
  /// In en, this message translates to:
  /// **'Switched off'**
  String get routesSwitchedOff;

  /// No description provided for @routesNoTripsUntilOn.
  ///
  /// In en, this message translates to:
  /// **'No trips until switched on'**
  String get routesNoTripsUntilOn;

  /// No description provided for @rdFreqOnCall.
  ///
  /// In en, this message translates to:
  /// **'On call'**
  String get rdFreqOnCall;

  /// No description provided for @rdSchedCalledIn.
  ///
  /// In en, this message translates to:
  /// **'Called in · today {time}'**
  String rdSchedCalledIn(String time);

  /// No description provided for @rdNotUsingAppBody.
  ///
  /// In en, this message translates to:
  /// **'{driver} hasn’t started the trip in the app. The shift started at {time}.'**
  String rdNotUsingAppBody(String driver, String time);

  /// No description provided for @rdMoreStopsPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{and 1 more stop, still pending} other{and {count} more stops, all still pending}}'**
  String rdMoreStopsPending(int count);

  /// No description provided for @rdSchedEveryDayExceptSun.
  ///
  /// In en, this message translates to:
  /// **'Every day except Sun · {time}'**
  String rdSchedEveryDayExceptSun(String time);

  /// No description provided for @dlNoInactiveDrivers.
  ///
  /// In en, this message translates to:
  /// **'No inactive drivers'**
  String get dlNoInactiveDrivers;

  /// No description provided for @dlNoInactiveLabour.
  ///
  /// In en, this message translates to:
  /// **'No inactive labour'**
  String get dlNoInactiveLabour;

  /// No description provided for @dlIdNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'ID number (Aadhaar or Voter ID)'**
  String get dlIdNumberLabel;

  /// No description provided for @dlIdNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1234 5678 9012'**
  String get dlIdNumberHint;

  /// No description provided for @dlProfilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get dlProfilePhotoLabel;

  /// No description provided for @dlIdProofPhoto.
  ///
  /// In en, this message translates to:
  /// **'ID proof photo'**
  String get dlIdProofPhoto;

  /// No description provided for @dlBothOptional.
  ///
  /// In en, this message translates to:
  /// **'Both optional.'**
  String get dlBothOptional;

  /// No description provided for @dlSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dlSave;

  /// No description provided for @dlFullNameLower.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get dlFullNameLower;

  /// No description provided for @dlMobileLower.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get dlMobileLower;

  /// No description provided for @dlIdNumber.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get dlIdNumber;

  /// No description provided for @dlAddedOn.
  ///
  /// In en, this message translates to:
  /// **'Added on'**
  String get dlAddedOn;

  /// No description provided for @dlReactivate.
  ///
  /// In en, this message translates to:
  /// **'Reactivate'**
  String get dlReactivate;

  /// No description provided for @dlDeactivateDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate driver?'**
  String get dlDeactivateDriverTitle;

  /// No description provided for @dlDeactivateLabourTitle.
  ///
  /// In en, this message translates to:
  /// **'Deactivate labour?'**
  String get dlDeactivateLabourTitle;

  /// No description provided for @dlDeactivateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is taken off {warehouse} and can’t be put on its routes. You can reactivate them later.'**
  String dlDeactivateBody(String name, String warehouse);

  /// No description provided for @dlReactivateDriverTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate driver?'**
  String get dlReactivateDriverTitle;

  /// No description provided for @dlReactivateLabourTitle.
  ///
  /// In en, this message translates to:
  /// **'Reactivate labour?'**
  String get dlReactivateLabourTitle;

  /// No description provided for @dlReactivateBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is back at {warehouse} and can be put on its routes again.'**
  String dlReactivateBody(String name, String warehouse);

  /// No description provided for @dlInUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Can’t deactivate yet'**
  String get dlInUseTitle;

  /// No description provided for @dlInUseDriverBody.
  ///
  /// In en, this message translates to:
  /// **'{name} drives {route}. Change the route’s driver first, then deactivate.'**
  String dlInUseDriverBody(String name, String route);

  /// No description provided for @dlInUseLabourBody.
  ///
  /// In en, this message translates to:
  /// **'{name} works on {route}. Change the route’s labour first, then deactivate.'**
  String dlInUseLabourBody(String name, String route);

  /// No description provided for @dlOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dlOk;

  /// No description provided for @dlDriverDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Driver Deactivated!'**
  String get dlDriverDeactivated;

  /// No description provided for @dlLabourDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Labour Deactivated!'**
  String get dlLabourDeactivated;

  /// No description provided for @dlDriverReactivated.
  ///
  /// In en, this message translates to:
  /// **'Driver Reactivated!'**
  String get dlDriverReactivated;

  /// No description provided for @dlLabourReactivated.
  ///
  /// In en, this message translates to:
  /// **'Labour Reactivated!'**
  String get dlLabourReactivated;

  /// No description provided for @dlOffWarehouse.
  ///
  /// In en, this message translates to:
  /// **'{name} is off {warehouse}.'**
  String dlOffWarehouse(String name, String warehouse);

  /// No description provided for @dlBackAtWarehouse.
  ///
  /// In en, this message translates to:
  /// **'{name} is back at {warehouse}.'**
  String dlBackAtWarehouse(String name, String warehouse);

  /// No description provided for @fgTimeClashLine.
  ///
  /// In en, this message translates to:
  /// **'Time clash · gets there about {arrive}, the window ends at {ends}'**
  String fgTimeClashLine(String arrive, String ends);

  /// No description provided for @fgOffRouteLine.
  ///
  /// In en, this message translates to:
  /// **'Off the route · {km} km from {route}'**
  String fgOffRouteLine(String km, String route);

  /// No description provided for @fgScheduleLine.
  ///
  /// In en, this message translates to:
  /// **'Schedule changed · now {schedule}'**
  String fgScheduleLine(String schedule);

  /// No description provided for @fgPausedLine.
  ///
  /// In en, this message translates to:
  /// **'Source paused · {dates}, {reason}'**
  String fgPausedLine(String dates, String reason);

  /// No description provided for @fgNewSourceLine.
  ///
  /// In en, this message translates to:
  /// **'New source, no route yet'**
  String get fgNewSourceLine;

  /// No description provided for @fgExtraLine.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup, no route · {date}'**
  String fgExtraLine(String date);

  /// No description provided for @fgMovedLine.
  ///
  /// In en, this message translates to:
  /// **'Source moved to you · {area}'**
  String fgMovedLine(String area);

  /// No description provided for @fgTimeClash.
  ///
  /// In en, this message translates to:
  /// **'Time clash'**
  String get fgTimeClash;

  /// No description provided for @fgOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Off the route'**
  String get fgOffRoute;

  /// No description provided for @fgScheduleChanged.
  ///
  /// In en, this message translates to:
  /// **'Schedule changed'**
  String get fgScheduleChanged;

  /// No description provided for @fgSourcePaused.
  ///
  /// In en, this message translates to:
  /// **'Source paused'**
  String get fgSourcePaused;

  /// No description provided for @fgNewSource.
  ///
  /// In en, this message translates to:
  /// **'New source, no route'**
  String get fgNewSource;

  /// No description provided for @fgExtraPickup.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup, no route'**
  String get fgExtraPickup;

  /// No description provided for @fgSourceMoved.
  ///
  /// In en, this message translates to:
  /// **'Source moved to you'**
  String get fgSourceMoved;

  /// No description provided for @fgRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get fgRoute;

  /// No description provided for @fgPickupWindow.
  ///
  /// In en, this message translates to:
  /// **'Pickup window'**
  String get fgPickupWindow;

  /// No description provided for @fgTripGetsThere.
  ///
  /// In en, this message translates to:
  /// **'The trip gets there'**
  String get fgTripGetsThere;

  /// No description provided for @fgDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get fgDistance;

  /// No description provided for @fgExtraTime.
  ///
  /// In en, this message translates to:
  /// **'Extra time'**
  String get fgExtraTime;

  /// No description provided for @fgWas.
  ///
  /// In en, this message translates to:
  /// **'Was'**
  String get fgWas;

  /// No description provided for @fgNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get fgNow;

  /// No description provided for @fgFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fgFrom;

  /// No description provided for @fgPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get fgPaused;

  /// No description provided for @fgReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get fgReason;

  /// No description provided for @fgSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get fgSchedule;

  /// No description provided for @fgExtraPickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup'**
  String get fgExtraPickupLabel;

  /// No description provided for @fgWhy.
  ///
  /// In en, this message translates to:
  /// **'Why'**
  String get fgWhy;

  /// No description provided for @fgWhatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get fgWhatToDo;

  /// No description provided for @fgRouteVehicle.
  ///
  /// In en, this message translates to:
  /// **'{route} · {plate}'**
  String fgRouteVehicle(String route, String plate);

  /// No description provided for @fgArrivalLate.
  ///
  /// In en, this message translates to:
  /// **'About {time}, {minutes} min after the window'**
  String fgArrivalLate(String time, String minutes);

  /// No description provided for @fgKmOffRoute.
  ///
  /// In en, this message translates to:
  /// **'{km} km off the route'**
  String fgKmOffRoute(String km);

  /// No description provided for @fgMinutesMore.
  ///
  /// In en, this message translates to:
  /// **'About {minutes} min more on each trip'**
  String fgMinutesMore(String minutes);

  /// No description provided for @fgReasonRenovation.
  ///
  /// In en, this message translates to:
  /// **'Renovation'**
  String get fgReasonRenovation;

  /// No description provided for @fgReasonRenovationLower.
  ///
  /// In en, this message translates to:
  /// **'renovation'**
  String get fgReasonRenovationLower;

  /// No description provided for @fgNoneYet.
  ///
  /// In en, this message translates to:
  /// **'None yet'**
  String get fgNoneYet;

  /// No description provided for @fgExtraValue.
  ///
  /// In en, this message translates to:
  /// **'{date} · {time} · about {kg} kg'**
  String fgExtraValue(String date, String time, String kg);

  /// No description provided for @fgAreaNowYours.
  ///
  /// In en, this message translates to:
  /// **'The {area} area is now yours'**
  String fgAreaNowYours(String area);

  /// No description provided for @fgDoTimeClash.
  ///
  /// In en, this message translates to:
  /// **'Move it earlier in the stop order, or onto a trip that gets there sooner.'**
  String get fgDoTimeClash;

  /// No description provided for @fgDoOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Keep it if the extra time is fine, or move it to a route that passes nearby.'**
  String get fgDoOffRoute;

  /// No description provided for @fgDoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Check that {route} still reaches it on the new days and in the new time.'**
  String fgDoSchedule(String route);

  /// No description provided for @fgDoPaused.
  ///
  /// In en, this message translates to:
  /// **'Nothing to change. It stays off every trip until the pause ends. The next pickup is {date}.'**
  String fgDoPaused(String date);

  /// No description provided for @fgDoNewSource.
  ///
  /// In en, this message translates to:
  /// **'Add it to a route so its pickups get on a trip.'**
  String get fgDoNewSource;

  /// No description provided for @fgDoExtra.
  ///
  /// In en, this message translates to:
  /// **'Add the pickup point to a route so Saturday’s pickup gets on a trip.'**
  String get fgDoExtra;

  /// No description provided for @fgDoMoved.
  ///
  /// In en, this message translates to:
  /// **'Its pickups are yours from now on. Add it to one of your routes.'**
  String get fgDoMoved;

  /// No description provided for @fgClosesByItself.
  ///
  /// In en, this message translates to:
  /// **'This flag closes by itself once it is on a route.'**
  String get fgClosesByItself;

  /// No description provided for @fgOpenRoutes.
  ///
  /// In en, this message translates to:
  /// **'Open your routes'**
  String get fgOpenRoutes;

  /// No description provided for @fgCheckRoute.
  ///
  /// In en, this message translates to:
  /// **'Check the route'**
  String get fgCheckRoute;

  /// No description provided for @fgAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to a route'**
  String get fgAddToRoute;

  /// No description provided for @fgDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Flag marked done'**
  String get fgDoneTitle;

  /// No description provided for @fgDoneBody.
  ///
  /// In en, this message translates to:
  /// **'{name} is off your list'**
  String fgDoneBody(String name);

  /// No description provided for @fgSecondWed.
  ///
  /// In en, this message translates to:
  /// **'2nd Wed of the month · {time}'**
  String fgSecondWed(String time);

  /// No description provided for @cpTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash & Payments'**
  String get cpTitle;

  /// No description provided for @cpCashInHand.
  ///
  /// In en, this message translates to:
  /// **'Cash in hand'**
  String get cpCashInHand;

  /// No description provided for @cpPaidThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Paid this week'**
  String get cpPaidThisWeek;

  /// No description provided for @cpRequestCash.
  ///
  /// In en, this message translates to:
  /// **'Request cash'**
  String get cpRequestCash;

  /// No description provided for @cpPointsToPay.
  ///
  /// In en, this message translates to:
  /// **'Pickup points to pay'**
  String get cpPointsToPay;

  /// No description provided for @cpPointsOwed.
  ///
  /// In en, this message translates to:
  /// **'{count} are owed {amount} in all. Pay them from your cash in hand.'**
  String cpPointsOwed(int count, String amount);

  /// No description provided for @cpSeeWhoToPay.
  ///
  /// In en, this message translates to:
  /// **'See who to pay'**
  String get cpSeeWhoToPay;

  /// No description provided for @cpRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get cpRecentActivity;

  /// No description provided for @cpPaymentsTab.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get cpPaymentsTab;

  /// No description provided for @cpCashRequestsTab.
  ///
  /// In en, this message translates to:
  /// **'Cash requests'**
  String get cpCashRequestsTab;

  /// No description provided for @cpToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get cpToday;

  /// No description provided for @cpWhen.
  ///
  /// In en, this message translates to:
  /// **'{day} • {time}'**
  String cpWhen(String day, String time);

  /// No description provided for @cpWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the office'**
  String get cpWaiting;

  /// No description provided for @cpAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to your cash'**
  String get cpAdded;

  /// No description provided for @cpRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected by the office'**
  String get cpRejected;

  /// No description provided for @cpAskedSent.
  ///
  /// In en, this message translates to:
  /// **'You asked for {asked}. The office sent {sent}.'**
  String cpAskedSent(String asked, String sent);

  /// No description provided for @cpOfficeSaid.
  ///
  /// In en, this message translates to:
  /// **'Office: “{text}”'**
  String cpOfficeSaid(String text);

  /// No description provided for @cpTagCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cpTagCash;

  /// No description provided for @cpTagUpiRef.
  ///
  /// In en, this message translates to:
  /// **'UPI · ref {ref}'**
  String cpTagUpiRef(String ref);

  /// No description provided for @cpTagBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get cpTagBank;

  /// No description provided for @cpAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount (₹)'**
  String get cpAmountLabel;

  /// No description provided for @cpReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get cpReason;

  /// No description provided for @cpMaxChars.
  ///
  /// In en, this message translates to:
  /// **'Max {count} characters'**
  String cpMaxChars(int count);

  /// No description provided for @cpRequestInfo.
  ///
  /// In en, this message translates to:
  /// **'Added to your cash in hand once the office approves.'**
  String get cpRequestInfo;

  /// No description provided for @cpSendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get cpSendRequest;

  /// No description provided for @cpRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get cpRequestSent;

  /// No description provided for @cpRequestSentBody.
  ///
  /// In en, this message translates to:
  /// **'Your request for {amount} is with the office. You see the answer under Cash & Payments.'**
  String cpRequestSentBody(String amount);

  /// No description provided for @cpBackToCash.
  ///
  /// In en, this message translates to:
  /// **'Back to Cash & Payments'**
  String get cpBackToCash;

  /// No description provided for @cpOwedHold.
  ///
  /// In en, this message translates to:
  /// **'{owed} owed · you hold {hold}'**
  String cpOwedHold(String owed, String hold);

  /// No description provided for @cpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or area'**
  String get cpSearchHint;

  /// No description provided for @cpFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cpFilterAll;

  /// No description provided for @cpFilterDueToday.
  ///
  /// In en, this message translates to:
  /// **'Due today'**
  String get cpFilterDueToday;

  /// No description provided for @cpDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String cpDueOn(String date);

  /// No description provided for @cpPointTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} · {type}'**
  String cpPointTitle(String name, String type);

  /// No description provided for @cpPerKg.
  ///
  /// In en, this message translates to:
  /// **'Per kg {amount}'**
  String cpPerKg(String amount);

  /// No description provided for @cpFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed {amount}'**
  String cpFixed(String amount);

  /// No description provided for @cpPerItem.
  ///
  /// In en, this message translates to:
  /// **'Per item'**
  String get cpPerItem;

  /// No description provided for @cpWeeklyOn.
  ///
  /// In en, this message translates to:
  /// **'weekly on {day}'**
  String cpWeeklyOn(String day);

  /// No description provided for @cpMonthly30th.
  ///
  /// In en, this message translates to:
  /// **'monthly on the 30th'**
  String get cpMonthly30th;

  /// No description provided for @cpMonthlyLastDay.
  ///
  /// In en, this message translates to:
  /// **'monthly, last day'**
  String get cpMonthlyLastDay;

  /// No description provided for @cpMethodCash.
  ///
  /// In en, this message translates to:
  /// **'cash'**
  String get cpMethodCash;

  /// No description provided for @cpMethodUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get cpMethodUpi;

  /// No description provided for @cpMethodBank.
  ///
  /// In en, this message translates to:
  /// **'bank'**
  String get cpMethodBank;

  /// No description provided for @cpTermsLine.
  ///
  /// In en, this message translates to:
  /// **'{rate} · {schedule} · {method}'**
  String cpTermsLine(String rate, String schedule, String method);

  /// No description provided for @cpOwed.
  ///
  /// In en, this message translates to:
  /// **'Owed {amount}'**
  String cpOwed(String amount);

  /// No description provided for @cpOwedLastPaid.
  ///
  /// In en, this message translates to:
  /// **'Owed {amount} · last paid {date}'**
  String cpOwedLastPaid(String amount, String date);

  /// No description provided for @cpPayTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay {name}'**
  String cpPayTitle(String name);

  /// No description provided for @cpHowPaid.
  ///
  /// In en, this message translates to:
  /// **'How did you pay?'**
  String get cpHowPaid;

  /// No description provided for @cpChipCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cpChipCash;

  /// No description provided for @cpChipUpi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get cpChipUpi;

  /// No description provided for @cpChipBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get cpChipBank;

  /// No description provided for @cpReference.
  ///
  /// In en, this message translates to:
  /// **'Reference (UPI or bank)'**
  String get cpReference;

  /// No description provided for @cpPaidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get cpPaidOn;

  /// No description provided for @cpTodayDate.
  ///
  /// In en, this message translates to:
  /// **'Today, {date}'**
  String cpTodayDate(String date);

  /// No description provided for @cpReceiptPhoto.
  ///
  /// In en, this message translates to:
  /// **'Receipt photo'**
  String get cpReceiptPhoto;

  /// No description provided for @cpReceiptHint.
  ///
  /// In en, this message translates to:
  /// **'Optional. A photo of the receipt or the UPI screen.'**
  String get cpReceiptHint;

  /// No description provided for @cpNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get cpNote;

  /// No description provided for @cpPayInfo.
  ///
  /// In en, this message translates to:
  /// **'Owed {owed} · you hold {hold}. You can’t pay more than either.'**
  String cpPayInfo(String owed, String hold);

  /// No description provided for @cpRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get cpRecordPayment;

  /// No description provided for @cpPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get cpPaymentRecorded;

  /// No description provided for @cpPaymentRecordedBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} to {name}. You now hold {hold}.'**
  String cpPaymentRecordedBody(String amount, String name, String hold);

  /// No description provided for @cpBackToPoints.
  ///
  /// In en, this message translates to:
  /// **'Back to pickup points to pay'**
  String get cpBackToPoints;

  /// No description provided for @cpNothingToPay.
  ///
  /// In en, this message translates to:
  /// **'Nobody is owed right now.'**
  String get cpNothingToPay;

  /// No description provided for @cpDayName.
  ///
  /// In en, this message translates to:
  /// **'{day, select, 1{Monday} 2{Tuesday} 3{Wednesday} 4{Thursday} 5{Friday} 6{Saturday} 7{Sunday} other{}}'**
  String cpDayName(String day);

  /// No description provided for @arHiredTruck.
  ///
  /// In en, this message translates to:
  /// **'Hired truck'**
  String get arHiredTruck;

  /// No description provided for @arHiredTruckHint.
  ///
  /// In en, this message translates to:
  /// **'Type its number, transporter and driver'**
  String get arHiredTruckHint;

  /// No description provided for @arHiredDetails.
  ///
  /// In en, this message translates to:
  /// **'Hired truck details'**
  String get arHiredDetails;

  /// No description provided for @arTruckNumber.
  ///
  /// In en, this message translates to:
  /// **'Truck number'**
  String get arTruckNumber;

  /// No description provided for @arTruckNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. GJ-05-EE-1002'**
  String get arTruckNumberHint;

  /// No description provided for @arTransporter.
  ///
  /// In en, this message translates to:
  /// **'Transporter'**
  String get arTransporter;

  /// No description provided for @arTransporterHint.
  ///
  /// In en, this message translates to:
  /// **'Transport company name'**
  String get arTransporterHint;

  /// No description provided for @arDriverName.
  ///
  /// In en, this message translates to:
  /// **'Driver’s name'**
  String get arDriverName;

  /// No description provided for @arDriverNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter driver’s name'**
  String get arDriverNameHint;

  /// No description provided for @arDriverPhone.
  ///
  /// In en, this message translates to:
  /// **'Driver’s phone'**
  String get arDriverPhone;

  /// No description provided for @arDriverPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter mobile number'**
  String get arDriverPhoneHint;

  /// No description provided for @arCapacityKg.
  ///
  /// In en, this message translates to:
  /// **'Capacity (KG)'**
  String get arCapacityKg;

  /// No description provided for @arCapacityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3000'**
  String get arCapacityHint;

  /// No description provided for @arHiredNote.
  ///
  /// In en, this message translates to:
  /// **'A hired truck’s driver has no app: they keep a slip and the gate team enters the stops at the warehouse.'**
  String get arHiredNote;

  /// No description provided for @arCapacityValue.
  ///
  /// In en, this message translates to:
  /// **'Capacity {kg} KG'**
  String arCapacityValue(String kg);

  /// No description provided for @vlRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get vlRequired;

  /// No description provided for @vlNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Enter numbers only.'**
  String get vlNumbersOnly;

  /// No description provided for @vlAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount more than 0.'**
  String get vlAmountPositive;

  /// No description provided for @vlWeightPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight more than 0.'**
  String get vlWeightPositive;

  /// No description provided for @vlCapacityPositive.
  ///
  /// In en, this message translates to:
  /// **'Enter a capacity more than 0.'**
  String get vlCapacityPositive;

  /// No description provided for @vlMaxDecimals.
  ///
  /// In en, this message translates to:
  /// **'Use up to {count} decimal places.'**
  String vlMaxDecimals(int count);

  /// No description provided for @vlMaxAmount.
  ///
  /// In en, this message translates to:
  /// **'Can’t be more than {amount}.'**
  String vlMaxAmount(String amount);

  /// No description provided for @vlIdNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a 12-digit Aadhaar number or a valid Voter ID.'**
  String get vlIdNumber;

  /// No description provided for @vlVehicleNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid vehicle number, e.g. GJ-05-EE-1002.'**
  String get vlVehicleNumber;
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
