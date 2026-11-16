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
}
