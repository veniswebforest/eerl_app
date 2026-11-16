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
}
