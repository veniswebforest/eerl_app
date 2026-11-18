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
  String get collectedCount => '03';

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
  String get skippedStatus => 'છોડેલ';

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
}
