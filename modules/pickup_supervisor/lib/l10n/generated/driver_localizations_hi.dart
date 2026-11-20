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
  String get supervisorKg => 'किग्रा';

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
  String get supervisorTripsSubtitle => 'आज के सक्रिय और आगामी पिकअप रूट';

  @override
  String get supervisorAdajanMorning => 'अडाजन सुबह';

  @override
  String get supervisorVikramProgress => 'विक्रम सिंह · 8 में से 3 एकत्रित';

  @override
  String get supervisorOwnVehicle => 'अपना वाहन';

  @override
  String get supervisorDailyWeekly => 'दैनिक 5 · साप्ताहिक 3';

  @override
  String get supervisorCallDriver => 'ड्राइवर को कॉल करें';

  @override
  String get supervisorPalGamMorning => 'पाल गाँव सुबह';

  @override
  String get supervisorAmitProgress => 'अमित पटेल · ऐप में 8 में से 0 दर्ज';

  @override
  String get supervisorDriverNotSetUp => 'ड्राइवर ने ऐप सेट नहीं किया';

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
  String get supervisorManageUnassigned => 'नए बिना असाइन स्रोत संभालें';

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
  String get attentionApprovalSubtitle => 'आपके ड्राइवरों और पिकअप पॉइंट से';

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
      'PET बोतल 50 किग्रा → 60 किग्रा। सुरेश कुमार: “स्केल की फोटो में 60 किग्रा दिखता है।”';

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
      'शनि 25 अक्तू, 10 am – 12 pm · मध्यम · अडाजन मॉर्निंग में उपयुक्त';

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
      'होटल राजधानी के रिकॉर्ड में अब PET बोतल 60 किग्रा है। सुरेश कुमार और पिकअप पॉइंट को बता दिया गया है।';

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
}
