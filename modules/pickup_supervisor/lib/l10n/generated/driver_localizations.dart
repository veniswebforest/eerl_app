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
  /// **'KG'**
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
  /// **'Active and upcoming pickup routes for today'**
  String get supervisorTripsSubtitle;

  /// No description provided for @supervisorAdajanMorning.
  ///
  /// In en, this message translates to:
  /// **'Adajan Morning'**
  String get supervisorAdajanMorning;

  /// No description provided for @supervisorVikramProgress.
  ///
  /// In en, this message translates to:
  /// **'Vikram Singh · 3 of 8 collected'**
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
  /// **'Amit Patel · 0 of 8 recorded in the app'**
  String get supervisorAmitProgress;

  /// No description provided for @supervisorDriverNotSetUp.
  ///
  /// In en, this message translates to:
  /// **'Driver hasn’t set up app'**
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
  /// **'Unassigned Sources'**
  String get supervisorUnassignedSources;

  /// No description provided for @supervisorManageUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Manage New Unassigned Sources'**
  String get supervisorManageUnassigned;

  /// No description provided for @supervisorViewSource.
  ///
  /// In en, this message translates to:
  /// **'View Source'**
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
  /// **'From your drivers and pickup points'**
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
  /// **'PET Bottles 50 kg → 60 kg. Suresh Kumar: “The scale photo shows 60 kg.”'**
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
  /// **'Sat 25 Oct, 10 am – 12 pm · Medium · fits Adajan Morning'**
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
  /// **'Hotel Rajdhani’s record now shows PET Bottles 60 kg. Suresh Kumar and the pickup point are told.'**
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

  /// No description provided for @flagTimeClash.
  ///
  /// In en, this message translates to:
  /// **'Time clash'**
  String get flagTimeClash;

  /// No description provided for @flagHotelRajdhaniTime.
  ///
  /// In en, this message translates to:
  /// **'Hotel Rajdhani · 1:30 pm vs 9–11 am'**
  String get flagHotelRajdhaniTime;

  /// No description provided for @flagOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Off the route'**
  String get flagOffRoute;

  /// No description provided for @flagSunriseOffRoute.
  ///
  /// In en, this message translates to:
  /// **'Sunrise School · 4.2 km off route'**
  String get flagSunriseOffRoute;

  /// No description provided for @flagScheduleChanged.
  ///
  /// In en, this message translates to:
  /// **'Schedule changed'**
  String get flagScheduleChanged;

  /// No description provided for @flagAdajanTextileSorted.
  ///
  /// In en, this message translates to:
  /// **'Adajan Textile Mill · Sorted'**
  String get flagAdajanTextileSorted;

  /// No description provided for @flagSourcePaused.
  ///
  /// In en, this message translates to:
  /// **'Source paused'**
  String get flagSourcePaused;

  /// No description provided for @flagClosedForDiwali.
  ///
  /// In en, this message translates to:
  /// **'Closed for Diwali'**
  String get flagClosedForDiwali;

  /// No description provided for @flagNewSourceNoRoute.
  ///
  /// In en, this message translates to:
  /// **'New source, no route'**
  String get flagNewSourceNoRoute;

  /// No description provided for @flagAbcTextileMills.
  ///
  /// In en, this message translates to:
  /// **'ABC Textile Mills'**
  String get flagAbcTextileMills;

  /// No description provided for @flagExtraPickupNoRoute.
  ///
  /// In en, this message translates to:
  /// **'Extra Pickup, no route'**
  String get flagExtraPickupNoRoute;

  /// No description provided for @flagExtraPickupNoRouteDetail.
  ///
  /// In en, this message translates to:
  /// **'Extra pickup, no route'**
  String get flagExtraPickupNoRouteDetail;

  /// No description provided for @flagShreeSaiSorted.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy · Sorted'**
  String get flagShreeSaiSorted;

  /// No description provided for @flagSourceMovedToYou.
  ///
  /// In en, this message translates to:
  /// **'Source moved to you'**
  String get flagSourceMovedToYou;

  /// No description provided for @flagRkTrading.
  ///
  /// In en, this message translates to:
  /// **'R.K trading and co.'**
  String get flagRkTrading;

  /// No description provided for @flagNothingToCheck.
  ///
  /// In en, this message translates to:
  /// **'Nothing to check!'**
  String get flagNothingToCheck;

  /// No description provided for @flagOctober.
  ///
  /// In en, this message translates to:
  /// **'october'**
  String get flagOctober;

  /// No description provided for @flagNothingToCheckSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any new notifications or pending action items right now.'**
  String get flagNothingToCheckSubtitle;

  /// No description provided for @flagShreeSaiDairy.
  ///
  /// In en, this message translates to:
  /// **'Shree Sai Dairy'**
  String get flagShreeSaiDairy;

  /// No description provided for @flagShreeSaiAddress.
  ///
  /// In en, this message translates to:
  /// **'U 9, 10, Siddhgiri Tower, B/H Navyug...'**
  String get flagShreeSaiAddress;

  /// No description provided for @flagWas.
  ///
  /// In en, this message translates to:
  /// **'Was'**
  String get flagWas;

  /// No description provided for @flagOldSchedule.
  ///
  /// In en, this message translates to:
  /// **'Mon, Thu · 8–10 am'**
  String get flagOldSchedule;

  /// No description provided for @flagNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get flagNow;

  /// No description provided for @flagNewSchedule.
  ///
  /// In en, this message translates to:
  /// **'Mon, Wed · 9–11 am'**
  String get flagNewSchedule;

  /// No description provided for @flagFromMon2Nov.
  ///
  /// In en, this message translates to:
  /// **'From : Mon 2 Nov'**
  String get flagFromMon2Nov;

  /// No description provided for @flagPausedDates.
  ///
  /// In en, this message translates to:
  /// **'Paused 20–26 Oct'**
  String get flagPausedDates;

  /// No description provided for @flagReasonClosedForDiwali.
  ///
  /// In en, this message translates to:
  /// **'Reason: Closed for Diwali'**
  String get flagReasonClosedForDiwali;

  /// No description provided for @flagMovedFromVesu.
  ///
  /// In en, this message translates to:
  /// **'Moved from Vesu area'**
  String get flagMovedFromVesu;

  /// No description provided for @flagCheckRoute.
  ///
  /// In en, this message translates to:
  /// **'Check route'**
  String get flagCheckRoute;

  /// No description provided for @flagAddToRoute.
  ///
  /// In en, this message translates to:
  /// **'Add to route'**
  String get flagAddToRoute;

  /// No description provided for @flagMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get flagMarkDone;

  /// No description provided for @flagDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get flagDone;

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
