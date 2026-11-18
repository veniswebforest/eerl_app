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
