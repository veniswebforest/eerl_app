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
  String collectedCount(int count) {
    return 'Collected ($count)';
  }

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

  @override
  String get requestSent => 'Request sent';

  @override
  String get toYourSupervisor => 'to your supervisor';

  @override
  String get correctionRequestSummary =>
      'Hotel Rajdhani · weight · 50 kg → 60 kg';

  @override
  String get whatHappensNext => 'WHAT HAPPENS NEXT';

  @override
  String get supervisorChecksPhotos =>
      'Kiran Shah checks it against your photos';

  @override
  String get correctionRequestedUntil =>
      'The stop shows “Correction requested” until then';

  @override
  String get correctionNotification =>
      'You get a notification when it is corrected';

  @override
  String get backToMyStops => 'Back to my stops';

  @override
  String get backToHome => 'Back to home';

  @override
  String get stopTripPosition => 'Stop 6 of 7 · Trip 1';

  @override
  String get personAtPickupPoint => 'Person at the pickup point';

  @override
  String get rakeshShah => 'Rakesh Shah';

  @override
  String get storeManager => 'Store manager';

  @override
  String get pickupContactPhone => '+91 98765 43214';

  @override
  String get nothingToCollectWeight => 'Nothing to collect (0 kg)';

  @override
  String get nothingToCollect => 'Nothing to collect';

  @override
  String get abcStopSixOfSeven => 'ABC Textile Mills · Stop 6 of 7';

  @override
  String get savedAsZeroKgMessage => 'This stop will be saved as 0 kg.';

  @override
  String get whyNothingCollected => 'Why was nothing collected?';

  @override
  String get reasonClosed => 'Closed';

  @override
  String get reasonRefused => 'Refused to give';

  @override
  String get reasonNotReachable => 'Not reachable';

  @override
  String get reasonVehicleFull => 'Vehicle full';

  @override
  String get photoOptional => 'Photo (optional)';

  @override
  String get noteForSupervisorOptional => 'Note for supervisor (optional)';

  @override
  String get typeANote => 'Type a note…';

  @override
  String get holdToRecordVoiceNote => 'Hold to record a voice note';

  @override
  String get upToOneMinute => 'Up to 1 minute';

  @override
  String get voiceNoteZeroTime => '0:00';

  @override
  String get recordingVoiceNote => 'Recording voice note…';

  @override
  String get voiceNoteRecorded => 'Voice note recorded';

  @override
  String get playVoiceNote => 'Play voice note';

  @override
  String get pauseVoiceNote => 'Pause voice note';

  @override
  String get removeVoiceNote => 'Remove voice note';

  @override
  String get voiceNotePlaybackFailed =>
      'Could not play the voice note. Please try again.';

  @override
  String get microphonePermissionRequired =>
      'Microphone permission is required to record a voice note.';

  @override
  String get voiceNoteRecordingFailed =>
      'Could not record the voice note. Please try again.';

  @override
  String get locationMatched => 'Location matched';

  @override
  String get locationNotMatched => 'Location not matched';

  @override
  String get sortedStopSixOfSeven => 'Stop 6 of 7 · Sorted';

  @override
  String get mixedStopSevenOfSeven => 'Stop 7 of 7 · Mixed';

  @override
  String get recordedLaterWarning =>
      'Recorded later: you are not at this stop now. The supervisor and the gate see this note.';

  @override
  String get saveAsZeroKg => 'Save as 0 kg';

  @override
  String get orderedPickupStops => 'Ordered Pickup Stops';

  @override
  String get startYourCollections => 'Start your collections';

  @override
  String get searchHere => 'Search Here...';

  @override
  String pendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get yashTextileHub => 'Yash Textile Hub';

  @override
  String get anjanaFarmAreaSurat => 'Anjana Farm Area, Surat';

  @override
  String get collectionWindowNineToTen => '09:00 AM - 10:00 AM';

  @override
  String get materialSortedLabel => 'Material : Sorted';

  @override
  String get findingYourLocationStatus => 'Finding your location…';

  @override
  String get findingYourLocation => 'Finding your location';

  @override
  String get findingLocationMessage =>
      'Stand near the pickup point. This takes a few seconds.';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get locationDetected => 'Location detected';

  @override
  String get notHere => 'Not Here';

  @override
  String get startCollection => 'Start collection';

  @override
  String stopsNearby(int count) {
    return '$count stops nearby';
  }

  @override
  String get whichStopAreYouAt => 'Which stop are you at?';

  @override
  String get twoStopsCloseMessage => 'Two stops on your trip are close to you.';

  @override
  String get distanceStopSeven => '40 m away · Stop 7';

  @override
  String get distanceAlreadyCollected => '85 m away · already collected';

  @override
  String get continueAction => 'Continue';

  @override
  String get noStopFoundHere => 'No stop found here';

  @override
  String get notAtTripStop => 'You’re not at a stop on this trip';

  @override
  String get notAtStopMessage =>
      'Move closer and try again, choose the stop yourself, or leave it for the gate team.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get chooseStopMyself => 'Choose the stop myself';

  @override
  String get gateTeamWillEnter => 'Gate team will enter';

  @override
  String get locationIsOff => 'Location is off';

  @override
  String get turnOnLocation => 'Turn on location';

  @override
  String get locationOffMessage =>
      'The app finds your stop from your location. Turn it on to record pickups.';

  @override
  String get shreeSaiStopSeven => 'Shree Sai Dairy · Stop 7 of 7';

  @override
  String get gateTeamEntryMessage =>
      'The back office enters this pickup at the warehouse gate.';

  @override
  String get weightYouNotedOptional => 'Weight you noted (optional)';

  @override
  String get aboutThreeHundred => 'about 300';

  @override
  String get gateWeightHelp =>
      'A rough figure helps the gate team. They weigh it again at the gate.';

  @override
  String get markForGateTeam => 'Mark for the gate team';

  @override
  String get nextPickupSavedMessage =>
      'ABC Textile Mills · 540 kg + 25 pcs saved.';

  @override
  String get lastPickupSavedMessage => 'Shree Sai Dairy · 300 kg saved.';

  @override
  String get nextStopSevenOfSeven => 'NEXT STOP · 7 OF 7';

  @override
  String get nextStopDistance => 'L.P Savani Road, Surat · 1.2 km';

  @override
  String get goToNextStop => 'Go to next stop';

  @override
  String get allTripStopsDone => 'ALL 7 STOPS OF TRIP 1 DONE';

  @override
  String get takeLoadToWarehouse => 'Take the load to Magdalla Warehouse';

  @override
  String get vehicleLoadTotal => '1,260 kg + 25 pcs on the vehicle';

  @override
  String get warehouseDistance => 'Magdalla, Surat · 6.4 km';

  @override
  String get viewTripSummary => 'View trip summary';

  @override
  String get tripOneSummary => 'Trip 1 summary';

  @override
  String get allStopsDone => 'All stops done';

  @override
  String get tripCollectedTotal => '1,260 kg + 25 pcs';

  @override
  String get mixedWaste => 'Mixed waste';

  @override
  String get weight635Kg => '635 kg';

  @override
  String get weight270Kg => '270 kg';

  @override
  String get weight85Kg => '85 kg';

  @override
  String get count25Pcs => '25 pcs';

  @override
  String get dropAt => 'DROP AT';

  @override
  String get warehouseAddressDistance => 'Magdalla Port Road, Surat · 6.4 km';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get callWarehouse => 'Call warehouse';

  @override
  String get notCollectedTwo => 'Not collected (2)';

  @override
  String get closedForStockTaking => 'Closed for stock-taking';

  @override
  String get handOverAtWarehouse => 'Hand over at the warehouse';

  @override
  String get warehouseGateInstruction =>
      'Tap at the warehouse gate. You enter the number of bags; the Warehouse Incharge weighs the vehicle.';

  @override
  String get handOverTripOne => 'Hand over · Trip 1';

  @override
  String get yourCountFromStops => 'Your count (from the stops)';

  @override
  String get numberOfBags => 'Number of bags';

  @override
  String get bagsUnit => 'BAGS';

  @override
  String get bagsCount => '42';

  @override
  String get bagsHelp =>
      'Count the bags you unload. Loose items such as e-waste are counted in pieces.';

  @override
  String get handOver => 'Hand over';

  @override
  String get warehouseWeighInstruction =>
      'The Warehouse Incharge checks the load and weighs the vehicle on the weighbridge. You see the weight here when they save it.';

  @override
  String get tripAtWarehouse => 'Trip 1 · at the warehouse';

  @override
  String get waitingStatus => 'Waiting';

  @override
  String get vehicleAtWarehouseSince =>
      'GJ-XX-1234 · at Magdalla since 11:20 am';

  @override
  String get youHandedOver => 'You handed over';

  @override
  String get handedOverTotal => '1,260 kg + 25 pcs · 42 bags';

  @override
  String get waitingWarehouseInstruction =>
      'Handed over at 11:20 am. The Warehouse Incharge is weighing the vehicle; the weighbridge weight shows here when they save it.';

  @override
  String get tripReceived => 'Trip 1 · received';

  @override
  String get receivedStatus => 'Received';

  @override
  String get vehicleAtWarehouse => 'GJ-XX-1234 · Magdalla Warehouse';

  @override
  String get weighbridgeEnteredByWarehouse =>
      'Weighbridge · entered by the warehouse';

  @override
  String get warehouseReceivedTotal => '1,240 kg net + 25 pcs';

  @override
  String get withLoadGross => 'With load (gross)';

  @override
  String get weight8940Kg => '8,940 kg';

  @override
  String get emptyVehicle => 'Empty vehicle';

  @override
  String get weight7700Kg => '7,700 kg';

  @override
  String get netWeight => 'Net weight';

  @override
  String get weight1240Kg => '1,240 kg';

  @override
  String get bagsReceived => 'Bags received';

  @override
  String get eWasteCounted => 'E-Waste (counted)';

  @override
  String get yourCountVsWeighbridge => 'Your count vs the weighbridge';

  @override
  String get yourCount => 'Your count';

  @override
  String get weight1260Kg => '1,260 kg';

  @override
  String get weighbridgeNet => 'Weighbridge net';

  @override
  String get difference => 'Difference';

  @override
  String get weightDifference => '−20 kg (1.6% less)';

  @override
  String get receivedWarehouseInstruction =>
      'Received at 11:42 am by Ramesh Patel, Warehouse Incharge. If the difference looks wrong, raise an issue.';
}
