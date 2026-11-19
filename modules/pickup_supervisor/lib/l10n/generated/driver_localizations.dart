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
