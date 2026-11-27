// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'driver_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class DriverLocalizationsGu extends DriverLocalizations {
  DriverLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get welcomeBack => 'ફરી સ્વાગત છે';

  @override
  String get homeDateAndZone => 'બુધ, 22 જુલાઈ · સુરત ઝોન';

  @override
  String get warehouseName => 'મગદલ્લા વેરહાઉસ';

  @override
  String get onlineStatus => 'તમે ઑનલાઇન છો';

  @override
  String pendingCollections(int count) {
    return '$count કલેક્શન બાકી';
  }

  @override
  String get syncNow => 'હવે સિંક કરો';

  @override
  String get todaysSummary => 'આજનો સારાંશ';

  @override
  String get pendingStops => 'બાકી સ્ટોપ્સ';

  @override
  String get pendingStopsCount => '05';

  @override
  String get collected => 'એકત્રિત';

  @override
  String collectedCount(int count) {
    return 'એકત્રિત ($count)';
  }

  @override
  String get todaysTrip => 'આજની ટ્રિપ';

  @override
  String get vehicleRegistration => 'GJ-XX-1234';

  @override
  String stopsCompleted(int completed, int total) {
    return '$total માંથી $completed સ્ટોપ્સ પૂર્ણ';
  }

  @override
  String get tripProgress => '37%';

  @override
  String get completedTripProgress => '100%';

  @override
  String get openMyStops => 'મારા સ્ટોપ્સ ખોલો';

  @override
  String get quickAction => 'ઝડપી કાર્યવાહી';

  @override
  String get raiseAnIssue => 'સમસ્યા જણાવો';

  @override
  String get issueDescription => 'વાહન, સ્રોત અથવા ટીમની સમસ્યા જણાવો';

  @override
  String get reportIssue => 'સમસ્યાનો રિપોર્ટ કરો';

  @override
  String get homeTab => 'હોમ';

  @override
  String get stopsTab => 'મારા સ્ટોપ્સ';

  @override
  String get issuesTab => 'સમસ્યાઓ';

  @override
  String get profileTab => 'પ્રોફાઇલ';

  @override
  String get driverPageUnavailable => 'આ ડ્રાઇવર પેજ હજી ઉપલબ્ધ નથી';

  @override
  String get pendingPickupStops => 'બાકી પિકઅપ સ્ટોપ્સ';

  @override
  String stopCardTitle(String name, String material) {
    return '$name · $material';
  }

  @override
  String get abcTextileMills => 'ABC ટેક્સટાઇલ મિલ્સ';

  @override
  String get shreeSaiDairy => 'શ્રી સાઈ ડેરી';

  @override
  String get xyzTextileMills => 'XYZ ટેક્સટાઇલ મિલ્સ';

  @override
  String get sortedMaterial => 'છાંટેલું';

  @override
  String get mixedMaterial => 'મિશ્ર';

  @override
  String get industrialAreaSurat => 'ઇન્ડસ્ટ્રિયલ એરિયા, સુરત';

  @override
  String get lpSavaniRoadSurat => 'એલ.પી. સવાણી રોડ, સુરત';

  @override
  String get pickupSchedule => 'ગુરુ · સવારે 8:00–10:00';

  @override
  String get noSchedule => '--';

  @override
  String get pendingStatus => 'બાકી';

  @override
  String get stopDetail => 'સ્ટોપની વિગતો';

  @override
  String get driverPhoneNumber => '+91 98765 432145';

  @override
  String get call => 'કૉલ';

  @override
  String get requestInformation => 'વિનંતીની માહિતી';

  @override
  String get address => 'સરનામું';

  @override
  String get pickupAddress =>
      'યુ 9, 10, સિદ્ધગિરી ટાવર, નેવીયુગ કોલેજ રોડ પાછળ, નેવીયુગ સોસાયટી, સંગના સોસાયટી, અડાજણ, સુરત, ગુજરાત 395009';

  @override
  String get schedule => 'સમયપત્રક';

  @override
  String get material => 'સામગ્રી';

  @override
  String get materialItems => 'દૂધની થેલી, કાર્ડ બોર્ડ';

  @override
  String get expectedWeight => 'અપેક્ષિત વજન';

  @override
  String get expectedWeightValue => '450 કિગ્રા';

  @override
  String get requestStatus => 'વિનંતીની સ્થિતિ';

  @override
  String get description => 'વર્ણન';

  @override
  String get pickupDescription =>
      'સરળ નેવિગેશન માટે મેં Google Mapsની લોકેશન લિંક જોડી છે. કૃપા કરીને અપલોડ કરેલા કચરાના ફોટા સ્પષ્ટ અને સરળતાથી વાંચી શકાય તેવા રાખો.';

  @override
  String get startPickup => 'પિકઅપ શરૂ કરો';

  @override
  String get mixedDriverPhoneNumber => '+91 1234567890';

  @override
  String get mixedExpectedWeightValue => '200 કિગ્રા';

  @override
  String get sortedWasteForm => 'છાંટેલા કચરાનું ફોર્મ';

  @override
  String get captureMaterialScalePhoto => 'સામગ્રી અને વજનકાંટાનો ફોટો લો';

  @override
  String get petBottles => 'PET બોટલો';

  @override
  String get hdpeRigid => 'HDPE રિજિડ';

  @override
  String get eWaste => 'ઈ-વેસ્ટ';

  @override
  String get kgUnit => 'કિગ્રા';

  @override
  String get pcsUnit => 'નંગ';

  @override
  String get collectedLabel => 'એકત્રિત';

  @override
  String get exampleWeight => 'દા.ત. 123.00';

  @override
  String get capturePhoto => 'ફોટો લો';

  @override
  String get petCollectedWeight => '270.00';

  @override
  String get hdpeCollectedWeight => '270.00';

  @override
  String get eWasteCollectedCount => '25';

  @override
  String get savePickup => 'પિકઅપ સાચવો';

  @override
  String get mixedWasteForm => 'મિશ્ર કચરાનું ફોર્મ';

  @override
  String get enterWeightKg => 'વજન દાખલ કરો (કિગ્રા)';

  @override
  String get mixedWeightValue => '300.00';

  @override
  String get materialAndScalePhoto => 'સામગ્રી અને વજનકાંટાનો ફોટો';

  @override
  String get supportedPhotoFormats => 'સપોર્ટેડ: JPG, PNG (મહત્તમ 5MB).';

  @override
  String get sortedPickupForm => 'છાંટેલા પિકઅપનું ફોર્મ';

  @override
  String get successWeightValue => '240.51';

  @override
  String get materialAndWeighbridgePhoto => 'સામગ્રી અને વેઇબ્રિજનો ફોટો';

  @override
  String get pickupRecorded => 'પિકઅપ નોંધાયું';

  @override
  String get successfully => 'સફળતાપૂર્વક!';

  @override
  String get pickupSuccessMessage =>
      'પિકઅપ સફળતાપૂર્વક સાચવવામાં આવ્યું છે. સ્થિતિ તમારી ટ્રિપમાં અપડેટ થશે.';

  @override
  String get backToList => 'લિસ્ટ પર પાછા જાઓ';

  @override
  String get selectProblemsStruggling => 'તમને આવતી સમસ્યાઓ પસંદ કરો';

  @override
  String get vehicleBreakdown => 'વાહન ખરાબ થવું';

  @override
  String get accident => 'અકસ્મત';

  @override
  String get sourceProblem => 'સ્રોતની સમસ્યા';

  @override
  String get otherIssue => 'અન્ય';

  @override
  String get remarks => 'ટિપ્પણીઓ';

  @override
  String get addYourRemarks => 'તમારી ટિપ્પણીઓ ઉમેરો...';

  @override
  String get max150Characters => 'મહત્તમ 150 અક્ષરો';

  @override
  String get submitIssue => 'સમસ્યા સબમિટ કરો';

  @override
  String get yourPickupSupervisor => 'તમારા પિકઅપ સુપરવાઇઝર';

  @override
  String get supervisorName => 'કિરણ શાહ';

  @override
  String get message => 'મેસેજ';

  @override
  String get collectedToday => 'આજે એકત્રિત';

  @override
  String get collectedWeight420 => 'અત્યાર સુધી 420 કિગ્રા';

  @override
  String get collectedWeightZero => '0 કિગ્રા';

  @override
  String get zeroKg => '0 કિગ્રા';

  @override
  String get cancelled => 'રદ કરેલ';

  @override
  String todaysTripsCount(int count) {
    return 'આજની ટ્રિપ્સ ($count)';
  }

  @override
  String get todaysTrips => 'આજની ટ્રિપ્સ';

  @override
  String get tripMorning => 'ટ્રિપ 1 · સવાર';

  @override
  String get tripAfternoon => 'ટ્રિપ 2 · બપોર';

  @override
  String get morningTripTime => 'સવારે 7:00 – 11:00 · 7 સ્ટોપ્સ';

  @override
  String get afternoonTripTime => 'બપોરે 2:00 – 5:00 · 6 સ્ટોપ્સ';

  @override
  String get afternoonStartTime => 'બપોરે 2:00';

  @override
  String get onTheWay => 'માર્ગમાં';

  @override
  String startsAt(String time) {
    return '$time વાગ્યે શરૂ';
  }

  @override
  String get delivered => 'પહોંચાડ્યું';

  @override
  String get vehicleCrew => 'GJ-XX-1234 · સુરેશ, મહેશ';

  @override
  String get dropMagdalla => 'મગદલ્લા વેરહાઉસ પર ડ્રોપ';

  @override
  String get dropSachin => 'સચિન વેરહાઉસ પર ડ્રોપ';

  @override
  String get collectedOnTrip => 'આ ટ્રિપમાં એકત્રિત';

  @override
  String get weight420Kg => '420 કિગ્રા';

  @override
  String get weight180Kg => '180 કિગ્રા';

  @override
  String stopsDone(int completed, int total) {
    return '$totalમાંથી $completed સ્ટોપ્સ પૂર્ણ';
  }

  @override
  String seeAllStops(int count) {
    return 'બધા $count સ્ટોપ્સ જુઓ';
  }

  @override
  String nextStopOnTrip(int trip) {
    return 'ટ્રિપ $tripનો આગામી સ્ટોપ';
  }

  @override
  String afterThat(int count) {
    return 'ત્યાર પછી ($count)';
  }

  @override
  String get laterToday => 'આજે પછી';

  @override
  String get earlierToday => 'આજે અગાઉ';

  @override
  String stopPosition(int current, int total) {
    return 'સ્ટોપ $current / $total';
  }

  @override
  String get nextStop => 'આગામી સ્ટોપ';

  @override
  String get enterCollection => 'કલેક્શન દાખલ કરો';

  @override
  String opensAfterStop(int stop) {
    return 'સ્ટોપ $stop પછી ખુલશે';
  }

  @override
  String unlockAfterStop(int stop) {
    return 'સ્ટોપ $stop પૂર્ણ થાય અથવા તમે આ સ્ટોપ પર પહોંચો (GPS) ત્યારે ખુલશે. સ્થાન તપાસવા ટેપ કરો.';
  }

  @override
  String get handedOverWeight => 'સોંપ્યું · ચોખ્ખું 1,240 કિગ્રા';

  @override
  String get royalResidency => 'રોયલ રેસિડન્સી';

  @override
  String get shantiNagar => 'શાંતિ નગર';

  @override
  String get ghodDodRoadSurat => 'ઘોડ દોડ રોડ, સુરત';

  @override
  String get citylightRoadSurat => 'સિટી લાઇટ રોડ, સુરત';

  @override
  String get rakeshStoreManager => 'રાકેશ શાહ · સ્ટોર મેનેજર';

  @override
  String get maheshOwner => 'મહેશ દેસાઈ · માલિક';

  @override
  String get priyaSecretary => 'પ્રિયા પટેલ · સેક્રેટરી';

  @override
  String get meenaSecretary => 'મીના દેસાઈ · સેક્રેટરી';

  @override
  String get pickupSchedule9to11 => 'ગુરુ · સવારે 9:00–11:00';

  @override
  String get pickupSchedule3to330 => 'ગુરુ · બપોરે 3:00–3:30';

  @override
  String get pickupSchedule330to4 => 'ગુરુ · બપોરે 3:30–4:00';

  @override
  String get noTripToday => 'આજે કોઈ ટ્રિપ નથી';

  @override
  String get noTripMessage =>
      'કિરણ શાહે આજે તમને કોઈ ટ્રિપમાં મૂક્યા નથી. ટ્રિપ ઉમેરાશે ત્યારે તમને મેસેજ મળશે.';

  @override
  String get tripOneStops => 'ટ્રિપ 1 સ્ટોપ્સ';

  @override
  String get morningTripWindow => 'સવાર · 7:00 – 11:00';

  @override
  String get fiveOfSevenDone => '7 માંથી 5 પૂર્ણ';

  @override
  String stillToCollect(int count) {
    return 'હજુ કલેક્શન બાકી ($count)';
  }

  @override
  String doneStops(int count) {
    return 'પૂર્ણ ($count)';
  }

  @override
  String stopNumber(int number) {
    return 'સ્ટોપ $number';
  }

  @override
  String get hotelRajdhani => 'હોટેલ રાજધાની';

  @override
  String get greenParkSociety => 'ગ્રીન પાર્ક સોસાયટી';

  @override
  String get navratriGroundEvent => 'નવરાત્રી ગ્રાઉન્ડ (ઇવેન્ટ)';

  @override
  String get cityBakery => 'સિટી બેકરી';

  @override
  String get hotelRajdhaniWeight => '85 કિગ્રા';

  @override
  String get greenParkWeight => '120 કિગ્રા';

  @override
  String get navratriGroundWeight => '215 કિગ્રા';

  @override
  String get noMaterialToday => 'આજે સામગ્રી નથી';

  @override
  String get cancelledBySource => 'સ્રોત દ્વારા રદ';

  @override
  String get stockTakingReason => 'સ્ટોક ગણતરી માટે બંધ';

  @override
  String get unlockStopMessage =>
      'સ્ટોપ 6 પૂર્ણ થાય અથવા તમે આ સ્ટોપ પર પહોંચો (GPS) ત્યારે ખુલશે. તમારું સ્થાન તપાસવા ટેપ કરો.';

  @override
  String get stopTwoCollection => 'સ્ટોપ 2 · કલેક્શન';

  @override
  String get savedAt => '7:52 વાગ્યે સેવ કર્યું · ગુરુ 22 જુલાઈ';

  @override
  String get whatYouSaved => 'તમે જે સેવ કર્યું';

  @override
  String get cardboard => 'કાર્ડબોર્ડ';

  @override
  String get petBottlesWeight => '50 કિગ્રા';

  @override
  String get cardboardWeight => '35 કિગ્રા';

  @override
  String get photosMaterialScale => 'ફોટા (સામગ્રી અને વજનકાંટો)';

  @override
  String get askSupervisorToCorrect => 'સુધારવા સુપરવાઇઝરને કહો';

  @override
  String get savedCollectionReadonlyMessage =>
      'તમે સેવ કરેલું કલેક્શન માત્ર જોઈ શકો છો. કંઈ ખોટું હોય તો તમારા સુપરવાઇઝરને કહો; તેઓ ફોટા સાથે તપાસીને સુધારશે.';

  @override
  String get askToCorrect => 'સુધારવા કહો';

  @override
  String get whatIsWrongAtStop => 'શું ખોટું છે? હોટેલ રાજધાની · સ્ટોપ 2';

  @override
  String get correctionWeight => 'વજન';

  @override
  String get correctionItem => 'વસ્તુ';

  @override
  String get correctionPhoto => 'ફોટો';

  @override
  String get correctionOther => 'અન્ય';

  @override
  String get rightValueAndNote => 'સાચી કિંમત અને નોંધ';

  @override
  String get correctionNoteExample =>
      'ઉદાહરણ: PET બોટલનું વજન 50 નહીં, 60 કિગ્રા હતું. વજનકાંટાના ફોટામાં 60 કિગ્રા દેખાય છે.';

  @override
  String get sendToSupervisor => 'સુપરવાઇઝરને મોકલો';

  @override
  String get requestSent => 'વિનંતી મોકલાઈ';

  @override
  String get toYourSupervisor => 'તમારા સુપરવાઇઝરને';

  @override
  String get correctionRequestSummary =>
      'હોટેલ રાજધાની · વજન · 50 કિગ્રા → 60 કિગ્રા';

  @override
  String get whatHappensNext => 'હવે આગળ શું થશે';

  @override
  String get supervisorChecksPhotos =>
      'કિરણ શાહ તમારા ફોટા સાથે તેની તપાસ કરશે';

  @override
  String get correctionRequestedUntil =>
      'ત્યાં સુધી સ્ટોપ પર “સુધારાની વિનંતી” દેખાશે';

  @override
  String get correctionNotification => 'સુધારો થયા પછી તમને સૂચના મળશે';

  @override
  String get backToMyStops => 'મારા સ્ટોપ્સ પર પાછા જાઓ';

  @override
  String get backToHome => 'હોમ પર પાછા જાઓ';

  @override
  String get stopTripPosition => 'સ્ટોપ 7 માંથી 6 · ટ્રિપ 1';

  @override
  String get personAtPickupPoint => 'પિકઅપ પોઇન્ટ પરની વ્યક્તિ';

  @override
  String get rakeshShah => 'રાકેશ શાહ';

  @override
  String get storeManager => 'સ્ટોર મેનેજર';

  @override
  String get pickupContactPhone => '+91 98765 43214';

  @override
  String get nothingToCollectWeight => 'કલેક્શન માટે કંઈ નથી (0 કિગ્રા)';

  @override
  String get nothingToCollect => 'કલેક્શન માટે કંઈ નથી';

  @override
  String get abcStopSixOfSeven => 'ABC ટેક્સટાઇલ મિલ્સ · સ્ટોપ 7 માંથી 6';

  @override
  String get savedAsZeroKgMessage => 'આ સ્ટોપ 0 કિગ્રા તરીકે સેવ થશે.';

  @override
  String get whyNothingCollected => 'કંઈ કલેક્શન કેમ ન થયું?';

  @override
  String get reasonClosed => 'બંધ હતું';

  @override
  String get reasonRefused => 'આપવાનો ઇનકાર કર્યો';

  @override
  String get reasonNotReachable => 'સંપર્ક ન થયો';

  @override
  String get reasonVehicleFull => 'વાહન ભરેલું છે';

  @override
  String get photoOptional => 'ફોટો (વૈકલ્પિક)';

  @override
  String get noteForSupervisorOptional => 'સુપરવાઇઝર માટે નોંધ (વૈકલ્પિક)';

  @override
  String get typeANote => 'નોંધ લખો…';

  @override
  String get holdToRecordVoiceNote => 'વોઇસ નોંધ રેકોર્ડ કરવા દબાવી રાખો';

  @override
  String get upToOneMinute => '1 મિનિટ સુધી';

  @override
  String get voiceNoteZeroTime => '0:00';

  @override
  String get recordingVoiceNote => 'વોઇસ નોંધ રેકોર્ડ થઈ રહી છે…';

  @override
  String get voiceNoteRecorded => 'વોઇસ નોંધ રેકોર્ડ થઈ';

  @override
  String get playVoiceNote => 'વોઇસ નોંધ ચલાવો';

  @override
  String get pauseVoiceNote => 'વોઇસ નોંધ થોભાવો';

  @override
  String get removeVoiceNote => 'વોઇસ નોંધ દૂર કરો';

  @override
  String get voiceNotePlaybackFailed =>
      'વોઇસ નોંધ ચાલી શકી નથી. ફરી પ્રયાસ કરો.';

  @override
  String get microphonePermissionRequired =>
      'વોઇસ નોંધ રેકોર્ડ કરવા માઇક્રોફોનની પરવાનગી જરૂરી છે.';

  @override
  String get voiceNoteRecordingFailed =>
      'વોઇસ નોંધ રેકોર્ડ થઈ શકી નથી. ફરી પ્રયાસ કરો.';

  @override
  String get locationMatched => 'સ્થાન મેળ ખાય છે';

  @override
  String get locationNotMatched => 'સ્થાન મેળ ખાતું નથી';

  @override
  String get sortedStopSixOfSeven => '7 માંથી સ્ટોપ 6 · છાંટેલું';

  @override
  String get mixedStopSevenOfSeven => '7 માંથી સ્ટોપ 7 · મિશ્ર';

  @override
  String get recordedLaterWarning =>
      'પછી નોંધ્યું: તમે અત્યારે આ સ્ટોપ પર નથી. સુપરવાઇઝર અને ગેટ આ નોંધ જોઈ શકે છે.';

  @override
  String get saveAsZeroKg => '0 કિગ્રા તરીકે સેવ કરો';

  @override
  String get orderedPickupStops => 'ક્રમબદ્ધ પિકઅપ સ્ટોપ્સ';

  @override
  String get startYourCollections => 'તમારું કલેક્શન શરૂ કરો';

  @override
  String get searchHere => 'અહીં શોધો...';

  @override
  String pendingCount(int count) {
    return 'બાકી ($count)';
  }

  @override
  String get yashTextileHub => 'યશ ટેક્સટાઇલ હબ';

  @override
  String get anjanaFarmAreaSurat => 'અંજના ફાર્મ વિસ્તાર, સુરત';

  @override
  String get collectionWindowNineToTen => '09:00 AM - 10:00 AM';

  @override
  String get materialSortedLabel => 'સામગ્રી : છાંટેલી';

  @override
  String get findingYourLocationStatus => 'તમારું સ્થાન શોધી રહ્યા છીએ…';

  @override
  String get findingYourLocation => 'તમારું સ્થાન શોધી રહ્યા છીએ';

  @override
  String get findingLocationMessage =>
      'પિકઅપ પોઇન્ટની નજીક ઊભા રહો. આમાં થોડી સેકન્ડ લાગે છે.';

  @override
  String get cancelAction => 'રદ કરો';

  @override
  String get locationDetected => 'સ્થાન મળ્યું';

  @override
  String get notHere => 'અહીં નથી';

  @override
  String get startCollection => 'કલેક્શન શરૂ કરો';

  @override
  String stopsNearby(int count) {
    return 'નજીકમાં $count સ્ટોપ્સ';
  }

  @override
  String get whichStopAreYouAt => 'તમે કયા સ્ટોપ પર છો?';

  @override
  String get twoStopsCloseMessage => 'તમારી ટ્રિપના બે સ્ટોપ તમારી નજીક છે.';

  @override
  String get distanceStopSeven => '40 મી દૂર · સ્ટોપ 7';

  @override
  String get distanceAlreadyCollected => '85 મી દૂર · પહેલેથી એકત્રિત';

  @override
  String get continueAction => 'આગળ વધો';

  @override
  String get noStopFoundHere => 'અહીં કોઈ સ્ટોપ મળ્યો નથી';

  @override
  String get notAtTripStop => 'તમે આ ટ્રિપના કોઈ સ્ટોપ પર નથી';

  @override
  String get notAtStopMessage =>
      'નજીક જાઓ અને ફરી પ્રયાસ કરો, સ્ટોપ જાતે પસંદ કરો અથવા ગેટ ટીમ માટે છોડી દો.';

  @override
  String get tryAgain => 'ફરી પ્રયાસ કરો';

  @override
  String get chooseStopMyself => 'સ્ટોપ જાતે પસંદ કરો';

  @override
  String get gateTeamWillEnter => 'ગેટ ટીમ દાખલ કરશે';

  @override
  String get locationIsOff => 'સ્થાન બંધ છે';

  @override
  String get turnOnLocation => 'સ્થાન ચાલુ કરો';

  @override
  String get locationOffMessage =>
      'એપ તમારા સ્થાન પરથી સ્ટોપ શોધે છે. પિકઅપ નોંધવા માટે તેને ચાલુ કરો.';

  @override
  String get shreeSaiStopSeven => 'શ્રી સાઈ ડેરી · 7 માંથી સ્ટોપ 7';

  @override
  String get gateTeamEntryMessage =>
      'બેક ઓફિસ વેરહાઉસ ગેટ પર આ પિકઅપ દાખલ કરે છે.';

  @override
  String get weightYouNotedOptional => 'તમે નોંધેલું વજન (વૈકલ્પિક)';

  @override
  String get aboutThreeHundred => 'લગભગ 300';

  @override
  String get gateWeightHelp =>
      'અંદાજિત આંકડો ગેટ ટીમને મદદ કરે છે. તેઓ ગેટ પર ફરી વજન કરે છે.';

  @override
  String get markForGateTeam => 'ગેટ ટીમ માટે ચિહ્નિત કરો';

  @override
  String get nextPickupSavedMessage =>
      'ABC ટેક્સટાઇલ મિલ્સ · 540 કિગ્રા + 25 નંગ સેવ થયા.';

  @override
  String get lastPickupSavedMessage => 'શ્રી સાઈ ડેરી · 300 કિગ્રા સેવ થયા.';

  @override
  String get nextStopSevenOfSeven => 'આગળનો સ્ટોપ · 7 માંથી 7';

  @override
  String get nextStopDistance => 'એલ.પી. સવાણી રોડ, સુરત · 1.2 કિમી';

  @override
  String get goToNextStop => 'આગળના સ્ટોપ પર જાઓ';

  @override
  String get allTripStopsDone => 'ટ્રિપ 1 ના તમામ 7 સ્ટોપ પૂર્ણ';

  @override
  String get takeLoadToWarehouse => 'લોડ મગદલ્લા વેરહાઉસ લઈ જાઓ';

  @override
  String get vehicleLoadTotal => 'વાહનમાં 1,260 કિગ્રા + 25 નંગ';

  @override
  String get warehouseDistance => 'મગદલ્લા, સુરત · 6.4 કિમી';

  @override
  String get viewTripSummary => 'ટ્રિપ સારાંશ જુઓ';

  @override
  String get tripOneSummary => 'ટ્રિપ 1 સારાંશ';

  @override
  String get allStopsDone => 'બધા સ્ટોપ પૂર્ણ';

  @override
  String get tripCollectedTotal => '1,260 કિગ્રા + 25 નંગ';

  @override
  String get mixedWaste => 'મિશ્ર કચરો';

  @override
  String get weight635Kg => '635 કિગ્રા';

  @override
  String get weight270Kg => '270 કિગ્રા';

  @override
  String get weight85Kg => '85 કિગ્રા';

  @override
  String get count25Pcs => '25 નંગ';

  @override
  String get dropAt => 'અહીં ઉતારો';

  @override
  String get warehouseAddressDistance => 'મગદલ્લા પોર્ટ રોડ, સુરત · 6.4 કિમી';

  @override
  String get openInMaps => 'નકશામાં ખોલો';

  @override
  String get callWarehouse => 'વેરહાઉસને કૉલ કરો';

  @override
  String get notCollectedTwo => 'સંગ્રહ ન થયું (2)';

  @override
  String get closedForStockTaking => 'સ્ટોક ગણતરી માટે બંધ';

  @override
  String get handOverAtWarehouse => 'વેરહાઉસમાં સોંપો';

  @override
  String get warehouseGateInstruction =>
      'વેરહાઉસ ગેટ પર ટેપ કરો. તમે બેગની સંખ્યા દાખલ કરો; વેરહાઉસ ઇન્ચાર્જ વાહનનું વજન કરે છે.';

  @override
  String get handOverTripOne => 'સોંપણી · ટ્રિપ 1';

  @override
  String get yourCountFromStops => 'તમારી ગણતરી (સ્ટોપ પરથી)';

  @override
  String get numberOfBags => 'બેગની સંખ્યા';

  @override
  String get bagsUnit => 'બેગ';

  @override
  String get bagsCount => '42';

  @override
  String get bagsHelp =>
      'તમે ઉતારેલી બેગ ગણો. ઇ-વેસ્ટ જેવી છૂટક વસ્તુઓ નંગમાં ગણાય છે.';

  @override
  String get handOver => 'સોંપો';

  @override
  String get warehouseWeighInstruction =>
      'વેરહાઉસ ઇન્ચાર્જ લોડ તપાસે છે અને વેઇબ્રિજ પર વાહનનું વજન કરે છે. તેઓ સેવ કરે પછી વજન અહીં દેખાશે.';

  @override
  String get tripAtWarehouse => 'ટ્રિપ 1 · વેરહાઉસ પર';

  @override
  String get waitingStatus => 'રાહમાં';

  @override
  String get vehicleAtWarehouseSince => 'GJ-XX-1234 · 11:20 થી મગદલ્લા પર';

  @override
  String get youHandedOver => 'તમે સોંપ્યું';

  @override
  String get handedOverTotal => '1,260 કિગ્રા + 25 નંગ · 42 બેગ';

  @override
  String get waitingWarehouseInstruction =>
      '11:20 વાગ્યે સોંપ્યું. વેરહાઉસ ઇન્ચાર્જ વાહનનું વજન કરી રહ્યા છે; સેવ થયા પછી વેઇબ્રિજ વજન અહીં દેખાશે.';

  @override
  String get tripReceived => 'ટ્રિપ 1 · પ્રાપ્ત';

  @override
  String get receivedStatus => 'પ્રાપ્ત';

  @override
  String get vehicleAtWarehouse => 'GJ-XX-1234 · મગદલ્લા વેરહાઉસ';

  @override
  String get weighbridgeEnteredByWarehouse => 'વેઇબ્રિજ · વેરહાઉસ દ્વારા દાખલ';

  @override
  String get warehouseReceivedTotal => '1,240 કિગ્રા નેટ + 25 નંગ';

  @override
  String get withLoadGross => 'લોડ સાથે (ગ્રોસ)';

  @override
  String get weight8940Kg => '8,940 કિગ્રા';

  @override
  String get emptyVehicle => 'ખાલી વાહન';

  @override
  String get weight7700Kg => '7,700 કિગ્રા';

  @override
  String get netWeight => 'નેટ વજન';

  @override
  String get weight1240Kg => '1,240 કિગ્રા';

  @override
  String get bagsReceived => 'પ્રાપ્ત બેગ';

  @override
  String get eWasteCounted => 'ઇ-વેસ્ટ (ગણેલ)';

  @override
  String get yourCountVsWeighbridge => 'તમારી ગણતરી અને વેઇબ્રિજ';

  @override
  String get yourCount => 'તમારી ગણતરી';

  @override
  String get weight1260Kg => '1,260 કિગ્રા';

  @override
  String get weighbridgeNet => 'વેઇબ્રિજ નેટ';

  @override
  String get difference => 'તફાવત';

  @override
  String get weightDifference => '−20 કિગ્રા (1.6% ઓછું)';

  @override
  String get receivedWarehouseInstruction =>
      '11:42 વાગ્યે વેરહાઉસ ઇન્ચાર્જ રમેશ પટેલે પ્રાપ્ત કર્યું. તફાવત ખોટો લાગે તો સમસ્યા નોંધાવો.';

  @override
  String get supervisorWelcomeBack => 'ફરી સ્વાગત છે';

  @override
  String get supervisorHeaderSubtitle =>
      'ગુરુ 22 ઑક્ટો 2026 · અડાજણ, વેસુ, પાલ';

  @override
  String get supervisorOnline => 'તમે ઑનલાઇન છો';

  @override
  String get supervisorLastSynced => 'છેલ્લું સિંક 2 મિનિટ પહેલાં';

  @override
  String get supervisorSyncNow => 'હમણાં સિંક કરો';

  @override
  String get supervisorNeedsAttention => 'તમારું ધ્યાન જરૂરી છે';

  @override
  String get supervisorAttentionSubtitle => 'પહેલા મંજૂર કરો, ઉકેલો અથવા તપાસો';

  @override
  String get supervisorApprovals => 'મંજૂરીઓ';

  @override
  String get supervisorIssues => 'સમસ્યાઓ';

  @override
  String get supervisorMyRequests => 'મારી વિનંતીઓ';

  @override
  String get supervisorFlags => 'ફ્લેગ્સ';

  @override
  String get supervisorCollectionSummary => 'કલેક્શન સારાંશ';

  @override
  String get supervisorToday => 'આજે';

  @override
  String get supervisorYesterday => 'ગઈકાલે';

  @override
  String get supervisorWeek => 'અઠવાડિયું';

  @override
  String get supervisorMonth => 'મહિનો';

  @override
  String get supervisorCollectedToday => 'આજે એકત્રિત · 16માંથી 12 સ્ટોપ';

  @override
  String get supervisorCollectedTotal => '320 કિગ્રા + 125 નંગ';

  @override
  String get supervisorCollected => 'એકત્રિત';

  @override
  String get supervisorKg => '0 કિગ્રા';

  @override
  String get supervisorMissed => 'ચૂક્યા';

  @override
  String get supervisorCancelled => 'રદ';

  @override
  String get supervisorTripsClosed => 'બંધ ટ્રિપ્સ';

  @override
  String get supervisorViewFullReport => 'સંપૂર્ણ રિપોર્ટ જુઓ';

  @override
  String get supervisorTodaysTrips => 'આજની ટ્રિપ્સ';

  @override
  String get supervisorTripsSubtitle => 'આજે 5 ટ્રિપ્સ · આગામી 2 નીચે છે';

  @override
  String get supervisorAdajanMorning => 'અડાજણ સવાર';

  @override
  String get supervisorVikramProgress => 'વિક્રમ સિંહ  •  8માંથી 3 એકત્રિત';

  @override
  String get supervisorOwnVehicle => 'પોતાનું વાહન';

  @override
  String get supervisorDailyWeekly => 'દૈનિક 5 · સાપ્તાહિક 3';

  @override
  String get supervisorCallDriver => 'ડ્રાઇવરને કૉલ કરો';

  @override
  String get supervisorPalGamMorning => 'પાલ ગામ સવાર';

  @override
  String get supervisorAmitProgress => 'અમિત પટેલ  •  એપમાં 8માંથી 0 નોંધાયા';

  @override
  String get supervisorDriverNotSetUp => 'ડ્રાઇવર એપ વાપરતા નથી';

  @override
  String get supervisorSeeTripsPlan => 'ટ્રિપ પ્લાન જુઓ';

  @override
  String get supervisorPickupPoints => 'મારા પિકઅપ પોઇન્ટ્સ';

  @override
  String get supervisorPickupPointsSubtitle =>
      'અડાજણ, વેસુ, પાલમાં 79 · કેટેગરી મુજબ';

  @override
  String get supervisorDaily => 'દૈનિક';

  @override
  String get supervisorWeekly => 'સાપ્તાહિક';

  @override
  String get supervisorBiWeekly => 'પખવાડિક';

  @override
  String get supervisorMonthly => 'માસિક';

  @override
  String get supervisorOnCall => 'કૉલ પર';

  @override
  String get supervisorQuickActions => 'ઝડપી ક્રિયાઓ';

  @override
  String get supervisorUnassignedSources => 'ફાળવ્યા વગરના સ્રોત';

  @override
  String get supervisorManageUnassigned => 'હજુ રૂટ વગરના પિકઅપ પોઇન્ટ';

  @override
  String get supervisorViewSource => 'સ્રોત જુઓ';

  @override
  String get supervisorExtraPickupRequests => 'વધારાના પિકઅપની વિનંતીઓ';

  @override
  String get supervisorManageExtraPickup => 'વધારાના પિકઅપ સ્રોત સંભાળો';

  @override
  String get supervisorViewPickups => 'પિકઅપ જુઓ';

  @override
  String get supervisorAskCollectionHead => 'કલેક્શન હેડને પૂછો';

  @override
  String get supervisorAskCollectionHeadSubtitle =>
      'વાહન, મજૂર અથવા પિકઅપ પોઇન્ટ ફેરફાર';

  @override
  String get supervisorNewRequest => 'નવી વિનંતી';

  @override
  String get supervisorSuggestions => 'સૂચનો';

  @override
  String get supervisorSuggestionsSubtitle =>
      'અંતર અને સમય બચાવવાની રીતો (કલ્પના)';

  @override
  String get supervisorSeeSuggestions => 'સૂચનો જુઓ';

  @override
  String get supervisorHome => 'હોમ';

  @override
  String get attentionApprovalRequests => 'મંજૂરી વિનંતીઓ';

  @override
  String get attentionApprovalSubtitle =>
      'તમારા ડ્રાઇવરો અને IEC એક્ઝિક્યુટિવ્સ તરફથી';

  @override
  String get attentionToApproveCount => 'મંજૂર કરવા 3';

  @override
  String get attentionDoneCount => 'પૂર્ણ 12';

  @override
  String get attentionCorrectionFromDriver => 'સુધારો · ડ્રાઇવર તરફથી';

  @override
  String get attentionWaiting => 'રાહમાં';

  @override
  String get attentionHotelRajdhaniStop =>
      'હોટેલ રજધાની · અડાજણ મોર્નિંગ, સ્ટોપ 2';

  @override
  String get attentionDriverCorrectionDetail =>
      'PET બોટલ 50 kg → 60 kg. વિક્રમ સિંહ: “વજનકાંટાના ફોટામાં 60 kg દેખાય છે.”';

  @override
  String get attentionSentToday => 'આજે, 10:05 am મોકલ્યું';

  @override
  String get attentionDecline => 'નકારો';

  @override
  String get attentionApprove => 'મંજૂર કરો';

  @override
  String get attentionExtraPickup => 'વધારાનું પિકઅપ';

  @override
  String get attentionAbcPlastic => 'ABC પ્લાસ્ટિક મેન્યુફેક્ચર';

  @override
  String get attentionExtraPickupDetail =>
      'શનિ 25 ઑક્ટો, સવારે 10 – બપોરે 12 · લગભગ 40 kg · અડાજણ મોર્નિંગમાં બંધબેસે છે';

  @override
  String get attentionSent21Oct => '21 ઑક્ટો મોકલ્યું';

  @override
  String get attentionCorrectionFromPickupPoint =>
      'સુધારો · પિકઅપ પોઇન્ટ તરફથી';

  @override
  String get attentionGreenParkSociety => 'ગ્રીન પાર્ક સોસાયટી';

  @override
  String get attentionPickupPointCorrectionDetail =>
      '19 ઑક્ટોના પિકઅપમાં કાર્ડબોર્ડ 20 કિગ્રા → 25 કિગ્રા';

  @override
  String get attentionSent20Oct => '20 ઑક્ટો મોકલ્યું';

  @override
  String get attentionCorrectionApproved => 'સુધારો મંજૂર થયો';

  @override
  String get attentionCorrectionApprovedMessage =>
      'હોટેલ રાજધાનીના રેકોર્ડમાં હવે PET બોટલ 60 kg છે. વિક્રમ સિંહને જાણ કરાઈ છે.';

  @override
  String get attentionBackToApprovals => 'મંજૂરી વિનંતીઓ પર પાછા જાઓ';

  @override
  String get attentionBackToHome => 'હોમ પર પાછા જાઓ';

  @override
  String get attentionMyRequests => 'મારી વિનંતીઓ';

  @override
  String get attentionToCollectionHead => 'કલેક્શન હેડને';

  @override
  String get attentionAll4 => 'બધી 4';

  @override
  String get attentionWaiting1 => 'રાહમાં 1';

  @override
  String get attentionApproved2 => 'મંજૂર 2';

  @override
  String get attentionDeclined1 => 'નકારેલ 1';

  @override
  String get attentionVehicleAdajan => 'વાહન · અડાજણ મોર્નિંગ';

  @override
  String get attentionVehicleRequestDescription =>
      'શનિ 25 અને રવિ 26 ઑક્ટોએ બીજું વાહન: નવરાત્રી ગ્રાઉન્ડમાં અંદાજે 2 ટન અપેક્ષિત';

  @override
  String get attentionVehicleRequestResponse =>
      'અરવિંદ દેસાઈ (કલેક્શન હેડ) સાથે';

  @override
  String get attentionSentTodayShort => 'આજે મોકલ્યું';

  @override
  String get attentionLabourPalGam => 'મજૂર · પાલ ગામ મોર્નિંગ';

  @override
  String get attentionLabourRequestDescription =>
      '3 દિવસ માટે એક વધુ લોડર (20–22 ઑક્ટો)';

  @override
  String get attentionLabourRequestResponse =>
      'અરવિંદ દેસાઈ: “રમેશ યાદવ આવતીકાલથી જોડાશે.”';

  @override
  String get attentionSent19Oct => '19 ઑક્ટો મોકલ્યું';

  @override
  String get attentionPauseHotelShivam => 'પિકઅપ પોઇન્ટ રોકો · હોટેલ શિવમ';

  @override
  String get attentionPauseRequestDescription =>
      '1 – 10 નવેમ્બર · રિનોવેશન માટે બંધ';

  @override
  String get attentionPauseRequestResponse =>
      'અરવિંદ દેસાઈ: “મંજૂર. IEC એક્ઝિક્યુટિવને જાણ કરાઈ છે.”';

  @override
  String get attentionSent18Oct => '18 ઑક્ટો મોકલ્યું';

  @override
  String get attentionStartSunriseSchool =>
      'પિકઅપ પોઇન્ટ શરૂ કરો · સનરાઇઝ સ્કૂલ';

  @override
  String get attentionStartRequestDescription =>
      '1 નવેમ્બરથી પુણાગામ ફુલડે પર દરરોજ';

  @override
  String get attentionStartRequestResponse =>
      'અરવિંદ દેસાઈ: “તે ટ્રિપમાં જગ્યા નથી. રાંદેર ઇવનિંગ અજમાવો.”';

  @override
  String get attentionSent16Oct => '16 ઑક્ટો મોકલ્યું';

  @override
  String get attentionApproved => 'મંજૂર';

  @override
  String get attentionDeclined => 'નકારેલ';

  @override
  String get attentionSuggestions => 'સૂચનો';

  @override
  String get attentionSuggestionsSubtitle =>
      'કલ્પના · GPS, રૂટ અને વિસ્તારના વિચારો';

  @override
  String get attentionAll3 => 'બધા 3';

  @override
  String get attentionMoveHotelRajdhani =>
      'હોટેલ રજધાનીને પાલ ગામ મોર્નિંગમાં ખસેડો';

  @override
  String get attentionMoveHotelDescription =>
      'તે અડાજણ મોર્નિંગથી 3.1 કિમી દૂર છે; પાલ ગામ મોર્નિંગ તેના ગેટ પાસેથી જાય છે';

  @override
  String get attentionMoveHotelRoute => 'અડાજણ મોર્નિંગ → પાલ ગામ મોર્નિંગ';

  @override
  String get attentionSaving31Km => 'દરરોજ 3.1 કિમી ઓછું';

  @override
  String get attentionReorderAdajan => 'અડાજણ મોર્નિંગનો ક્રમ બદલો';

  @override
  String get attentionReorderDescription =>
      'ગ્રીન પાર્ક સોસાયટી પહેલાં ઓમ સ્વીટ્સની મુલાકાત લો';

  @override
  String get attentionReorderSecondary => 'એ જ સ્ટોપ, ટૂંકો રસ્તો';

  @override
  String get attentionSaving12Min => 'દરરોજ 12 મિનિટ ઓછી';

  @override
  String get attentionCombineFridayRoutes =>
      'શુક્રવારે રાંદેર અને વેસુ ઇવનિંગ: એક વાહન';

  @override
  String get attentionCombineDescription =>
      'શુક્રવારે બંને અડધાથી ઓછાં ભરાય છે (310 કિગ્રા અને 280 કિગ્રા)';

  @override
  String get attentionCombineSecondary => 'શુક્રવારે GJ-05-EE-1001 ખાલી કરે છે';

  @override
  String get attentionSavingOneVehicle => 'શુક્રવારે એક વાહન ઓછું';

  @override
  String get attentionLast30Days => 'GPSના છેલ્લા 30 દિવસ';

  @override
  String get attentionDismiss => 'રદ કરો';

  @override
  String get attentionApply => 'લાગુ કરો';

  @override
  String get attentionIssues => 'સમસ્યાઓ';

  @override
  String get attentionVehicleBreakdown => 'વાહન બગડ્યું';

  @override
  String get attentionSourceClosed => 'સ્રોત બંધ';

  @override
  String get attentionRameshDriver => 'રમેશ આહિર (ડ્રાઇવર)';

  @override
  String get attentionMohanDriver => 'મોહન લાલ (ડ્રાઇવર)';

  @override
  String get attentionPrakashDriver => 'પ્રકાશ જાદવ (ડ્રાઇવર)';

  @override
  String get attentionVehicleNumber => 'GJ-05-BX-1234';

  @override
  String get attentionDriver => 'ડ્રાઇવર';

  @override
  String get attentionRameshAhir => 'રમેશ આહિર';

  @override
  String get attentionContactNumber => 'સંપર્ક નંબર';

  @override
  String get attentionPhoneNumber => '9876543210';

  @override
  String get attentionRoute => 'રૂટ';

  @override
  String get attentionAdajanMorning => 'અડાજણ મોર્નિંગ';

  @override
  String get attentionReasonFor => 'કારણ: ';

  @override
  String get attentionIssueWord => 'સમસ્યા';

  @override
  String get attentionIssueReason => 'કારણ : કોઈ વાહન ઉપલબ્ધ નથી';

  @override
  String get attentionIssueRemarks =>
      'નોંધ : યાર્ડના બધા ટ્રક હાલમાં બહાર છે. બપોરે 2 પછી પ્રયાસ કરો.';

  @override
  String get flagNothingToCheck => 'તપાસવા જેવું કંઈ નથી';

  @override
  String get flagOctober => 'ઑક્ટોબર';

  @override
  String get flagNothingToCheckSubtitle =>
      'હમણાં કોઈ ફ્લેગ નથી. શેડ્યૂલ ફેરફાર, વિરામ અને રૂટ વગરના પિકઅપ પોઇન્ટ અહીં દેખાય છે.';

  @override
  String get flagMarkDone => 'પૂર્ણ તરીકે ચિહ્નિત કરો';

  @override
  String get sourcesNavLabel => 'સ્રોતો';

  @override
  String get sourcesRoutesNavLabel => 'રૂટ';

  @override
  String get sourcesProfileNavLabel => 'પ્રોફાઇલ';

  @override
  String get routesTitle => 'રૂટ્સ';

  @override
  String get routesSubtitle => 'દરરોજ તેમાંથી ટ્રિપ્સ બનાવવામાં આવે છે';

  @override
  String get routesSearchHint => 'અહીં શોધો...';

  @override
  String get routesEmptyMessage =>
      'હજુ કોઈ રૂટ નથી. તમારો પહેલો રૂટ બનાવવા + પર ટેપ કરો';

  @override
  String get routesFilterAll => 'બધા 4';

  @override
  String get routesFilterOwn => 'પોતાનું વાહન 2';

  @override
  String get routesFilterContract => 'કોન્ટ્રાક્ટ વાહન 2';

  @override
  String get routesPalGamMorning => 'પાલ ગામ મોર્નિંગ';

  @override
  String get routesOwnVehicle => 'પોતાનું વાહન';

  @override
  String get routesDriverNotUsingApp => 'ડ્રાઇવર એપ વાપરતા નથી';

  @override
  String get routesVehicle5678 => 'GJ-05-BX-5678';

  @override
  String get routesPalGamTime => 'સવાર (12:00 PM – 05:00 PM)';

  @override
  String get routesOnRoute => 'રૂટ પર';

  @override
  String get routesRecordedZero => 'એપમાં 8માંથી 0 નોંધાયા';

  @override
  String get routesAdajanMorning => 'અડાજણ મોર્નિંગ';

  @override
  String get routesDailyWeekly => 'દૈનિક 5 · સાપ્તાહિક 3';

  @override
  String get routesVehicle1234 => 'GJ-05-BX-1234';

  @override
  String get routesAdajanTime => 'સવાર (08:00 AM – 02:00 PM)';

  @override
  String get routesPlanned => 'આયોજિત';

  @override
  String get routesCollectedZero => '8માંથી 0 એકત્રિત';

  @override
  String get routesPunagamFullDay => 'પુણાગામ ફુલ ડે';

  @override
  String get routesContractVehicle => 'કોન્ટ્રાક્ટ વાહન';

  @override
  String get routesDailyMonthly => 'દૈનિક 6 · માસિક 2';

  @override
  String get routesFullDayTime => 'આખો દિવસ (08:00 AM – 12:00 PM)';

  @override
  String get routesApproved => 'મંજૂર';

  @override
  String get routesCollectedEight => '8માંથી 8 એકત્રિત';

  @override
  String get routesRanderEvening => 'રાંદેર ઇવનિંગ';

  @override
  String get routesWeeklyBiWeekly => 'સાપ્તાહિક 6 · પખવાડિક 2';

  @override
  String get routesVehicle9012 => 'GJ-05-BX-9012';

  @override
  String get routesEveningTime => 'સાંજ (8 am–8 pm)';

  @override
  String get routesSwitchOff => 'બંધ';

  @override
  String get supervisorDrawerUserName => 'કિરણ શાહ';

  @override
  String get supervisorDrawerRole => 'પિકઅપ સુપરવાઇઝર';

  @override
  String get supervisorDrawerUnassignedSources => 'સોંપ્યા વિનાના સ્રોતો';

  @override
  String get supervisorDrawerRoutes => 'રૂટ્સ';

  @override
  String get supervisorDrawerDriversLabour => 'ડ્રાઇવરો અને મજૂરો';

  @override
  String get supervisorDrawerIssues => 'સમસ્યાઓ';

  @override
  String get supervisorDrawerExtraPickupRequests => 'વધારાની પિકઅપ વિનંતીઓ';

  @override
  String get supervisorDrawerSyncStatus => 'સિંક સ્થિતિ';

  @override
  String get supervisorDrawerNotifications => 'સૂચનાઓ';

  @override
  String get supervisorDrawerHelpSupport => 'મદદ અને સહાય';

  @override
  String get supervisorDrawerLogout => 'લૉગ આઉટ';

  @override
  String get supervisorDrawerPoweredBy => 'ઇકો વિઝન દ્વારા સંચાલિત';

  @override
  String get addRouteStep1 => 'પગલું 1 માંથી 2';

  @override
  String get addRouteStep2 => 'પગલું 2 માંથી 2';

  @override
  String get addRouteRouteName => 'રૂટનું નામ';

  @override
  String get addRouteRouteNameHint => 'ઉદાહરણ તરીકે, અડાજણ મોર્નિંગ';

  @override
  String get addRouteWarehouse => 'વેરહાઉસ';

  @override
  String get addRouteSelectWarehouse => 'વેરહાઉસ પસંદ કરો';

  @override
  String get addRouteShift => 'શિફ્ટ';

  @override
  String get addRouteSelectShift => 'શિફ્ટ પસંદ કરો';

  @override
  String get addRouteContinue => 'આગળ વધો';

  @override
  String get addRouteWarehouseAdajan => 'અડાજણ સેન્ટ્રલ વેરહાઉસ';

  @override
  String get addRouteWarehouseVesu => 'વેસુ સ્ટોરેજ હબ';

  @override
  String get addRouteWarehouseKatargam => 'કતારગામ ડેપો';

  @override
  String get addRouteWarehousePal => 'પાલ સોર્ટિંગ ફેસિલિટી';

  @override
  String get addRouteWarehouseUdhna => 'ઉધના ઇન્ડસ્ટ્રીયલ વેરહાઉસ';

  @override
  String get addRouteShiftMorningEarly => 'સવાર · 7 am–3 pm';

  @override
  String get addRouteShiftMorningLate => 'સવાર · 2 pm–8 pm';

  @override
  String get addRouteShiftFullDay => 'આખો દિવસ (8 am–8 pm)';

  @override
  String get addRouteSelectVehicle => 'વાહન પસંદ કરો';

  @override
  String get addRouteVehicleLabel => 'વાહન';

  @override
  String get addRouteVehicleHint => 'પિકઅપ માટે વાહન પસંદ કરો';

  @override
  String get addRouteSelectDriver => 'ડ્રાઇવર પસંદ કરો';

  @override
  String get addRouteDriverHint => 'પિકઅપ માટે ડ્રાઇવર પસંદ કરો';

  @override
  String get addRouteSelectLabour => 'મજૂર પસંદ કરો';

  @override
  String get addRouteLabourHint => 'મજૂર પસંદ કરો';

  @override
  String get addRouteDriverNotFound => 'ડ્રાઇવર મળ્યો નથી';

  @override
  String get addRouteDriverNotFoundHint =>
      'હજુ કોઈ ડ્રાઇવર ઉમેર્યો નથી. ઉમેરવા નીચે ટેપ કરો.';

  @override
  String get addRouteLabourNotFound => 'મજૂર મળ્યો નથી';

  @override
  String get addRouteLabourNotFoundHint =>
      'હજુ કોઈ મજૂર ઉમેર્યો નથી. ઉમેરવા નીચે ટેપ કરો.';

  @override
  String get addRouteAdd => 'ઉમેરો';

  @override
  String get addRouteVehicleCompany1001 => 'GJ-05-EE-1001';

  @override
  String get addRouteVehicleCompany1234 => 'GJ-05-BX-1234';

  @override
  String get addRouteCompanyTruck => 'કંપની ટ્રક';

  @override
  String get addRouteCapacity => 'ક્ષમતા 3000 KG';

  @override
  String get addRouteDriverVikram => 'વિક્રમ સિંહ (••• 4321)';

  @override
  String get addRouteDriverSuresh => 'સુરેશ કુમાર (••• 5847)';

  @override
  String get addRouteDriverMahesh => 'મહેશ પરમાર (••• 2282)';

  @override
  String get addRouteDriverRakesh => 'રાકેશ શર્મા (••• 2458)';

  @override
  String get addRouteDriverAmit => 'અમિત પટેલ (••• 9510)';

  @override
  String get addRouteLabourRavi => 'રવિ બિષ્ટ (••• 5847)';

  @override
  String get addRouteLabourRam => 'રામ સિંહ (••• 2282)';

  @override
  String get addRouteLabourRamesh => 'રમેશ યાદવ (••• 2458)';

  @override
  String get addRouteLabourArjun => 'અર્જુન જાટવ (••• 9510)';

  @override
  String get addRouteDeactivate => 'નિષ્ક્રિય કરો';

  @override
  String get addRouteDeactivateTitle => 'નિષ્ક્રિય કરવું?';

  @override
  String get addRouteDeactivateMessage =>
      'શું તમે ખરેખર આ વ્યક્તિને નિષ્ક્રિય કરવા માંગો છો?';

  @override
  String get addRouteCancel => 'રદ કરો';

  @override
  String get addRouteYes => 'હા';

  @override
  String get addRouteAddNewDriverPrefix => 'નવો ઉમેરો: ';

  @override
  String get addRouteDriverWord => 'ડ્રાઇવર';

  @override
  String get addRouteLabourWord => 'મજૂર';

  @override
  String get addRouteFullName => 'પૂરું નામ';

  @override
  String get addRouteFullNameHint => 'પૂરું નામ દાખલ કરો';

  @override
  String get addRouteMobileNumber => 'મોબાઇલ નંબર';

  @override
  String get addRouteMobileNumberHint => 'મોબાઇલ નંબર દાખલ કરો';

  @override
  String get addRouteCountryCode => '+91';

  @override
  String get addRouteAadhaarNumber => 'આધાર કાર્ડ નંબર';

  @override
  String get addRouteAadhaarHint => 'આધાર / મતદાર ઓળખપત્ર';

  @override
  String get addRouteProfileProof => 'પ્રોફાઇલ ફોટો / ઓળખ પુરાવો';

  @override
  String get addRouteCapturePhoto => 'ફોટો લો';

  @override
  String get addRoutePhotoHint => 'વિગતો નોંધવા અને ચકાસવા ફોટો અપલોડ કરો.';

  @override
  String get addRouteSaveSelect => 'સાચવો અને પસંદ કરો';

  @override
  String get addRouteFullNameRequired => 'કૃપા કરીને પૂરું નામ દાખલ કરો.';

  @override
  String get addRouteFullNameMinLength =>
      'પૂરું નામ ઓછામાં ઓછા 2 અક્ષરનું હોવું જોઈએ.';

  @override
  String get addRouteMobileRequired => 'કૃપા કરીને મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get addRouteMobileInvalid =>
      '6–9થી શરૂ થતો માન્ય 10 અંકનો મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get addRouteReviewShift => 'સવાર (8 am–2 pm)';

  @override
  String get addRouteReviewVehicle => 'GJ-05-EE-1001';

  @override
  String get addRouteReviewCompany => '(કંપની ટ્રક)';

  @override
  String get addRouteReviewDriver => 'વિક્રમ સિંહ (12345 43210)';

  @override
  String get addRouteReviewLabour => 'રવિ બિષ્ટ (23456 58492)';

  @override
  String get addRouteAddToRoute => 'રૂટમાં ઉમેરો';

  @override
  String get addRouteSavedTitle => 'સફળતાપૂર્વક સાચવ્યું!';

  @override
  String get addRouteSavedSubtitle => 'અડાજણ મોર્નિંગ રૂટ સાચવાયો';

  @override
  String get sourcesUnassignedTitle => 'ફાળવ્યા વગરના સ્રોતો';

  @override
  String get sourcesManageSubtitle => 'કલેક્શન સ્રોતો મેનેજ કરો';

  @override
  String get sourcesSearchHint => 'સ્રોતો શોધો';

  @override
  String get sourcesTabCount => 'સ્રોતો (3)';

  @override
  String get sourcesExtraTabCount => 'વધારાના પિકઅપ (1)';

  @override
  String get sourcesAdajanTextileSorted => 'અડાજણ ટેક્સટાઇલ મિલ · સોર્ટેડ';

  @override
  String get sourcesAddressShort => 'U 9, 10, સિદ્ધગિરી ટાવર, B/H નવયુગ...';

  @override
  String get sourcesMonThuSchedule => 'સોમ, ગુરુ · 8–10 am';

  @override
  String get sourcesUnassignedStatus => 'ફાળવેલ નથી';

  @override
  String get sourcesShreeSaiMixed => 'શ્રી સાઈ ડેરી · મિક્સ્ડ';

  @override
  String get sourcesEmbraneAddress => 'X 3, 10, એમ્બ્રેન ઝોન, નવયુગ પ્લસ...';

  @override
  String get sourcesExceptSunSchedule => 'રવિવાર સિવાય · 9–11 am';

  @override
  String get sourcesShreeSaiSorted => 'શ્રી સાઈ ડેરી · સોર્ટેડ';

  @override
  String get sourcesSecondWedSchedule => 'મહિનાનો બીજો બુધ · 10–11 am';

  @override
  String get sourcesMahavirSorted => 'મહાવીર પેપર મિલ · સોર્ટેડ';

  @override
  String get sourcesExtraPickupSchedule => 'શનિ 24 ઑક્ટો · 11 am–12 pm';

  @override
  String get sourcesEmptyMessage => 'કોઈ ફાળવ્યા વગરની ટ્રિપ ઉપલબ્ધ નથી';

  @override
  String get sourcesAbcTextileMills => 'ABC ટેક્સટાઇલ મિલ્સ';

  @override
  String get sourcesShreeSaiDairy => 'શ્રી સાઈ ડેરી';

  @override
  String get sourcesMahavirPaperMill => 'મહાવીર પેપર મિલ';

  @override
  String get sourcesAddress => 'સરનામું';

  @override
  String get sourcesFullAddress =>
      'U 9, 10, સિદ્ધગિરી ટાવર, B/H નવયુગ કોલેજ રોડ, નવયુગ સોસાયટી, સંગાના સોસાયટી, અડાજણ, સુરત, ગુજરાત 395009';

  @override
  String get sourcesOpenMaps => 'Google Mapsમાં ખોલો';

  @override
  String get sourcesSchedule => 'સમયપત્રક';

  @override
  String get sourcesContactNumber => 'સંપર્ક નંબર';

  @override
  String get sourcesPhone => '9876543210';

  @override
  String get sourcesMaterial => 'સામગ્રી';

  @override
  String get sourcesSorted => 'સોર્ટેડ';

  @override
  String get sourcesMixed => 'મિક્સ્ડ';

  @override
  String get sourcesMaterialsList => 'દૂધની થેલી, કાર્ડ બોર્ડ';

  @override
  String get sourcesPickupStatus => 'પિકઅપ સ્થિતિ';

  @override
  String get sourcesAddToRoute => 'રૂટમાં ઉમેરો';

  @override
  String get sourcesAdajanMorning => 'અડાજણ મોર્નિંગ';

  @override
  String get sourcesVehicleGj051824 => 'GJ 05 1824';

  @override
  String get sourcesMorningTime => 'સવાર (08:00 AM – 02:00 PM)';

  @override
  String get sourcesAssignedCount => 'ફાળવેલા સ્રોતો : 2';

  @override
  String get sourcesPalGamMorning => 'પાલ ગામ મોર્નિંગ';

  @override
  String get sourcesVehicleGj052564 => 'GJ 05 2564';

  @override
  String get sourcesPalGamTime => 'સવારની શિફ્ટ (10:00 AM – 12:00 PM)';

  @override
  String get sourcesVesuEvening => 'વેસુ ઇવનિંગ';

  @override
  String get sourcesTimeClashWarning =>
      'સમય અથડામણ: અડાજણ મોર્નિંગ અહીં લગભગ 1:30 pm પહોંચે છે, પરંતુ પિકઅપ વિન્ડો 9–11 am છે.\nરૂટથી 4.2 કિમી દૂર: દરેક ટ્રિપમાં લગભગ 20 મિનિટ વધુ.\nપાલ ગામ મોર્નિંગ 9:40 am નજીકથી પસાર થાય છે.';

  @override
  String get sourcesAddNew => 'નવું ઉમેરો';

  @override
  String get sourcesAssignAnyway => 'તેમ છતાં ફાળવો';

  @override
  String get sourcesAddedToRoute => 'સ્રોત રૂટમાં ઉમેરાયો';

  @override
  String get sourcesAddedMessage =>
      'ABC ટેક્સટાઇલ મિલ્સ હવે GJ 05 1824 (મોર્નિંગ શિફ્ટ)ને ફાળવવામાં આવી છે.';

  @override
  String get sourcesBackToRequests => 'વિનંતીઓ પર પાછા જાઓ';

  @override
  String get profileTitle => 'યુઝર પ્રોફાઇલ';

  @override
  String get profileSubtitle => 'એકાઉન્ટની વિગતો અને માહિતી';

  @override
  String get profileLanguageCode => 'ગુ';

  @override
  String get profileUserName => 'કિરણ શાહ';

  @override
  String get profileRole => 'પિકઅપ સુપરવાઇઝર';

  @override
  String get profileAccountInformation => 'એકાઉન્ટ માહિતી';

  @override
  String get profileMyAreas => 'મારા વિસ્તારો';

  @override
  String get profileAreasValue => 'અડાજણ, વેસુ, પાલ';

  @override
  String get profileMobileNumber => 'મોબાઇલ નંબર';

  @override
  String get profileMobileValue => '+91 98765 43210';

  @override
  String get profileRoleLabel => 'ભૂમિકા';

  @override
  String get profileSessionExpires => 'સેશન સમાપ્ત';

  @override
  String get profileSessionValue => '6 કલાક 24 મિનિટમાં સમાપ્ત';

  @override
  String get profileActions => 'ક્રિયાઓ';

  @override
  String get profileSyncData => 'ડેટા સિંક કરો';

  @override
  String get profileSyncDataSubtitle => 'તમારો ઓફલાઇન ડેટા સિંક કરો';

  @override
  String get profileAccount => 'એકાઉન્ટ';

  @override
  String get profileLogout => 'લૉગઆઉટ';

  @override
  String get profileLogoutSubtitle => 'તમારા એકાઉન્ટમાંથી સાઇન આઉટ કરો';

  @override
  String get profileSyncOfflineData => 'ઓફલાઇન ડેટા સિંક કરો';

  @override
  String get profileChangesNotSent => '3 ફેરફારો હજી મોકલ્યા નથી';

  @override
  String get profileSyncNow => 'હવે સિંક કરો';

  @override
  String get profileDataAlreadySynced => 'ડેટા પહેલેથી સિંક છે';

  @override
  String get profileBack => 'પાછા';

  @override
  String get profileLogoutQuestion => 'શું તમે ખરેખર લૉગઆઉટ કરવા માંગો છો?';

  @override
  String get profileLogoutMessage =>
      'સિંક ન થયેલો ઓફલાઇન ડેટા આગામી સાઇન-ઇન સુધી આ ઉપકરણ પર રહેશે.';

  @override
  String get profileSendChangesWarning => 'ડ્રાઇવરોને જાણ કરવા ફેરફારો મોકલો';

  @override
  String get profileNo => 'ના';

  @override
  String get profileYes => 'હા';

  @override
  String get profileNotifications => 'સૂચનાઓ';

  @override
  String get profileToday => 'આજે';

  @override
  String get profileEarlier => 'અગાઉ';

  @override
  String get profileOfflineMode => 'ઓફલાઇન મોડ';

  @override
  String get profileOfflineModeMessage =>
      'ઇન્ટરનેટ કનેક્શન નથી. કનેક્શન પાછું આવે ત્યારે ડેટા આપમેળે સિંક થશે.';

  @override
  String get profileJustNow => 'હમણાં જ';

  @override
  String get profileNewSourceUnassigned => 'નવો સોર્સ ફાળવેલ નથી';

  @override
  String get profileNewSourceMessage =>
      'ગ્લોબલ ગાર્મેન્ટ્સ (અડાજણ)ને રૂટ ફાળવણી જોઈએ છે.';

  @override
  String get profileTenMinutesAgo => '10 મિનિટ પહેલાં';

  @override
  String get profileDriverEscalation => 'ડ્રાઇવર એસ્કેલેશન';

  @override
  String get profileDriverEscalationMessage =>
      'ડ્રાઇવર રમેશે પાલ સ્થળે ગેટ પ્રવેશમાં વિલંબની જાણ કરી.';

  @override
  String get profileYesterdayTime => 'ગઈકાલે, 11:30 AM';

  @override
  String get profilePickupSkipped => 'પિકઅપ છોડ્યું';

  @override
  String get profilePickupSkippedMessage =>
      'સિદ્ધગિરી ટ્રેડર્સનું કલેક્શન છોડ્યું.';

  @override
  String get profilePickupSkippedTime => '24 ઑક્ટો, 08:00 AM';

  @override
  String get profileAllCaughtUp => 'બધું પૂર્ણ!';

  @override
  String get profileNoNotifications =>
      'તમારી પાસે નવી સૂચનાઓ નથી. સિસ્ટમ અને એડમિન અપડેટ માટે પછી તપાસો.';

  @override
  String get profileHelpSupport => 'મદદ અને સહાય';

  @override
  String get profileCallSupport => 'સપોર્ટને કૉલ કરો';

  @override
  String get profileCallSupportSubtitle => 'ફીલ્ડ સમસ્યાઓ માટે 24/7 ઉપલબ્ધ';

  @override
  String get profileInstantHelp => 'તાત્કાલિક મદદ';

  @override
  String get profileInstantHelpSubtitle => 'સપોર્ટ એજન્ટ સાથે ચેટ કરો';

  @override
  String get profileFaqTitle => 'વારંવાર પૂછાતા પ્રશ્નો';

  @override
  String get profileFaqDailyTrips => 'દૈનિક ટ્રિપ કેવી રીતે કામ કરે છે?';

  @override
  String get profileFaqDailyTripsAnswer =>
      'દરરોજ સવારે તમારા માસ્ટર રૂટ પરથી આપમેળે બને છે.';

  @override
  String get profileFaqSwapDriver => 'આજ માટે ડ્રાઇવર કેવી રીતે બદલવો?';

  @override
  String get profileFaqSwapDriverAnswer =>
      'આજનો રૂટ ખોલો અને ડ્રાઇવર એડિટ ક્રિયા વાપરો.';

  @override
  String get profileFaqUnassigned => 'અનઅસાઇન્ડ સોર્સ શું છે?';

  @override
  String get profileFaqUnassignedAnswer =>
      'જે સોર્સ હાલમાં કોઈ રૂટ સાથે જોડાયેલા નથી.';

  @override
  String get profileFaqSkipping => 'સ્ટોપ છોડવાથી શું થાય છે?';

  @override
  String get profileFaqSkippingAnswer =>
      'વર્તમાન ટ્રિપમાં સ્ટોપ છોડ્યો હોવાનું નોંધાય છે.';

  @override
  String get profileClosedDayArtwork => 'હવે દિવસ\nબંધ કરવાનો સમય';

  @override
  String get driverProfileUserName => 'રમેશ કુમાર';

  @override
  String get driverProfileWarehouseLabel => 'મારું વેરહાઉસ';

  @override
  String get driverProfileWarehouseValue => 'મગદલ્લા વેરહાઉસ';

  @override
  String get driverProfileDriverCodeLabel => 'ડ્રાઇવર કોડ';

  @override
  String get driverProfileDriverCodeValue => 'SUR-DRV-0007';

  @override
  String get driverProfileMobileValue => '+91 98765 43226';

  @override
  String get driverProfileRoleValue => 'ડ્રાઇવર';

  @override
  String get driverProfileLogoutWarning =>
      '3 કલેક્શન હજુ મોકલાયા નથી: પહેલા સિંક કરો';

  @override
  String get dlDriverDirectory => 'ડ્રાઇવર ડિરેક્ટરી';

  @override
  String get dlLabourDirectory => 'મજૂર ડિરેક્ટરી';

  @override
  String get dlFilterActive => 'સક્રિય';

  @override
  String get dlFilterInactive => 'નિષ્ક્રિય';

  @override
  String dlTabDrivers(int count) {
    return 'ડ્રાઇવર ($count)';
  }

  @override
  String dlTabLabour(int count) {
    return 'મજૂર ($count)';
  }

  @override
  String get dlSearchHint => 'અહીં શોધો...';

  @override
  String get dlAddDriver => 'ડ્રાઇવર ઉમેરો';

  @override
  String get dlAddLabour => 'મજૂર ઉમેરો';

  @override
  String get dlAddLabourer => 'મજૂર ઉમેરો';

  @override
  String get dlNoDetailsFound => 'કોઈ વિગતો મળી નથી';

  @override
  String get dlNoPhone => '--';

  @override
  String get dlAddNewDriver => 'નવો ડ્રાઇવર ઉમેરો';

  @override
  String get dlAddNewLabour => 'નવો મજૂર ઉમેરો';

  @override
  String get dlEditDriver => 'ડ્રાઇવર સંપાદિત કરો';

  @override
  String get dlEditLabour => 'મજૂર સંપાદિત કરો';

  @override
  String get dlFullName => 'પૂરું નામ';

  @override
  String get dlEnterFullName => 'પૂરું નામ દાખલ કરો';

  @override
  String get dlMobileNumber => 'મોબાઇલ નંબર';

  @override
  String get dlEnterMobileNumber => 'મોબાઇલ નંબર દાખલ કરો';

  @override
  String get dlCountryCode => '+91';

  @override
  String get dlProfilePhoto => 'પ્રોફાઇલ ફોટો / ID પ્રૂફ';

  @override
  String get dlCapturePhoto => 'ફોટો લો';

  @override
  String get dlCancel => 'રદ કરો';

  @override
  String get dlDeactivate => 'નિષ્ક્રિય કરો';

  @override
  String get dlEdit => 'સંપાદિત કરો';

  @override
  String get supervisorTripsToday => 'આજની ટ્રિપ્સ';

  @override
  String get tpTitle => 'ટ્રિપ પ્લાન';

  @override
  String get tpAreas => 'અડાજણ, વેસુ, પાલ';

  @override
  String get tpChoiceToday => 'આજે';

  @override
  String get tpChoiceTomorrow => 'આવતીકાલે';

  @override
  String get tpChoiceWeek => 'આ અઠવાડિયું';

  @override
  String get tpDateToday => 'ગુરુ 22 ઑક્ટો 2026';

  @override
  String get tpDateTomorrow => 'શુક્ર 23 ઑક્ટો 2026';

  @override
  String get tpDateNoTrips => 'રવિ 8 નવે 2026';

  @override
  String tpTripsStops(int trips, int stops) {
    return '$trips ટ્રિપ · $stops સ્ટોપ';
  }

  @override
  String tpExtraPickups(int count) {
    return '$count વધારાના પિકઅપ';
  }

  @override
  String tpSourcePaused(int count) {
    return '$count સોર્સ થોભાવેલ';
  }

  @override
  String get tpNoTrips => 'કોઈ ટ્રિપ નથી';

  @override
  String get tpStatusOnRoute => 'રસ્તામાં';

  @override
  String get tpStatusApproved => 'મંજૂર';

  @override
  String get tpStatusPlanned => 'આયોજિત';

  @override
  String get tpOwnVehicle => 'પોતાનું વાહન';

  @override
  String get tpContractVehicle => 'કરાર વાળું વાહન';

  @override
  String tpVehicleTag(String plate, String vehicle) {
    return '$plate · $vehicle';
  }

  @override
  String get tpChangedForToday => 'આજ માટે બદલાયું';

  @override
  String get tpDriverNotUsingApp => 'ડ્રાઇવર એપ વાપરતા નથી';

  @override
  String tpCoverFor(String substitute, String original) {
    return '$substitute ($original ની જગ્યાએ)';
  }

  @override
  String tpTransporterDriver(String transporter, String driver) {
    return '$transporter · ડ્રાઇવર $driver';
  }

  @override
  String tpStops(int count) {
    return '$count સ્ટોપ';
  }

  @override
  String tpDaily(int count) {
    return 'દૈનિક $count';
  }

  @override
  String tpWeekly(int count) {
    return 'સાપ્તાહિક $count';
  }

  @override
  String tpMonthly(int count) {
    return 'માસિક $count';
  }

  @override
  String tpBiWeekly(int count) {
    return 'દ્વિ-સાપ્તાહિક $count';
  }

  @override
  String tpOnCall(int count) {
    return 'ઑન કૉલ $count';
  }

  @override
  String tpPaused(int count) {
    return '$count થોભાવેલ';
  }

  @override
  String tpCollectedOf(int done, int total) {
    return '$total માંથી $done એકત્ર';
  }

  @override
  String tpRecordedOf(int done, int total) {
    return '$total માંથી $done એપમાં નોંધાયા';
  }

  @override
  String tpCollectedMissed(int collected, int missed) {
    return '$collected એકત્ર · $missed ચૂકી ગયા';
  }

  @override
  String tpWeightKg(String kg) {
    return '$kg કિગ્રા';
  }

  @override
  String get tpCallDriver => 'ડ્રાઇવરને કૉલ કરો';

  @override
  String tpOwnVehicleCount(int count) {
    return 'પોતાનું વાહન $count';
  }

  @override
  String tpContractCount(int count) {
    return 'કરાર $count';
  }

  @override
  String get tpDay0 => 'ગુરુ 22 ઑક્ટો · આજે';

  @override
  String get tpDay1 => 'શુક્ર 23 ઑક્ટો';

  @override
  String get tpDay2 => 'શનિ 24 ઑક્ટો';

  @override
  String get tpDay3 => 'રવિ 25 ઑક્ટો';

  @override
  String get tpDay4 => 'સોમ 26 ઑક્ટો';

  @override
  String get tpDay5 => 'મંગળ 27 ઑક્ટો';

  @override
  String get tpDay6 => 'બુધ 28 ઑક્ટો';

  @override
  String get tpEmptyTitle => 'આ દિવસે કોઈ ટ્રિપ નથી';

  @override
  String get tpEmptyMessage =>
      'તે દિવસે વેરહાઉસ બંધ છે (રજા). તે દિવસના પિકઅપ દરેક પિકઅપ પોઇન્ટના રજા નિયમ મુજબ આગલા કામકાજના દિવસે જશે અથવા છોડી દેવાશે.';

  @override
  String get rdNext7Days => 'આગામી 7 દિવસ';

  @override
  String get rdDateToday => 'ગુરુ, 22 ઑક્ટો 2026';

  @override
  String get rdDateRange => 'શુક્ર 23 ઑક્ટો – ગુરુ 29 ઑક્ટો';

  @override
  String rdShift(String time) {
    return 'સવાર ($time)';
  }

  @override
  String rdAssignedSources(int count) {
    return 'સોંપાયેલા સોર્સ : $count';
  }

  @override
  String rdAssignedSourcesPaused(int count, int paused) {
    return 'સોંપાયેલા સોર્સ : $count ($paused થોભાવેલ)';
  }

  @override
  String rdDriverLine(String name, String phone) {
    return 'ડ્રાઇવર : $name ($phone)';
  }

  @override
  String rdLabourLine(String name) {
    return 'મજૂર : $name';
  }

  @override
  String get rdList => 'લિસ્ટ';

  @override
  String get rdMap => 'નકશો';

  @override
  String get rdFilterAll => 'બધા';

  @override
  String get rdFilterCollected => 'એકત્ર';

  @override
  String get rdFilterPending => 'બાકી';

  @override
  String get rdFilterZeroKg => '0 કિગ્રા';

  @override
  String get rdFilterMissed => 'ચૂકી ગયેલ';

  @override
  String get rdFilterCancelled => 'રદ';

  @override
  String get rdFilterInactive => 'નિષ્ક્રિય';

  @override
  String get rdFreqDaily => 'દૈનિક';

  @override
  String get rdFreqWeekly => 'સાપ્તાહિક';

  @override
  String get rdTypeSorted => 'સૉર્ટેડ';

  @override
  String get rdTypeMixed => 'મિશ્ર';

  @override
  String rdStopTitle(String name, String type) {
    return '$name · $type';
  }

  @override
  String rdSchedEveryDay(String time) {
    return 'દરરોજ · $time';
  }

  @override
  String rdSchedDays(String days, String time) {
    return '$days · $time';
  }

  @override
  String rdSchedExceptSun(String time) {
    return 'રવિ સિવાય, $time';
  }

  @override
  String rdSchedSecondWed(String time) {
    return 'બીજો બુધ, $time';
  }

  @override
  String rdSchedOnce(String date, String time) {
    return '(એક વાર) $date, $time';
  }

  @override
  String rdSchedPausedTill(String date) {
    return '$date સુધી થોભાવેલ';
  }

  @override
  String get rdWeekdayMon => 'સોમ';

  @override
  String get rdWeekdayThu => 'ગુરુ';

  @override
  String get rdStatusCollected => 'એકત્ર';

  @override
  String get rdStatusZeroKg => '0 કિગ્રા';

  @override
  String get rdStatusCancelledBySource => 'સોર્સ દ્વારા રદ';

  @override
  String get rdStatusNextStop => 'આગલો સ્ટોપ';

  @override
  String get rdStatusPending => 'બાકી';

  @override
  String get rdStatusInactive => 'નિષ્ક્રિય';

  @override
  String rdAmountKgPcs(String kg, String pcs) {
    return '$kg કિગ્રા + $pcs નંગ';
  }

  @override
  String get rdNoteNoMaterial => 'આજે કોઈ માલ નથી';

  @override
  String get rdNoteClosedStocktaking => 'સ્ટોક ગણતરી માટે બંધ';

  @override
  String get rdNotePausedRenovation => 'સોર્સ થોભાવેલ (રિનોવેશન)';

  @override
  String rdTagCollectedAt(String time) {
    return '$time એ એકત્ર';
  }

  @override
  String rdTagVisitedAt(String time) {
    return '$time એ મુલાકાત';
  }

  @override
  String get rdTagNoteFromDriver => 'ડ્રાઇવરની નોંધ';

  @override
  String rdTagVoiceNote(String duration) {
    return 'વૉઇસ નોંધ $duration';
  }

  @override
  String get rdLegendCollected => 'એકત્ર';

  @override
  String get rdLegendZeroKg => '0 કિગ્રા';

  @override
  String get rdLegendCancelled => 'રદ';

  @override
  String get rdLegendNextStop => 'આગલો સ્ટોપ';

  @override
  String get rdLegendPending => 'બાકી';

  @override
  String get rdLegendPaused => 'થોભાવેલ';

  @override
  String get rdLegendWarehouse => 'વેરહાઉસ';

  @override
  String rdMapNext(int number, String name, String time, String distance) {
    return 'આગલો: $number · $name · $time · $distance દૂર';
  }

  @override
  String get rdMapHint =>
      'સ્ટોપ મુલાકાતના ક્રમમાં. ઘન રેખા પૂર્ણ થઈ છે; ડૅશ રેખા બાકી છે, વેરહાઉસ પર પાછા. સ્ટોપ ખોલવા તેના પર ટૅપ કરો.';

  @override
  String get rdAddedLastHint =>
      'તે છેલ્લા સ્ટોપ તરીકે ઉમેરાય છે. તમે રૂટના પેજ પર ક્રમ બદલી શકો છો.';

  @override
  String get rdAddSources => 'સોર્સ ઉમેરો';

  @override
  String get sdAddress => 'સરનામું';

  @override
  String get sdSchedule => 'સમયપત્રક';

  @override
  String get sdPersonAtPickup => 'પિકઅપ સ્થળે વ્યક્તિ';

  @override
  String get sdIecExecutive => 'IEC એક્ઝિક્યુટિવ';

  @override
  String get sdRoleManager => 'મેનેજર';

  @override
  String sdContactLine(String name, String role, String phone) {
    return '$name · $role · $phone';
  }

  @override
  String sdIecLine(String name, String phone) {
    return '$name · $phone';
  }

  @override
  String get skTitle => 'આ પિકઅપ છોડો';

  @override
  String get skReasonLabel => 'છોડવાનું કારણ';

  @override
  String get skReasonClosed => 'સોર્સ બંધ છે';

  @override
  String get skReasonHoliday => 'રજા';

  @override
  String get skReasonVehicle => 'વાહન ઉપલબ્ધ નથી';

  @override
  String get skReasonOther => 'અન્ય';

  @override
  String get skRemarks => 'ટિપ્પણી';

  @override
  String get skMaxChars => 'વધુમાં વધુ 150 અક્ષરો';

  @override
  String get skConfirm => 'છોડવાની પુષ્ટિ કરો';

  @override
  String get apToApprove => 'મંજૂર કરવાના';

  @override
  String get apDone => 'પૂર્ણ';

  @override
  String get apCorrectionDoneDetail =>
      'PET બોટલ 50 kg → 60 kg. સ્ટોપનો રેકોર્ડ બદલાયો છે; વિક્રમ સિંહને જાણ કરાઈ છે.';

  @override
  String get apApprovedToday => 'તમે આજે સવારે 10:20 વાગ્યે મંજૂર કર્યું';

  @override
  String get apExtraPickupDoneDetail =>
      'શનિ 25 ઑક્ટો, સવારે 10 – બપોરે 12 · લગભગ 40 kg · અડાજણ મોર્નિંગમાં ઉમેરાયું';

  @override
  String get apApproved21Oct => 'તમે 21 ઑક્ટોએ મંજૂર કર્યું';

  @override
  String get apStartPickupsFromIec => 'પિકઅપ શરૂ કરો · IEC તરફથી';

  @override
  String get apGreenLeafNisha => 'ગ્રીન લીફ હોટેલ · નિશા મહેતા';

  @override
  String get apDeclineReplyDetail =>
      'તમારો જવાબ: “1 ડિસે. સુધી અડાજણ મોર્નિંગમાં જગ્યા નથી. ત્યારે ફરી પૂછો.”';

  @override
  String get apDeclined20Oct => 'તમે 20 ઑક્ટોએ નકાર્યું';

  @override
  String get apDeclineCorrectionTitle => 'સુધારો નકારો';

  @override
  String get apDeclineCorrectionBody =>
      'વિક્રમ સિંહ તમારો જવાબ જોશે. સ્ટોપ નોંધ્યા મુજબ જ રહેશે.';

  @override
  String get apDeclineCorrectionReply =>
      'વજનકાંટાના ફોટામાં 50 kg દેખાય છે. વધારે હોય તો ગેટ ટીમને ફરી વજન કરવા કહો.';

  @override
  String get apDeclineExtraTitle => 'વધારાનું પિકઅપ નકારો';

  @override
  String get apDeclineExtraBody =>
      'ABC પ્લાસ્ટિક મેન્યુફેક્ચર તમારો જવાબ જોશે. કોઈ પિકઅપ ઉમેરાશે નહીં.';

  @override
  String get apReplyHint => 'તમારો જવાબ લખો';

  @override
  String get apDeclineAndReply => 'નકારો અને જવાબ આપો';

  @override
  String get apCancel => 'રદ કરો';

  @override
  String get apExtraApprovedTitle => 'વધારાનું પિકઅપ મંજૂર';

  @override
  String get apExtraApprovedBody =>
      'ABC પ્લાસ્ટિક મેન્યુફેક્ચર શનિ 25 ઑક્ટોએ અડાજણ મોર્નિંગમાં ઉમેરાયું છે.';

  @override
  String get rpTitle => 'કલેક્શન રિપોર્ટ';

  @override
  String get rpShare => 'શેર કરો';

  @override
  String get rpCollectedToday => 'આજે એકત્રિત';

  @override
  String get rpCollectedYesterday => 'ગઈકાલે એકત્રિત';

  @override
  String get rpCollectedThisWeek => 'આ અઠવાડિયે એકત્રિત';

  @override
  String get rpCollectedThisMonth => 'આ મહિને એકત્રિત';

  @override
  String get rpCollectedTheseDates => 'આ તારીખોમાં એકત્રિત';

  @override
  String rpTotal(String kg, String pcs) {
    return '$kg kg + $pcs નંગ';
  }

  @override
  String rpKg(String kg) {
    return '$kg kg';
  }

  @override
  String rpStopsDue(String count) {
    return '$count સ્ટોપ બાકી';
  }

  @override
  String get rpByRoute => 'રૂટ પ્રમાણે';

  @override
  String get rpByCategory => 'પિકઅપ કેટેગરી પ્રમાણે';

  @override
  String get rpStopsToLook => 'ધ્યાન આપવાના સ્ટોપ';

  @override
  String rpOfStops(String done, String total) {
    return '$totalમાંથી $done સ્ટોપ';
  }

  @override
  String rpStops(String count) {
    return '$count સ્ટોપ';
  }

  @override
  String get rpOwn => 'પોતાનું';

  @override
  String get rpContract => 'કોન્ટ્રાક્ટ';

  @override
  String get rpCancelledBySource => 'સ્રોતે રદ કર્યું';

  @override
  String rpNamesMore(String first, String second, String count) {
    return '$first, $second અને બીજા $count';
  }

  @override
  String rpNamesPlus(String first, String second, String count) {
    return '$first, $second +$count';
  }

  @override
  String rpCollectedStops(String label, String done, String total) {
    return '$label · $totalમાંથી $done સ્ટોપ';
  }

  @override
  String get rpPdfTitle => 'રિપોર્ટ PDF';

  @override
  String rpPdfSubtitle(String range) {
    return 'કલેક્શન રિપોર્ટ · $range';
  }

  @override
  String get rpCompany => 'Ecovision Environmental Resources LLP';

  @override
  String rpPdfSupervisor(String name, String period, String range) {
    return 'પિકઅપ સુપરવાઇઝર: $name · $period, $range';
  }

  @override
  String get rpPeriodToday => 'આજે';

  @override
  String get rpPeriodYesterday => 'ગઈકાલે';

  @override
  String get rpPeriodThisWeek => 'આ અઠવાડિયે';

  @override
  String get rpPeriodThisMonth => 'આ મહિને';

  @override
  String get rpPeriodDates => 'પસંદ કરેલી તારીખો';

  @override
  String rpPdfSummary(
    String due,
    String collected,
    String zero,
    String missed,
    String cancelled,
  ) {
    return '$due સ્ટોપ બાકી · એકત્રિત $collected · 0 kg $zero · ચૂકી ગયા $missed · રદ $cancelled';
  }

  @override
  String get rpColRoute => 'રૂટ';

  @override
  String get rpColVehicle => 'વાહન';

  @override
  String get rpColStops => 'સ્ટોપ';

  @override
  String get rpColCollected => 'એકત્રિત';

  @override
  String get rpColCategory => 'કેટેગરી';

  @override
  String get rpColOutcome => 'પરિણામ';

  @override
  String get rpColPickupPoints => 'પિકઅપ પોઇન્ટ';

  @override
  String rpOf(String done, String total) {
    return '$totalમાંથી $done';
  }

  @override
  String rpPdfMade(String date, String time) {
    return '$date, $time એ બનાવ્યું · પાનું 1 માંથી 1';
  }

  @override
  String get rpPdfPageHint => 'પાનું 1 માંથી 1 · ઝૂમ કરવા પિંચ કરો';

  @override
  String get rpSharePdf => 'PDF શેર કરો';

  @override
  String get calClear => 'સાફ કરો';

  @override
  String get calApply => 'લાગુ કરો';

  @override
  String get calPrevMonth => 'પાછલો મહિનો';

  @override
  String get calNextMonth => 'આગલો મહિનો';

  @override
  String calSelection(String range, String days) {
    return '$range · $days';
  }

  @override
  String calDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count દિવસ',
      one: '1 દિવસ',
    );
    return '$_temp0';
  }

  @override
  String get calPickDates => 'તારીખો પસંદ કરો';

  @override
  String calMonthLong(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'જાન્યુઆરી',
      '2': 'ફેબ્રુઆરી',
      '3': 'માર્ચ',
      '4': 'એપ્રિલ',
      '5': 'મે',
      '6': 'જૂન',
      '7': 'જુલાઈ',
      '8': 'ઑગસ્ટ',
      '9': 'સપ્ટેમ્બર',
      '10': 'ઑક્ટોબર',
      '11': 'નવેમ્બર',
      '12': 'ડિસેમ્બર',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calMonthShort(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      '1': 'જાન્યુ',
      '2': 'ફેબ્રુ',
      '3': 'માર્ચ',
      '4': 'એપ્રિ',
      '5': 'મે',
      '6': 'જૂન',
      '7': 'જુલા',
      '8': 'ઑગ',
      '9': 'સપ્ટે',
      '10': 'ઑક્ટો',
      '11': 'નવે',
      '12': 'ડિસે',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'સો',
      '2': 'મં',
      '3': 'બુ',
      '4': 'ગુ',
      '5': 'શુ',
      '6': 'શ',
      '7': 'ર',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get supervisorDrawerCashPayments => 'રોકડ અને ચુકવણી';

  @override
  String lkRouteDate(String route, String date) {
    return '$route · $date';
  }

  @override
  String get lkNotOnRoute => 'કોઈ રૂટ પર નથી';

  @override
  String lkContractVehicle(String plate) {
    return 'કોન્ટ્રાક્ટ વાહન · $plate';
  }

  @override
  String lkOwnVehicle(String name) {
    return 'પોતાનું વાહન · ડ્રાઇવર $name';
  }

  @override
  String get lkExtraPickup => 'વધારાનું પિકઅપ';

  @override
  String get lkCalledOffIec => 'IEC એ અગાઉથી રદ કર્યું';

  @override
  String lkCalledOffAtStop(String name) {
    return 'સ્ટોપ પર રદ થયું · ડ્રાઇવર $name';
  }

  @override
  String get lkCalledOffByYou => 'તમે રદ કર્યું';

  @override
  String get lkReasonNotRecorded => 'ડ્રાઇવર કે ગેટે નોંધ્યું નથી';

  @override
  String get lkReasonTripCancelled => 'તેની ટ્રિપ રદ થઈ હતી';

  @override
  String get lkReasonNoRoute => 'તે દિવસે કોઈ રૂટ નહોતો';

  @override
  String get lkReasonTakenOff => 'ટ્રિપમાંથી કાઢ્યું અને બીજીમાં મૂક્યું નહીં';

  @override
  String get lkReasonClosedToday => 'આજે બંધ';

  @override
  String get lkReasonHoliday => 'રજા';

  @override
  String get lkReasonShifted => 'બીજા દિવસે ખસેડ્યું';

  @override
  String get lkReasonNoMaterial => 'કોઈ માલ નથી';

  @override
  String get lkReasonNoMaterialToday => 'આજે કોઈ માલ નથી';

  @override
  String get lkReasonClosed => 'બંધ';

  @override
  String get lkReasonRefused => 'આપવાની ના પાડી';

  @override
  String get lkReasonVehicleFull => 'વાહન ભરાઈ ગયું';

  @override
  String get lkEmpty => 'આ તારીખોમાં ધ્યાન આપવા જેવું કંઈ નથી';

  @override
  String calWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'સોમ',
      '2': 'મંગળ',
      '3': 'બુધ',
      '4': 'ગુરુ',
      '5': 'શુક્ર',
      '6': 'શનિ',
      '7': 'રવિ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get isTypeSourceProblem => 'સ્રોત પર સમસ્યા';

  @override
  String isDriverRole(String name) {
    return '$name (ડ્રાઇવર)';
  }

  @override
  String isRaised(String time) {
    return '$time એ નોંધાવ્યું';
  }

  @override
  String get isOpen => 'ખુલ્લું';

  @override
  String get isEscalated => 'આગળ મોકલ્યું';

  @override
  String get isResolved => 'ઉકેલાયું';

  @override
  String get isTypeLabel => 'પ્રકાર :';

  @override
  String get isDriverNote => 'ડ્રાઇવરની નોંધ :';

  @override
  String get isBy => 'દ્વારા :';

  @override
  String isByValue(String name, String time) {
    return '$name · $time';
  }

  @override
  String get isWhatWasDone => 'શું કર્યું :';

  @override
  String get isTold => 'જાણ કરી :';

  @override
  String isToldValue(String name) {
    return 'ઑફિસ અને $name (IEC).';
  }

  @override
  String get isEscalate => 'આગળ મોકલો';

  @override
  String get isMarkResolved => 'ઉકેલાયું ગણો';

  @override
  String get isSheetTitle => 'ઉકેલાયું તરીકે નોંધો';

  @override
  String get isSheetBody => 'શું કર્યું તે લખો. ડ્રાઇવર અને ઑફિસ તે જોશે.';

  @override
  String get isWhatWasDoneLabel => 'શું કર્યું';

  @override
  String get isEscalateTitle => 'આ સમસ્યા આગળ મોકલવી છે?';

  @override
  String get isEscalateBody =>
      'ઑફિસ અને સ્રોતના IEC ને જાણ થશે, અને તે આગળ મોકલ્યું તરીકે દેખાશે. જ્યારે તમે જાતે ઉકેલી ન શકો ત્યારે વાપરો.';

  @override
  String get isResolvedToastTitle => 'સમસ્યા ઉકેલાઈ!';

  @override
  String isResolvedToastBody(String name) {
    return '$name ને જાણ કરાઈ છે.';
  }

  @override
  String get isEscalatedToastTitle => 'સમસ્યા આગળ મોકલી!';

  @override
  String get isEscalatedToastBody => 'ઑફિસ અને સ્રોતના IEC ને જાણ કરાઈ છે.';

  @override
  String get tpStatusExpected => 'અપેક્ષિત';

  @override
  String get tpExpectedInfo =>
      'ટ્રિપ્સ આગલા દિવસે બને છે. તે દિવસના રૂટ્સ અને બાકી પિકઅપ મળીને આટલું થાય છે; ટીમ હજુ બદલી શકે છે.';

  @override
  String tpExtra(int count) {
    return 'વધારાના $count';
  }

  @override
  String tpTodaySuffix(String date) {
    return '$date · આજે';
  }

  @override
  String tpWarehouseClosed(String date) {
    return '$date · વેરહાઉસ બંધ';
  }

  @override
  String get tpNoTripsHoliday => 'કોઈ ટ્રિપ નથી · વેરહાઉસ રજા';

  @override
  String get rdTripDetails => 'ટ્રિપ વિગતો';

  @override
  String get rdThisTrip => 'આ ટ્રિપ';

  @override
  String rdStarted(String time) {
    return '$time એ શરૂ થઈ (ટ્રિપ શરૂ)';
  }

  @override
  String get rdLabourNone => 'કોઈ નહીં';

  @override
  String get rdAtWarehouse => 'વેરહાઉસ પર';

  @override
  String get rdWeighbridge => 'વજનકાંટા નેટ :';

  @override
  String get rdDriversTotal => 'ડ્રાઇવરનું કુલ :';

  @override
  String get rdBagsReceived => 'મળેલી થેલીઓ :';

  @override
  String get rdApprovedBy => 'મંજૂર કરનાર :';

  @override
  String rdDriversTotalValue(String kg, String diff, String pct) {
    return '$kg kg · તફાવત $diff kg ($pct%)';
  }

  @override
  String rdApprovedByValue(String name, String time) {
    return '$name · $time';
  }

  @override
  String rdTagGate(String time) {
    return 'ગેટ પર દાખલ · $time';
  }

  @override
  String get rdStatusMissed => 'ચૂકી ગયા';

  @override
  String get rdNoteNotRecorded => 'ડ્રાઇવરે નોંધ્યું નથી';

  @override
  String get rdNoteNoMaterialDriver => 'ડ્રાઇવર મુજબ કોઈ માલ નથી';

  @override
  String get rdNoteAskedToSkip => 'આજે છોડવા કહ્યું';

  @override
  String rdNextVisits(String dates) {
    return 'આગળ: $dates';
  }

  @override
  String rdEveryDayVisits(String count) {
    return 'દરરોજ · $count મુલાકાત';
  }

  @override
  String get rdStatusApprovedTrip => 'મંજૂર';

  @override
  String raOnRouteTitle(String route) {
    return '$route · રૂટ પર';
  }

  @override
  String get raOnRouteBody =>
      'ટ્રિપ શરૂ થઈ ગઈ છે, તેથી તેની ટીમ અને સ્ટોપ બદલી શકાશે નહીં.';

  @override
  String get raCompleteTrip => 'ડ્રાઇવર માટે ટ્રિપ પૂર્ણ કરો';

  @override
  String get raCompleteTripBody => 'ડ્રાઇવર એપમાં તે પૂર્ણ કરી શકતા નથી';

  @override
  String get raAskHeadBody => 'બીજું વાહન કે વધુ મજૂર જોઈએ';

  @override
  String raPlannedTitle(String route) {
    return '$route · આયોજિત';
  }

  @override
  String get raPlannedBody => 'ટ્રિપ શરૂ થઈ નથી, તેથી તમે હજુ તે બદલી શકો છો.';

  @override
  String get raChangeTeam => 'ડ્રાઇવર કે મજૂર બદલો';

  @override
  String get raChangeTeamBody => 'આ ટ્રિપ માટે બીજા ડ્રાઇવર કે મજૂર પસંદ કરો';

  @override
  String get raMoveStops => 'સ્ટોપ બીજી ટ્રિપમાં ખસેડો';

  @override
  String get raMoveStopsBody => 'કેટલાક પિકઅપ બીજી ટ્રિપમાં મોકલો';

  @override
  String get raSwitchOff => 'આ ટ્રિપ બંધ કરો';

  @override
  String get raSwitchOffBody => 'તે દિવસે ટ્રિપ નહીં; તેના પિકઅપ છોડાશે';

  @override
  String get sdTitle => 'સ્ટોપ વિગત';

  @override
  String get sdRoute => 'રૂટ';

  @override
  String get sdDue => 'બાકી';

  @override
  String get sdOnTrip => 'ટ્રિપ પર';

  @override
  String sdStopOf(String number, String total) {
    return '$total માંથી સ્ટોપ $number';
  }

  @override
  String sdStopOfDistance(String number, String total, String km) {
    return '$total માંથી સ્ટોપ $number · છેલ્લા સ્ટોપથી $km km';
  }

  @override
  String sdDueToday(String time) {
    return 'આજે · $time';
  }

  @override
  String sdDueOn(String date, String time) {
    return '$date · $time';
  }

  @override
  String get sdCallPerson => 'પિકઅપ પોઇન્ટ પરની વ્યક્તિને કૉલ કરો';

  @override
  String get sdTripStartedNote =>
      'ટ્રિપ શરૂ થઈ ગઈ છે. આ સ્ટોપ પર શું થાય છે તે ડ્રાઇવર નોંધે છે.';

  @override
  String get sdSkipThisPickup => 'આ પિકઅપ છોડો';

  @override
  String sdRouteVehicle(String route, String plate, String vehicle) {
    return '$route · $plate · $vehicle';
  }

  @override
  String sdRoutePlanned(String route, String date, String plate) {
    return '$route · $date · $plate';
  }

  @override
  String get sdOwnVehicleLower => 'પોતાનું વાહન';

  @override
  String get sdContractVehicleLower => 'કોન્ટ્રાક્ટ વાહન';

  @override
  String get sdRoleOwner => 'માલિક';

  @override
  String get skReasonSourceAsked => 'સ્રોતે કહ્યું';

  @override
  String get skReasonCapacity => 'વેરહાઉસમાં જગ્યા ભરાઈ ગઈ';

  @override
  String get skReasonShift => 'શિફ્ટમાં પૂરતો સમય નથી';

  @override
  String get skPickupSkippedTitle => 'પિકઅપ છોડ્યું!';

  @override
  String skPickupSkippedBody(String name, String date, String next) {
    return '$name $date ની ટ્રિપમાંથી બહાર છે. આગલી મુલાકાત: $next.';
  }

  @override
  String get rdDateTomorrow => 'શુક્ર, 23 ઑક્ટો 2026';

  @override
  String get rdFreqMonthly => 'માસિક';

  @override
  String rdSchedFirstOfMonth(String time) {
    return 'મહિનાની 1લી · $time';
  }

  @override
  String get sdRoleStoreManager => 'સ્ટોર મેનેજર';

  @override
  String get sdRoleOffice => 'ઑફિસ';

  @override
  String sdRouteVehicleTransport(
    String route,
    String plate,
    String vehicle,
    String transport,
  ) {
    return '$route · $plate · $vehicle ($transport)';
  }

  @override
  String sxCollectedTitle(String amount) {
    return 'એકત્રિત · $amount';
  }

  @override
  String get sxCollectedAt => 'એકત્રિત સમય';

  @override
  String get sxVisitedAt => 'મુલાકાત સમય';

  @override
  String sxAtDate(String time, String date) {
    return '$time · $date';
  }

  @override
  String sxFromSlip(String time, String date) {
    return '$time · $date (ડ્રાઇવરની સ્લિપ પરથી)';
  }

  @override
  String get sxDataEntry => 'ડેટા એન્ટ્રી';

  @override
  String sxByDriverApp(String name, String time) {
    return '$name (ડ્રાઇવર) દ્વારા, એપમાં · $time';
  }

  @override
  String sxByGate(String name, String time) {
    return '$name (બેક ઑફિસ) દ્વારા, ગેટ પર · $time';
  }

  @override
  String get sxEnteredApp => 'એપમાં દાખલ';

  @override
  String get sxEnteredGate => 'ગેટ પર દાખલ';

  @override
  String get sxGps => 'GPS સ્થાન';

  @override
  String sxGpsValue(String coords, String meters) {
    return '$coords · પિકઅપ પોઇન્ટથી $meters m';
  }

  @override
  String get sxGpsNotRecorded => 'નોંધાયું નથી (ગેટ પર દાખલ, સ્રોત પર નહીં)';

  @override
  String get sxLocationMatched => 'સ્થાન મેળ ખાય છે';

  @override
  String get sxViewOnMap => 'નકશા પર જુઓ';

  @override
  String get sxNoteFromDriver => 'ડ્રાઇવરની નોંધ';

  @override
  String sxQuoted(String text) {
    return '“$text”';
  }

  @override
  String get sxCollectedItems => 'એકત્રિત વસ્તુઓ';

  @override
  String get sxCollected => 'એકત્રિત';

  @override
  String get sxKg => 'KG';

  @override
  String get sxPcs => 'નંગ';

  @override
  String get sxKgBlock => 'KG બ્લોક';

  @override
  String get sxPcsBlock => 'નંગ બ્લોક';

  @override
  String get sxTotalCollected => 'કુલ એકત્રિત';

  @override
  String sxTotalKg(String amount) {
    return '$amount KG.';
  }

  @override
  String sxTotalPcs(String amount) {
    return '$amount નંગ';
  }

  @override
  String get sxZeroTitle => '0 kg · આજે કોઈ માલ નથી';

  @override
  String get sxPhotoFromDriver => 'ડ્રાઇવરનો ફોટો';

  @override
  String get sxAddExtra => 'વધારાનું પિકઅપ ઉમેરો';

  @override
  String get sxAddExtraTomorrow => 'આવતીકાલે વધારાનું પિકઅપ ઉમેરો';

  @override
  String get sxCallDriver => 'ડ્રાઇવરને કૉલ કરો';

  @override
  String get sxMissedTitle => 'ચૂકી ગયા · નોંધાયું નથી';

  @override
  String get sxWhatHappened => 'શું થયું';

  @override
  String sxMissedBody(String warehouse, String time) {
    return 'ટ્રિપ $time એ $warehouse પહોંચી અને ગેટે બાકીના બધા સ્ટોપ દાખલ કર્યા, પણ આ નહીં.';
  }

  @override
  String get sxVehicleDriver => 'વાહન અને ડ્રાઇવર';

  @override
  String sxVehicleDriverValue(
    String plate,
    String driver,
    String transport,
    String phone,
  ) {
    return '$plate · $driver ($transport) · $phone';
  }

  @override
  String get sxReason => 'કારણ';

  @override
  String get sxCalledOffBy => 'રદ કરનાર';

  @override
  String sxCalledOffValue(String source, String iec, String when) {
    return '$source (સ્રોત), $iec (IEC) મારફતે · $when';
  }

  @override
  String get sxNextPickup => 'આગલું પિકઅપ';

  @override
  String sxPausedTitle(String range) {
    return 'થોભાવ્યું $range';
  }

  @override
  String get sxReasonRenovation => 'રિનોવેશન';

  @override
  String get sxAskedBy => 'વિનંતી કરનાર';

  @override
  String sxAskedByValue(String date, String iec) {
    return 'સ્રોત, $date એ · $iec (IEC) એ મંજૂર કર્યું';
  }

  @override
  String get sxWhatHappens => 'શું થશે';

  @override
  String sxPausedBody(String date) {
    return 'વિરામ પૂરો થાય ત્યાં સુધી કોઈ ટ્રિપ પર નહીં. આગલું પિકઅપ $date છે.';
  }

  @override
  String get sxAskRestart => 'પિકઅપ ફરી શરૂ કરવા કહો';

  @override
  String exIntro(String name, String address) {
    return '$name · $address. તે દિવસની ટ્રિપમાં જોડાશે, અથવા ફાળવ્યા વગરનામાં રાહ જોશે.';
  }

  @override
  String get exDateLabel => 'પિકઅપ તારીખ અને સમય';

  @override
  String get exAmountLabel => 'આશરે કેટલું? (kg)';

  @override
  String get exSubmit => 'વધારાનું પિકઅપ ઉમેરો';

  @override
  String get exAddedTitle => 'વધારાનું પિકઅપ ઉમેરાયું';

  @override
  String exAddedBody(String name, String date, String time, String route) {
    return '$name $date, $time એ. તે આવતીકાલની $route ટ્રિપમાં જોડાશે, અને ડ્રાઇવર તેને ત્યાં જોશે.';
  }

  @override
  String get exBackToStop => 'સ્ટોપ પર પાછા જાઓ';

  @override
  String taSheetTitle(String route, String date) {
    return '$route · $date';
  }

  @override
  String get taSheetBody =>
      'અહીંના ફેરફાર ફક્ત આ ટ્રિપ માટે છે. રૂટ જેમ છે તેમ રહે છે.';

  @override
  String get taChangeTeamBody => 'આજે કોઈ ગેરહાજર છે';

  @override
  String get taMoveStops => 'સ્ટોપ બીજા વાહનમાં ખસેડો';

  @override
  String get taMoveStopsBody => 'બ્રેકડાઉન, અથવા વાહન ઉપલબ્ધ નથી';

  @override
  String get taCancelTrip => 'આ ટ્રિપ રદ કરો';

  @override
  String taCancelTripBody(String date) {
    return '$date એ ટ્રિપ નહીં. રૂટ ચાલુ રહે છે.';
  }

  @override
  String get taSwitchOffRoute => 'રૂટ બંધ કરો';

  @override
  String get taSwitchOffRouteBody => 'તમે ચાલુ ન કરો ત્યાં સુધી કોઈ ટ્રિપ નહીં';

  @override
  String get ctTitle => 'આ ટ્રિપ માટે બદલો';

  @override
  String get ctInfo =>
      'ફક્ત આ ટ્રિપ બદલાય છે. રૂટની પોતાની ટીમ રહે છે. ટીમ કાયમ માટે બદલવા રૂટ એડિટ કરો.';

  @override
  String get ctOnRoute => 'રૂટ પર';

  @override
  String get ctDriver => 'ડ્રાઇવર';

  @override
  String get ctLabour => 'મજૂર';

  @override
  String get ctAbsent => 'ગેરહાજર';

  @override
  String ctPerson(String name, String tail) {
    return '$name (••• $tail)';
  }

  @override
  String ctPersonNote(String person, String note) {
    return '$person · $note';
  }

  @override
  String get ctDriverForTrip => 'આ ટ્રિપ માટે ડ્રાઇવર';

  @override
  String get ctLabourForTrip => 'આ ટ્રિપ માટે મજૂર';

  @override
  String ctReplaces(String name) {
    return '$name (ગેરહાજર) ની જગ્યાએ';
  }

  @override
  String get ctNoChange => 'કોઈ ફેરફાર નહીં';

  @override
  String get ctFreeToday => 'આજે ફ્રી';

  @override
  String get ctReason => 'કારણ';

  @override
  String get ctOther => 'અન્ય';

  @override
  String get ctSave => 'આ ટ્રિપ માટે સેવ કરો';

  @override
  String ctFreeOn(String date, String time) {
    return '$date, $time એ ફ્રી';
  }

  @override
  String get ctBusyAtTime => 'આ સમયે વ્યસ્ત';

  @override
  String ctFreeUntil(String route, String time) {
    return '$route, $time: ત્યાં સુધી ફ્રી';
  }

  @override
  String ctBusy(String route, String time) {
    return 'વ્યસ્ત: $route, $time';
  }

  @override
  String get ctBusyDriverNote =>
      'તમે હજી પણ વ્યસ્ત ડ્રાઇવર પસંદ કરી શકો છો. ઍપ તમને ટકરાવ વિશે ચેતવે છે.';

  @override
  String get ctBusyLabourNote =>
      'તમે હજી પણ વ્યસ્ત મજૂર પસંદ કરી શકો છો. ઍપ તમને ટકરાવ વિશે ચેતવે છે.';

  @override
  String get ctSavedTitle => 'આ ટ્રિપ માટે સેવ થયું!';

  @override
  String ctSavedBody(String name, String date) {
    return '$name $date એ ડ્રાઇવ કરે છે. બંને ડ્રાઇવરને જાણ કરાઈ છે.';
  }

  @override
  String rdChangedOnlyTrip(String driver, String absent) {
    return 'ડ્રાઇવર: $absent (ગેરહાજર) ની જગ્યાએ $driver. ફક્ત આ ટ્રિપ.';
  }

  @override
  String rdChangedTomorrow(String driver, String absent) {
    return 'ડ્રાઇવર: $absent (ગેરહાજર) ની જગ્યાએ $driver. આવતીકાલે રૂટની પોતાની ટીમ પાછી આવે છે.';
  }

  @override
  String rdForPerson(String name) {
    return '$name ની જગ્યાએ';
  }

  @override
  String rdTodayForPerson(String name) {
    return 'આજે, $name ની જગ્યાએ';
  }

  @override
  String get rdStatusCancelled => 'રદ';

  @override
  String get rdStatusSwitchedOff => 'બંધ';

  @override
  String rdShiftEvening(String time) {
    return 'સાંજ ($time)';
  }

  @override
  String get msTitle => 'સ્ટોપ ખસેડો';

  @override
  String get msWhy => 'શા માટે?';

  @override
  String get msBreakdown => 'બ્રેકડાઉન';

  @override
  String get msVehicleNa => 'વાહન ઉપલબ્ધ નથી';

  @override
  String get msDriverAbsent => 'ડ્રાઇવર ગેરહાજર';

  @override
  String get msMoveTo => 'ક્યાં ખસેડવું';

  @override
  String msTripLine(String plate, String driver, String time) {
    return '$plate · $driver · $time';
  }

  @override
  String get msContract => 'કોન્ટ્રાક્ટ';

  @override
  String msStopsToMove(int count) {
    return 'ખસેડવાના સ્ટોપ ($count પસંદ)';
  }

  @override
  String msStopLine(String name, String frequency, String time) {
    return '$name · $frequency · $time';
  }

  @override
  String get msHint =>
      'સ્ટોપ પસંદ કરેલી ટ્રિપના અંતે જોડાય છે. બધા સ્ટોપ ખસેડવાથી આ ટ્રિપ રદ થાય છે.';

  @override
  String msMove(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સ્ટોપ ખસેડો',
      one: '1 સ્ટોપ ખસેડો',
    );
    return '$_temp0';
  }

  @override
  String msMovedTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count સ્ટોપ ખસેડાયા',
      one: '1 સ્ટોપ ખસેડાયો',
    );
    return '$_temp0';
  }

  @override
  String msMovedBody(String names, String trip, String date) {
    return '$names હવે $trip ($date) ના અંતે છે. બંને ડ્રાઇવરને જાણ કરાઈ છે.';
  }

  @override
  String msAnd(String first, String last) {
    return '$first અને $last';
  }

  @override
  String msOpenTrip(String trip) {
    return '$trip ની ટ્રિપ ખોલો';
  }

  @override
  String get msBackToTrip => 'ટ્રિપ પર પાછા';

  @override
  String get ahSubtitle => 'તેઓ મંજૂર ન કરે ત્યાં સુધી કંઈ બદલાતું નથી';

  @override
  String get ahWhat => 'તમને શું જોઈએ છે?';

  @override
  String get ahForTrip => 'ટ્રિપ માટે';

  @override
  String get ahVehicle => 'વાહન';

  @override
  String get ahLabour => 'મજૂર';

  @override
  String get ahForPoint => 'પિકઅપ પોઇન્ટ માટે';

  @override
  String get ahChangeDetails => 'વિગતો બદલો';

  @override
  String get ahStartPickups => 'પિકઅપ શરૂ કરો';

  @override
  String get ahStopPickups => 'પિકઅપ બંધ કરો';

  @override
  String get ahPausePickups => 'પિકઅપ થોભાવો';

  @override
  String get ahFor => 'કોના માટે';

  @override
  String get ahDates => 'તારીખો';

  @override
  String get ahDetails => 'વિગતો અને કારણ';

  @override
  String ahRouteLine(String route, String plate) {
    return '$route · $plate';
  }

  @override
  String get ahInfo =>
      'અરવિંદ દેસાઈ (કલેક્શન હેડ) ને જાય છે. તેઓ વેબ પેનલમાં જવાબ આપે છે; તમે જવાબ મારી વિનંતીઓમાં જુઓ છો.';

  @override
  String get ahSend => 'વિનંતી મોકલો';

  @override
  String get ahWhich => 'કઈ ટ્રિપ કે રૂટ?';

  @override
  String get ahWhichPoint => 'કયો પિકઅપ પોઇન્ટ?';

  @override
  String get ahYourRoutes => 'તમારા રૂટ';

  @override
  String get ahYourPoints => 'તમારા પિકઅપ પોઇન્ટ';

  @override
  String ahRouteOption(String plate, String vehicle, String time) {
    return '$plate · $vehicle · $time';
  }

  @override
  String get ahSheetNote =>
      'પિકઅપ પોઇન્ટની વિનંતી માટે, આ યાદી તમારા પિકઅપ પોઇન્ટ બતાવે છે.';

  @override
  String get ahSheetNotePoint =>
      'ટ્રિપની વિનંતી માટે, આ યાદી તમારા રૂટ બતાવે છે.';

  @override
  String get ahSentTitle => 'વિનંતી મોકલાઈ';

  @override
  String get ahSentBody =>
      'અરવિંદ દેસાઈ (કલેક્શન હેડ) વેબ પેનલમાં જવાબ આપે છે. તમે જવાબ મારી વિનંતીઓમાં જુઓ છો.';

  @override
  String get ahSeeRequests => 'મારી વિનંતીઓ જુઓ';

  @override
  String get ahBackHome => 'હોમ પર પાછા';

  @override
  String ahDayRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get cxTitle => 'આ ટ્રિપ રદ કરવી છે?';

  @override
  String cxBody(String route, String date, int count) {
    return '$route $date એ નહીં ચાલે. તેના $count સ્ટોપ તે દિવસ માટે અનઅસાઇન્ડમાં જાય છે.';
  }

  @override
  String get cxKeep => 'ટ્રિપ રાખો';

  @override
  String get cxConfirm => 'ટ્રિપ રદ કરો';

  @override
  String get cxDoneTitle => 'ટ્રિપ રદ થઈ!';

  @override
  String cxDoneBody(String route, String date, String driver) {
    return '$route $date એ નહીં ચાલે. $driver ને જાણ કરાઈ છે.';
  }

  @override
  String cxNote(String reason, int count, String date) {
    return 'આ ટ્રિપ રદ છે ($reason). તેના $count સ્ટોપ $date માટે અનઅસાઇન્ડમાં છે.';
  }

  @override
  String get soTitle => 'રૂટ બંધ કરવો છે?';

  @override
  String soBody(String route, int count) {
    return 'તમે ચાલુ ન કરો ત્યાં સુધી $route કોઈ ટ્રિપ નહીં બનાવે. તેના $count પિકઅપ પોઇન્ટ અનઅસાઇન્ડમાં જાય છે.';
  }

  @override
  String get soConfirm => 'બંધ કરો';

  @override
  String get soDoneTitle => 'રૂટ બંધ થયો!';

  @override
  String soDoneBody(String route) {
    return 'તમે ચાલુ ન કરો ત્યાં સુધી $route કોઈ ટ્રિપ નહીં બનાવે.';
  }

  @override
  String soEmpty(int count) {
    return 'બંધ છે. કોઈ ટ્રિપ બનતી નથી; તમે ચાલુ ન કરો ત્યાં સુધી તેના $count પિકઅપ પોઇન્ટ અનઅસાઇન્ડમાં દેખાય છે.';
  }

  @override
  String get soNoTrips => 'કોઈ ટ્રિપ નહીં';

  @override
  String get soSwitchOn => 'આ રૂટ ચાલુ કરો';

  @override
  String get onTitle => 'રૂટ ચાલુ કરવો છે?';

  @override
  String onBody(String route) {
    return '$route તેના પિકઅપમાંથી ફરી ટ્રિપ બનાવે છે. પહેલા ટીમ તપાસાય છે.';
  }

  @override
  String get onConfirm => 'ચાલુ કરો';

  @override
  String get onDoneTitle => 'રૂટ ચાલુ થયો!';

  @override
  String onDoneBody(String route) {
    return '$route આજથી ફરી ટ્રિપ બનાવે છે.';
  }

  @override
  String get routesSwitchedOff => 'બંધ';

  @override
  String get routesNoTripsUntilOn => 'ચાલુ ન થાય ત્યાં સુધી કોઈ ટ્રિપ નહીં';

  @override
  String get rdFreqOnCall => 'કૉલ પર';

  @override
  String rdSchedCalledIn(String time) {
    return 'બોલાવ્યું · આજે $time';
  }

  @override
  String rdNotUsingAppBody(String driver, String time) {
    return '$driver એ ઍપમાં ટ્રિપ શરૂ કરી નથી. શિફ્ટ $time એ શરૂ થઈ.';
  }

  @override
  String rdMoreStopsPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'અને $count વધુ સ્ટોપ, બધા હજી બાકી',
      one: 'અને 1 વધુ સ્ટોપ, હજી બાકી',
    );
    return '$_temp0';
  }

  @override
  String rdSchedEveryDayExceptSun(String time) {
    return 'રવિ સિવાય દરરોજ · $time';
  }

  @override
  String get dlNoInactiveDrivers => 'કોઈ નિષ્ક્રિય ડ્રાઇવર નથી';

  @override
  String get dlNoInactiveLabour => 'કોઈ નિષ્ક્રિય મજૂર નથી';

  @override
  String get dlIdNumberLabel => 'ID નંબર (આધાર અથવા મતદાર ID)';

  @override
  String get dlIdNumberHint => 'દા.ત. 1234 5678 9012';

  @override
  String get dlProfilePhotoLabel => 'પ્રોફાઇલ ફોટો';

  @override
  String get dlIdProofPhoto => 'ID પ્રૂફ ફોટો';

  @override
  String get dlBothOptional => 'બંને વૈકલ્પિક.';

  @override
  String get dlSave => 'સેવ કરો';

  @override
  String get dlFullNameLower => 'પૂરું નામ';

  @override
  String get dlMobileLower => 'મોબાઇલ નંબર';

  @override
  String get dlIdNumber => 'ID નંબર';

  @override
  String get dlAddedOn => 'ઉમેર્યાની તારીખ';

  @override
  String get dlReactivate => 'ફરી સક્રિય કરો';

  @override
  String get dlDeactivateDriverTitle => 'ડ્રાઇવરને નિષ્ક્રિય કરવો છે?';

  @override
  String get dlDeactivateLabourTitle => 'મજૂરને નિષ્ક્રિય કરવો છે?';

  @override
  String dlDeactivateBody(String name, String warehouse) {
    return '$name ને $warehouse માંથી દૂર કરાય છે અને તેના રૂટ પર મૂકી શકાશે નહીં. તમે પછીથી ફરી સક્રિય કરી શકો છો.';
  }

  @override
  String get dlReactivateDriverTitle => 'ડ્રાઇવરને ફરી સક્રિય કરવો છે?';

  @override
  String get dlReactivateLabourTitle => 'મજૂરને ફરી સક્રિય કરવો છે?';

  @override
  String dlReactivateBody(String name, String warehouse) {
    return '$name $warehouse પર પાછા છે અને ફરી તેના રૂટ પર મૂકી શકાય છે.';
  }

  @override
  String get dlInUseTitle => 'હજી નિષ્ક્રિય કરી શકાતું નથી';

  @override
  String dlInUseDriverBody(String name, String route) {
    return '$name $route ચલાવે છે. પહેલા રૂટનો ડ્રાઇવર બદલો, પછી નિષ્ક્રિય કરો.';
  }

  @override
  String dlInUseLabourBody(String name, String route) {
    return '$name $route પર કામ કરે છે. પહેલા રૂટનો મજૂર બદલો, પછી નિષ્ક્રિય કરો.';
  }

  @override
  String get dlOk => 'ઓકે';

  @override
  String get dlDriverDeactivated => 'ડ્રાઇવર નિષ્ક્રિય થયો!';

  @override
  String get dlLabourDeactivated => 'મજૂર નિષ્ક્રિય થયો!';

  @override
  String get dlDriverReactivated => 'ડ્રાઇવર ફરી સક્રિય થયો!';

  @override
  String get dlLabourReactivated => 'મજૂર ફરી સક્રિય થયો!';

  @override
  String dlOffWarehouse(String name, String warehouse) {
    return '$name હવે $warehouse પર નથી.';
  }

  @override
  String dlBackAtWarehouse(String name, String warehouse) {
    return '$name $warehouse પર પાછા છે.';
  }

  @override
  String fgTimeClashLine(String arrive, String ends) {
    return 'સમય ટકરાવ · લગભગ $arrive એ પહોંચે છે, સમય $ends એ પૂરો થાય છે';
  }

  @override
  String fgOffRouteLine(String km, String route) {
    return 'રૂટથી દૂર · $route થી $km km';
  }

  @override
  String fgScheduleLine(String schedule) {
    return 'શેડ્યૂલ બદલાયું · હવે $schedule';
  }

  @override
  String fgPausedLine(String dates, String reason) {
    return 'સોર્સ થોભાવ્યો · $dates, $reason';
  }

  @override
  String get fgNewSourceLine => 'નવો સોર્સ, હજી રૂટ નથી';

  @override
  String fgExtraLine(String date) {
    return 'વધારાનો પિકઅપ, રૂટ નથી · $date';
  }

  @override
  String fgMovedLine(String area) {
    return 'સોર્સ તમને સોંપાયો · $area';
  }

  @override
  String get fgTimeClash => 'સમય ટકરાવ';

  @override
  String get fgOffRoute => 'રૂટથી દૂર';

  @override
  String get fgScheduleChanged => 'શેડ્યૂલ બદલાયું';

  @override
  String get fgSourcePaused => 'સોર્સ થોભાવ્યો';

  @override
  String get fgNewSource => 'નવો સોર્સ, રૂટ નથી';

  @override
  String get fgExtraPickup => 'વધારાનો પિકઅપ, રૂટ નથી';

  @override
  String get fgSourceMoved => 'સોર્સ તમને સોંપાયો';

  @override
  String get fgRoute => 'રૂટ';

  @override
  String get fgPickupWindow => 'પિકઅપ સમય';

  @override
  String get fgTripGetsThere => 'ટ્રિપ ત્યાં પહોંચે છે';

  @override
  String get fgDistance => 'અંતર';

  @override
  String get fgExtraTime => 'વધારાનો સમય';

  @override
  String get fgWas => 'પહેલાં';

  @override
  String get fgNow => 'હવે';

  @override
  String get fgFrom => 'થી';

  @override
  String get fgPaused => 'થોભાવ્યું';

  @override
  String get fgReason => 'કારણ';

  @override
  String get fgSchedule => 'શેડ્યૂલ';

  @override
  String get fgExtraPickupLabel => 'વધારાનો પિકઅપ';

  @override
  String get fgWhy => 'શા માટે';

  @override
  String get fgWhatToDo => 'શું કરવું';

  @override
  String fgRouteVehicle(String route, String plate) {
    return '$route · $plate';
  }

  @override
  String fgArrivalLate(String time, String minutes) {
    return 'લગભગ $time, સમય પછી $minutes મિનિટ';
  }

  @override
  String fgKmOffRoute(String km) {
    return 'રૂટથી $km km દૂર';
  }

  @override
  String fgMinutesMore(String minutes) {
    return 'દરેક ટ્રિપ પર લગભગ $minutes મિનિટ વધુ';
  }

  @override
  String get fgReasonRenovation => 'રિનોવેશન';

  @override
  String get fgReasonRenovationLower => 'રિનોવેશન';

  @override
  String get fgNoneYet => 'હજી નથી';

  @override
  String fgExtraValue(String date, String time, String kg) {
    return '$date · $time · લગભગ $kg kg';
  }

  @override
  String fgAreaNowYours(String area) {
    return '$area વિસ્તાર હવે તમારો છે';
  }

  @override
  String get fgDoTimeClash =>
      'તેને સ્ટોપ ક્રમમાં આગળ લાવો, અથવા વહેલી પહોંચતી ટ્રિપ પર મૂકો.';

  @override
  String get fgDoOffRoute =>
      'વધારાનો સમય ઠીક હોય તો રાખો, અથવા નજીકથી પસાર થતા રૂટ પર ખસેડો.';

  @override
  String fgDoSchedule(String route) {
    return 'ખાતરી કરો કે $route નવા દિવસો અને નવા સમયે હજી ત્યાં પહોંચે છે.';
  }

  @override
  String fgDoPaused(String date) {
    return 'કંઈ બદલવાનું નથી. વિરામ પૂરો ન થાય ત્યાં સુધી તે દરેક ટ્રિપમાંથી બહાર રહે છે. આગલો પિકઅપ $date છે.';
  }

  @override
  String get fgDoNewSource => 'તેને રૂટમાં ઉમેરો જેથી તેના પિકઅપ ટ્રિપ પર આવે.';

  @override
  String get fgDoExtra =>
      'પિકઅપ પોઇન્ટને રૂટમાં ઉમેરો જેથી શનિવારનો પિકઅપ ટ્રિપ પર આવે.';

  @override
  String get fgDoMoved =>
      'હવેથી તેના પિકઅપ તમારા છે. તેને તમારા કોઈ રૂટમાં ઉમેરો.';

  @override
  String get fgClosesByItself => 'રૂટ પર આવતા જ આ ફ્લેગ આપમેળે બંધ થાય છે.';

  @override
  String get fgOpenRoutes => 'તમારા રૂટ ખોલો';

  @override
  String get fgCheckRoute => 'રૂટ તપાસો';

  @override
  String get fgAddToRoute => 'રૂટમાં ઉમેરો';

  @override
  String get fgDoneTitle => 'ફ્લેગ પૂર્ણ થયો';

  @override
  String fgDoneBody(String name) {
    return '$name તમારી યાદીમાંથી દૂર થયો';
  }

  @override
  String fgSecondWed(String time) {
    return 'મહિનાનો 2જો બુધ · $time';
  }

  @override
  String get cpTitle => 'રોકડ અને ચુકવણી';

  @override
  String get cpCashInHand => 'હાથમાં રોકડ';

  @override
  String get cpPaidThisWeek => 'આ અઠવાડિયે ચૂકવ્યું';

  @override
  String get cpRequestCash => 'રોકડ માંગો';

  @override
  String get cpPointsToPay => 'ચૂકવવાના પિકઅપ પોઇન્ટ';

  @override
  String cpPointsOwed(int count, String amount) {
    return '$count ને કુલ $amount બાકી છે. તમારી હાથમાંની રોકડમાંથી ચૂકવો.';
  }

  @override
  String get cpSeeWhoToPay => 'કોને ચૂકવવું તે જુઓ';

  @override
  String get cpRecentActivity => 'તાજેતરની પ્રવૃત્તિ';

  @override
  String get cpPaymentsTab => 'ચુકવણી';

  @override
  String get cpCashRequestsTab => 'રોકડ વિનંતીઓ';

  @override
  String get cpToday => 'આજે';

  @override
  String cpWhen(String day, String time) {
    return '$day • $time';
  }

  @override
  String get cpWaiting => 'ઓફિસની રાહ';

  @override
  String get cpAdded => 'તમારી રોકડમાં ઉમેરાયું';

  @override
  String get cpRejected => 'ઓફિસે નકાર્યું';

  @override
  String cpAskedSent(String asked, String sent) {
    return 'તમે $asked માંગ્યા. ઓફિસે $sent મોકલ્યા.';
  }

  @override
  String cpOfficeSaid(String text) {
    return 'ઓફિસ: “$text”';
  }

  @override
  String get cpTagCash => 'રોકડ';

  @override
  String cpTagUpiRef(String ref) {
    return 'UPI · રેફ $ref';
  }

  @override
  String get cpTagBank => 'બેંક ટ્રાન્સફર';

  @override
  String get cpAmountLabel => 'રકમ (₹)';

  @override
  String get cpReason => 'કારણ';

  @override
  String cpMaxChars(int count) {
    return 'વધુમાં વધુ $count અક્ષર';
  }

  @override
  String get cpRequestInfo =>
      'ઓફિસ મંજૂર કરે પછી તમારી હાથમાંની રોકડમાં ઉમેરાય છે.';

  @override
  String get cpSendRequest => 'વિનંતી મોકલો';

  @override
  String get cpRequestSent => 'વિનંતી મોકલાઈ';

  @override
  String cpRequestSentBody(String amount) {
    return '$amount માટેની તમારી વિનંતી ઓફિસ પાસે છે. જવાબ રોકડ અને ચુકવણીમાં દેખાશે.';
  }

  @override
  String get cpBackToCash => 'રોકડ અને ચુકવણી પર પાછા';

  @override
  String cpOwedHold(String owed, String hold) {
    return '$owed બાકી · તમારી પાસે $hold';
  }

  @override
  String get cpSearchHint => 'નામ અથવા વિસ્તારથી શોધો';

  @override
  String get cpFilterAll => 'બધા';

  @override
  String get cpFilterDueToday => 'આજે બાકી';

  @override
  String cpDueOn(String date) {
    return '$date સુધી';
  }

  @override
  String cpPointTitle(String name, String type) {
    return '$name · $type';
  }

  @override
  String cpPerKg(String amount) {
    return 'પ્રતિ કિલો $amount';
  }

  @override
  String cpFixed(String amount) {
    return 'નક્કી $amount';
  }

  @override
  String get cpPerItem => 'પ્રતિ નંગ';

  @override
  String cpWeeklyOn(String day) {
    return 'દર અઠવાડિયે $day';
  }

  @override
  String get cpMonthly30th => 'દર મહિને 30 તારીખે';

  @override
  String get cpMonthlyLastDay => 'દર મહિને, છેલ્લા દિવસે';

  @override
  String get cpMethodCash => 'રોકડ';

  @override
  String get cpMethodUpi => 'UPI';

  @override
  String get cpMethodBank => 'બેંક';

  @override
  String cpTermsLine(String rate, String schedule, String method) {
    return '$rate · $schedule · $method';
  }

  @override
  String cpOwed(String amount) {
    return 'બાકી $amount';
  }

  @override
  String cpOwedLastPaid(String amount, String date) {
    return 'બાકી $amount · છેલ્લે ચૂકવ્યું $date';
  }

  @override
  String cpPayTitle(String name) {
    return '$name ને ચૂકવો';
  }

  @override
  String get cpHowPaid => 'કેવી રીતે ચૂકવ્યું?';

  @override
  String get cpChipCash => 'રોકડ';

  @override
  String get cpChipUpi => 'UPI';

  @override
  String get cpChipBank => 'બેંક';

  @override
  String get cpReference => 'રેફરન્સ (UPI અથવા બેંક)';

  @override
  String get cpPaidOn => 'ચૂકવણીની તારીખ';

  @override
  String cpTodayDate(String date) {
    return 'આજે, $date';
  }

  @override
  String get cpReceiptPhoto => 'રસીદનો ફોટો';

  @override
  String get cpReceiptHint => 'વૈકલ્પિક. રસીદ અથવા UPI સ્ક્રીનનો ફોટો.';

  @override
  String get cpNote => 'નોંધ';

  @override
  String cpPayInfo(String owed, String hold) {
    return 'બાકી $owed · તમારી પાસે $hold. તમે બંનેમાંથી કોઈ કરતાં વધુ ચૂકવી શકતા નથી.';
  }

  @override
  String get cpRecordPayment => 'ચુકવણી નોંધો';

  @override
  String get cpPaymentRecorded => 'ચુકવણી નોંધાઈ';

  @override
  String cpPaymentRecordedBody(String amount, String name, String hold) {
    return '$name ને $amount. હવે તમારી પાસે $hold છે.';
  }

  @override
  String get cpBackToPoints => 'ચૂકવવાના પિકઅપ પોઇન્ટ પર પાછા';

  @override
  String get cpNothingToPay => 'હમણાં કોઈને બાકી નથી.';

  @override
  String cpDayName(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      '1': 'સોમવાર',
      '2': 'મંગળવાર',
      '3': 'બુધવાર',
      '4': 'ગુરુવાર',
      '5': 'શુક્રવાર',
      '6': 'શનિવાર',
      '7': 'રવિવાર',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get arHiredTruck => 'ભાડાની ટ્રક';

  @override
  String get arHiredTruckHint => 'તેનો નંબર, ટ્રાન્સપોર્ટર અને ડ્રાઇવર લખો';

  @override
  String get arHiredDetails => 'ભાડાની ટ્રકની વિગતો';

  @override
  String get arTruckNumber => 'ટ્રક નંબર';

  @override
  String get arTruckNumberHint => 'દા.ત. GJ-05-EE-1002';

  @override
  String get arTransporter => 'ટ્રાન્સપોર્ટર';

  @override
  String get arTransporterHint => 'ટ્રાન્સપોર્ટ કંપનીનું નામ';

  @override
  String get arDriverName => 'ડ્રાઇવરનું નામ';

  @override
  String get arDriverNameHint => 'ડ્રાઇવરનું નામ લખો';

  @override
  String get arDriverPhone => 'ડ્રાઇવરનો ફોન';

  @override
  String get arDriverPhoneHint => 'મોબાઇલ નંબર લખો';

  @override
  String get arCapacityKg => 'ક્ષમતા (KG)';

  @override
  String get arCapacityHint => 'દા.ત. 3000';

  @override
  String get arHiredNote =>
      'ભાડાની ટ્રકના ડ્રાઇવર પાસે ઍપ નથી: તેઓ સ્લિપ રાખે છે અને ગેટ ટીમ વેરહાઉસ પર સ્ટોપ દાખલ કરે છે.';

  @override
  String arCapacityValue(String kg) {
    return 'ક્ષમતા $kg KG';
  }

  @override
  String get vlRequired => 'આ ફીલ્ડ જરૂરી છે.';

  @override
  String get vlNumbersOnly => 'ફક્ત આંકડા લખો.';

  @override
  String get vlAmountPositive => '0 કરતાં વધુ રકમ લખો.';

  @override
  String get vlWeightPositive => '0 કરતાં વધુ વજન લખો.';

  @override
  String get vlCapacityPositive => '0 કરતાં વધુ ક્ષમતા લખો.';

  @override
  String vlMaxDecimals(int count) {
    return 'વધુમાં વધુ $count દશાંશ સ્થાન વાપરો.';
  }

  @override
  String vlMaxAmount(String amount) {
    return '$amount કરતાં વધુ ન હોઈ શકે.';
  }

  @override
  String get vlIdNumber => '12 અંકનો આધાર નંબર અથવા માન્ય મતદાર ID લખો.';

  @override
  String get vlVehicleNumber => 'માન્ય વાહન નંબર લખો, દા.ત. GJ-05-EE-1002.';

  @override
  String get dhDateAdajan => 'ગુરુ, 22 ઑક્ટો · અડાજણ';

  @override
  String get dhEverythingSynced => 'બધું સિંક થઈ ગયું છે';

  @override
  String get dhNotStarted => 'શરૂ નથી થઈ';

  @override
  String get dhStartTrip => 'ટ્રિપ શરૂ કરો';

  @override
  String get dhStartTripHint =>
      'વેરહાઉસ છોડો ત્યારે ટૅપ કરો. તમારા સુપરવાઇઝર સમય અને સ્થળ જુએ છે.';

  @override
  String dhMorningTripTime(int count) {
    return 'સવારે 8:00 – બપોરે 2:00 · $count સ્ટોપ';
  }

  @override
  String get dhVehicleCrew => 'GJ-05-BX-1234 · વિક્રમ, રવિ';

  @override
  String get dhDropAdajan => 'અડાજણ સેન્ટ્રલ વેરહાઉસ પર ઉતારો';

  @override
  String get dhZeroSoFar => 'અત્યાર સુધી 0 kg';

  @override
  String liveTripTitle(int index, String shift) {
    return 'ટ્રિપ $index · $shift';
  }

  @override
  String liveTripTime(String start, String end, int count) {
    return '$start – $end · $count સ્ટોપ';
  }

  @override
  String liveDropAt(String warehouse) {
    return '$warehouse પર ઉતારો';
  }

  @override
  String liveKgSoFar(String kg) {
    return 'અત્યાર સુધી $kg kg';
  }

  @override
  String liveKg(String kg) {
    return '$kg kg';
  }

  @override
  String get liveAnyTime => 'કોઈપણ સમયે';

  @override
  String liveHandedOverNet(String kg) {
    return 'સોંપ્યું · $kg kg નેટ';
  }

  @override
  String get liveHandedOver => 'સોંપ્યું';

  @override
  String get liveNoSupervisor => 'કોઈ સુપરવાઇઝર નથી';

  @override
  String liveDateAndPlace(String date, String place) {
    return '$date · $place';
  }

  @override
  String get liveNeedsConnection => 'કનેક્શન જરૂરી છે';

  @override
  String get liveSaved => 'સાચવ્યું. ઓનલાઇન થતાં મોકલાશે.';

  @override
  String liveCollectedOf(String name, int done, int total) {
    return '$name  •  $total માંથી $done એકત્રિત';
  }

  @override
  String get liveRentedTruck => 'ભાડાની ટ્રક';

  @override
  String liveNotSent(int count) {
    return '$count ફેરફાર હજી મોકલ્યા નથી';
  }

  @override
  String get liveAllSent => 'બધું મોકલાઈ ગયું છે';

  @override
  String get liveNoTripsToday => 'આજે કોઈ ટ્રિપ નથી';

  @override
  String liveTripsTodayCount(int count) {
    return 'આજે $count ટ્રિપ';
  }

  @override
  String livePickupPointsByCategory(int count, String areas) {
    return '$areas માં $count · પ્રકાર મુજબ';
  }

  @override
  String get liveAtGate => 'ગેટ પર';

  @override
  String get liveReasonHoliday => 'રજા';

  @override
  String get liveReasonShifted => 'બીજા દિવસે ખસેડ્યું';

  @override
  String get liveNotVisitedHint =>
      'જ્યાં વાહન પહોંચ્યું નથી તે સ્ટોપ પસંદ કરો. તે ફરી અસોંપિત થશે; બાકીના ગેટ ટીમ માટે રાહ જોશે.';

  @override
  String liveCollectedCount(int done, int total) {
    return '$total માંથી $done એકત્રિત';
  }

  @override
  String get liveNoTripToday => 'આજે કોઈ ટ્રિપ નથી';

  @override
  String get liveKindVehicle => 'વાહન';

  @override
  String get liveKindLabour => 'મજૂર';

  @override
  String get liveKindPointChange => 'પિકઅપ પોઇન્ટ ફેરફાર';

  @override
  String get liveKindStart => 'પિકઅપ શરૂ કરો';

  @override
  String get liveKindStop => 'પિકઅપ બંધ કરો';

  @override
  String get liveKindPause => 'પિકઅપ થોભાવો';

  @override
  String get liveKindSchedule => 'શેડ્યૂલ ફેરફાર';

  @override
  String get liveKindRoute => 'રૂટ અથવા વાહન';

  @override
  String get liveKindOther => 'અન્ય';

  @override
  String get liveKindCorrection => 'સુધારો';

  @override
  String liveKindFrom(String kind, String who) {
    return '$kind · $who તરફથી';
  }

  @override
  String liveKindFor(String kind, String target) {
    return '$kind · $target';
  }

  @override
  String liveAllCount(int count) {
    return 'બધા $count';
  }

  @override
  String liveWaitingCount(int count) {
    return 'રાહ $count';
  }

  @override
  String liveApprovedCount(int count) {
    return 'મંજૂર $count';
  }

  @override
  String liveDeclinedCount(int count) {
    return 'નકાર્યું $count';
  }

  @override
  String liveSentOn(String date) {
    return '$date મોકલ્યું';
  }

  @override
  String liveAnsweredBy(String name, String date) {
    return '$name · $date';
  }

  @override
  String liveSourcesTab(int count) {
    return 'સ્રોત ($count)';
  }

  @override
  String livePickupsTab(int count) {
    return 'પિકઅપ ($count)';
  }

  @override
  String liveSourceAdded(String source, String route) {
    return '$source હવે $route પર છે.';
  }

  @override
  String liveAssignedCount(int count) {
    return '$count પિકઅપ પોઇન્ટ';
  }
}
