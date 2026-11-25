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

  @override
  String get supervisorWelcomeBack => 'Welcome back';

  @override
  String get supervisorHeaderSubtitle => 'Thu 22 Oct 2026 · Adajan, Vesu, Pal';

  @override
  String get supervisorOnline => 'You’re Online';

  @override
  String get supervisorLastSynced => 'Last synced 2 min ago';

  @override
  String get supervisorSyncNow => 'Sync Now';

  @override
  String get supervisorNeedsAttention => 'Needs your attention';

  @override
  String get supervisorAttentionSubtitle =>
      'Approve, sort out or check these first';

  @override
  String get supervisorApprovals => 'Approvals';

  @override
  String get supervisorIssues => 'Issues';

  @override
  String get supervisorMyRequests => 'My requests';

  @override
  String get supervisorFlags => 'Flags';

  @override
  String get supervisorCollectionSummary => 'Collection summary';

  @override
  String get supervisorToday => 'Today';

  @override
  String get supervisorYesterday => 'Yesterday';

  @override
  String get supervisorWeek => 'Week';

  @override
  String get supervisorMonth => 'Month';

  @override
  String get supervisorCollectedToday => 'Collected today · 12 of 16 stops';

  @override
  String get supervisorCollectedTotal => '320 kg + 125 pcs';

  @override
  String get supervisorCollected => 'Collected';

  @override
  String get supervisorKg => '0 kg';

  @override
  String get supervisorMissed => 'Missed';

  @override
  String get supervisorCancelled => 'Cancelled';

  @override
  String get supervisorTripsClosed => 'Trips closed';

  @override
  String get supervisorViewFullReport => 'View full report';

  @override
  String get supervisorTodaysTrips => 'Today’s trips';

  @override
  String get supervisorTripsSubtitle => '5 trips today · the next 2 are below';

  @override
  String get supervisorAdajanMorning => 'Adajan Morning';

  @override
  String get supervisorVikramProgress => 'Vikram Singh  •  3 of 8 collected';

  @override
  String get supervisorOwnVehicle => 'Own vehicle';

  @override
  String get supervisorDailyWeekly => 'Daily 5 · Weekly 3';

  @override
  String get supervisorCallDriver => 'Call driver';

  @override
  String get supervisorPalGamMorning => 'Pal Gam Morning';

  @override
  String get supervisorAmitProgress =>
      'Amit Patel  •  0 of 8 recorded in the app';

  @override
  String get supervisorDriverNotSetUp => 'Driver not using app';

  @override
  String get supervisorSeeTripsPlan => 'See trips plan';

  @override
  String get supervisorPickupPoints => 'My pickup points';

  @override
  String get supervisorPickupPointsSubtitle =>
      '79 in Adajan, Vesu, Pal · by category';

  @override
  String get supervisorDaily => 'Daily';

  @override
  String get supervisorWeekly => 'Weekly';

  @override
  String get supervisorBiWeekly => 'Bi-weekly';

  @override
  String get supervisorMonthly => 'Monthly';

  @override
  String get supervisorOnCall => 'On call';

  @override
  String get supervisorQuickActions => 'Quick Actions';

  @override
  String get supervisorUnassignedSources => 'Unassigned sources';

  @override
  String get supervisorManageUnassigned => 'Pickup points with no route yet';

  @override
  String get supervisorViewSource => 'View sources';

  @override
  String get supervisorExtraPickupRequests => 'Extra pickups requests';

  @override
  String get supervisorManageExtraPickup => 'Manage Extra Pickup Sources';

  @override
  String get supervisorViewPickups => 'View Pickups';

  @override
  String get supervisorAskCollectionHead => 'Ask the Collection Head';

  @override
  String get supervisorAskCollectionHeadSubtitle =>
      'Vehicle, labour or pickup point changes';

  @override
  String get supervisorNewRequest => 'New request';

  @override
  String get supervisorSuggestions => 'Suggestions';

  @override
  String get supervisorSuggestionsSubtitle =>
      'Ways to save distance and time (concept)';

  @override
  String get supervisorSeeSuggestions => 'See suggestions';

  @override
  String get supervisorHome => 'Home';

  @override
  String get attentionApprovalRequests => 'Approval requests';

  @override
  String get attentionApprovalSubtitle =>
      'From your drivers and IEC Executives';

  @override
  String get attentionToApproveCount => 'To approve 3';

  @override
  String get attentionDoneCount => 'Done 12';

  @override
  String get attentionCorrectionFromDriver => 'Correction · from driver';

  @override
  String get attentionWaiting => 'Waiting';

  @override
  String get attentionHotelRajdhaniStop =>
      'Hotel Rajdhani · Adajan Morning, stop 2';

  @override
  String get attentionDriverCorrectionDetail =>
      'PET Bottles 50 kg → 60 kg. Vikram Singh: “The scale photo shows 60 kg.”';

  @override
  String get attentionSentToday => 'Sent today, 10:05 am';

  @override
  String get attentionDecline => 'Decline';

  @override
  String get attentionApprove => 'Approve';

  @override
  String get attentionExtraPickup => 'Extra pickup';

  @override
  String get attentionAbcPlastic => 'ABC Plastic Manufacture';

  @override
  String get attentionExtraPickupDetail =>
      'Sat 25 Oct, 10 am – 12 pm · about 40 kg · fits Adajan Morning';

  @override
  String get attentionSent21Oct => 'Sent 21 Oct';

  @override
  String get attentionCorrectionFromPickupPoint =>
      'Correction · from pickup point';

  @override
  String get attentionGreenParkSociety => 'Green Park Society';

  @override
  String get attentionPickupPointCorrectionDetail =>
      'Cardboard 20 kg → 25 kg on the 19 Oct pickup';

  @override
  String get attentionSent20Oct => 'Sent 20 Oct';

  @override
  String get attentionCorrectionApproved => 'Correction approved';

  @override
  String get attentionCorrectionApprovedMessage =>
      'Hotel Rajdhani’s record now shows PET Bottles 60 kg. Vikram Singh is told.';

  @override
  String get attentionBackToApprovals => 'Back to approval requests';

  @override
  String get attentionBackToHome => 'Back to home';

  @override
  String get attentionMyRequests => 'My requests';

  @override
  String get attentionToCollectionHead => 'To the Collection Head';

  @override
  String get attentionAll4 => 'All 4';

  @override
  String get attentionWaiting1 => 'Waiting 1';

  @override
  String get attentionApproved2 => 'Approved 2';

  @override
  String get attentionDeclined1 => 'Declined 1';

  @override
  String get attentionVehicleAdajan => 'Vehicle · Adajan Morning';

  @override
  String get attentionVehicleRequestDescription =>
      'A second vehicle on Sat 25 and Sun 26 Oct: Navratri Ground expects about 2 tonnes';

  @override
  String get attentionVehicleRequestResponse =>
      'With Arvind Desai (Collection Head)';

  @override
  String get attentionSentTodayShort => 'Sent today';

  @override
  String get attentionLabourPalGam => 'Labour · Pal Gam Morning';

  @override
  String get attentionLabourRequestDescription =>
      'One more loader for 3 days (20–22 Oct)';

  @override
  String get attentionLabourRequestResponse =>
      'Arvind Desai: “Ramesh Yadav joins from tomorrow.”';

  @override
  String get attentionSent19Oct => 'Sent 19 Oct';

  @override
  String get attentionPauseHotelShivam => 'Pause pickup point · Hotel Shivam';

  @override
  String get attentionPauseRequestDescription =>
      '1 – 10 Nov · closed for renovation';

  @override
  String get attentionPauseRequestResponse =>
      'Arvind Desai: “Approved. The IEC Executive is told.”';

  @override
  String get attentionSent18Oct => 'Sent 18 Oct';

  @override
  String get attentionStartSunriseSchool =>
      'Start pickup point · Sunrise School';

  @override
  String get attentionStartRequestDescription =>
      'Daily from 1 Nov on Punagam FullDay';

  @override
  String get attentionStartRequestResponse =>
      'Arvind Desai: “No room on that trip. Try Rander Evening.”';

  @override
  String get attentionSent16Oct => 'Sent 16 Oct';

  @override
  String get attentionApproved => 'Approved';

  @override
  String get attentionDeclined => 'Declined';

  @override
  String get attentionSuggestions => 'Suggestions';

  @override
  String get attentionSuggestionsSubtitle =>
      'Concept · ideas from GPS, routes and areas';

  @override
  String get attentionAll3 => 'All 3';

  @override
  String get attentionMoveHotelRajdhani =>
      'Move Hotel Rajdhani to Pal Gam Morning';

  @override
  String get attentionMoveHotelDescription =>
      'It is 3.1 km off Adajan Morning; Pal Gam Morning passes its gate';

  @override
  String get attentionMoveHotelRoute => 'Adajan Morning → Pal Gam Morning';

  @override
  String get attentionSaving31Km => 'Less 3.1 km a day';

  @override
  String get attentionReorderAdajan => 'Reorder Adajan Morning';

  @override
  String get attentionReorderDescription =>
      'Visit Om Sweets before Green Park Society';

  @override
  String get attentionReorderSecondary => 'Same stops, shorter path';

  @override
  String get attentionSaving12Min => 'Less 12 min a day';

  @override
  String get attentionCombineFridayRoutes =>
      'Rander and Vesu Evening on Fridays: one vehicle';

  @override
  String get attentionCombineDescription =>
      'Both run under half full on Fridays (310 kg and 280 kg)';

  @override
  String get attentionCombineSecondary => 'Frees GJ-05-EE-1001 on Fridays';

  @override
  String get attentionSavingOneVehicle => 'One vehicle less on Fri';

  @override
  String get attentionLast30Days => 'Last 30 days of GPS';

  @override
  String get attentionDismiss => 'Dismiss';

  @override
  String get attentionApply => 'Apply';

  @override
  String get attentionIssues => 'Issues';

  @override
  String get attentionVehicleBreakdown => 'Vehicle breakdown';

  @override
  String get attentionSourceClosed => 'Source closed';

  @override
  String get attentionRameshDriver => 'Ramesh Ahir (Driver)';

  @override
  String get attentionMohanDriver => 'Mohan laal (Driver)';

  @override
  String get attentionPrakashDriver => 'Prakash Jadav (Driver)';

  @override
  String get attentionVehicleNumber => 'GJ-05-BX-1234';

  @override
  String get attentionDriver => 'Driver';

  @override
  String get attentionRameshAhir => 'Ramesh Ahir';

  @override
  String get attentionContactNumber => 'Contact Number';

  @override
  String get attentionPhoneNumber => '9876543210';

  @override
  String get attentionRoute => 'Route';

  @override
  String get attentionAdajanMorning => 'Adajan Morning';

  @override
  String get attentionReasonFor => 'Reason for ';

  @override
  String get attentionIssueWord => 'Issue';

  @override
  String get attentionIssueReason => 'Reason : No Vehicle Available';

  @override
  String get attentionIssueRemarks =>
      'Remarks : All yard trucks are currently out. Try after 2 PM.';

  @override
  String get flagTimeClash => 'Time clash';

  @override
  String get flagHotelRajdhaniTime => 'Hotel Rajdhani · 1:30 pm vs 9–11 am';

  @override
  String get flagOffRoute => 'Off the route';

  @override
  String get flagSunriseOffRoute => 'Sunrise School · 4.2 km off route';

  @override
  String get flagScheduleChanged => 'Schedule changed';

  @override
  String get flagAdajanTextileSorted => 'Adajan Textile Mill · Sorted';

  @override
  String get flagSourcePaused => 'Source paused';

  @override
  String get flagClosedForDiwali => 'Closed for Diwali';

  @override
  String get flagNewSourceNoRoute => 'New source, no route';

  @override
  String get flagAbcTextileMills => 'ABC Textile Mills';

  @override
  String get flagExtraPickupNoRoute => 'Extra Pickup, no route';

  @override
  String get flagExtraPickupNoRouteDetail => 'Extra pickup, no route';

  @override
  String get flagShreeSaiSorted => 'Shree Sai Dairy · Sorted';

  @override
  String get flagSourceMovedToYou => 'Source moved to you';

  @override
  String get flagRkTrading => 'R.K trading and co.';

  @override
  String get flagNothingToCheck => 'Nothing to check!';

  @override
  String get flagOctober => 'october';

  @override
  String get flagNothingToCheckSubtitle =>
      'You don’t have any new notifications or pending action items right now.';

  @override
  String get flagShreeSaiDairy => 'Shree Sai Dairy';

  @override
  String get flagShreeSaiAddress => 'U 9, 10, Siddhgiri Tower, B/H Navyug...';

  @override
  String get flagWas => 'Was';

  @override
  String get flagOldSchedule => 'Mon, Thu · 8–10 am';

  @override
  String get flagNow => 'Now';

  @override
  String get flagNewSchedule => 'Mon, Wed · 9–11 am';

  @override
  String get flagFromMon2Nov => 'From : Mon 2 Nov';

  @override
  String get flagPausedDates => 'Paused 20–26 Oct';

  @override
  String get flagReasonClosedForDiwali => 'Reason: Closed for Diwali';

  @override
  String get flagMovedFromVesu => 'Moved from Vesu area';

  @override
  String get flagCheckRoute => 'Check route';

  @override
  String get flagAddToRoute => 'Add to route';

  @override
  String get flagMarkDone => 'Mark done';

  @override
  String get flagDone => 'Done';

  @override
  String get sourcesNavLabel => 'Sources';

  @override
  String get sourcesRoutesNavLabel => 'Route';

  @override
  String get sourcesProfileNavLabel => 'Profile';

  @override
  String get routesTitle => 'Routes';

  @override
  String get routesSubtitle => 'Trips are made from them every day';

  @override
  String get routesSearchHint => 'Search Here...';

  @override
  String get routesEmptyMessage =>
      'No routes yet. Tap + to make your first route';

  @override
  String get routesFilterAll => 'All 4';

  @override
  String get routesFilterOwn => 'Own vehicle 2';

  @override
  String get routesFilterContract => 'Contract vehicle 2';

  @override
  String get routesPalGamMorning => 'Pal Gam Morning';

  @override
  String get routesOwnVehicle => 'Own vehicle';

  @override
  String get routesDriverNotUsingApp => 'Driver not using app';

  @override
  String get routesVehicle5678 => 'GJ-05-BX-5678';

  @override
  String get routesPalGamTime => 'Morning (12:00 PM – 05:00 PM)';

  @override
  String get routesOnRoute => 'On route';

  @override
  String get routesRecordedZero => '0 of 8 recorded in the app';

  @override
  String get routesAdajanMorning => 'Adajan Morning';

  @override
  String get routesDailyWeekly => 'Daily 5 · Weekly 3';

  @override
  String get routesVehicle1234 => 'GJ-05-BX-1234';

  @override
  String get routesAdajanTime => 'Morning (08:00 AM – 02:00 PM)';

  @override
  String get routesPlanned => 'Planned';

  @override
  String get routesCollectedZero => '0 of 8 collected';

  @override
  String get routesPunagamFullDay => 'Punagam FullDay';

  @override
  String get routesContractVehicle => 'Contract vehicle';

  @override
  String get routesDailyMonthly => 'Daily 6 · Monthly 2';

  @override
  String get routesFullDayTime => 'Full Day (08:00 AM – 12:00 PM)';

  @override
  String get routesApproved => 'Approved';

  @override
  String get routesCollectedEight => '8 of 8 collected';

  @override
  String get routesRanderEvening => 'Rander Evening';

  @override
  String get routesWeeklyBiWeekly => 'Weekly 6 · Bi-weekly 2';

  @override
  String get routesVehicle9012 => 'GJ-05-BX-9012';

  @override
  String get routesEveningTime => 'Evening (8 am–8 pm)';

  @override
  String get routesSwitchOff => 'Switch Off';

  @override
  String get supervisorDrawerUserName => 'Kiran Shah';

  @override
  String get supervisorDrawerRole => 'Pickup Supervisor';

  @override
  String get supervisorDrawerUnassignedSources => 'Unassigned sources';

  @override
  String get supervisorDrawerRoutes => 'Routes';

  @override
  String get supervisorDrawerDriversLabour => 'Drivers and labour';

  @override
  String get supervisorDrawerIssues => 'Issues';

  @override
  String get supervisorDrawerExtraPickupRequests => 'Extra pickup requests';

  @override
  String get supervisorDrawerSyncStatus => 'Sync Status';

  @override
  String get supervisorDrawerNotifications => 'Notifications';

  @override
  String get supervisorDrawerHelpSupport => 'Help & Support';

  @override
  String get supervisorDrawerLogout => 'Logout';

  @override
  String get supervisorDrawerPoweredBy => 'Powered by Eco Vision';

  @override
  String get addRouteStep1 => 'Step 1 of 2';

  @override
  String get addRouteStep2 => 'Step 2 of 2';

  @override
  String get addRouteRouteName => 'Route name';

  @override
  String get addRouteRouteNameHint => 'For example, Adajan Morning';

  @override
  String get addRouteWarehouse => 'Warehouse';

  @override
  String get addRouteSelectWarehouse => 'Select warehouse';

  @override
  String get addRouteShift => 'Shift';

  @override
  String get addRouteSelectShift => 'Select Shift';

  @override
  String get addRouteContinue => 'Continue';

  @override
  String get addRouteWarehouseAdajan => 'Adajan Central Warehouse';

  @override
  String get addRouteWarehouseVesu => 'Vesu Storage Hub';

  @override
  String get addRouteWarehouseKatargam => 'Katargam Depot';

  @override
  String get addRouteWarehousePal => 'Pal Sorting Facility';

  @override
  String get addRouteWarehouseUdhna => 'Udhna Industrial Warehouse';

  @override
  String get addRouteShiftMorningEarly => 'Morning · 7 am–3 pm';

  @override
  String get addRouteShiftMorningLate => 'Morning · 2 pm–8 pm';

  @override
  String get addRouteShiftFullDay => 'Full Day (8 am–8 pm)';

  @override
  String get addRouteSelectVehicle => 'Select Vehicle';

  @override
  String get addRouteVehicleLabel => 'Vehicle';

  @override
  String get addRouteVehicleHint => 'Select Vehicle for Pickup';

  @override
  String get addRouteSelectDriver => 'Select Driver';

  @override
  String get addRouteDriverHint => 'Select Driver for Pickup';

  @override
  String get addRouteSelectLabour => 'Select Labour';

  @override
  String get addRouteLabourHint => 'Select Labour';

  @override
  String get addRouteDriverNotFound => 'Driver Not Found';

  @override
  String get addRouteDriverNotFoundHint =>
      'No driver added yet. Tap below to add.';

  @override
  String get addRouteLabourNotFound => 'Labour Not Found';

  @override
  String get addRouteLabourNotFoundHint =>
      'No labour added yet. Tap below to add.';

  @override
  String get addRouteAdd => 'Add';

  @override
  String get addRouteVehicleCompany1001 => 'GJ-05-EE-1001';

  @override
  String get addRouteVehicleCompany1234 => 'GJ-05-BX-1234';

  @override
  String get addRouteVehicleRental1002 => 'GJ-05-EE-1002';

  @override
  String get addRouteVehicleRental1001 => 'GJ-05-EE-1001';

  @override
  String get addRouteCompanyTruck => 'Company truck';

  @override
  String get addRouteRentalShreeRam => 'Hired from Shree ram Transport';

  @override
  String get addRouteRentalKhodiyar => 'Hired from Khodiyar Transport';

  @override
  String get addRouteCapacity => 'Capacity 3000 KG';

  @override
  String get addRouteDriverVikram => 'Vikram Singh (••• 4321)';

  @override
  String get addRouteDriverSuresh => 'Suresh Kumar (••• 5847)';

  @override
  String get addRouteDriverMahesh => 'Mahesh Parmar (••• 2282)';

  @override
  String get addRouteDriverRakesh => 'Rakesh Sharma (••• 2458)';

  @override
  String get addRouteDriverAmit => 'Amit Patel (••• 9510)';

  @override
  String get addRouteLabourRavi => 'Ravi Bisht (••• 5847)';

  @override
  String get addRouteLabourRam => 'Ram Singh (••• 2282)';

  @override
  String get addRouteLabourRamesh => 'Ramesh Yadav (••• 2458)';

  @override
  String get addRouteLabourArjun => 'Arjun Jatav (••• 9510)';

  @override
  String get addRouteDeactivate => 'Deactivate';

  @override
  String get addRouteDeactivateTitle => 'Deactivate?';

  @override
  String get addRouteDeactivateMessage =>
      'Are you sure you want to deactivate this person?';

  @override
  String get addRouteCancel => 'Cancel';

  @override
  String get addRouteYes => 'Yes';

  @override
  String get addRouteAddNewDriverPrefix => 'Add New ';

  @override
  String get addRouteDriverWord => 'Driver';

  @override
  String get addRouteLabourWord => 'Labour';

  @override
  String get addRouteFullName => 'Full Name';

  @override
  String get addRouteFullNameHint => 'Enter Full Name';

  @override
  String get addRouteMobileNumber => 'Mobile Number';

  @override
  String get addRouteMobileNumberHint => 'Enter Mobile number';

  @override
  String get addRouteCountryCode => '+91';

  @override
  String get addRouteAadhaarNumber => 'Aadhar card Number';

  @override
  String get addRouteAadhaarHint => 'Aadhaar / Voter ID';

  @override
  String get addRouteProfileProof => 'Profile Photo / ID Proof';

  @override
  String get addRouteCapturePhoto => 'Capture Photo';

  @override
  String get addRoutePhotoHint =>
      'Upload a photo to record and verify details.';

  @override
  String get addRouteSaveSelect => 'Save & Select';

  @override
  String get addRouteFullNameRequired => 'Please enter the full name.';

  @override
  String get addRouteFullNameMinLength =>
      'Full name must be at least 2 characters.';

  @override
  String get addRouteMobileRequired => 'Please enter the mobile number.';

  @override
  String get addRouteMobileInvalid =>
      'Enter a valid 10-digit mobile number starting with 6–9.';

  @override
  String get addRouteReviewShift => 'Morning (8 am–2 pm)';

  @override
  String get addRouteReviewVehicle => 'GJ-05-EE-1001';

  @override
  String get addRouteReviewCompany => '(Company Truck)';

  @override
  String get addRouteReviewDriver => 'Vikram Singh (12345 43210)';

  @override
  String get addRouteReviewLabour => 'Ravi Bisht (23456 58492)';

  @override
  String get addRouteAddToRoute => 'Add to route';

  @override
  String get addRouteSavedTitle => 'Successfully Saved!';

  @override
  String get addRouteSavedSubtitle => 'Adajan Morning Route Saved';

  @override
  String get sourcesUnassignedTitle => 'Unassigned sources';

  @override
  String get sourcesManageSubtitle => 'Manage collection sources';

  @override
  String get sourcesSearchHint => 'Search sources';

  @override
  String get sourcesTabCount => 'Sources (3)';

  @override
  String get sourcesExtraTabCount => 'Extra Pickups (1)';

  @override
  String get sourcesAdajanTextileSorted => 'Adajan Textile Mill · Sorted';

  @override
  String get sourcesAddressShort => 'U 9, 10, Siddhgiri Tower, B/H Navyug...';

  @override
  String get sourcesMonThuSchedule => 'Mon, Thu · 8–10 am';

  @override
  String get sourcesUnassignedStatus => 'Unassigned';

  @override
  String get sourcesShreeSaiMixed => 'Shree Sai Dairy · Mixed';

  @override
  String get sourcesEmbraneAddress => 'X 3, 10, Embrane Zone, navyug plus...';

  @override
  String get sourcesExceptSunSchedule => 'Except Sun · 9–11 am';

  @override
  String get sourcesShreeSaiSorted => 'Shree Sai Dairy · Sorted';

  @override
  String get sourcesSecondWedSchedule => '2nd Wed of the month · 10–11 am';

  @override
  String get sourcesMahavirSorted => 'Mahavir Paper Mill · Sorted';

  @override
  String get sourcesExtraPickupSchedule => 'Sat 24 Oct · 11 am–12 pm';

  @override
  String get sourcesEmptyMessage => 'No Unassigned trips available';

  @override
  String get sourcesAbcTextileMills => 'ABC Textile Mills';

  @override
  String get sourcesShreeSaiDairy => 'Shree Sai Dairy';

  @override
  String get sourcesMahavirPaperMill => 'Mahavir Paper Mill';

  @override
  String get sourcesAddress => 'Address';

  @override
  String get sourcesFullAddress =>
      'U 9, 10, Siddhgiri Tower, B/H Navyug College Rd, Navyug Society, Sangana Society, Adajan, Surat, Gujarat 395009';

  @override
  String get sourcesOpenMaps => 'Open in Google Maps';

  @override
  String get sourcesSchedule => 'Schedule';

  @override
  String get sourcesContactNumber => 'Contact Number';

  @override
  String get sourcesPhone => '9876543210';

  @override
  String get sourcesMaterial => 'Material';

  @override
  String get sourcesSorted => 'Sorted';

  @override
  String get sourcesMixed => 'Mixed';

  @override
  String get sourcesMaterialsList => 'Milk Pouch, Card Board';

  @override
  String get sourcesPickupStatus => 'Pickup Status';

  @override
  String get sourcesAddToRoute => 'Add to route';

  @override
  String get sourcesAdajanMorning => 'Adajan Morning';

  @override
  String get sourcesVehicleGj051824 => 'GJ 05 1824';

  @override
  String get sourcesMorningTime => 'Morning (08:00 AM – 02:00 PM)';

  @override
  String get sourcesAssignedCount => 'Assigned Sources : 2';

  @override
  String get sourcesPalGamMorning => 'Pal Gam Morning';

  @override
  String get sourcesVehicleGj052564 => 'GJ 05 2564';

  @override
  String get sourcesPalGamTime => 'Morning Shift (10:00 AM – 12:00 PM)';

  @override
  String get sourcesVesuEvening => 'Vesu Evening';

  @override
  String get sourcesTimeClashWarning =>
      'Time clash: Adajan Morning reaches here at about 1:30 pm, but the pickup window is 9–11 am.\n4.2 km off the route: about 20 min more on each trip.\nPal Gam Morning passes nearby at 9:40 am.';

  @override
  String get sourcesAddNew => 'Add New';

  @override
  String get sourcesAssignAnyway => 'Assign anyway';

  @override
  String get sourcesAddedToRoute => 'Source Added to Route';

  @override
  String get sourcesAddedMessage =>
      'ABC Textile Mills is now assigned to GJ 05 1824 (Morning Shift).';

  @override
  String get sourcesBackToRequests => 'Back to Requests';

  @override
  String get profileTitle => 'User Profile';

  @override
  String get profileSubtitle => 'Account details & info';

  @override
  String get profileLanguageCode => 'EN';

  @override
  String get profileUserName => 'Kiran Shah';

  @override
  String get profileRole => 'Pickup Supervisor';

  @override
  String get profileAccountInformation => 'Account Information';

  @override
  String get profileMyAreas => 'My areas';

  @override
  String get profileAreasValue => 'Adajan, Vesu, Pal';

  @override
  String get profileMobileNumber => 'Mobile Number';

  @override
  String get profileMobileValue => '+91 98765 43210';

  @override
  String get profileRoleLabel => 'Role';

  @override
  String get profileSessionExpires => 'Session Expires';

  @override
  String get profileSessionValue => 'Expires in 6h 24m';

  @override
  String get profileActions => 'Actions';

  @override
  String get profileSyncData => 'Sync Data';

  @override
  String get profileSyncDataSubtitle => 'Sync your offline data';

  @override
  String get profileAccount => 'Account';

  @override
  String get profileLogout => 'Logout';

  @override
  String get profileLogoutSubtitle => 'Sign out from your account';

  @override
  String get profileSyncOfflineData => 'Sync Offline Data';

  @override
  String get profileChangesNotSent => '3 changes not sent yet';

  @override
  String get profileSyncNow => 'Sync Now';

  @override
  String get profileDataAlreadySynced => 'Data Already Synced';

  @override
  String get profileBack => 'Back';

  @override
  String get profileLogoutQuestion => 'Are you sure you want to log out?';

  @override
  String get profileLogoutMessage =>
      'Any unsynced offline data will remain on this device until your next sign-in.';

  @override
  String get profileSendChangesWarning => 'Send changes to notify drivers';

  @override
  String get profileNo => 'No';

  @override
  String get profileYes => 'Yes';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileToday => 'Today';

  @override
  String get profileEarlier => 'Earlier';

  @override
  String get profileOfflineMode => 'Offline Mode';

  @override
  String get profileOfflineModeMessage =>
      'No internet connection. Data will sync automatically when Connection Restored.';

  @override
  String get profileJustNow => 'Just now';

  @override
  String get profileNewSourceUnassigned => 'New Source Unassigned';

  @override
  String get profileNewSourceMessage =>
      'Global Garments (Adajan) needs a route assignment.';

  @override
  String get profileTenMinutesAgo => '10 Mins ago';

  @override
  String get profileDriverEscalation => 'Driver Escalation';

  @override
  String get profileDriverEscalationMessage =>
      'Driver Ramesh reported gate entry delay at Pal spot.';

  @override
  String get profileYesterdayTime => 'Yesterday, 11:30 AM';

  @override
  String get profilePickupSkipped => 'Pickup Skipped';

  @override
  String get profilePickupSkippedMessage =>
      'Siddhgiri Traders Skipped collection.';

  @override
  String get profilePickupSkippedTime => '24 Oct, 08:00 AM';

  @override
  String get profileAllCaughtUp => 'All Caught Up!';

  @override
  String get profileNoNotifications =>
      'You have no new notifications. Check back later for system alerts and Admin updates.';

  @override
  String get profileHelpSupport => 'Help & Support';

  @override
  String get profileCallSupport => 'Call Support';

  @override
  String get profileCallSupportSubtitle => 'Available 24/7 for field issues';

  @override
  String get profileInstantHelp => 'Instant Help';

  @override
  String get profileInstantHelpSubtitle => 'Chat with a support agent';

  @override
  String get profileFaqTitle => 'Frequently Asked Questions';

  @override
  String get profileFaqDailyTrips => 'How do daily trips work?';

  @override
  String get profileFaqDailyTripsAnswer =>
      'Generated automatically each morning from your Master Routes.';

  @override
  String get profileFaqSwapDriver => 'How to swap a driver for today?';

  @override
  String get profileFaqSwapDriverAnswer =>
      'Open today\'s route and use the driver edit action.';

  @override
  String get profileFaqUnassigned => 'What is the unassigned sources?';

  @override
  String get profileFaqUnassignedAnswer =>
      'Sources that are not currently attached to a route.';

  @override
  String get profileFaqSkipping => 'What does Skipping a stop do?';

  @override
  String get profileFaqSkippingAnswer =>
      'It records the stop as skipped for the current trip.';

  @override
  String get profileClosedDayArtwork => 'Now Time to\nCLOSED The Day';

  @override
  String get driverProfileUserName => 'Ramesh Kumar';

  @override
  String get driverProfileWarehouseLabel => 'My warehouse';

  @override
  String get driverProfileWarehouseValue => 'Magdalla Warehouse';

  @override
  String get driverProfileDriverCodeLabel => 'Driver code';

  @override
  String get driverProfileDriverCodeValue => 'SUR-DRV-0007';

  @override
  String get driverProfileMobileValue => '+91 98765 43226';

  @override
  String get driverProfileRoleValue => 'Driver';

  @override
  String get driverProfileLogoutWarning =>
      '3 collections not sent yet: sync first';

  @override
  String get dlDriverDirectory => 'Driver Directory';

  @override
  String get dlLabourDirectory => 'Labour Directory';

  @override
  String get dlFilterActive => 'Active';

  @override
  String get dlFilterInactive => 'Inactive';

  @override
  String dlTabDrivers(int count) {
    return 'Driver ($count)';
  }

  @override
  String dlTabLabour(int count) {
    return 'Labour ($count)';
  }

  @override
  String get dlSearchHint => 'Search Here...';

  @override
  String get dlAddDriver => 'Add Driver';

  @override
  String get dlAddLabour => 'Add Labour';

  @override
  String get dlAddLabourer => 'Add labourer';

  @override
  String get dlNoDetailsFound => 'No Details Found';

  @override
  String get dlNoPhone => '--';

  @override
  String get dlAddNewDriver => 'Add New Driver';

  @override
  String get dlAddNewLabour => 'Add New Labour';

  @override
  String get dlEditDriver => 'Edit Driver';

  @override
  String get dlEditLabour => 'Edit Labour';

  @override
  String get dlFullName => 'Full Name';

  @override
  String get dlEnterFullName => 'Enter Full Name';

  @override
  String get dlMobileNumber => 'Mobile Number';

  @override
  String get dlEnterMobileNumber => 'Enter Mobile number';

  @override
  String get dlCountryCode => '+91';

  @override
  String get dlAadhaarLabel => 'Aadhar card Number';

  @override
  String get dlAadhaarHint => 'Aadhaar / Voter ID';

  @override
  String get dlProfilePhoto => 'Profile Photo / ID Proof';

  @override
  String get dlCapturePhoto => 'Capture Photo';

  @override
  String get dlUploadHint => 'Upload a photo to record and verify details.';

  @override
  String get dlCancel => 'Cancel';

  @override
  String get dlSaveSelect => 'Save & Select';

  @override
  String get dlIdCardNumber => 'ID / Card Number';

  @override
  String get dlDateTime => 'Date & Time';

  @override
  String get dlDeactivate => 'Deactivate';

  @override
  String get dlEdit => 'Edit';

  @override
  String get dlReactive => 'Reactive';

  @override
  String get dlAreYouSure => 'Are you sure?';

  @override
  String get dlDeactivateDriverMessage =>
      'Are you sure you want to deactivated this Driver person';

  @override
  String get dlDeactivateLabourMessage =>
      'Are you sure you want to deactivated this Labour person';

  @override
  String get dlReactiveDriverMessage =>
      'Are you sure you want to reactive this Driver person';

  @override
  String get dlReactiveLabourMessage =>
      'Are you sure you want to reactive this Labour person';

  @override
  String get dlYes => 'Yes';

  @override
  String get dlDeactivatedTitle => 'Deactivated Successfully!';

  @override
  String get dlDeactivatedBody => 'Profile deactivated.';

  @override
  String get dlReactivedTitle => 'Reactive Successfully!';

  @override
  String get dlReactivedBody => 'Profile reactivated.';

  @override
  String get supervisorTripsToday => 'Trips today';

  @override
  String get tpTitle => 'Trips plan';

  @override
  String get tpAreas => 'Adajan, Vesu, Pal';

  @override
  String get tpChoiceToday => 'Today';

  @override
  String get tpChoiceTomorrow => 'Tomorrow';

  @override
  String get tpChoiceWeek => 'This week';

  @override
  String get tpDateToday => 'Thu 22 Oct 2026';

  @override
  String get tpDateTomorrow => 'Fri 23 Oct 2026';

  @override
  String get tpDateNoTrips => 'Sun 8 Nov 2026';

  @override
  String tpTripsStops(int trips, int stops) {
    return '$trips trips · $stops stops';
  }

  @override
  String tpExtraPickups(int count) {
    return '$count extra pickups';
  }

  @override
  String tpSourcePaused(int count) {
    return '$count source paused';
  }

  @override
  String get tpNoTrips => 'No trips';

  @override
  String get tpStatusOnRoute => 'On route';

  @override
  String get tpStatusApproved => 'Approved';

  @override
  String get tpStatusPlanned => 'Planned';

  @override
  String get tpOwnVehicle => 'Own vehicle';

  @override
  String get tpContractVehicle => 'Contract vehicle';

  @override
  String tpVehicleTag(String plate, String vehicle) {
    return '$plate · $vehicle';
  }

  @override
  String get tpChangedForToday => 'Changed for today';

  @override
  String get tpDriverNotUsingApp => 'Driver not using app';

  @override
  String tpCoverFor(String substitute, String original) {
    return '$substitute (for $original)';
  }

  @override
  String tpTransporterDriver(String transporter, String driver) {
    return '$transporter · Driver $driver';
  }

  @override
  String tpStops(int count) {
    return '$count stops';
  }

  @override
  String tpDaily(int count) {
    return 'Daily $count';
  }

  @override
  String tpWeekly(int count) {
    return 'Weekly $count';
  }

  @override
  String tpMonthly(int count) {
    return 'Monthly $count';
  }

  @override
  String tpBiWeekly(int count) {
    return 'Bi-weekly $count';
  }

  @override
  String tpOnCall(int count) {
    return 'On call $count';
  }

  @override
  String tpPaused(int count) {
    return '$count paused';
  }

  @override
  String tpCollectedOf(int done, int total) {
    return '$done of $total collected';
  }

  @override
  String tpRecordedOf(int done, int total) {
    return '$done of $total recorded in the app';
  }

  @override
  String tpCollectedMissed(int collected, int missed) {
    return '$collected collected · $missed missed';
  }

  @override
  String tpWeightKg(String kg) {
    return '$kg kg';
  }

  @override
  String get tpCallDriver => 'Call driver';

  @override
  String tpOwnVehicleCount(int count) {
    return 'Own vehicle $count';
  }

  @override
  String tpContractCount(int count) {
    return 'Contract $count';
  }

  @override
  String get tpDay0 => 'Thu 22 Oct · Today';

  @override
  String get tpDay1 => 'Fri 23 Oct';

  @override
  String get tpDay2 => 'Sat 24 Oct';

  @override
  String get tpDay3 => 'Sun 25 Oct';

  @override
  String get tpDay4 => 'Mon 26 Oct';

  @override
  String get tpDay5 => 'Tue 27 Oct';

  @override
  String get tpDay6 => 'Wed 28 Oct';

  @override
  String get tpEmptyTitle => 'No trips on this day';

  @override
  String get tpEmptyMessage =>
      'The warehouse is closed that day (holiday). Pickups due that day move to the next working day or are skipped, as each pickup point’s holiday rule says.';

  @override
  String get rdNext7Days => 'Next 7 Days';

  @override
  String get rdDateToday => 'Thu, 22 Oct 2026';

  @override
  String get rdDateRange => 'Fri 23 Oct – Thu 29 Oct';

  @override
  String rdShift(String time) {
    return 'Morning ($time)';
  }

  @override
  String rdAssignedSources(int count) {
    return 'Assigned Sources : $count';
  }

  @override
  String rdAssignedSourcesPaused(int count, int paused) {
    return 'Assigned Sources : $count ($paused paused)';
  }

  @override
  String rdDriverLine(String name, String phone) {
    return 'Driver : $name ($phone)';
  }

  @override
  String rdLabourLine(String name) {
    return 'Labour : $name';
  }

  @override
  String get rdList => 'List';

  @override
  String get rdMap => 'Map';

  @override
  String get rdFilterAll => 'All';

  @override
  String get rdFilterCollected => 'Collected';

  @override
  String get rdFilterPending => 'Pending';

  @override
  String get rdFilterZeroKg => '0 kg';

  @override
  String get rdFilterMissed => 'Missed';

  @override
  String get rdFilterCancelled => 'Cancelled';

  @override
  String get rdFilterInactive => 'Inactive';

  @override
  String get rdFreqDaily => 'Daily';

  @override
  String get rdFreqWeekly => 'Weekly';

  @override
  String get rdTypeSorted => 'Sorted';

  @override
  String get rdTypeMixed => 'Mixed';

  @override
  String rdStopTitle(String name, String type) {
    return '$name · $type';
  }

  @override
  String rdSchedEveryDay(String time) {
    return 'Every day · $time';
  }

  @override
  String rdSchedDays(String days, String time) {
    return '$days · $time';
  }

  @override
  String rdSchedExceptSun(String time) {
    return 'Except Sun, $time';
  }

  @override
  String rdSchedSecondWed(String time) {
    return 'Second Wed, $time';
  }

  @override
  String rdSchedOnce(String date, String time) {
    return '(Once) $date, $time';
  }

  @override
  String rdSchedPausedTill(String date) {
    return 'Paused till $date';
  }

  @override
  String get rdWeekdayMon => 'Mon';

  @override
  String get rdWeekdayThu => 'Thu';

  @override
  String get rdStatusCollected => 'Collected';

  @override
  String get rdStatusZeroKg => '0 kg';

  @override
  String get rdStatusCancelledBySource => 'Cancelled by source';

  @override
  String get rdStatusNextStop => 'Next stop';

  @override
  String get rdStatusPending => 'Pending';

  @override
  String get rdStatusInactive => 'Inactive';

  @override
  String rdAmountKgPcs(String kg, String pcs) {
    return '$kg kg + $pcs pcs';
  }

  @override
  String get rdNoteNoMaterial => 'No material today';

  @override
  String get rdNoteClosedStocktaking => 'Closed for stock-taking';

  @override
  String get rdNotePausedRenovation => 'Source paused (renovation)';

  @override
  String rdTagCollectedAt(String time) {
    return 'Collected $time';
  }

  @override
  String rdTagVisitedAt(String time) {
    return 'Visited $time';
  }

  @override
  String get rdTagNoteFromDriver => 'Note from driver';

  @override
  String rdTagVoiceNote(String duration) {
    return 'Voice note $duration';
  }

  @override
  String get rdLegendCollected => 'Collected';

  @override
  String get rdLegendZeroKg => '0 kg';

  @override
  String get rdLegendCancelled => 'Cancelled';

  @override
  String get rdLegendNextStop => 'Next stop';

  @override
  String get rdLegendPending => 'Pending';

  @override
  String get rdLegendPaused => 'Paused';

  @override
  String get rdLegendWarehouse => 'Warehouse';

  @override
  String rdMapNext(int number, String name, String time, String distance) {
    return 'Next: $number · $name · $time · $distance away';
  }

  @override
  String get rdMapHint =>
      'Stops in visiting order. The solid line is done; the dashed line is still to go, back to the warehouse. Tap a stop to open it.';

  @override
  String get rdAddedLastHint =>
      'It is added as the last stop. You can change the order on the route\'s page.';

  @override
  String get rdAddSources => 'Add sources';

  @override
  String get sdAddress => 'Address';

  @override
  String get sdOpenMaps => 'Open in Google Maps';

  @override
  String get sdSchedule => 'Schedule';

  @override
  String get sdPersonAtPickup => 'Person at the pickup point';

  @override
  String get sdIecExecutive => 'IEC Executive';

  @override
  String get sdPickupCategory => 'Pickup category';

  @override
  String get sdMaterial => 'Material';

  @override
  String get sdPickupStatus => 'Pickup Status';

  @override
  String get sdWarehouse => 'Warehouse';

  @override
  String get sdStatusNextStop => 'Next Stop';

  @override
  String get sdCall => 'Call';

  @override
  String get sdSkipForToday => 'Skip For Today';

  @override
  String get sdMaterialsList => 'Milk Pouch, Card Board';

  @override
  String get sdRoleManager => 'Manager';

  @override
  String sdContactLine(String name, String role, String phone) {
    return '$name · $role · $phone';
  }

  @override
  String sdIecLine(String name, String phone) {
    return '$name · $phone';
  }

  @override
  String get skTitle => 'Skip Source';

  @override
  String get skReasonLabel => 'Reason for Skip';

  @override
  String get skReasonClosed => 'Source closed';

  @override
  String get skReasonHoliday => 'Holiday';

  @override
  String get skReasonVehicle => 'Vehicle unavailable';

  @override
  String get skReasonOther => 'Other';

  @override
  String get skRemarks => 'Remarks';

  @override
  String get skMaxChars => 'Max 150 Characters';

  @override
  String get skConfirm => 'Confirm Skip';

  @override
  String get skSkippedTitle => 'Source Skipped!';

  @override
  String get skSkippedBody => 'Resumes tomorrow automatically.';

  @override
  String get apToApprove => 'To approve';

  @override
  String get apDone => 'Done';

  @override
  String get apCorrectionDoneDetail =>
      'PET Bottles 50 kg → 60 kg. The stop’s record is changed; Vikram Singh is told.';

  @override
  String get apApprovedToday => 'Approved by you today, 10:20 am';

  @override
  String get apExtraPickupDoneDetail =>
      'Sat 25 Oct, 10 am – 12 pm · about 40 kg · added to Adajan Morning';

  @override
  String get apApproved21Oct => 'Approved by you 21 Oct';

  @override
  String get apStartPickupsFromIec => 'Start pickups · from IEC';

  @override
  String get apGreenLeafNisha => 'Green Leaf Hotel · Nisha Mehta';

  @override
  String get apDeclineReplyDetail =>
      'Your reply: “No room on Adajan Morning until 1 Dec. Ask again then.”';

  @override
  String get apDeclined20Oct => 'Declined by you 20 Oct';

  @override
  String get apDeclineCorrectionTitle => 'Decline the correction';

  @override
  String get apDeclineCorrectionBody =>
      'Vikram Singh sees your reply. The stop stays as recorded.';

  @override
  String get apDeclineCorrectionReply =>
      'The scale photo shows 50 kg. If it was more, ask the gate team to weigh it again.';

  @override
  String get apDeclineExtraTitle => 'Decline the extra pickup';

  @override
  String get apDeclineExtraBody =>
      'ABC Plastic Manufacture sees your reply. No pickup is added.';

  @override
  String get apReplyHint => 'Write your reply';

  @override
  String get apDeclineAndReply => 'Decline and reply';

  @override
  String get apCancel => 'Cancel';

  @override
  String get apExtraApprovedTitle => 'Extra pickup approved';

  @override
  String get apExtraApprovedBody =>
      'ABC Plastic Manufacture is added to Adajan Morning on Sat 25 Oct.';

  @override
  String get rpTitle => 'Collection report';

  @override
  String get rpShare => 'Share';

  @override
  String get rpCollectedToday => 'Collected today';

  @override
  String get rpCollectedYesterday => 'Collected yesterday';

  @override
  String get rpCollectedThisWeek => 'Collected this week';

  @override
  String get rpCollectedThisMonth => 'Collected this month';

  @override
  String get rpCollectedTheseDates => 'Collected on these dates';

  @override
  String rpTotal(String kg, String pcs) {
    return '$kg kg + $pcs pcs';
  }

  @override
  String rpKg(String kg) {
    return '$kg kg';
  }

  @override
  String rpStopsDue(String count) {
    return '$count stops due';
  }

  @override
  String get rpByRoute => 'By route';

  @override
  String get rpByCategory => 'By pickup category';

  @override
  String get rpStopsToLook => 'Stops to look at';

  @override
  String rpOfStops(String done, String total) {
    return '$done of $total stops';
  }

  @override
  String rpStops(String count) {
    return '$count stops';
  }

  @override
  String get rpOwn => 'Own';

  @override
  String get rpContract => 'Contract';

  @override
  String get rpCancelledBySource => 'Cancelled by source';

  @override
  String rpNamesMore(String first, String second, String count) {
    return '$first, $second and $count more';
  }

  @override
  String rpNamesPlus(String first, String second, String count) {
    return '$first, $second +$count';
  }

  @override
  String rpCollectedStops(String label, String done, String total) {
    return '$label · $done of $total stops';
  }

  @override
  String get rpPdfTitle => 'Report PDF';

  @override
  String rpPdfSubtitle(String range) {
    return 'Collection report · $range';
  }

  @override
  String get rpCompany => 'Ecovision Environmental Resources LLP';

  @override
  String rpPdfSupervisor(String name, String period, String range) {
    return 'Pickup Supervisor: $name · $period, $range';
  }

  @override
  String get rpPeriodToday => 'Today';

  @override
  String get rpPeriodYesterday => 'Yesterday';

  @override
  String get rpPeriodThisWeek => 'This week';

  @override
  String get rpPeriodThisMonth => 'This month';

  @override
  String get rpPeriodDates => 'Selected dates';

  @override
  String rpPdfSummary(
    String due,
    String collected,
    String zero,
    String missed,
    String cancelled,
  ) {
    return '$due stops due · Collected $collected · 0 kg $zero · Missed $missed · Cancelled $cancelled';
  }

  @override
  String get rpColRoute => 'Route';

  @override
  String get rpColVehicle => 'Vehicle';

  @override
  String get rpColStops => 'Stops';

  @override
  String get rpColCollected => 'Collected';

  @override
  String get rpColCategory => 'Category';

  @override
  String get rpColOutcome => 'Outcome';

  @override
  String get rpColPickupPoints => 'Pickup points';

  @override
  String rpOf(String done, String total) {
    return '$done of $total';
  }

  @override
  String rpPdfMade(String date, String time) {
    return 'Made $date, $time · Page 1 of 1';
  }

  @override
  String get rpPdfPageHint => 'Page 1 of 1 · pinch to zoom';

  @override
  String get rpSharePdf => 'Share PDF';

  @override
  String get calClear => 'Clear';

  @override
  String get calApply => 'Apply';

  @override
  String get calPrevMonth => 'Previous month';

  @override
  String get calNextMonth => 'Next month';

  @override
  String calSelection(String range, String days) {
    return '$range · $days';
  }

  @override
  String calDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get calPickDates => 'Pick dates';

  @override
  String calMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'January',
      '2': 'February',
      '3': 'March',
      '4': 'April',
      '5': 'May',
      '6': 'June',
      '7': 'July',
      '8': 'August',
      '9': 'September',
      '10': 'October',
      '11': 'November',
      '12': 'December',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'Jan',
      '2': 'Feb',
      '3': 'Mar',
      '4': 'Apr',
      '5': 'May',
      '6': 'Jun',
      '7': 'Jul',
      '8': 'Aug',
      '9': 'Sep',
      '10': 'Oct',
      '11': 'Nov',
      '12': 'Dec',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'M',
      '2': 'T',
      '3': 'W',
      '4': 'T',
      '5': 'F',
      '6': 'S',
      '7': 'S',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get supervisorDrawerCashPayments => 'Cash & payments';

  @override
  String lkRouteDate(String route, String date) {
    return '$route · $date';
  }

  @override
  String get lkNotOnRoute => 'Not on a route';

  @override
  String lkContractVehicle(String plate) {
    return 'Contract vehicle · $plate';
  }

  @override
  String lkOwnVehicle(String name) {
    return 'Own vehicle · driver $name';
  }

  @override
  String get lkExtraPickup => 'Extra pickup';

  @override
  String get lkCalledOffIec => 'Called off by the IEC ahead of time';

  @override
  String lkCalledOffAtStop(String name) {
    return 'Called off at the stop · driver $name';
  }

  @override
  String get lkCalledOffByYou => 'Called off by you';

  @override
  String get lkReasonNotRecorded => 'Not recorded by the driver or the gate';

  @override
  String get lkReasonTripCancelled => 'Its trip was cancelled';

  @override
  String get lkReasonNoRoute => 'No route that day';

  @override
  String get lkReasonTakenOff => 'Taken off the trip and not put on another';

  @override
  String get lkReasonClosedToday => 'Closed today';

  @override
  String get lkReasonHoliday => 'Holiday';

  @override
  String get lkReasonShifted => 'Shifted to another day';

  @override
  String get lkReasonNoMaterial => 'No material';

  @override
  String get lkReasonNoMaterialToday => 'No material today';

  @override
  String get lkReasonClosed => 'Closed';

  @override
  String get lkReasonRefused => 'Refused to give';

  @override
  String get lkReasonVehicleFull => 'Vehicle full';

  @override
  String get lkEmpty => 'Nothing to look at for these dates';

  @override
  String calWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'Mon',
      '2': 'Tue',
      '3': 'Wed',
      '4': 'Thu',
      '5': 'Fri',
      '6': 'Sat',
      '7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get isTypeSourceProblem => 'Problem at the source';

  @override
  String isDriverRole(String name) {
    return '$name (Driver)';
  }

  @override
  String isRaised(String time) {
    return 'Raised $time';
  }

  @override
  String get isOpen => 'Open';

  @override
  String get isEscalated => 'Escalated';

  @override
  String get isResolved => 'Resolved';

  @override
  String get isTypeLabel => 'Type :';

  @override
  String get isDriverNote => 'Driver’s note :';

  @override
  String get isBy => 'By :';

  @override
  String isByValue(String name, String time) {
    return '$name · $time';
  }

  @override
  String get isWhatWasDone => 'What was done :';

  @override
  String get isTold => 'Told :';

  @override
  String isToldValue(String name) {
    return 'The office and $name (IEC).';
  }

  @override
  String get isEscalate => 'Escalate';

  @override
  String get isMarkResolved => 'Mark resolved';

  @override
  String get isSheetTitle => 'Mark as resolved';

  @override
  String get isSheetBody =>
      'Say what was done. The driver and the office see it.';

  @override
  String get isWhatWasDoneLabel => 'What was done';

  @override
  String get isEscalateTitle => 'Escalate this issue?';

  @override
  String get isEscalateBody =>
      'The office and the source’s IEC are told, and it shows as Escalated. Use it when you cannot sort it out yourself.';

  @override
  String get isResolvedToastTitle => 'Issue Resolved!';

  @override
  String isResolvedToastBody(String name) {
    return '$name is told.';
  }

  @override
  String get isEscalatedToastTitle => 'Issue Escalated!';

  @override
  String get isEscalatedToastBody =>
      'The office and the source’s IEC are told.';

  @override
  String get tpStatusExpected => 'Expected';

  @override
  String get tpExpectedInfo =>
      'Trips are made the day before. This is what the routes and the pickups due that day add up to; the team can still change.';

  @override
  String tpExtra(int count) {
    return 'Extra $count';
  }

  @override
  String tpTodaySuffix(String date) {
    return '$date · Today';
  }

  @override
  String tpWarehouseClosed(String date) {
    return '$date · Warehouse closed';
  }

  @override
  String get tpNoTripsHoliday => 'No trips · warehouse holiday';
}
