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
  String get collectedCount => '03';

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
}
