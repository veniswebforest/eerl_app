// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'driver_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DriverLocalizationsEn extends DriverLocalizations {
  DriverLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get homeDateAndZone => 'Wed, 22 Jul · Surat Zone';

  @override
  String get warehouseName => 'Magdalla Warehouse';

  @override
  String get onlineStatus => 'You’re Online';

  @override
  String pendingCollections(int count) {
    return '$count collection Pending';
  }

  @override
  String get syncNow => 'Sync Now';

  @override
  String get todaysSummary => 'Todays Summary';

  @override
  String get pendingStops => 'Pending Stops';

  @override
  String get pendingStopsCount => '05';

  @override
  String get collected => 'Collected';

  @override
  String get collectedCount => '03';

  @override
  String get todaysTrip => 'Today’s Trip';

  @override
  String get vehicleRegistration => 'GJ-XX-1234';

  @override
  String stopsCompleted(int completed, int total) {
    return '$completed of $total stops completed';
  }

  @override
  String get tripProgress => '37%';

  @override
  String get completedTripProgress => '100%';

  @override
  String get openMyStops => 'Open my stops';

  @override
  String get quickAction => 'Quick Action';

  @override
  String get raiseAnIssue => 'Raise an Issue';

  @override
  String get issueDescription => 'Report a vehicle, source, or team issue';

  @override
  String get reportIssue => 'Report Issue';

  @override
  String get homeTab => 'Home';

  @override
  String get stopsTab => 'My Stops';

  @override
  String get issuesTab => 'Issues';

  @override
  String get profileTab => 'Profile';

  @override
  String get driverPageUnavailable => 'This driver page is not available yet';

  @override
  String get pendingPickupStops => 'Pending Pickup Stops';

  @override
  String stopCardTitle(String name, String material) {
    return '$name · $material';
  }

  @override
  String get abcTextileMills => 'ABC Textile Mills';

  @override
  String get shreeSaiDairy => 'Shree Sai Dairy';

  @override
  String get xyzTextileMills => 'XYZ Textile Mills';

  @override
  String get sortedMaterial => 'Sorted';

  @override
  String get mixedMaterial => 'Mixed';

  @override
  String get industrialAreaSurat => 'Industrial Area, Surat';

  @override
  String get lpSavaniRoadSurat => 'L.P Savani Road, Surat';

  @override
  String get pickupSchedule => 'Thu · 8:00–10:00 am';

  @override
  String get noSchedule => '--';

  @override
  String get pendingStatus => 'Pending';

  @override
  String get skippedStatus => 'Skipped';

  @override
  String get stopDetail => 'Stop Detail';

  @override
  String get driverPhoneNumber => '+91 98765 432145';

  @override
  String get call => 'Call';

  @override
  String get requestInformation => 'Request Information';

  @override
  String get address => 'Address';

  @override
  String get pickupAddress =>
      'U 9, 10, Siddhgiri Tower, B/H Navyug College Rd, Navyug Society, Sangana Society, Adajan, Surat, Gujarat 395009';

  @override
  String get schedule => 'Schedule';

  @override
  String get material => 'Material';

  @override
  String get materialItems => 'Milk Pouch, Card Board';

  @override
  String get expectedWeight => 'Expected Weight';

  @override
  String get expectedWeightValue => '450 KG';

  @override
  String get requestStatus => 'Request Status';

  @override
  String get description => 'Description';

  @override
  String get pickupDescription =>
      'I’ve attached a Google Maps location link for easy navigation. Please ensure that any waste photos uploaded are clear and easy to read.';

  @override
  String get startPickup => 'Start Pickup';

  @override
  String get mixedDriverPhoneNumber => '+91 1234567890';

  @override
  String get mixedExpectedWeightValue => '200 KG';

  @override
  String get sortedWasteForm => 'Sorted Waste Form';

  @override
  String get captureMaterialScalePhoto => 'Capture Material & Scale Photo';

  @override
  String get petBottles => 'PET Bottles';

  @override
  String get hdpeRigid => 'HDPE Rigid';

  @override
  String get eWaste => 'E-Waste';

  @override
  String get kgUnit => 'KG';

  @override
  String get pcsUnit => 'PCS';

  @override
  String get collectedLabel => 'Collected';

  @override
  String get exampleWeight => 'ex 123.00';

  @override
  String get capturePhoto => 'Capture Photo';

  @override
  String get petCollectedWeight => '270.00';

  @override
  String get hdpeCollectedWeight => '270.00';

  @override
  String get eWasteCollectedCount => '25';

  @override
  String get savePickup => 'Save Pickup';

  @override
  String get mixedWasteForm => 'Mixed Waste Form';

  @override
  String get enterWeightKg => 'Enter Weight (KG)';

  @override
  String get mixedWeightValue => '300.00';

  @override
  String get materialAndScalePhoto => 'Material & Material & Scale Photo';

  @override
  String get supportedPhotoFormats => 'Supported: JPG, PNG (Max 5MB).';

  @override
  String get sortedPickupForm => 'Sorted Pickup Form';

  @override
  String get successWeightValue => '240.51';

  @override
  String get materialAndWeighbridgePhoto => 'Material & Weighbridge Photo';

  @override
  String get pickupRecorded => 'Pickup Recorded';

  @override
  String get successfully => 'Successfully!';

  @override
  String get pickupSuccessMessage =>
      'The pickup has been successfully saved. The status will be updated in your trip.';

  @override
  String get backToList => 'Back to List';

  @override
  String get selectProblemsStruggling => 'Select Problems You Struggling With';

  @override
  String get vehicleBreakdown => 'Vehicle breakdown';

  @override
  String get accident => 'Accident';

  @override
  String get sourceProblem => 'Source problem';

  @override
  String get otherIssue => 'Other';

  @override
  String get remarks => 'Remarks';

  @override
  String get addYourRemarks => 'Add your remarks...';

  @override
  String get max150Characters => 'Max 150 Characters';

  @override
  String get submitIssue => 'Submit Issue';

  @override
  String get yourPickupSupervisor => 'Your Pickup Supervisor';

  @override
  String get supervisorName => 'Kiran Shah';

  @override
  String get message => 'Message';

  @override
  String get collectedToday => 'Collected today';

  @override
  String get collectedWeight420 => '420 kg so far';

  @override
  String get collectedWeightZero => '0 kg';

  @override
  String get zeroKg => '0 kg';

  @override
  String get cancelled => 'Cancelled';

  @override
  String todaysTripsCount(int count) {
    return 'Today’s Trips ($count)';
  }

  @override
  String get todaysTrips => 'Today’s Trips';

  @override
  String get tripMorning => 'Trip 1 · Morning';

  @override
  String get tripAfternoon => 'Trip 2 · Afternoon';

  @override
  String get morningTripTime => '7:00 – 11:00 am · 7 stops';

  @override
  String get afternoonTripTime => '2:00 – 5:00 pm · 6 stops';

  @override
  String get afternoonStartTime => '2:00 pm';

  @override
  String get onTheWay => 'On the way';

  @override
  String startsAt(String time) {
    return 'Starts $time';
  }

  @override
  String get delivered => 'Delivered';

  @override
  String get vehicleCrew => 'GJ-XX-1234 · Suresh, Mahesh';

  @override
  String get dropMagdalla => 'Drop at Magdalla Warehouse';

  @override
  String get dropSachin => 'Drop at Sachin Warehouse';

  @override
  String get collectedOnTrip => 'Collected on this trip';

  @override
  String get weight420Kg => '420 kg';

  @override
  String get weight180Kg => '180 kg';

  @override
  String stopsDone(int completed, int total) {
    return '$completed of $total stops done';
  }

  @override
  String seeAllStops(int count) {
    return 'See all $count stops';
  }

  @override
  String nextStopOnTrip(int trip) {
    return 'Next stop on Trip $trip';
  }

  @override
  String afterThat(int count) {
    return 'After that ($count)';
  }

  @override
  String get laterToday => 'Later today';

  @override
  String get earlierToday => 'Earlier today';

  @override
  String stopPosition(int current, int total) {
    return 'Stop $current of $total';
  }

  @override
  String get nextStop => 'Next stop';

  @override
  String get enterCollection => 'Enter collection';

  @override
  String opensAfterStop(int stop) {
    return 'Opens after stop $stop';
  }

  @override
  String unlockAfterStop(int stop) {
    return 'Unlocks when stop $stop is done, or when you reach this stop (GPS). Tap to check your location.';
  }

  @override
  String get handedOverWeight => 'Handed over · 1,240 kg net';

  @override
  String get royalResidency => 'Royal Residency';

  @override
  String get shantiNagar => 'Shanti Nagar';

  @override
  String get ghodDodRoadSurat => 'Ghod Dod Road, Surat';

  @override
  String get citylightRoadSurat => 'Citylight Road, Surat';

  @override
  String get rakeshStoreManager => 'Rakesh Shah · Store manager';

  @override
  String get maheshOwner => 'Mahesh Desai · Owner';

  @override
  String get priyaSecretary => 'Priya Patel · Secretary';

  @override
  String get meenaSecretary => 'Meena Desai · Secretary';

  @override
  String get pickupSchedule9to11 => 'Thu · 9:00–11:00 am';

  @override
  String get pickupSchedule3to330 => 'Thu · 3:00–3:30 pm';

  @override
  String get pickupSchedule330to4 => 'Thu · 3:30–4:00 pm';

  @override
  String get noTripToday => 'No trip today';

  @override
  String get noTripMessage =>
      'Kiran Shah hasn’t put you on a trip today. You’ll get a message when one is added.';

  @override
  String get tripOneStops => 'Trip 1 stops';

  @override
  String get morningTripWindow => 'Morning · 7:00 – 11:00 am';

  @override
  String get fiveOfSevenDone => '5 of 7 done';

  @override
  String stillToCollect(int count) {
    return 'Still to collect ($count)';
  }

  @override
  String doneStops(int count) {
    return 'Done ($count)';
  }

  @override
  String stopNumber(int number) {
    return 'Stop $number';
  }

  @override
  String get hotelRajdhani => 'Hotel Rajdhani';

  @override
  String get greenParkSociety => 'Green Park Society';

  @override
  String get navratriGroundEvent => 'Navratri Ground (event)';

  @override
  String get cityBakery => 'City Bakery';

  @override
  String get hotelRajdhaniWeight => '85 kg';

  @override
  String get greenParkWeight => '120 kg';

  @override
  String get navratriGroundWeight => '215 kg';

  @override
  String get noMaterialToday => 'No material today';

  @override
  String get cancelledBySource => 'Cancelled by source';

  @override
  String get stockTakingReason => 'Closed for stock-taking';

  @override
  String get unlockStopMessage =>
      'Unlocks when stop 6 is done, or when you reach this stop (GPS). Tap to check your location.';

  @override
  String get stopTwoCollection => 'Stop 2 · collection';

  @override
  String get savedAt => 'Saved at 7:52 am · Thu 22 Jul';

  @override
  String get whatYouSaved => 'What you saved';

  @override
  String get cardboard => 'Cardboard';

  @override
  String get petBottlesWeight => '50 kg';

  @override
  String get cardboardWeight => '35 kg';

  @override
  String get photosMaterialScale => 'Photos (material and scale)';

  @override
  String get askSupervisorToCorrect => 'Ask supervisor to correct';

  @override
  String get savedCollectionReadonlyMessage =>
      'You can only view a saved collection. If something is wrong, ask your supervisor: they check it against the photos and correct it.';

  @override
  String get askToCorrect => 'Ask to correct';

  @override
  String get whatIsWrongAtStop => 'What is wrong? Hotel Rajdhani · stop 2';

  @override
  String get correctionWeight => 'Weight';

  @override
  String get correctionItem => 'Item';

  @override
  String get correctionPhoto => 'Photo';

  @override
  String get correctionOther => 'Other';

  @override
  String get rightValueAndNote => 'Right value and note';

  @override
  String get correctionNoteExample =>
      'Example: PET Bottles was 60 kg, not 50 kg. The scale photo shows 60 kg.';

  @override
  String get sendToSupervisor => 'Send to supervisor';
}
