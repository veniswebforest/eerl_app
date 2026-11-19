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
}
