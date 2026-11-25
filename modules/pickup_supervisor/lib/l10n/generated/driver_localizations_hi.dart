// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'driver_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class DriverLocalizationsHi extends DriverLocalizations {
  DriverLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get homeDateAndZone => 'बुध, 22 जुलाई · सूरत ज़ोन';

  @override
  String get warehouseName => 'मगदल्ला वेयरहाउस';

  @override
  String get onlineStatus => 'आप ऑनलाइन हैं';

  @override
  String pendingCollections(int count) {
    return '$count कलेक्शन बाकी';
  }

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get todaysSummary => 'आज का सारांश';

  @override
  String get pendingStops => 'बाकी स्टॉप';

  @override
  String get pendingStopsCount => '05';

  @override
  String get collected => 'एकत्रित';

  @override
  String collectedCount(int count) {
    return 'एकत्रित ($count)';
  }

  @override
  String get todaysTrip => 'आज की ट्रिप';

  @override
  String get vehicleRegistration => 'GJ-XX-1234';

  @override
  String stopsCompleted(int completed, int total) {
    return '$total में से $completed स्टॉप पूरे';
  }

  @override
  String get tripProgress => '37%';

  @override
  String get completedTripProgress => '100%';

  @override
  String get openMyStops => 'मेरे स्टॉप खोलें';

  @override
  String get quickAction => 'त्वरित कार्रवाई';

  @override
  String get raiseAnIssue => 'समस्या बताएं';

  @override
  String get issueDescription => 'वाहन, स्रोत या टीम की समस्या की रिपोर्ट करें';

  @override
  String get reportIssue => 'समस्या रिपोर्ट करें';

  @override
  String get homeTab => 'होम';

  @override
  String get stopsTab => 'मेरे स्टॉप';

  @override
  String get issuesTab => 'समस्याएं';

  @override
  String get profileTab => 'प्रोफ़ाइल';

  @override
  String get driverPageUnavailable => 'यह ड्राइवर पेज अभी उपलब्ध नहीं है';

  @override
  String get pendingPickupStops => 'लंबित पिकअप स्टॉप';

  @override
  String stopCardTitle(String name, String material) {
    return '$name · $material';
  }

  @override
  String get abcTextileMills => 'ABC टेक्सटाइल मिल्स';

  @override
  String get shreeSaiDairy => 'श्री साई डेयरी';

  @override
  String get xyzTextileMills => 'XYZ टेक्सटाइल मिल्स';

  @override
  String get sortedMaterial => 'छांटा हुआ';

  @override
  String get mixedMaterial => 'मिश्रित';

  @override
  String get industrialAreaSurat => 'इंडस्ट्रियल एरिया, सूरत';

  @override
  String get lpSavaniRoadSurat => 'एल.पी. सवानी रोड, सूरत';

  @override
  String get pickupSchedule => 'गुरु · सुबह 8:00–10:00';

  @override
  String get noSchedule => '--';

  @override
  String get pendingStatus => 'लंबित';

  @override
  String get skippedStatus => 'छोड़ा गया';

  @override
  String get stopDetail => 'स्टॉप विवरण';

  @override
  String get driverPhoneNumber => '+91 98765 432145';

  @override
  String get call => 'कॉल';

  @override
  String get requestInformation => 'अनुरोध की जानकारी';

  @override
  String get address => 'पता';

  @override
  String get pickupAddress =>
      'यू 9, 10, सिद्धगिरि टावर, नेवीयुग कॉलेज रोड के पीछे, नेवीयुग सोसाइटी, संगाना सोसाइटी, अडाजन, सूरत, गुजरात 395009';

  @override
  String get schedule => 'समय';

  @override
  String get material => 'सामग्री';

  @override
  String get materialItems => 'दूध की थैली, कार्ड बोर्ड';

  @override
  String get expectedWeight => 'अनुमानित वजन';

  @override
  String get expectedWeightValue => '450 किग्रा';

  @override
  String get requestStatus => 'अनुरोध स्थिति';

  @override
  String get description => 'विवरण';

  @override
  String get pickupDescription =>
      'आसान नेविगेशन के लिए मैंने Google Maps का लोकेशन लिंक जोड़ा है। कृपया सुनिश्चित करें कि अपलोड किए गए कचरे के फोटो साफ़ और आसानी से पढ़े जा सकें।';

  @override
  String get startPickup => 'पिकअप शुरू करें';

  @override
  String get mixedDriverPhoneNumber => '+91 1234567890';

  @override
  String get mixedExpectedWeightValue => '200 किग्रा';

  @override
  String get sortedWasteForm => 'छांटे हुए कचरे का फ़ॉर्म';

  @override
  String get captureMaterialScalePhoto => 'सामग्री और तराज़ू की फोटो लें';

  @override
  String get petBottles => 'PET बोतलें';

  @override
  String get hdpeRigid => 'HDPE रिजिड';

  @override
  String get eWaste => 'ई-वेस्ट';

  @override
  String get kgUnit => 'किग्रा';

  @override
  String get pcsUnit => 'नग';

  @override
  String get collectedLabel => 'एकत्रित';

  @override
  String get exampleWeight => 'जैसे 123.00';

  @override
  String get capturePhoto => 'फोटो लें';

  @override
  String get petCollectedWeight => '270.00';

  @override
  String get hdpeCollectedWeight => '270.00';

  @override
  String get eWasteCollectedCount => '25';

  @override
  String get savePickup => 'पिकअप सहेजें';

  @override
  String get mixedWasteForm => 'मिश्रित कचरे का फ़ॉर्म';

  @override
  String get enterWeightKg => 'वजन दर्ज करें (किग्रा)';

  @override
  String get mixedWeightValue => '300.00';

  @override
  String get materialAndScalePhoto => 'सामग्री और तराज़ू की फोटो';

  @override
  String get supportedPhotoFormats => 'समर्थित: JPG, PNG (अधिकतम 5MB)।';

  @override
  String get sortedPickupForm => 'छांटे हुए पिकअप का फ़ॉर्म';

  @override
  String get successWeightValue => '240.51';

  @override
  String get materialAndWeighbridgePhoto => 'सामग्री और वेब्रिज की फोटो';

  @override
  String get pickupRecorded => 'पिकअप दर्ज हुआ';

  @override
  String get successfully => 'सफलतापूर्वक!';

  @override
  String get pickupSuccessMessage =>
      'पिकअप सफलतापूर्वक सहेजा गया है। स्थिति आपकी ट्रिप में अपडेट हो जाएगी।';

  @override
  String get backToList => 'सूची पर वापस जाएं';

  @override
  String get selectProblemsStruggling =>
      'आप जिन समस्याओं से जूझ रहे हैं उन्हें चुनें';

  @override
  String get vehicleBreakdown => 'वाहन खराब होना';

  @override
  String get accident => 'दुर्घटना';

  @override
  String get sourceProblem => 'स्रोत की समस्या';

  @override
  String get otherIssue => 'अन्य';

  @override
  String get remarks => 'टिप्पणियां';

  @override
  String get addYourRemarks => 'अपनी टिप्पणियां जोड़ें...';

  @override
  String get max150Characters => 'अधिकतम 150 अक्षर';

  @override
  String get submitIssue => 'समस्या सबमिट करें';

  @override
  String get yourPickupSupervisor => 'आपके पिकअप सुपरवाइज़र';

  @override
  String get supervisorName => 'किरण शाह';

  @override
  String get message => 'संदेश';

  @override
  String get collectedToday => 'आज एकत्रित';

  @override
  String get collectedWeight420 => 'अब तक 420 किग्रा';

  @override
  String get collectedWeightZero => '0 किग्रा';

  @override
  String get zeroKg => '0 किग्रा';

  @override
  String get cancelled => 'रद्द';

  @override
  String todaysTripsCount(int count) {
    return 'आज की ट्रिप्स ($count)';
  }

  @override
  String get todaysTrips => 'आज की ट्रिप्स';

  @override
  String get tripMorning => 'ट्रिप 1 · सुबह';

  @override
  String get tripAfternoon => 'ट्रिप 2 · दोपहर';

  @override
  String get morningTripTime => 'सुबह 7:00 – 11:00 · 7 स्टॉप';

  @override
  String get afternoonTripTime => 'दोपहर 2:00 – 5:00 · 6 स्टॉप';

  @override
  String get afternoonStartTime => 'दोपहर 2:00';

  @override
  String get onTheWay => 'रास्ते में';

  @override
  String startsAt(String time) {
    return '$time बजे शुरू';
  }

  @override
  String get delivered => 'पहुंचाया गया';

  @override
  String get vehicleCrew => 'GJ-XX-1234 · सुरेश, महेश';

  @override
  String get dropMagdalla => 'मगदल्ला वेयरहाउस पर ड्रॉप';

  @override
  String get dropSachin => 'सचिन वेयरहाउस पर ड्रॉप';

  @override
  String get collectedOnTrip => 'इस ट्रिप में एकत्रित';

  @override
  String get weight420Kg => '420 किग्रा';

  @override
  String get weight180Kg => '180 किग्रा';

  @override
  String stopsDone(int completed, int total) {
    return '$total में से $completed स्टॉप पूरे';
  }

  @override
  String seeAllStops(int count) {
    return 'सभी $count स्टॉप देखें';
  }

  @override
  String nextStopOnTrip(int trip) {
    return 'ट्रिप $trip का अगला स्टॉप';
  }

  @override
  String afterThat(int count) {
    return 'उसके बाद ($count)';
  }

  @override
  String get laterToday => 'आज बाद में';

  @override
  String get earlierToday => 'आज पहले';

  @override
  String stopPosition(int current, int total) {
    return 'स्टॉप $current / $total';
  }

  @override
  String get nextStop => 'अगला स्टॉप';

  @override
  String get enterCollection => 'कलेक्शन दर्ज करें';

  @override
  String opensAfterStop(int stop) {
    return 'स्टॉप $stop के बाद खुलेगा';
  }

  @override
  String unlockAfterStop(int stop) {
    return 'स्टॉप $stop पूरा होने या इस स्टॉप पर पहुंचने (GPS) पर खुलेगा। स्थान जांचने के लिए टैप करें।';
  }

  @override
  String get handedOverWeight => 'सौंपा गया · शुद्ध 1,240 किग्रा';

  @override
  String get royalResidency => 'रॉयल रेसिडेंसी';

  @override
  String get shantiNagar => 'शांति नगर';

  @override
  String get ghodDodRoadSurat => 'घोड़ दौड़ रोड, सूरत';

  @override
  String get citylightRoadSurat => 'सिटीलाइट रोड, सूरत';

  @override
  String get rakeshStoreManager => 'राकेश शाह · स्टोर मैनेजर';

  @override
  String get maheshOwner => 'महेश देसाई · मालिक';

  @override
  String get priyaSecretary => 'प्रिया पटेल · सचिव';

  @override
  String get meenaSecretary => 'मीना देसाई · सचिव';

  @override
  String get pickupSchedule9to11 => 'गुरु · सुबह 9:00–11:00';

  @override
  String get pickupSchedule3to330 => 'गुरु · दोपहर 3:00–3:30';

  @override
  String get pickupSchedule330to4 => 'गुरु · दोपहर 3:30–4:00';

  @override
  String get noTripToday => 'आज कोई ट्रिप नहीं';

  @override
  String get noTripMessage =>
      'किरण शाह ने आज आपको किसी ट्रिप पर नहीं रखा है। ट्रिप जुड़ने पर आपको संदेश मिलेगा।';

  @override
  String get tripOneStops => 'ट्रिप 1 स्टॉप्स';

  @override
  String get morningTripWindow => 'सुबह · 7:00 – 11:00 बजे';

  @override
  String get fiveOfSevenDone => '7 में से 5 पूरे';

  @override
  String stillToCollect(int count) {
    return 'अभी संग्रह बाकी ($count)';
  }

  @override
  String doneStops(int count) {
    return 'पूर्ण ($count)';
  }

  @override
  String stopNumber(int number) {
    return 'स्टॉप $number';
  }

  @override
  String get hotelRajdhani => 'होटल राजधानी';

  @override
  String get greenParkSociety => 'ग्रीन पार्क सोसायटी';

  @override
  String get navratriGroundEvent => 'नवरात्रि ग्राउंड (कार्यक्रम)';

  @override
  String get cityBakery => 'सिटी बेकरी';

  @override
  String get hotelRajdhaniWeight => '85 किग्रा';

  @override
  String get greenParkWeight => '120 किग्रा';

  @override
  String get navratriGroundWeight => '215 किग्रा';

  @override
  String get noMaterialToday => 'आज कोई सामग्री नहीं';

  @override
  String get cancelledBySource => 'स्रोत द्वारा रद्द';

  @override
  String get stockTakingReason => 'स्टॉक गणना के लिए बंद';

  @override
  String get unlockStopMessage =>
      'स्टॉप 6 पूरा होने या इस स्टॉप पर पहुँचने (GPS) पर खुलेगा। अपना स्थान जाँचने के लिए टैप करें।';

  @override
  String get stopTwoCollection => 'स्टॉप 2 · संग्रह';

  @override
  String get savedAt => 'सुबह 7:52 बजे सेव किया · गुरु 22 जुलाई';

  @override
  String get whatYouSaved => 'आपने जो सेव किया';

  @override
  String get cardboard => 'कार्डबोर्ड';

  @override
  String get petBottlesWeight => '50 किग्रा';

  @override
  String get cardboardWeight => '35 किग्रा';

  @override
  String get photosMaterialScale => 'फोटो (सामग्री और तराजू)';

  @override
  String get askSupervisorToCorrect => 'सुधार के लिए सुपरवाइज़र से कहें';

  @override
  String get savedCollectionReadonlyMessage =>
      'आप सेव किया हुआ संग्रह केवल देख सकते हैं। कुछ गलत हो तो अपने सुपरवाइज़र से कहें; वे फोटो से जाँच कर उसे सुधारेंगे।';

  @override
  String get askToCorrect => 'सुधार के लिए कहें';

  @override
  String get whatIsWrongAtStop => 'क्या गलत है? होटल राजधानी · स्टॉप 2';

  @override
  String get correctionWeight => 'वज़न';

  @override
  String get correctionItem => 'वस्तु';

  @override
  String get correctionPhoto => 'फोटो';

  @override
  String get correctionOther => 'अन्य';

  @override
  String get rightValueAndNote => 'सही मान और टिप्पणी';

  @override
  String get correctionNoteExample =>
      'उदाहरण: PET बोतलें 50 नहीं, 60 किग्रा थीं। तराजू के फोटो में 60 किग्रा दिखता है।';

  @override
  String get sendToSupervisor => 'सुपरवाइज़र को भेजें';

  @override
  String get requestSent => 'अनुरोध भेजा गया';

  @override
  String get toYourSupervisor => 'आपके सुपरवाइज़र को';

  @override
  String get correctionRequestSummary =>
      'होटल राजधानी · वज़न · 50 किग्रा → 60 किग्रा';

  @override
  String get whatHappensNext => 'आगे क्या होगा';

  @override
  String get supervisorChecksPhotos => 'किरण शाह आपके फोटो से इसकी जाँच करेंगे';

  @override
  String get correctionRequestedUntil =>
      'तब तक स्टॉप पर “सुधार अनुरोधित” दिखाई देगा';

  @override
  String get correctionNotification => 'सुधार होने पर आपको सूचना मिलेगी';

  @override
  String get backToMyStops => 'मेरे स्टॉप्स पर वापस जाएँ';

  @override
  String get backToHome => 'होम पर वापस जाएँ';

  @override
  String get stopTripPosition => '7 में से स्टॉप 6 · ट्रिप 1';

  @override
  String get personAtPickupPoint => 'पिकअप स्थान पर व्यक्ति';

  @override
  String get rakeshShah => 'राकेश शाह';

  @override
  String get storeManager => 'स्टोर मैनेजर';

  @override
  String get pickupContactPhone => '+91 98765 43214';

  @override
  String get nothingToCollectWeight => 'संग्रह के लिए कुछ नहीं (0 किग्रा)';

  @override
  String get nothingToCollect => 'संग्रह के लिए कुछ नहीं';

  @override
  String get abcStopSixOfSeven => 'ABC टेक्सटाइल मिल्स · 7 में से स्टॉप 6';

  @override
  String get savedAsZeroKgMessage => 'यह स्टॉप 0 किग्रा के रूप में सेव होगा।';

  @override
  String get whyNothingCollected => 'कुछ भी एकत्र क्यों नहीं हुआ?';

  @override
  String get reasonClosed => 'बंद था';

  @override
  String get reasonRefused => 'देने से मना किया';

  @override
  String get reasonNotReachable => 'संपर्क नहीं हुआ';

  @override
  String get reasonVehicleFull => 'वाहन भरा हुआ है';

  @override
  String get photoOptional => 'फोटो (वैकल्पिक)';

  @override
  String get noteForSupervisorOptional => 'सुपरवाइज़र के लिए नोट (वैकल्पिक)';

  @override
  String get typeANote => 'नोट लिखें…';

  @override
  String get holdToRecordVoiceNote => 'वॉइस नोट रिकॉर्ड करने के लिए दबाए रखें';

  @override
  String get upToOneMinute => '1 मिनट तक';

  @override
  String get voiceNoteZeroTime => '0:00';

  @override
  String get recordingVoiceNote => 'वॉइस नोट रिकॉर्ड हो रहा है…';

  @override
  String get voiceNoteRecorded => 'वॉइस नोट रिकॉर्ड हो गया';

  @override
  String get playVoiceNote => 'वॉइस नोट चलाएँ';

  @override
  String get pauseVoiceNote => 'वॉइस नोट रोकें';

  @override
  String get removeVoiceNote => 'वॉइस नोट हटाएँ';

  @override
  String get voiceNotePlaybackFailed =>
      'वॉइस नोट चल नहीं सका। कृपया फिर से कोशिश करें।';

  @override
  String get microphonePermissionRequired =>
      'वॉइस नोट रिकॉर्ड करने के लिए माइक्रोफ़ोन की अनुमति आवश्यक है।';

  @override
  String get voiceNoteRecordingFailed =>
      'वॉइस नोट रिकॉर्ड नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get locationMatched => 'स्थान मेल खाता है';

  @override
  String get locationNotMatched => 'स्थान मेल नहीं खाता';

  @override
  String get sortedStopSixOfSeven => '7 में से स्टॉप 6 · छांटा हुआ';

  @override
  String get mixedStopSevenOfSeven => '7 में से स्टॉप 7 · मिश्रित';

  @override
  String get recordedLaterWarning =>
      'बाद में दर्ज किया गया: आप अभी इस स्टॉप पर नहीं हैं। सुपरवाइज़र और गेट यह नोट देख सकते हैं।';

  @override
  String get saveAsZeroKg => '0 किग्रा के रूप में सेव करें';

  @override
  String get orderedPickupStops => 'क्रमबद्ध पिकअप स्टॉप';

  @override
  String get startYourCollections => 'अपना कलेक्शन शुरू करें';

  @override
  String get searchHere => 'यहाँ खोजें...';

  @override
  String pendingCount(int count) {
    return 'बाकी ($count)';
  }

  @override
  String get yashTextileHub => 'यश टेक्सटाइल हब';

  @override
  String get anjanaFarmAreaSurat => 'अंजना फार्म क्षेत्र, सूरत';

  @override
  String get collectionWindowNineToTen => '09:00 AM - 10:00 AM';

  @override
  String get materialSortedLabel => 'सामग्री : छँटी हुई';

  @override
  String get findingYourLocationStatus => 'आपका स्थान खोज रहे हैं…';

  @override
  String get findingYourLocation => 'आपका स्थान खोज रहे हैं';

  @override
  String get findingLocationMessage =>
      'पिकअप पॉइंट के पास खड़े रहें। इसमें कुछ सेकंड लगेंगे।';

  @override
  String get cancelAction => 'रद्द करें';

  @override
  String get locationDetected => 'स्थान मिल गया';

  @override
  String get notHere => 'यहाँ नहीं';

  @override
  String get startCollection => 'कलेक्शन शुरू करें';

  @override
  String stopsNearby(int count) {
    return 'पास में $count स्टॉप';
  }

  @override
  String get whichStopAreYouAt => 'आप किस स्टॉप पर हैं?';

  @override
  String get twoStopsCloseMessage => 'आपकी यात्रा के दो स्टॉप आपके पास हैं।';

  @override
  String get distanceStopSeven => '40 मी दूर · स्टॉप 7';

  @override
  String get distanceAlreadyCollected => '85 मी दूर · पहले ही एकत्रित';

  @override
  String get continueAction => 'जारी रखें';

  @override
  String get noStopFoundHere => 'यहाँ कोई स्टॉप नहीं मिला';

  @override
  String get notAtTripStop => 'आप इस यात्रा के किसी स्टॉप पर नहीं हैं';

  @override
  String get notAtStopMessage =>
      'पास जाएँ और फिर कोशिश करें, स्टॉप स्वयं चुनें या गेट टीम के लिए छोड़ दें।';

  @override
  String get tryAgain => 'फिर कोशिश करें';

  @override
  String get chooseStopMyself => 'स्टॉप स्वयं चुनें';

  @override
  String get gateTeamWillEnter => 'गेट टीम दर्ज करेगी';

  @override
  String get locationIsOff => 'स्थान बंद है';

  @override
  String get turnOnLocation => 'स्थान चालू करें';

  @override
  String get locationOffMessage =>
      'ऐप आपके स्थान से स्टॉप खोजता है। पिकअप दर्ज करने के लिए इसे चालू करें।';

  @override
  String get shreeSaiStopSeven => 'श्री साई डेयरी · 7 में से स्टॉप 7';

  @override
  String get gateTeamEntryMessage =>
      'बैक ऑफिस वेयरहाउस गेट पर इस पिकअप को दर्ज करता है।';

  @override
  String get weightYouNotedOptional => 'आपके द्वारा नोट किया वजन (वैकल्पिक)';

  @override
  String get aboutThreeHundred => 'लगभग 300';

  @override
  String get gateWeightHelp =>
      'अनुमानित आँकड़ा गेट टीम की मदद करता है। वे गेट पर फिर वजन करते हैं।';

  @override
  String get markForGateTeam => 'गेट टीम के लिए चिह्नित करें';

  @override
  String get nextPickupSavedMessage =>
      'ABC टेक्सटाइल मिल्स · 540 किग्रा + 25 नग सेव हुए।';

  @override
  String get lastPickupSavedMessage => 'श्री साई डेयरी · 300 किग्रा सेव हुआ।';

  @override
  String get nextStopSevenOfSeven => 'अगला स्टॉप · 7 में से 7';

  @override
  String get nextStopDistance => 'एल.पी. सवाणी रोड, सूरत · 1.2 किमी';

  @override
  String get goToNextStop => 'अगले स्टॉप पर जाएँ';

  @override
  String get allTripStopsDone => 'यात्रा 1 के सभी 7 स्टॉप पूरे';

  @override
  String get takeLoadToWarehouse => 'लोड मगदल्ला वेयरहाउस ले जाएँ';

  @override
  String get vehicleLoadTotal => 'वाहन में 1,260 किग्रा + 25 नग';

  @override
  String get warehouseDistance => 'मगदल्ला, सूरत · 6.4 किमी';

  @override
  String get viewTripSummary => 'यात्रा सारांश देखें';

  @override
  String get tripOneSummary => 'ट्रिप 1 सारांश';

  @override
  String get allStopsDone => 'सभी स्टॉप पूरे';

  @override
  String get tripCollectedTotal => '1,260 किग्रा + 25 नग';

  @override
  String get mixedWaste => 'मिश्रित कचरा';

  @override
  String get weight635Kg => '635 किग्रा';

  @override
  String get weight270Kg => '270 किग्रा';

  @override
  String get weight85Kg => '85 किग्रा';

  @override
  String get count25Pcs => '25 नग';

  @override
  String get dropAt => 'यहाँ उतारें';

  @override
  String get warehouseAddressDistance => 'मगदल्ला पोर्ट रोड, सूरत · 6.4 किमी';

  @override
  String get openInMaps => 'मैप में खोलें';

  @override
  String get callWarehouse => 'वेयरहाउस को कॉल करें';

  @override
  String get notCollectedTwo => 'एकत्र नहीं हुआ (2)';

  @override
  String get closedForStockTaking => 'स्टॉक गिनती के लिए बंद';

  @override
  String get handOverAtWarehouse => 'वेयरहाउस में सौंपें';

  @override
  String get warehouseGateInstruction =>
      'वेयरहाउस गेट पर टैप करें। आप बैग की संख्या दर्ज करते हैं; वेयरहाउस इंचार्ज वाहन का वजन करता है।';

  @override
  String get handOverTripOne => 'सौंपें · ट्रिप 1';

  @override
  String get yourCountFromStops => 'आपकी गिनती (स्टॉप से)';

  @override
  String get numberOfBags => 'बैग की संख्या';

  @override
  String get bagsUnit => 'बैग';

  @override
  String get bagsCount => '42';

  @override
  String get bagsHelp =>
      'उतारे गए बैग गिनें। ई-वेस्ट जैसी खुली वस्तुएँ नग में गिनी जाती हैं।';

  @override
  String get handOver => 'सौंपें';

  @override
  String get warehouseWeighInstruction =>
      'वेयरहाउस इंचार्ज लोड जाँचता है और वेब्रिज पर वाहन का वजन करता है। सेव होने पर वजन यहाँ दिखेगा।';

  @override
  String get tripAtWarehouse => 'ट्रिप 1 · वेयरहाउस पर';

  @override
  String get waitingStatus => 'प्रतीक्षा';

  @override
  String get vehicleAtWarehouseSince => 'GJ-XX-1234 · 11:20 से मगदल्ला पर';

  @override
  String get youHandedOver => 'आपने सौंपा';

  @override
  String get handedOverTotal => '1,260 किग्रा + 25 नग · 42 बैग';

  @override
  String get waitingWarehouseInstruction =>
      '11:20 बजे सौंपा गया। वेयरहाउस इंचार्ज वाहन का वजन कर रहा है; सेव होने पर वेब्रिज वजन यहाँ दिखेगा।';

  @override
  String get tripReceived => 'ट्रिप 1 · प्राप्त';

  @override
  String get receivedStatus => 'प्राप्त';

  @override
  String get vehicleAtWarehouse => 'GJ-XX-1234 · मगदल्ला वेयरहाउस';

  @override
  String get weighbridgeEnteredByWarehouse => 'वेब्रिज · वेयरहाउस द्वारा दर्ज';

  @override
  String get warehouseReceivedTotal => '1,240 किग्रा नेट + 25 नग';

  @override
  String get withLoadGross => 'लोड सहित (ग्रॉस)';

  @override
  String get weight8940Kg => '8,940 किग्रा';

  @override
  String get emptyVehicle => 'खाली वाहन';

  @override
  String get weight7700Kg => '7,700 किग्रा';

  @override
  String get netWeight => 'नेट वजन';

  @override
  String get weight1240Kg => '1,240 किग्रा';

  @override
  String get bagsReceived => 'प्राप्त बैग';

  @override
  String get eWasteCounted => 'ई-वेस्ट (गिना हुआ)';

  @override
  String get yourCountVsWeighbridge => 'आपकी गिनती और वेब्रिज';

  @override
  String get yourCount => 'आपकी गिनती';

  @override
  String get weight1260Kg => '1,260 किग्रा';

  @override
  String get weighbridgeNet => 'वेब्रिज नेट';

  @override
  String get difference => 'अंतर';

  @override
  String get weightDifference => '−20 किग्रा (1.6% कम)';

  @override
  String get receivedWarehouseInstruction =>
      '11:42 बजे वेयरहाउस इंचार्ज रमेश पटेल ने प्राप्त किया। अंतर गलत लगे तो समस्या दर्ज करें।';

  @override
  String get supervisorWelcomeBack => 'वापसी पर स्वागत है';

  @override
  String get supervisorHeaderSubtitle =>
      'गुरु 22 अक्तू 2026 · अडाजन, वेसु, पाल';

  @override
  String get supervisorOnline => 'आप ऑनलाइन हैं';

  @override
  String get supervisorLastSynced => 'अंतिम सिंक 2 मिनट पहले';

  @override
  String get supervisorSyncNow => 'अभी सिंक करें';

  @override
  String get supervisorNeedsAttention => 'आपके ध्यान की ज़रूरत है';

  @override
  String get supervisorAttentionSubtitle => 'पहले इन्हें मंज़ूर, हल या जाँचें';

  @override
  String get supervisorApprovals => 'मंज़ूरियाँ';

  @override
  String get supervisorIssues => 'समस्याएँ';

  @override
  String get supervisorMyRequests => 'मेरे अनुरोध';

  @override
  String get supervisorFlags => 'फ़्लैग';

  @override
  String get supervisorCollectionSummary => 'कलेक्शन सारांश';

  @override
  String get supervisorToday => 'आज';

  @override
  String get supervisorYesterday => 'कल';

  @override
  String get supervisorWeek => 'सप्ताह';

  @override
  String get supervisorMonth => 'महीना';

  @override
  String get supervisorCollectedToday => 'आज एकत्रित · 16 में से 12 स्टॉप';

  @override
  String get supervisorCollectedTotal => '320 किग्रा + 125 नग';

  @override
  String get supervisorCollected => 'एकत्रित';

  @override
  String get supervisorKg => '0 किग्रा';

  @override
  String get supervisorMissed => 'छूटे';

  @override
  String get supervisorCancelled => 'रद्द';

  @override
  String get supervisorTripsClosed => 'बंद ट्रिप';

  @override
  String get supervisorViewFullReport => 'पूरी रिपोर्ट देखें';

  @override
  String get supervisorTodaysTrips => 'आज की ट्रिप';

  @override
  String get supervisorTripsSubtitle => 'आज 5 ट्रिप · अगली 2 नीचे हैं';

  @override
  String get supervisorAdajanMorning => 'अडाजन सुबह';

  @override
  String get supervisorVikramProgress => 'विक्रम सिंह  •  8 में से 3 एकत्रित';

  @override
  String get supervisorOwnVehicle => 'अपना वाहन';

  @override
  String get supervisorDailyWeekly => 'दैनिक 5 · साप्ताहिक 3';

  @override
  String get supervisorCallDriver => 'ड्राइवर को कॉल करें';

  @override
  String get supervisorPalGamMorning => 'पाल गाँव सुबह';

  @override
  String get supervisorAmitProgress => 'अमित पटेल  •  ऐप में 8 में से 0 दर्ज';

  @override
  String get supervisorDriverNotSetUp => 'ड्राइवर ऐप का उपयोग नहीं कर रहा';

  @override
  String get supervisorSeeTripsPlan => 'ट्रिप प्लान देखें';

  @override
  String get supervisorPickupPoints => 'मेरे पिकअप पॉइंट';

  @override
  String get supervisorPickupPointsSubtitle =>
      'अडाजन, वेसु, पाल में 79 · श्रेणी अनुसार';

  @override
  String get supervisorDaily => 'दैनिक';

  @override
  String get supervisorWeekly => 'साप्ताहिक';

  @override
  String get supervisorBiWeekly => 'पाक्षिक';

  @override
  String get supervisorMonthly => 'मासिक';

  @override
  String get supervisorOnCall => 'कॉल पर';

  @override
  String get supervisorQuickActions => 'त्वरित कार्य';

  @override
  String get supervisorUnassignedSources => 'बिना असाइन स्रोत';

  @override
  String get supervisorManageUnassigned =>
      'जिन पिकअप पॉइंट का अभी कोई रूट नहीं';

  @override
  String get supervisorViewSource => 'स्रोत देखें';

  @override
  String get supervisorExtraPickupRequests => 'अतिरिक्त पिकअप अनुरोध';

  @override
  String get supervisorManageExtraPickup => 'अतिरिक्त पिकअप स्रोत संभालें';

  @override
  String get supervisorViewPickups => 'पिकअप देखें';

  @override
  String get supervisorAskCollectionHead => 'कलेक्शन हेड से पूछें';

  @override
  String get supervisorAskCollectionHeadSubtitle =>
      'वाहन, श्रमिक या पिकअप पॉइंट बदलाव';

  @override
  String get supervisorNewRequest => 'नया अनुरोध';

  @override
  String get supervisorSuggestions => 'सुझाव';

  @override
  String get supervisorSuggestionsSubtitle =>
      'दूरी और समय बचाने के तरीके (कॉन्सेप्ट)';

  @override
  String get supervisorSeeSuggestions => 'सुझाव देखें';

  @override
  String get supervisorHome => 'होम';

  @override
  String get attentionApprovalRequests => 'मंज़ूरी अनुरोध';

  @override
  String get attentionApprovalSubtitle =>
      'आपके ड्राइवरों और IEC एक्ज़ीक्यूटिव से';

  @override
  String get attentionToApproveCount => 'मंज़ूरी के लिए 3';

  @override
  String get attentionDoneCount => 'पूर्ण 12';

  @override
  String get attentionCorrectionFromDriver => 'सुधार · ड्राइवर से';

  @override
  String get attentionWaiting => 'प्रतीक्षा में';

  @override
  String get attentionHotelRajdhaniStop =>
      'होटल राजधानी · अडाजन मॉर्निंग, स्टॉप 2';

  @override
  String get attentionDriverCorrectionDetail =>
      'PET बोतलें 50 kg → 60 kg. विक्रम सिंह: “तराज़ू की फ़ोटो में 60 kg दिख रहा है।”';

  @override
  String get attentionSentToday => 'आज, 10:05 am भेजा';

  @override
  String get attentionDecline => 'अस्वीकार करें';

  @override
  String get attentionApprove => 'मंज़ूर करें';

  @override
  String get attentionExtraPickup => 'अतिरिक्त पिकअप';

  @override
  String get attentionAbcPlastic => 'ABC प्लास्टिक मैन्युफैक्चर';

  @override
  String get attentionExtraPickupDetail =>
      'शनि 25 अक्टू, सुबह 10 – दोपहर 12 · लगभग 40 kg · अडाजण मॉर्निंग में फ़िट';

  @override
  String get attentionSent21Oct => '21 अक्तू भेजा';

  @override
  String get attentionCorrectionFromPickupPoint => 'सुधार · पिकअप पॉइंट से';

  @override
  String get attentionGreenParkSociety => 'ग्रीन पार्क सोसायटी';

  @override
  String get attentionPickupPointCorrectionDetail =>
      '19 अक्तू के पिकअप में कार्डबोर्ड 20 किग्रा → 25 किग्रा';

  @override
  String get attentionSent20Oct => '20 अक्तू भेजा';

  @override
  String get attentionCorrectionApproved => 'सुधार मंज़ूर हुआ';

  @override
  String get attentionCorrectionApprovedMessage =>
      'होटल राजधानी के रिकॉर्ड में अब PET बोतलें 60 kg हैं। विक्रम सिंह को बता दिया गया है।';

  @override
  String get attentionBackToApprovals => 'मंज़ूरी अनुरोध पर वापस जाएँ';

  @override
  String get attentionBackToHome => 'होम पर वापस जाएँ';

  @override
  String get attentionMyRequests => 'मेरे अनुरोध';

  @override
  String get attentionToCollectionHead => 'कलेक्शन हेड को';

  @override
  String get attentionAll4 => 'सभी 4';

  @override
  String get attentionWaiting1 => 'प्रतीक्षा 1';

  @override
  String get attentionApproved2 => 'मंज़ूर 2';

  @override
  String get attentionDeclined1 => 'अस्वीकृत 1';

  @override
  String get attentionVehicleAdajan => 'वाहन · अडाजन मॉर्निंग';

  @override
  String get attentionVehicleRequestDescription =>
      'शनि 25 और रवि 26 अक्तू को दूसरा वाहन: नवरात्रि ग्राउंड में लगभग 2 टन अपेक्षित';

  @override
  String get attentionVehicleRequestResponse =>
      'अरविंद देसाई (कलेक्शन हेड) के साथ';

  @override
  String get attentionSentTodayShort => 'आज भेजा';

  @override
  String get attentionLabourPalGam => 'श्रमिक · पाल गाम मॉर्निंग';

  @override
  String get attentionLabourRequestDescription =>
      '3 दिनों के लिए एक और लोडर (20–22 अक्तू)';

  @override
  String get attentionLabourRequestResponse =>
      'अरविंद देसाई: “रमेश यादव कल से जुड़ेंगे।”';

  @override
  String get attentionSent19Oct => '19 अक्तू भेजा';

  @override
  String get attentionPauseHotelShivam => 'पिकअप पॉइंट रोकें · होटल शिवम';

  @override
  String get attentionPauseRequestDescription =>
      '1 – 10 नवम्बर · नवीनीकरण के लिए बंद';

  @override
  String get attentionPauseRequestResponse =>
      'अरविंद देसाई: “मंज़ूर। IEC एग्ज़ीक्यूटिव को बता दिया गया है।”';

  @override
  String get attentionSent18Oct => '18 अक्तू भेजा';

  @override
  String get attentionStartSunriseSchool =>
      'पिकअप पॉइंट शुरू करें · सनराइज़ स्कूल';

  @override
  String get attentionStartRequestDescription =>
      '1 नवम्बर से पुनागाम फुलडे पर प्रतिदिन';

  @override
  String get attentionStartRequestResponse =>
      'अरविंद देसाई: “उस ट्रिप में जगह नहीं है। रांदेर ईवनिंग आज़माएँ।”';

  @override
  String get attentionSent16Oct => '16 अक्तू भेजा';

  @override
  String get attentionApproved => 'मंज़ूर';

  @override
  String get attentionDeclined => 'अस्वीकृत';

  @override
  String get attentionSuggestions => 'सुझाव';

  @override
  String get attentionSuggestionsSubtitle =>
      'कॉन्सेप्ट · GPS, रूट और क्षेत्रों के विचार';

  @override
  String get attentionAll3 => 'सभी 3';

  @override
  String get attentionMoveHotelRajdhani =>
      'होटल राजधानी को पाल गाम मॉर्निंग में ले जाएँ';

  @override
  String get attentionMoveHotelDescription =>
      'यह अडाजन मॉर्निंग से 3.1 किमी दूर है; पाल गाम मॉर्निंग इसके गेट से गुजरता है';

  @override
  String get attentionMoveHotelRoute => 'अडाजन मॉर्निंग → पाल गाम मॉर्निंग';

  @override
  String get attentionSaving31Km => 'प्रतिदिन 3.1 किमी कम';

  @override
  String get attentionReorderAdajan => 'अडाजन मॉर्निंग का क्रम बदलें';

  @override
  String get attentionReorderDescription =>
      'ग्रीन पार्क सोसायटी से पहले ओम स्वीट्स जाएँ';

  @override
  String get attentionReorderSecondary => 'वही स्टॉप, छोटा रास्ता';

  @override
  String get attentionSaving12Min => 'प्रतिदिन 12 मिनट कम';

  @override
  String get attentionCombineFridayRoutes =>
      'शुक्रवार को रांदेर और वेसु ईवनिंग: एक वाहन';

  @override
  String get attentionCombineDescription =>
      'शुक्रवार को दोनों आधे से कम भरे होते हैं (310 किग्रा और 280 किग्रा)';

  @override
  String get attentionCombineSecondary =>
      'शुक्रवार को GJ-05-EE-1001 खाली होता है';

  @override
  String get attentionSavingOneVehicle => 'शुक्रवार को एक वाहन कम';

  @override
  String get attentionLast30Days => 'GPS के पिछले 30 दिन';

  @override
  String get attentionDismiss => 'हटाएँ';

  @override
  String get attentionApply => 'लागू करें';

  @override
  String get attentionIssues => 'समस्याएँ';

  @override
  String get attentionVehicleBreakdown => 'वाहन खराब';

  @override
  String get attentionSourceClosed => 'स्रोत बंद';

  @override
  String get attentionRameshDriver => 'रमेश आहिर (ड्राइवर)';

  @override
  String get attentionMohanDriver => 'मोहन लाल (ड्राइवर)';

  @override
  String get attentionPrakashDriver => 'प्रकाश जादव (ड्राइवर)';

  @override
  String get attentionVehicleNumber => 'GJ-05-BX-1234';

  @override
  String get attentionDriver => 'ड्राइवर';

  @override
  String get attentionRameshAhir => 'रमेश आहिर';

  @override
  String get attentionContactNumber => 'संपर्क नंबर';

  @override
  String get attentionPhoneNumber => '9876543210';

  @override
  String get attentionRoute => 'रूट';

  @override
  String get attentionAdajanMorning => 'अडाजन मॉर्निंग';

  @override
  String get attentionReasonFor => 'कारण: ';

  @override
  String get attentionIssueWord => 'समस्या';

  @override
  String get attentionIssueReason => 'कारण : कोई वाहन उपलब्ध नहीं';

  @override
  String get attentionIssueRemarks =>
      'टिप्पणी : यार्ड के सभी ट्रक अभी बाहर हैं। दोपहर 2 बजे के बाद प्रयास करें।';

  @override
  String get flagTimeClash => 'समय टकराव';

  @override
  String get flagHotelRajdhaniTime => 'होटल राजधानी · 1:30 pm बनाम 9–11 am';

  @override
  String get flagOffRoute => 'रूट से बाहर';

  @override
  String get flagSunriseOffRoute => 'सनराइज़ स्कूल · रूट से 4.2 किमी दूर';

  @override
  String get flagScheduleChanged => 'समय-सारणी बदली';

  @override
  String get flagAdajanTextileSorted => 'अडाजन टेक्सटाइल मिल · सुलझाया गया';

  @override
  String get flagSourcePaused => 'स्रोत रोका गया';

  @override
  String get flagClosedForDiwali => 'दिवाली के लिए बंद';

  @override
  String get flagNewSourceNoRoute => 'नया स्रोत, कोई रूट नहीं';

  @override
  String get flagAbcTextileMills => 'ABC टेक्सटाइल मिल्स';

  @override
  String get flagExtraPickupNoRoute => 'अतिरिक्त पिकअप, कोई रूट नहीं';

  @override
  String get flagExtraPickupNoRouteDetail => 'अतिरिक्त पिकअप, कोई रूट नहीं';

  @override
  String get flagShreeSaiSorted => 'श्री साई डेयरी · सुलझाया गया';

  @override
  String get flagSourceMovedToYou => 'स्रोत आपको दिया गया';

  @override
  String get flagRkTrading => 'R.K ट्रेडिंग एंड कंपनी';

  @override
  String get flagNothingToCheck => 'जाँचने के लिए कुछ नहीं!';

  @override
  String get flagOctober => 'अक्तूबर';

  @override
  String get flagNothingToCheckSubtitle =>
      'अभी कोई नई सूचना या लंबित कार्रवाई नहीं है।';

  @override
  String get flagShreeSaiDairy => 'श्री साई डेयरी';

  @override
  String get flagShreeSaiAddress => 'U 9, 10, सिद्धगिरि टावर, B/H नवयुग...';

  @override
  String get flagWas => 'पहले';

  @override
  String get flagOldSchedule => 'सोम, गुरु · 8–10 am';

  @override
  String get flagNow => 'अब';

  @override
  String get flagNewSchedule => 'सोम, बुध · 9–11 am';

  @override
  String get flagFromMon2Nov => 'से : सोम 2 नवम्बर';

  @override
  String get flagPausedDates => '20–26 अक्तू तक रोका गया';

  @override
  String get flagReasonClosedForDiwali => 'कारण: दिवाली के लिए बंद';

  @override
  String get flagMovedFromVesu => 'वेसु क्षेत्र से स्थानांतरित';

  @override
  String get flagCheckRoute => 'रूट जाँचें';

  @override
  String get flagAddToRoute => 'रूट में जोड़ें';

  @override
  String get flagMarkDone => 'पूर्ण चिह्नित करें';

  @override
  String get flagDone => 'पूर्ण';

  @override
  String get sourcesNavLabel => 'स्रोत';

  @override
  String get sourcesRoutesNavLabel => 'रूट';

  @override
  String get sourcesProfileNavLabel => 'प्रोफ़ाइल';

  @override
  String get routesTitle => 'रूट्स';

  @override
  String get routesSubtitle => 'हर दिन उनसे यात्राएँ बनाई जाती हैं';

  @override
  String get routesSearchHint => 'यहाँ खोजें...';

  @override
  String get routesEmptyMessage =>
      'अभी कोई रूट नहीं है। अपना पहला रूट बनाने के लिए + दबाएँ';

  @override
  String get routesFilterAll => 'सभी 4';

  @override
  String get routesFilterOwn => 'अपना वाहन 2';

  @override
  String get routesFilterContract => 'अनुबंध वाहन 2';

  @override
  String get routesPalGamMorning => 'पाल गाम मॉर्निंग';

  @override
  String get routesOwnVehicle => 'अपना वाहन';

  @override
  String get routesDriverNotUsingApp => 'ड्राइवर ऐप का उपयोग नहीं कर रहा';

  @override
  String get routesVehicle5678 => 'GJ-05-BX-5678';

  @override
  String get routesPalGamTime => 'सुबह (12:00 PM – 05:00 PM)';

  @override
  String get routesOnRoute => 'रूट पर';

  @override
  String get routesRecordedZero => 'ऐप में 8 में से 0 दर्ज';

  @override
  String get routesAdajanMorning => 'अडाजन मॉर्निंग';

  @override
  String get routesDailyWeekly => 'दैनिक 5 · साप्ताहिक 3';

  @override
  String get routesVehicle1234 => 'GJ-05-BX-1234';

  @override
  String get routesAdajanTime => 'सुबह (08:00 AM – 02:00 PM)';

  @override
  String get routesPlanned => 'नियोजित';

  @override
  String get routesCollectedZero => '8 में से 0 एकत्रित';

  @override
  String get routesPunagamFullDay => 'पुनागाम फुल डे';

  @override
  String get routesContractVehicle => 'अनुबंध वाहन';

  @override
  String get routesDailyMonthly => 'दैनिक 6 · मासिक 2';

  @override
  String get routesFullDayTime => 'पूरा दिन (08:00 AM – 12:00 PM)';

  @override
  String get routesApproved => 'स्वीकृत';

  @override
  String get routesCollectedEight => '8 में से 8 एकत्रित';

  @override
  String get routesRanderEvening => 'रांदेर इवनिंग';

  @override
  String get routesWeeklyBiWeekly => 'साप्ताहिक 6 · पाक्षिक 2';

  @override
  String get routesVehicle9012 => 'GJ-05-BX-9012';

  @override
  String get routesEveningTime => 'शाम (8 am–8 pm)';

  @override
  String get routesSwitchOff => 'बंद';

  @override
  String get supervisorDrawerUserName => 'किरण शाह';

  @override
  String get supervisorDrawerRole => 'पिकअप सुपरवाइज़र';

  @override
  String get supervisorDrawerUnassignedSources => 'असाइन न किए गए स्रोत';

  @override
  String get supervisorDrawerRoutes => 'रूट्स';

  @override
  String get supervisorDrawerDriversLabour => 'ड्राइवर और श्रमिक';

  @override
  String get supervisorDrawerIssues => 'समस्याएँ';

  @override
  String get supervisorDrawerExtraPickupRequests => 'अतिरिक्त पिकअप अनुरोध';

  @override
  String get supervisorDrawerSyncStatus => 'सिंक स्थिति';

  @override
  String get supervisorDrawerNotifications => 'सूचनाएँ';

  @override
  String get supervisorDrawerHelpSupport => 'सहायता और समर्थन';

  @override
  String get supervisorDrawerLogout => 'लॉग आउट';

  @override
  String get supervisorDrawerPoweredBy => 'ईको विज़न द्वारा संचालित';

  @override
  String get addRouteStep1 => 'चरण 1 में से 2';

  @override
  String get addRouteStep2 => 'चरण 2 में से 2';

  @override
  String get addRouteRouteName => 'रूट का नाम';

  @override
  String get addRouteRouteNameHint => 'उदाहरण के लिए, अडाजन मॉर्निंग';

  @override
  String get addRouteWarehouse => 'वेयरहाउस';

  @override
  String get addRouteSelectWarehouse => 'वेयरहाउस चुनें';

  @override
  String get addRouteShift => 'शिफ्ट';

  @override
  String get addRouteSelectShift => 'शिफ्ट चुनें';

  @override
  String get addRouteContinue => 'आगे बढ़ें';

  @override
  String get addRouteWarehouseAdajan => 'अडाजन सेंट्रल वेयरहाउस';

  @override
  String get addRouteWarehouseVesu => 'वेसु स्टोरेज हब';

  @override
  String get addRouteWarehouseKatargam => 'कतारगाम डिपो';

  @override
  String get addRouteWarehousePal => 'पाल सॉर्टिंग फैसिलिटी';

  @override
  String get addRouteWarehouseUdhna => 'उधना इंडस्ट्रियल वेयरहाउस';

  @override
  String get addRouteShiftMorningEarly => 'सुबह · 7 am–3 pm';

  @override
  String get addRouteShiftMorningLate => 'सुबह · 2 pm–8 pm';

  @override
  String get addRouteShiftFullDay => 'पूरा दिन (8 am–8 pm)';

  @override
  String get addRouteSelectVehicle => 'वाहन चुनें';

  @override
  String get addRouteVehicleLabel => 'वाहन';

  @override
  String get addRouteVehicleHint => 'पिकअप के लिए वाहन चुनें';

  @override
  String get addRouteSelectDriver => 'ड्राइवर चुनें';

  @override
  String get addRouteDriverHint => 'पिकअप के लिए ड्राइवर चुनें';

  @override
  String get addRouteSelectLabour => 'श्रमिक चुनें';

  @override
  String get addRouteLabourHint => 'श्रमिक चुनें';

  @override
  String get addRouteDriverNotFound => 'ड्राइवर नहीं मिला';

  @override
  String get addRouteDriverNotFoundHint =>
      'अभी कोई ड्राइवर नहीं जोड़ा गया। जोड़ने के लिए नीचे दबाएँ।';

  @override
  String get addRouteLabourNotFound => 'श्रमिक नहीं मिला';

  @override
  String get addRouteLabourNotFoundHint =>
      'अभी कोई श्रमिक नहीं जोड़ा गया। जोड़ने के लिए नीचे दबाएँ।';

  @override
  String get addRouteAdd => 'जोड़ें';

  @override
  String get addRouteVehicleCompany1001 => 'GJ-05-EE-1001';

  @override
  String get addRouteVehicleCompany1234 => 'GJ-05-BX-1234';

  @override
  String get addRouteVehicleRental1002 => 'GJ-05-EE-1002';

  @override
  String get addRouteVehicleRental1001 => 'GJ-05-EE-1001';

  @override
  String get addRouteCompanyTruck => 'कंपनी ट्रक';

  @override
  String get addRouteRentalShreeRam => 'श्री राम ट्रांसपोर्ट से किराए पर';

  @override
  String get addRouteRentalKhodiyar => 'खोडियार ट्रांसपोर्ट से किराए पर';

  @override
  String get addRouteCapacity => 'क्षमता 3000 KG';

  @override
  String get addRouteDriverVikram => 'विक्रम सिंह (••• 4321)';

  @override
  String get addRouteDriverSuresh => 'सुरेश कुमार (••• 5847)';

  @override
  String get addRouteDriverMahesh => 'महेश परमार (••• 2282)';

  @override
  String get addRouteDriverRakesh => 'राकेश शर्मा (••• 2458)';

  @override
  String get addRouteDriverAmit => 'अमित पटेल (••• 9510)';

  @override
  String get addRouteLabourRavi => 'रवि बिष्ट (••• 5847)';

  @override
  String get addRouteLabourRam => 'राम सिंह (••• 2282)';

  @override
  String get addRouteLabourRamesh => 'रमेश यादव (••• 2458)';

  @override
  String get addRouteLabourArjun => 'अर्जुन जाटव (••• 9510)';

  @override
  String get addRouteDeactivate => 'निष्क्रिय करें';

  @override
  String get addRouteDeactivateTitle => 'निष्क्रिय करें?';

  @override
  String get addRouteDeactivateMessage =>
      'क्या आप वाकई इस व्यक्ति को निष्क्रिय करना चाहते हैं?';

  @override
  String get addRouteCancel => 'रद्द करें';

  @override
  String get addRouteYes => 'हाँ';

  @override
  String get addRouteAddNewDriverPrefix => 'नया जोड़ें: ';

  @override
  String get addRouteDriverWord => 'ड्राइवर';

  @override
  String get addRouteLabourWord => 'श्रमिक';

  @override
  String get addRouteFullName => 'पूरा नाम';

  @override
  String get addRouteFullNameHint => 'पूरा नाम दर्ज करें';

  @override
  String get addRouteMobileNumber => 'मोबाइल नंबर';

  @override
  String get addRouteMobileNumberHint => 'मोबाइल नंबर दर्ज करें';

  @override
  String get addRouteCountryCode => '+91';

  @override
  String get addRouteAadhaarNumber => 'आधार कार्ड नंबर';

  @override
  String get addRouteAadhaarHint => 'आधार / मतदाता पहचान पत्र';

  @override
  String get addRouteProfileProof => 'प्रोफ़ाइल फोटो / पहचान प्रमाण';

  @override
  String get addRouteCapturePhoto => 'फोटो लें';

  @override
  String get addRoutePhotoHint =>
      'विवरण दर्ज और सत्यापित करने के लिए फोटो अपलोड करें।';

  @override
  String get addRouteSaveSelect => 'सहेजें और चुनें';

  @override
  String get addRouteFullNameRequired => 'कृपया पूरा नाम दर्ज करें।';

  @override
  String get addRouteFullNameMinLength =>
      'पूरा नाम कम से कम 2 अक्षरों का होना चाहिए।';

  @override
  String get addRouteMobileRequired => 'कृपया मोबाइल नंबर दर्ज करें।';

  @override
  String get addRouteMobileInvalid =>
      '6–9 से शुरू होने वाला मान्य 10 अंकों का मोबाइल नंबर दर्ज करें।';

  @override
  String get addRouteReviewShift => 'सुबह (8 am–2 pm)';

  @override
  String get addRouteReviewVehicle => 'GJ-05-EE-1001';

  @override
  String get addRouteReviewCompany => '(कंपनी ट्रक)';

  @override
  String get addRouteReviewDriver => 'विक्रम सिंह (12345 43210)';

  @override
  String get addRouteReviewLabour => 'रवि बिष्ट (23456 58492)';

  @override
  String get addRouteAddToRoute => 'रूट में जोड़ें';

  @override
  String get addRouteSavedTitle => 'सफलतापूर्वक सहेजा गया!';

  @override
  String get addRouteSavedSubtitle => 'अडाजन मॉर्निंग रूट सहेजा गया';

  @override
  String get sourcesUnassignedTitle => 'बिना असाइन किए स्रोत';

  @override
  String get sourcesManageSubtitle => 'कलेक्शन स्रोत प्रबंधित करें';

  @override
  String get sourcesSearchHint => 'स्रोत खोजें';

  @override
  String get sourcesTabCount => 'स्रोत (3)';

  @override
  String get sourcesExtraTabCount => 'अतिरिक्त पिकअप (1)';

  @override
  String get sourcesAdajanTextileSorted => 'अडाजन टेक्सटाइल मिल · सॉर्टेड';

  @override
  String get sourcesAddressShort => 'U 9, 10, सिद्धगिरि टावर, B/H नवयुग...';

  @override
  String get sourcesMonThuSchedule => 'सोम, गुरु · 8–10 am';

  @override
  String get sourcesUnassignedStatus => 'असाइन नहीं';

  @override
  String get sourcesShreeSaiMixed => 'श्री साई डेयरी · मिक्स्ड';

  @override
  String get sourcesEmbraneAddress => 'X 3, 10, एम्ब्रेन ज़ोन, नवयुग प्लस...';

  @override
  String get sourcesExceptSunSchedule => 'रविवार छोड़कर · 9–11 am';

  @override
  String get sourcesShreeSaiSorted => 'श्री साई डेयरी · सॉर्टेड';

  @override
  String get sourcesSecondWedSchedule => 'महीने का दूसरा बुध · 10–11 am';

  @override
  String get sourcesMahavirSorted => 'महावीर पेपर मिल · सॉर्टेड';

  @override
  String get sourcesExtraPickupSchedule => 'शनि 24 अक्तू · 11 am–12 pm';

  @override
  String get sourcesEmptyMessage => 'कोई बिना असाइन की ट्रिप उपलब्ध नहीं';

  @override
  String get sourcesAbcTextileMills => 'ABC टेक्सटाइल मिल्स';

  @override
  String get sourcesShreeSaiDairy => 'श्री साई डेयरी';

  @override
  String get sourcesMahavirPaperMill => 'महावीर पेपर मिल';

  @override
  String get sourcesAddress => 'पता';

  @override
  String get sourcesFullAddress =>
      'U 9, 10, सिद्धगिरि टावर, B/H नवयुग कॉलेज रोड, नवयुग सोसायटी, संगाना सोसायटी, अडाजन, सूरत, गुजरात 395009';

  @override
  String get sourcesOpenMaps => 'Google Maps में खोलें';

  @override
  String get sourcesSchedule => 'समय-सारणी';

  @override
  String get sourcesContactNumber => 'संपर्क नंबर';

  @override
  String get sourcesPhone => '9876543210';

  @override
  String get sourcesMaterial => 'सामग्री';

  @override
  String get sourcesSorted => 'सॉर्टेड';

  @override
  String get sourcesMixed => 'मिक्स्ड';

  @override
  String get sourcesMaterialsList => 'दूध की थैली, कार्ड बोर्ड';

  @override
  String get sourcesPickupStatus => 'पिकअप स्थिति';

  @override
  String get sourcesAddToRoute => 'रूट में जोड़ें';

  @override
  String get sourcesAdajanMorning => 'अडाजन मॉर्निंग';

  @override
  String get sourcesVehicleGj051824 => 'GJ 05 1824';

  @override
  String get sourcesMorningTime => 'सुबह (08:00 AM – 02:00 PM)';

  @override
  String get sourcesAssignedCount => 'असाइन स्रोत : 2';

  @override
  String get sourcesPalGamMorning => 'पाल गाम मॉर्निंग';

  @override
  String get sourcesVehicleGj052564 => 'GJ 05 2564';

  @override
  String get sourcesPalGamTime => 'मॉर्निंग शिफ्ट (10:00 AM – 12:00 PM)';

  @override
  String get sourcesVesuEvening => 'वेसु ईवनिंग';

  @override
  String get sourcesTimeClashWarning =>
      'समय टकराव: अडाजन मॉर्निंग यहाँ लगभग 1:30 pm पहुँचता है, लेकिन पिकअप समय 9–11 am है।\nरूट से 4.2 किमी दूर: प्रत्येक ट्रिप में लगभग 20 मिनट अधिक।\nपाल गाम मॉर्निंग 9:40 am पर पास से गुजरता है।';

  @override
  String get sourcesAddNew => 'नया जोड़ें';

  @override
  String get sourcesAssignAnyway => 'फिर भी असाइन करें';

  @override
  String get sourcesAddedToRoute => 'स्रोत रूट में जोड़ा गया';

  @override
  String get sourcesAddedMessage =>
      'ABC टेक्सटाइल मिल्स अब GJ 05 1824 (मॉर्निंग शिफ्ट) को असाइन है।';

  @override
  String get sourcesBackToRequests => 'अनुरोधों पर वापस जाएँ';

  @override
  String get profileTitle => 'यूज़र प्रोफ़ाइल';

  @override
  String get profileSubtitle => 'खाते का विवरण और जानकारी';

  @override
  String get profileLanguageCode => 'हि';

  @override
  String get profileUserName => 'किरण शाह';

  @override
  String get profileRole => 'पिकअप सुपरवाइज़र';

  @override
  String get profileAccountInformation => 'खाता जानकारी';

  @override
  String get profileMyAreas => 'मेरे क्षेत्र';

  @override
  String get profileAreasValue => 'अडाजन, वेसु, पाल';

  @override
  String get profileMobileNumber => 'मोबाइल नंबर';

  @override
  String get profileMobileValue => '+91 98765 43210';

  @override
  String get profileRoleLabel => 'भूमिका';

  @override
  String get profileSessionExpires => 'सत्र समाप्ति';

  @override
  String get profileSessionValue => '6 घंटे 24 मिनट में समाप्त';

  @override
  String get profileActions => 'कार्रवाइयाँ';

  @override
  String get profileSyncData => 'डेटा सिंक करें';

  @override
  String get profileSyncDataSubtitle => 'अपना ऑफ़लाइन डेटा सिंक करें';

  @override
  String get profileAccount => 'खाता';

  @override
  String get profileLogout => 'लॉगआउट';

  @override
  String get profileLogoutSubtitle => 'अपने खाते से साइन आउट करें';

  @override
  String get profileSyncOfflineData => 'ऑफ़लाइन डेटा सिंक करें';

  @override
  String get profileChangesNotSent => '3 बदलाव अभी भेजे नहीं गए';

  @override
  String get profileSyncNow => 'अभी सिंक करें';

  @override
  String get profileDataAlreadySynced => 'डेटा पहले से सिंक है';

  @override
  String get profileBack => 'वापस';

  @override
  String get profileLogoutQuestion => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get profileLogoutMessage =>
      'बिना सिंक किया ऑफ़लाइन डेटा अगले साइन-इन तक इस डिवाइस पर रहेगा।';

  @override
  String get profileSendChangesWarning =>
      'ड्राइवरों को सूचित करने के लिए बदलाव भेजें';

  @override
  String get profileNo => 'नहीं';

  @override
  String get profileYes => 'हाँ';

  @override
  String get profileNotifications => 'सूचनाएँ';

  @override
  String get profileToday => 'आज';

  @override
  String get profileEarlier => 'पहले';

  @override
  String get profileOfflineMode => 'ऑफ़लाइन मोड';

  @override
  String get profileOfflineModeMessage =>
      'इंटरनेट कनेक्शन नहीं है। कनेक्शन लौटने पर डेटा अपने-आप सिंक होगा।';

  @override
  String get profileJustNow => 'अभी';

  @override
  String get profileNewSourceUnassigned => 'नया स्रोत असाइन नहीं है';

  @override
  String get profileNewSourceMessage =>
      'ग्लोबल गारमेंट्स (अडाजन) को रूट असाइनमेंट चाहिए।';

  @override
  String get profileTenMinutesAgo => '10 मिनट पहले';

  @override
  String get profileDriverEscalation => 'ड्राइवर एस्केलेशन';

  @override
  String get profileDriverEscalationMessage =>
      'ड्राइवर रमेश ने पाल स्थान पर गेट प्रवेश में देरी बताई।';

  @override
  String get profileYesterdayTime => 'कल, 11:30 AM';

  @override
  String get profilePickupSkipped => 'पिकअप छोड़ा गया';

  @override
  String get profilePickupSkippedMessage =>
      'सिद्धगिरी ट्रेडर्स का कलेक्शन छोड़ा गया।';

  @override
  String get profilePickupSkippedTime => '24 अक्तू, 08:00 AM';

  @override
  String get profileAllCaughtUp => 'सब पूरा हुआ!';

  @override
  String get profileNoNotifications =>
      'आपके पास कोई नई सूचना नहीं है। सिस्टम और एडमिन अपडेट के लिए बाद में देखें।';

  @override
  String get profileHelpSupport => 'मदद और सहायता';

  @override
  String get profileCallSupport => 'सहायता को कॉल करें';

  @override
  String get profileCallSupportSubtitle => 'फील्ड समस्याओं के लिए 24/7 उपलब्ध';

  @override
  String get profileInstantHelp => 'तुरंत सहायता';

  @override
  String get profileInstantHelpSubtitle => 'सहायता एजेंट से चैट करें';

  @override
  String get profileFaqTitle => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get profileFaqDailyTrips => 'दैनिक ट्रिप कैसे काम करती हैं?';

  @override
  String get profileFaqDailyTripsAnswer =>
      'हर सुबह आपके मास्टर रूट से अपने-आप बनती हैं।';

  @override
  String get profileFaqSwapDriver => 'आज के लिए ड्राइवर कैसे बदलें?';

  @override
  String get profileFaqSwapDriverAnswer =>
      'आज का रूट खोलें और ड्राइवर एडिट कार्रवाई चुनें।';

  @override
  String get profileFaqUnassigned => 'अनअसाइन्ड स्रोत क्या हैं?';

  @override
  String get profileFaqUnassignedAnswer =>
      'वे स्रोत जो अभी किसी रूट से जुड़े नहीं हैं।';

  @override
  String get profileFaqSkipping => 'स्टॉप छोड़ने से क्या होता है?';

  @override
  String get profileFaqSkippingAnswer =>
      'वर्तमान ट्रिप में स्टॉप छोड़ा गया दर्ज होता है।';

  @override
  String get profileClosedDayArtwork => 'अब दिन\nबंद करने का समय';

  @override
  String get driverProfileUserName => 'रमेश कुमार';

  @override
  String get driverProfileWarehouseLabel => 'मेरा गोदाम';

  @override
  String get driverProfileWarehouseValue => 'मगदल्ला गोदाम';

  @override
  String get driverProfileDriverCodeLabel => 'ड्राइवर कोड';

  @override
  String get driverProfileDriverCodeValue => 'SUR-DRV-0007';

  @override
  String get driverProfileMobileValue => '+91 98765 43226';

  @override
  String get driverProfileRoleValue => 'ड्राइवर';

  @override
  String get driverProfileLogoutWarning =>
      '3 कलेक्शन अभी नहीं भेजे गए: पहले सिंक करें';

  @override
  String get dlDriverDirectory => 'ड्राइवर डायरेक्टरी';

  @override
  String get dlLabourDirectory => 'मज़दूर डायरेक्टरी';

  @override
  String get dlFilterActive => 'सक्रिय';

  @override
  String get dlFilterInactive => 'निष्क्रिय';

  @override
  String dlTabDrivers(int count) {
    return 'ड्राइवर ($count)';
  }

  @override
  String dlTabLabour(int count) {
    return 'मज़दूर ($count)';
  }

  @override
  String get dlSearchHint => 'यहाँ खोजें...';

  @override
  String get dlAddDriver => 'ड्राइवर जोड़ें';

  @override
  String get dlAddLabour => 'मज़दूर जोड़ें';

  @override
  String get dlAddLabourer => 'मज़दूर जोड़ें';

  @override
  String get dlNoDetailsFound => 'कोई विवरण नहीं मिला';

  @override
  String get dlNoPhone => '--';

  @override
  String get dlAddNewDriver => 'नया ड्राइवर जोड़ें';

  @override
  String get dlAddNewLabour => 'नया मज़दूर जोड़ें';

  @override
  String get dlEditDriver => 'ड्राइवर संपादित करें';

  @override
  String get dlEditLabour => 'मज़दूर संपादित करें';

  @override
  String get dlFullName => 'पूरा नाम';

  @override
  String get dlEnterFullName => 'पूरा नाम दर्ज करें';

  @override
  String get dlMobileNumber => 'मोबाइल नंबर';

  @override
  String get dlEnterMobileNumber => 'मोबाइल नंबर दर्ज करें';

  @override
  String get dlCountryCode => '+91';

  @override
  String get dlAadhaarLabel => 'आधार कार्ड नंबर';

  @override
  String get dlAadhaarHint => 'आधार / वोटर आईडी';

  @override
  String get dlProfilePhoto => 'प्रोफ़ाइल फ़ोटो / आईडी प्रूफ़';

  @override
  String get dlCapturePhoto => 'फ़ोटो लें';

  @override
  String get dlUploadHint =>
      'विवरण दर्ज और सत्यापित करने के लिए फ़ोटो अपलोड करें।';

  @override
  String get dlCancel => 'रद्द करें';

  @override
  String get dlSaveSelect => 'सेव करें और चुनें';

  @override
  String get dlIdCardNumber => 'आईडी / कार्ड नंबर';

  @override
  String get dlDateTime => 'तारीख़ और समय';

  @override
  String get dlDeactivate => 'निष्क्रिय करें';

  @override
  String get dlEdit => 'संपादित करें';

  @override
  String get dlReactive => 'पुनः सक्रिय करें';

  @override
  String get dlAreYouSure => 'क्या आप सुनिश्चित हैं?';

  @override
  String get dlDeactivateDriverMessage =>
      'क्या आप इस ड्राइवर को निष्क्रिय करना चाहते हैं?';

  @override
  String get dlDeactivateLabourMessage =>
      'क्या आप इस मज़दूर को निष्क्रिय करना चाहते हैं?';

  @override
  String get dlReactiveDriverMessage =>
      'क्या आप इस ड्राइवर को फिर से सक्रिय करना चाहते हैं?';

  @override
  String get dlReactiveLabourMessage =>
      'क्या आप इस मज़दूर को फिर से सक्रिय करना चाहते हैं?';

  @override
  String get dlYes => 'हाँ';

  @override
  String get dlDeactivatedTitle => 'सफलतापूर्वक निष्क्रिय किया गया!';

  @override
  String get dlDeactivatedBody => 'प्रोफ़ाइल निष्क्रिय की गई।';

  @override
  String get dlReactivedTitle => 'सफलतापूर्वक पुनः सक्रिय किया गया!';

  @override
  String get dlReactivedBody => 'प्रोफ़ाइल पुनः सक्रिय की गई।';

  @override
  String get supervisorTripsToday => 'आज की ट्रिप';

  @override
  String get tpTitle => 'ट्रिप प्लान';

  @override
  String get tpAreas => 'अडाजन, वेसु, पाल';

  @override
  String get tpChoiceToday => 'आज';

  @override
  String get tpChoiceTomorrow => 'कल';

  @override
  String get tpChoiceWeek => 'इस सप्ताह';

  @override
  String get tpDateToday => 'गुरु 22 अक्टू 2026';

  @override
  String get tpDateTomorrow => 'शुक्र 23 अक्टू 2026';

  @override
  String get tpDateNoTrips => 'रवि 8 नवं 2026';

  @override
  String tpTripsStops(int trips, int stops) {
    return '$trips ट्रिप · $stops स्टॉप';
  }

  @override
  String tpExtraPickups(int count) {
    return '$count अतिरिक्त पिकअप';
  }

  @override
  String tpSourcePaused(int count) {
    return '$count सोर्स रुका हुआ';
  }

  @override
  String get tpNoTrips => 'कोई ट्रिप नहीं';

  @override
  String get tpStatusOnRoute => 'रास्ते में';

  @override
  String get tpStatusApproved => 'स्वीकृत';

  @override
  String get tpStatusPlanned => 'योजनाबद्ध';

  @override
  String get tpOwnVehicle => 'अपना वाहन';

  @override
  String get tpContractVehicle => 'अनुबंध वाला वाहन';

  @override
  String tpVehicleTag(String plate, String vehicle) {
    return '$plate · $vehicle';
  }

  @override
  String get tpChangedForToday => 'आज के लिए बदला गया';

  @override
  String get tpDriverNotUsingApp => 'ड्राइवर ऐप इस्तेमाल नहीं कर रहा';

  @override
  String tpCoverFor(String substitute, String original) {
    return '$substitute ($original की जगह)';
  }

  @override
  String tpTransporterDriver(String transporter, String driver) {
    return '$transporter · ड्राइवर $driver';
  }

  @override
  String tpStops(int count) {
    return '$count स्टॉप';
  }

  @override
  String tpDaily(int count) {
    return 'दैनिक $count';
  }

  @override
  String tpWeekly(int count) {
    return 'साप्ताहिक $count';
  }

  @override
  String tpMonthly(int count) {
    return 'मासिक $count';
  }

  @override
  String tpBiWeekly(int count) {
    return 'द्वि-साप्ताहिक $count';
  }

  @override
  String tpOnCall(int count) {
    return 'ऑन कॉल $count';
  }

  @override
  String tpPaused(int count) {
    return '$count रुका हुआ';
  }

  @override
  String tpCollectedOf(int done, int total) {
    return '$total में से $done एकत्र';
  }

  @override
  String tpRecordedOf(int done, int total) {
    return '$total में से $done ऐप में दर्ज';
  }

  @override
  String tpCollectedMissed(int collected, int missed) {
    return '$collected एकत्र · $missed छूटे';
  }

  @override
  String tpWeightKg(String kg) {
    return '$kg किग्रा';
  }

  @override
  String get tpCallDriver => 'ड्राइवर को कॉल करें';

  @override
  String tpOwnVehicleCount(int count) {
    return 'अपना वाहन $count';
  }

  @override
  String tpContractCount(int count) {
    return 'अनुबंध $count';
  }

  @override
  String get tpDay0 => 'गुरु 22 अक्टू · आज';

  @override
  String get tpDay1 => 'शुक्र 23 अक्टू';

  @override
  String get tpDay2 => 'शनि 24 अक्टू';

  @override
  String get tpDay3 => 'रवि 25 अक्टू';

  @override
  String get tpDay4 => 'सोम 26 अक्टू';

  @override
  String get tpDay5 => 'मंगल 27 अक्टू';

  @override
  String get tpDay6 => 'बुध 28 अक्टू';

  @override
  String get tpEmptyTitle => 'इस दिन कोई ट्रिप नहीं';

  @override
  String get tpEmptyMessage =>
      'उस दिन वेयरहाउस बंद है (छुट्टी)। उस दिन के पिकअप हर पिकअप पॉइंट के छुट्टी नियम के अनुसार अगले कामकाजी दिन पर जाएँगे या छोड़ दिए जाएँगे।';

  @override
  String get rdNext7Days => 'अगले 7 दिन';

  @override
  String get rdDateToday => 'गुरु, 22 अक्टू 2026';

  @override
  String get rdDateRange => 'शुक्र 23 अक्टू – गुरु 29 अक्टू';

  @override
  String rdShift(String time) {
    return 'सुबह ($time)';
  }

  @override
  String rdAssignedSources(int count) {
    return 'सौंपे गए सोर्स : $count';
  }

  @override
  String rdAssignedSourcesPaused(int count, int paused) {
    return 'सौंपे गए सोर्स : $count ($paused रुके हुए)';
  }

  @override
  String rdDriverLine(String name, String phone) {
    return 'ड्राइवर : $name ($phone)';
  }

  @override
  String rdLabourLine(String name) {
    return 'मज़दूर : $name';
  }

  @override
  String get rdList => 'सूची';

  @override
  String get rdMap => 'नक्शा';

  @override
  String get rdFilterAll => 'सभी';

  @override
  String get rdFilterCollected => 'एकत्र';

  @override
  String get rdFilterPending => 'लंबित';

  @override
  String get rdFilterZeroKg => '0 किग्रा';

  @override
  String get rdFilterMissed => 'छूटे';

  @override
  String get rdFilterCancelled => 'रद्द';

  @override
  String get rdFilterInactive => 'निष्क्रिय';

  @override
  String get rdFreqDaily => 'दैनिक';

  @override
  String get rdFreqWeekly => 'साप्ताहिक';

  @override
  String get rdTypeSorted => 'छंटा हुआ';

  @override
  String get rdTypeMixed => 'मिश्रित';

  @override
  String rdStopTitle(String name, String type) {
    return '$name · $type';
  }

  @override
  String rdSchedEveryDay(String time) {
    return 'हर दिन · $time';
  }

  @override
  String rdSchedDays(String days, String time) {
    return '$days · $time';
  }

  @override
  String rdSchedExceptSun(String time) {
    return 'रवि को छोड़कर, $time';
  }

  @override
  String rdSchedSecondWed(String time) {
    return 'दूसरा बुध, $time';
  }

  @override
  String rdSchedOnce(String date, String time) {
    return '(एक बार) $date, $time';
  }

  @override
  String rdSchedPausedTill(String date) {
    return '$date तक रुका हुआ';
  }

  @override
  String get rdWeekdayMon => 'सोम';

  @override
  String get rdWeekdayThu => 'गुरु';

  @override
  String get rdStatusCollected => 'एकत्र';

  @override
  String get rdStatusZeroKg => '0 किग्रा';

  @override
  String get rdStatusCancelledBySource => 'सोर्स द्वारा रद्द';

  @override
  String get rdStatusNextStop => 'अगला स्टॉप';

  @override
  String get rdStatusPending => 'लंबित';

  @override
  String get rdStatusInactive => 'निष्क्रिय';

  @override
  String rdAmountKgPcs(String kg, String pcs) {
    return '$kg किग्रा + $pcs नग';
  }

  @override
  String get rdNoteNoMaterial => 'आज कोई माल नहीं';

  @override
  String get rdNoteClosedStocktaking => 'स्टॉक गिनती के लिए बंद';

  @override
  String get rdNotePausedRenovation => 'सोर्स रुका हुआ (मरम्मत)';

  @override
  String rdTagCollectedAt(String time) {
    return '$time पर एकत्र';
  }

  @override
  String rdTagVisitedAt(String time) {
    return '$time पर दौरा';
  }

  @override
  String get rdTagNoteFromDriver => 'ड्राइवर का नोट';

  @override
  String rdTagVoiceNote(String duration) {
    return 'वॉइस नोट $duration';
  }

  @override
  String get rdLegendCollected => 'एकत्र';

  @override
  String get rdLegendZeroKg => '0 किग्रा';

  @override
  String get rdLegendCancelled => 'रद्द';

  @override
  String get rdLegendNextStop => 'अगला स्टॉप';

  @override
  String get rdLegendPending => 'लंबित';

  @override
  String get rdLegendPaused => 'रुका हुआ';

  @override
  String get rdLegendWarehouse => 'गोदाम';

  @override
  String rdMapNext(int number, String name, String time, String distance) {
    return 'अगला: $number · $name · $time · $distance दूर';
  }

  @override
  String get rdMapHint =>
      'स्टॉप दौरे के क्रम में। ठोस रेखा पूरी हो चुकी है; बिंदीदार रेखा बाकी है, गोदाम तक वापसी। स्टॉप खोलने के लिए उस पर टैप करें।';

  @override
  String get rdAddedLastHint =>
      'इसे आख़िरी स्टॉप के रूप में जोड़ा जाता है। आप रूट के पेज पर क्रम बदल सकते हैं।';

  @override
  String get rdAddSources => 'सोर्स जोड़ें';

  @override
  String get sdAddress => 'पता';

  @override
  String get sdOpenMaps => 'Google Maps में खोलें';

  @override
  String get sdSchedule => 'समय-सारणी';

  @override
  String get sdPersonAtPickup => 'पिकअप स्थान पर व्यक्ति';

  @override
  String get sdIecExecutive => 'IEC एग्जीक्यूटिव';

  @override
  String get sdPickupCategory => 'पिकअप श्रेणी';

  @override
  String get sdMaterial => 'सामग्री';

  @override
  String get sdPickupStatus => 'पिकअप स्थिति';

  @override
  String get sdWarehouse => 'गोदाम';

  @override
  String get sdStatusNextStop => 'अगला स्टॉप';

  @override
  String get sdCall => 'कॉल';

  @override
  String get sdSkipForToday => 'आज के लिए छोड़ें';

  @override
  String get sdMaterialsList => 'दूध पाउच, कार्ड बोर्ड';

  @override
  String get sdRoleManager => 'मैनेजर';

  @override
  String sdContactLine(String name, String role, String phone) {
    return '$name · $role · $phone';
  }

  @override
  String sdIecLine(String name, String phone) {
    return '$name · $phone';
  }

  @override
  String get skTitle => 'सोर्स छोड़ें';

  @override
  String get skReasonLabel => 'छोड़ने का कारण';

  @override
  String get skReasonClosed => 'सोर्स बंद है';

  @override
  String get skReasonHoliday => 'छुट्टी';

  @override
  String get skReasonVehicle => 'वाहन उपलब्ध नहीं';

  @override
  String get skReasonOther => 'अन्य';

  @override
  String get skRemarks => 'टिप्पणी';

  @override
  String get skMaxChars => 'अधिकतम 150 अक्षर';

  @override
  String get skConfirm => 'छोड़ने की पुष्टि करें';

  @override
  String get skSkippedTitle => 'सोर्स छोड़ा गया!';

  @override
  String get skSkippedBody => 'कल अपने आप फिर शुरू होगा।';

  @override
  String get apToApprove => 'मंज़ूरी बाकी';

  @override
  String get apDone => 'पूरे';

  @override
  String get apCorrectionDoneDetail =>
      'PET बोतलें 50 kg → 60 kg. स्टॉप का रिकॉर्ड बदल दिया गया; विक्रम सिंह को बता दिया गया।';

  @override
  String get apApprovedToday => 'आपने आज सुबह 10:20 बजे मंज़ूर किया';

  @override
  String get apExtraPickupDoneDetail =>
      'शनि 25 अक्टू, सुबह 10 – दोपहर 12 · लगभग 40 kg · अडाजण मॉर्निंग में जोड़ा गया';

  @override
  String get apApproved21Oct => 'आपने 21 अक्टू को मंज़ूर किया';

  @override
  String get apStartPickupsFromIec => 'पिकअप शुरू करें · IEC से';

  @override
  String get apGreenLeafNisha => 'ग्रीन लीफ होटल · निशा मेहता';

  @override
  String get apDeclineReplyDetail =>
      'आपका जवाब: “1 दिसं. तक अडाजण मॉर्निंग में जगह नहीं है। तब फिर पूछें।”';

  @override
  String get apDeclined20Oct => 'आपने 20 अक्टू को अस्वीकार किया';

  @override
  String get apDeclineCorrectionTitle => 'सुधार अस्वीकार करें';

  @override
  String get apDeclineCorrectionBody =>
      'विक्रम सिंह आपका जवाब देखेंगे। स्टॉप दर्ज जैसा ही रहेगा।';

  @override
  String get apDeclineCorrectionReply =>
      'तराज़ू की फ़ोटो में 50 kg दिख रहा है। अगर ज़्यादा था, तो गेट टीम से दोबारा तौलने को कहें।';

  @override
  String get apDeclineExtraTitle => 'अतिरिक्त पिकअप अस्वीकार करें';

  @override
  String get apDeclineExtraBody =>
      'ABC प्लास्टिक मैन्युफ़ैक्चर आपका जवाब देखेगा। कोई पिकअप नहीं जोड़ा जाएगा।';

  @override
  String get apReplyHint => 'अपना जवाब लिखें';

  @override
  String get apDeclineAndReply => 'अस्वीकार करें और जवाब दें';

  @override
  String get apCancel => 'रद्द करें';

  @override
  String get apExtraApprovedTitle => 'अतिरिक्त पिकअप मंज़ूर';

  @override
  String get apExtraApprovedBody =>
      'ABC प्लास्टिक मैन्युफ़ैक्चर को शनि 25 अक्टू को अडाजण मॉर्निंग में जोड़ दिया गया है।';

  @override
  String get rpTitle => 'कलेक्शन रिपोर्ट';

  @override
  String get rpShare => 'शेयर करें';

  @override
  String get rpCollectedToday => 'आज एकत्रित';

  @override
  String get rpCollectedYesterday => 'कल एकत्रित';

  @override
  String get rpCollectedThisWeek => 'इस हफ़्ते एकत्रित';

  @override
  String get rpCollectedThisMonth => 'इस महीने एकत्रित';

  @override
  String get rpCollectedTheseDates => 'इन तारीखों में एकत्रित';

  @override
  String rpTotal(String kg, String pcs) {
    return '$kg kg + $pcs पीस';
  }

  @override
  String rpKg(String kg) {
    return '$kg kg';
  }

  @override
  String rpStopsDue(String count) {
    return '$count स्टॉप बाकी';
  }

  @override
  String get rpByRoute => 'रूट के अनुसार';

  @override
  String get rpByCategory => 'पिकअप श्रेणी के अनुसार';

  @override
  String get rpStopsToLook => 'ध्यान देने वाले स्टॉप';

  @override
  String rpOfStops(String done, String total) {
    return '$total में से $done स्टॉप';
  }

  @override
  String rpStops(String count) {
    return '$count स्टॉप';
  }

  @override
  String get rpOwn => 'अपना';

  @override
  String get rpContract => 'कॉन्ट्रैक्ट';

  @override
  String get rpCancelledBySource => 'स्रोत ने रद्द किया';

  @override
  String rpNamesMore(String first, String second, String count) {
    return '$first, $second और $count अन्य';
  }

  @override
  String rpNamesPlus(String first, String second, String count) {
    return '$first, $second +$count';
  }

  @override
  String rpCollectedStops(String label, String done, String total) {
    return '$label · $total में से $done स्टॉप';
  }

  @override
  String get rpPdfTitle => 'रिपोर्ट PDF';

  @override
  String rpPdfSubtitle(String range) {
    return 'कलेक्शन रिपोर्ट · $range';
  }

  @override
  String get rpCompany => 'Ecovision Environmental Resources LLP';

  @override
  String rpPdfSupervisor(String name, String period, String range) {
    return 'पिकअप सुपरवाइज़र: $name · $period, $range';
  }

  @override
  String get rpPeriodToday => 'आज';

  @override
  String get rpPeriodYesterday => 'कल';

  @override
  String get rpPeriodThisWeek => 'इस हफ़्ते';

  @override
  String get rpPeriodThisMonth => 'इस महीने';

  @override
  String get rpPeriodDates => 'चुनी गई तारीखें';

  @override
  String rpPdfSummary(
    String due,
    String collected,
    String zero,
    String missed,
    String cancelled,
  ) {
    return '$due स्टॉप बाकी · एकत्रित $collected · 0 kg $zero · छूटे $missed · रद्द $cancelled';
  }

  @override
  String get rpColRoute => 'रूट';

  @override
  String get rpColVehicle => 'वाहन';

  @override
  String get rpColStops => 'स्टॉप';

  @override
  String get rpColCollected => 'एकत्रित';

  @override
  String get rpColCategory => 'श्रेणी';

  @override
  String get rpColOutcome => 'नतीजा';

  @override
  String get rpColPickupPoints => 'पिकअप पॉइंट';

  @override
  String rpOf(String done, String total) {
    return '$total में से $done';
  }

  @override
  String rpPdfMade(String date, String time) {
    return '$date, $time को बनाया · पेज 1 में से 1';
  }

  @override
  String get rpPdfPageHint => 'पेज 1 में से 1 · ज़ूम के लिए पिंच करें';

  @override
  String get rpSharePdf => 'PDF शेयर करें';

  @override
  String get calClear => 'साफ़ करें';

  @override
  String get calApply => 'लागू करें';

  @override
  String get calPrevMonth => 'पिछला महीना';

  @override
  String get calNextMonth => 'अगला महीना';

  @override
  String calSelection(String range, String days) {
    return '$range · $days';
  }

  @override
  String calDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन',
      one: '1 दिन',
    );
    return '$_temp0';
  }

  @override
  String get calPickDates => 'तारीखें चुनें';

  @override
  String calMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'जनवरी',
      '2': 'फ़रवरी',
      '3': 'मार्च',
      '4': 'अप्रैल',
      '5': 'मई',
      '6': 'जून',
      '7': 'जुलाई',
      '8': 'अगस्त',
      '9': 'सितंबर',
      '10': 'अक्टूबर',
      '11': 'नवंबर',
      '12': 'दिसंबर',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'जन',
      '2': 'फ़र',
      '3': 'मार्च',
      '4': 'अप्रै',
      '5': 'मई',
      '6': 'जून',
      '7': 'जुला',
      '8': 'अग',
      '9': 'सितं',
      '10': 'अक्टू',
      '11': 'नवं',
      '12': 'दिसं',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'सो',
      '2': 'मं',
      '3': 'बु',
      '4': 'गु',
      '5': 'शु',
      '6': 'श',
      '7': 'र',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get supervisorDrawerCashPayments => 'नकद और भुगतान';

  @override
  String lkRouteDate(String route, String date) {
    return '$route · $date';
  }

  @override
  String get lkNotOnRoute => 'किसी रूट पर नहीं';

  @override
  String lkContractVehicle(String plate) {
    return 'कॉन्ट्रैक्ट वाहन · $plate';
  }

  @override
  String lkOwnVehicle(String name) {
    return 'अपना वाहन · ड्राइवर $name';
  }

  @override
  String get lkExtraPickup => 'अतिरिक्त पिकअप';

  @override
  String get lkCalledOffIec => 'IEC ने पहले ही रद्द किया';

  @override
  String lkCalledOffAtStop(String name) {
    return 'स्टॉप पर रद्द हुआ · ड्राइवर $name';
  }

  @override
  String get lkCalledOffByYou => 'आपने रद्द किया';

  @override
  String get lkReasonNotRecorded => 'ड्राइवर या गेट ने दर्ज नहीं किया';

  @override
  String get lkReasonTripCancelled => 'इसकी ट्रिप रद्द हो गई थी';

  @override
  String get lkReasonNoRoute => 'उस दिन कोई रूट नहीं था';

  @override
  String get lkReasonTakenOff => 'ट्रिप से हटाया और किसी दूसरी में नहीं डाला';

  @override
  String get lkReasonClosedToday => 'आज बंद';

  @override
  String get lkReasonHoliday => 'छुट्टी';

  @override
  String get lkReasonShifted => 'दूसरे दिन पर खिसकाया';

  @override
  String get lkReasonNoMaterial => 'कोई माल नहीं';

  @override
  String get lkReasonNoMaterialToday => 'आज कोई माल नहीं';

  @override
  String get lkReasonClosed => 'बंद';

  @override
  String get lkReasonRefused => 'देने से मना किया';

  @override
  String get lkReasonVehicleFull => 'वाहन भर गया';

  @override
  String get lkEmpty => 'इन तारीखों में देखने लायक कुछ नहीं';

  @override
  String calWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'सोम',
      '2': 'मंगल',
      '3': 'बुध',
      '4': 'गुरु',
      '5': 'शुक्र',
      '6': 'शनि',
      '7': 'रवि',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get isTypeSourceProblem => 'स्रोत पर समस्या';

  @override
  String isDriverRole(String name) {
    return '$name (ड्राइवर)';
  }

  @override
  String isRaised(String time) {
    return '$time पर दर्ज';
  }

  @override
  String get isOpen => 'खुला';

  @override
  String get isEscalated => 'आगे भेजा';

  @override
  String get isResolved => 'हल हुआ';

  @override
  String get isTypeLabel => 'प्रकार :';

  @override
  String get isDriverNote => 'ड्राइवर का नोट :';

  @override
  String get isBy => 'द्वारा :';

  @override
  String isByValue(String name, String time) {
    return '$name · $time';
  }

  @override
  String get isWhatWasDone => 'क्या किया :';

  @override
  String get isTold => 'सूचित :';

  @override
  String isToldValue(String name) {
    return 'ऑफ़िस और $name (IEC).';
  }

  @override
  String get isEscalate => 'आगे भेजें';

  @override
  String get isMarkResolved => 'हल हुआ मानें';

  @override
  String get isSheetTitle => 'हल हुआ दर्ज करें';

  @override
  String get isSheetBody => 'बताएँ कि क्या किया। ड्राइवर और ऑफ़िस इसे देखेंगे।';

  @override
  String get isWhatWasDoneLabel => 'क्या किया';

  @override
  String get isEscalateTitle => 'यह समस्या आगे भेजें?';

  @override
  String get isEscalateBody =>
      'ऑफ़िस और स्रोत के IEC को सूचित किया जाएगा, और यह आगे भेजा के रूप में दिखेगा। तब इस्तेमाल करें जब आप खुद इसे सुलझा न सकें।';

  @override
  String get isResolvedToastTitle => 'समस्या हल हुई!';

  @override
  String isResolvedToastBody(String name) {
    return '$name को बता दिया गया।';
  }

  @override
  String get isEscalatedToastTitle => 'समस्या आगे भेजी!';

  @override
  String get isEscalatedToastBody =>
      'ऑफ़िस और स्रोत के IEC को सूचित कर दिया गया।';

  @override
  String get tpStatusExpected => 'अपेक्षित';

  @override
  String get tpExpectedInfo =>
      'ट्रिप एक दिन पहले बनती हैं। उस दिन के रूट और बाकी पिकअप मिलाकर इतना बनता है; टीम अभी भी बदल सकती है।';

  @override
  String tpExtra(int count) {
    return 'अतिरिक्त $count';
  }

  @override
  String tpTodaySuffix(String date) {
    return '$date · आज';
  }

  @override
  String tpWarehouseClosed(String date) {
    return '$date · वेयरहाउस बंद';
  }

  @override
  String get tpNoTripsHoliday => 'कोई ट्रिप नहीं · वेयरहाउस छुट्टी';
}
