import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';

/// Mock data until routes are read from SQLite.
abstract final class RouteDetailMockData {
  static const todaySummary = RouteSummary(
    name: 'Adajan Morning',
    plate: 'GJ-05-BX-1234',
    shiftTime: '08:00 AM – 02:00 PM',
    assignedSources: 9,
    pausedSources: 1,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Vikram Singh',
    driverPhone: '12345 43210',
    labourName: 'Ravi Bisht',
    daily: 5,
    weekly: 3,
    startedAt: '8:05 am',
  );

  static const nextSevenDaysSummary = RouteSummary(
    name: 'Adajan Morning',
    plate: 'GJ-05-BX-1234',
    shiftTime: '08:00 AM – 02:00 PM',
    assignedSources: 8,
    pausedSources: 0,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Vikram Singh',
    driverPhone: '12345 43210',
    labourName: 'Ravi Bisht',
    daily: 5,
    weekly: 3,
  );

  static const todayStops = <RouteStop>[
    RouteStop(
      name: 'ABC Textile Mills',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'U 9, 10, Siddhgiri Tower, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [1, 4],
        time: '8–10 am',
      ),
      status: StopStatus.collected,
      amountKg: '350',
      amountPcs: '25',
      collectedAt: '8:42 am',
      hasDriverNote: true,
      contact: StopContact(
        'Rakesh Shah',
        ContactRole.storeManager,
        '98765 43214',
      ),
      record: abcRecord,
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'L.P Savani Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '9–11 am'),
      status: StopStatus.collected,
      amountKg: '270',
      collectedAt: '9:15 am',
      contact: _maheshDesai,
      record: shreeSaiRecord,
    ),
    RouteStop(
      name: 'Green Park Society',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Anand Mahal Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '9–11 am'),
      status: StopStatus.collected,
      amountKg: '120',
      collectedAt: '9:40 am',
    ),
    RouteStop(
      name: 'City Bakery',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Honey Park Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.days, days: [4], time: '9–11 am'),
      status: StopStatus.zeroKg,
      note: StopNote.noMaterial,
      visitedAt: '10:05 am',
      voiceNote: '0:18',
      contact: StopContact('Farhan Shaikh', ContactRole.owner, '98240 55621'),
      record: StopRecord(
        time: '10:05 am',
        date: 'Thu 22 Oct 2026',
        enteredBy: 'Vikram Singh',
        enteredAt: '10:05 am',
        gps: '21.1872° N, 72.7956° E',
        gpsDistanceM: '12',
        voice: '0:18',
        hasPhoto: true,
      ),
    ),
    RouteStop(
      name: 'XYZ Textile Mills',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Industrial Area, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [4],
        time: '10 am – 12 pm',
      ),
      status: StopStatus.cancelledBySource,
      note: StopNote.closedForStocktaking,
      contact: StopContact('Rajesh Mehta', ContactRole.manager, '98250 77881'),
      record: StopRecord(
        calledOffBy: 'Rajesh Mehta',
        calledOffAt: 'Wed 21 Oct, 6:10 pm',
        nextPickup: 'Thu 29 Oct',
      ),
    ),
    RouteStop(
      name: 'Om Sweets',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Ghod Dod Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '10 am – 12 pm'),
      status: StopStatus.nextStop,
      contact: StopContact('Pinal Joshi', ContactRole.manager, '98980 22110'),
      distanceKm: '1.2',
    ),
    RouteStop(
      name: 'Navratri Ground',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Pal Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '11–12 am'),
      status: StopStatus.pending,
    ),
    RouteStop(
      name: 'Hotel Rajdhani',
      type: StopType.sorted,
      frequency: StopFrequency.daily,
      address: 'Station Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '11 am – 1 pm'),
      status: StopStatus.pending,
      contact: StopContact('Kunal Shah', ContactRole.manager, '98791 33445'),
    ),
    RouteStop(
      name: 'Sai Kirana Store',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Gaurav Path, Adajan',
      schedule: StopSchedule(StopScheduleKind.pausedTill, date: '30 Oct'),
      status: StopStatus.inactive,
      note: StopNote.pausedForRenovation,
      contact: StopContact('Dinesh Patel', ContactRole.owner, '98791 22334'),
      record: saiKiranaPause,
    ),
  ];

  static const _img = 'assets/images/stop_detail';

  static const _mixed300 = CollectedItem(
    name: 'Mixed Waste',
    unit: CollectedUnit.kg,
    amount: '300.00',
    thumb: '$_img/mixed.jpg',
    photos: ['$_img/mixed.jpg', '$_img/scale_photo.jpg'],
  );

  static const abcRecord = StopRecord(
    time: '8:42 am',
    date: 'Thu 22 Oct 2026',
    enteredBy: 'Vikram Singh',
    enteredAt: '8:43 am',
    gps: '21.1959° N, 72.7933° E',
    gpsDistanceM: '18',
    note: 'Front gate was closed, collected from the side entrance.',
    voice: '0:18',
    items: [
      CollectedItem(
        name: 'PET Bottles',
        unit: CollectedUnit.kg,
        amount: '270.00',
        thumb: '$_img/pet_thumb.jpg',
        photos: ['$_img/pet_photo.jpg', '$_img/scale_photo.jpg'],
      ),
      CollectedItem(
        name: 'HDPE Rigid',
        unit: CollectedUnit.kg,
        amount: '80.00',
        thumb: '$_img/hdpe_thumb.jpg',
        photos: ['$_img/hdpe_photo.jpg', '$_img/scale_photo.jpg'],
      ),
      CollectedItem(
        name: 'E-Waste',
        unit: CollectedUnit.pcs,
        amount: '25',
        thumb: '$_img/ewaste.jpg',
        photos: ['$_img/ewaste.jpg', '$_img/scale_photo.jpg'],
      ),
    ],
    totalKg: '350.00',
    totalPcs: '25',
  );

  static const shreeSaiRecord = StopRecord(
    time: '9:15 am',
    date: 'Thu 22 Oct 2026',
    enteredBy: 'Vikram Singh',
    enteredAt: '9:16 am',
    gps: '21.1931° N, 72.7902° E',
    gpsDistanceM: '24',
    note:
        'Two bags from the back gate. Owner was not there; the helper '
        'handed over.',
    voice: '0:12',
    items: [
      CollectedItem(
        name: 'Mixed Waste',
        unit: CollectedUnit.kg,
        amount: '270.00',
        thumb: '$_img/mixed.jpg',
        photos: ['$_img/mixed.jpg', '$_img/scale_photo.jpg'],
      ),
    ],
    totalKg: '270.00',
  );

  static const saiKiranaPause = StopRecord(
    pausedRange: '20 – 30 Oct',
    askedOn: '18 Oct',
    nextPickup: 'Thu 5 Nov',
    regularSchedule: StopSchedule(
      StopScheduleKind.days,
      days: [4],
      time: '11 am – 12 pm',
    ),
  );

  /// The supervisor who adds extra pickups, and the next day's trip.
  static const extraPickupDate = 'Fri 23 Oct';

  static const _maheshDesai = StopContact(
    'Mahesh Desai',
    ContactRole.owner,
    '12345 67890',
  );

  /// Fallback contact for stops without one in the mock data.
  static const defaultContact = StopContact(
    'Kunal Shah',
    ContactRole.manager,
    '98791 33445',
  );

  /// The source's IEC executive.
  static const iecName = 'Nisha Mehta';
  static const iecPhone = '98250 11223';

  /// Next 7 Days: the route's pickup points and their next visits.
  static const nextSevenDaysStops = <RouteStop>[
    RouteStop(
      name: 'ABC Textile Mills',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'U 9, 10, Siddhgiri Tower, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [1, 4],
        time: '8–10 am',
      ),
      status: StopStatus.pending,
      nextVisits: 'Mon 26, Thu 29 Oct',
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'L.P Savani Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '9–11 am'),
      status: StopStatus.pending,
      visitsThisWeek: 7,
      contact: _maheshDesai,
    ),
    RouteStop(
      name: 'City Bakery',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Honey Park Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.days, days: [4], time: '9–11 am'),
      status: StopStatus.pending,
      nextVisits: 'Thu 29 Oct',
    ),
    RouteStop(
      name: 'XYZ Textile Mills',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Industrial Area, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [4],
        time: '10 am – 12 pm',
      ),
      status: StopStatus.pending,
      nextVisits: 'Thu 29 Oct',
    ),
    RouteStop(
      name: 'Sai Kirana Store',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Gaurav Path, Adajan',
      schedule: StopSchedule(StopScheduleKind.pausedTill, date: '30 Oct'),
      status: StopStatus.inactive,
      note: StopNote.pausedForRenovation,
    ),
  ];

  /// Planned trip: Adajan Morning tomorrow, not started yet.
  static const plannedSummary = RouteSummary(
    name: 'Adajan Morning',
    plate: 'GJ-05-BX-1234',
    shiftTime: '08:00 AM – 02:00 PM',
    assignedSources: 7,
    pausedSources: 0,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Vikram Singh',
    driverPhone: '12345 43210',
    labourName: 'Ravi Bisht',
    daily: 5,
    weekly: 0,
    onCall: 2,
  );

  static RouteStop _planned(
    String name,
    String address,
    String time, {
    StopType type = StopType.mixed,
    StopContact? contact,
  }) => RouteStop(
    name: name,
    type: type,
    frequency: StopFrequency.daily,
    address: address,
    schedule: StopSchedule(StopScheduleKind.everyDay, time: time),
    status: StopStatus.pending,
    contact: contact,
  );

  static final plannedStops = <RouteStop>[
    _planned(
      'Shree Sai Dairy',
      'L.P Savani Road, Adajan',
      '9–11 am',
      contact: _maheshDesai,
    ),
    _planned('Green Park Society', 'Anand Mahal Road, Adajan', '9–11 am'),
    _planned('Om Sweets', 'Ghod Dod Road, Adajan', '10 am – 12 pm'),
    _planned('Navratri Ground', 'Pal Road, Adajan', '11 am – 12 pm'),
    _planned(
      'Hotel Rajdhani',
      'Station Road, Adajan',
      '11 am – 1 pm',
      type: StopType.sorted,
    ),
    _planned(
      'Ganesh Traders',
      'Rander Road, Adajan',
      '12–1 pm',
      type: StopType.sorted,
    ),
    _planned('Shiv Tiffin Centre', 'Pal Gam, Adajan', '12–2 pm'),
  ];

  /// "Next visit" shown in the toast after a planned pickup is skipped.
  static const plannedTripDate = 'Fri 23 Oct';
  static const nextVisitAfterSkip = 'Sat 24 Oct';

  /// Approved trip: Punagam FullDay, contract vehicle, no labourer.
  /// Pal Gam Morning: an own-vehicle trip whose shift started 30+ minutes
  /// ago with no stop recorded in the driver's app.
  static const palGamSummary = RouteSummary(
    name: 'Pal Gam Morning',
    plate: 'GJ-05-BX-5678',
    shiftTime: '12:00 PM – 05:00 PM',
    assignedSources: 8,
    pausedSources: 0,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Amit Patel',
    driverPhone: '98250 99510',
    labourName: 'Ram Singh',
    daily: 4,
    weekly: 3,
    onCall: 1,
  );

  /// When Pal Gam Morning's shift started.
  static const palGamShiftStart = '12:00 pm';

  static RouteStop _palGam(
    String name,
    StopType type,
    StopFrequency frequency,
    String address,
    StopSchedule schedule,
  ) => RouteStop(
    name: name,
    type: type,
    frequency: frequency,
    address: address,
    schedule: schedule,
    status: StopStatus.pending,
  );

  static final palGamStops = <RouteStop>[
    _palGam(
      'Laxmi Provision Store',
      StopType.sorted,
      StopFrequency.daily,
      'Pal Gam Road, Pal',
      const StopSchedule(StopScheduleKind.everyDayExceptSun, time: '12–2 pm'),
    ),
    _palGam(
      'Pal Gam Society',
      StopType.mixed,
      StopFrequency.daily,
      'Pal Gam, Adajan',
      const StopSchedule(StopScheduleKind.everyDay, time: '12–2 pm'),
    ),
    _palGam(
      'Shiv Hardware',
      StopType.sorted,
      StopFrequency.weekly,
      'LP Savani Road, Pal',
      const StopSchedule(StopScheduleKind.days, days: [4], time: '1–3 pm'),
    ),
    _palGam(
      'Hotel Shivam',
      StopType.mixed,
      StopFrequency.onCall,
      'Pal Road, Pal',
      const StopSchedule(StopScheduleKind.calledIn, time: '2–4 pm'),
    ),
    _palGam(
      'Pal Gam Dairy',
      StopType.mixed,
      StopFrequency.daily,
      'Pal Gam Main Road, Pal',
      const StopSchedule(StopScheduleKind.everyDay, time: '2–4 pm'),
    ),
    _palGam(
      'Sai Medical Store',
      StopType.sorted,
      StopFrequency.weekly,
      'Pal Lake Road, Pal',
      const StopSchedule(StopScheduleKind.days, days: [1, 4], time: '3–4 pm'),
    ),
    _palGam(
      'Krishna Bakery',
      StopType.mixed,
      StopFrequency.daily,
      'Bhatha Road, Pal',
      const StopSchedule(StopScheduleKind.everyDay, time: '3–5 pm'),
    ),
    _palGam(
      'Om Electricals',
      StopType.sorted,
      StopFrequency.weekly,
      'Pal RTO Road, Pal',
      const StopSchedule(StopScheduleKind.days, days: [4], time: '4–5 pm'),
    ),
  ];

  static const approvedSummary = RouteSummary(
    name: 'Punagam FullDay',
    plate: 'GJ-05-EE-1002',
    shiftTime: '08:00 AM – 02:00 PM',
    assignedSources: 8,
    pausedSources: 0,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Kishan',
    driverPhone: 'Shree Ram Transport',
    labourName: '',
    daily: 6,
    weekly: 0,
    monthly: 2,
    contractVehicle: true,
  );

  static const warehouseResult = WarehouseResult(
    netKg: '1,340',
    driverKg: '1,355',
    differenceKg: '−15',
    differencePct: '1.1',
    bags: 42,
    approvedBy: 'Mehul Shah',
    approvedAt: '3:10 pm',
  );

  static const approvedStops = <RouteStop>[
    RouteStop(
      name: 'Krishna Traders',
      type: StopType.sorted,
      frequency: StopFrequency.daily,
      address: 'Punagam Main Road',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '8–10 am'),
      status: StopStatus.collected,
      amountKg: '210',
      collectedAt: '8:30 am',
      gateEntryAt: '2:05 pm',
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Saroli Road, Punagam',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '9–11 am'),
      status: StopStatus.collected,
      amountKg: '300',
      collectedAt: '9:10 am',
      gateEntryAt: '2:08 pm',
      contact: _maheshDesai,
      record: StopRecord(
        time: '9:10 am',
        date: 'Thu 22 Oct 2026',
        fromSlip: true,
        entry: EntrySource.gate,
        enteredBy: 'Meena Shah',
        enteredAt: '2:08 pm',
        items: [_mixed300],
        totalKg: '300.00',
      ),
    ),
    RouteStop(
      name: 'Sunrise School',
      type: StopType.sorted,
      frequency: StopFrequency.monthly,
      address: 'Kumbharia Road, Punagam',
      schedule: StopSchedule(StopScheduleKind.firstOfMonth, time: '1–3 pm'),
      status: StopStatus.missed,
      note: StopNote.notRecordedByDriver,
      contact: StopContact('Sister Mary', ContactRole.office, '98255 10987'),
      record: StopRecord(
        warehouse: 'Adajan Central Warehouse',
        reachedAt: '1:50 pm',
        driverPhone: '99780 44120',
      ),
    ),
    RouteStop(
      name: 'Patel Kirana',
      type: StopType.sorted,
      frequency: StopFrequency.daily,
      address: 'Sitanagar, Punagam',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '10 am – 12 pm'),
      status: StopStatus.collected,
      amountKg: '45',
      collectedAt: '11:05 am',
      gateEntryAt: '2:14 pm',
    ),
    RouteStop(
      name: 'Royal Hotel',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Kadodara Road',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '11 am – 1 pm'),
      status: StopStatus.collected,
      amountKg: '160',
      collectedAt: '11:40 am',
      gateEntryAt: '2:16 pm',
    ),
    RouteStop(
      name: 'Gokul Society',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Punagam Char Rasta',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '12–2 pm'),
      status: StopStatus.zeroKg,
      note: StopNote.noMaterialPerDriver,
      gateEntryAt: '2:18 pm',
    ),
    RouteStop(
      name: 'Ambika Paper Mart',
      type: StopType.sorted,
      frequency: StopFrequency.daily,
      address: 'Saroli GIDC, Punagam',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '12–1 pm'),
      status: StopStatus.collected,
      amountKg: '640',
      collectedAt: '12:20 pm',
      gateEntryAt: '2:20 pm',
    ),
    RouteStop(
      name: 'Om Fabrics',
      type: StopType.sorted,
      frequency: StopFrequency.daily,
      address: 'Punagam GIDC',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '1–3 pm'),
      status: StopStatus.cancelledBySource,
      note: StopNote.askedToSkipToday,
    ),
  ];

  static const mapStops = <MapStopPoint>[
    MapStopPoint(1, 43, 318, StopStatus.collected),
    MapStopPoint(2, 93, 270, StopStatus.collected),
    MapStopPoint(3, 50, 200, StopStatus.collected),
    MapStopPoint(4, 120, 164, StopStatus.zeroKg),
    MapStopPoint(5, 183, 194, StopStatus.cancelledBySource),
    MapStopPoint(6, 213, 131, StopStatus.nextStop),
    MapStopPoint(7, 263, 84, StopStatus.pending),
    MapStopPoint(8, 210, 40, StopStatus.pending),
    MapStopPoint(9, 128, 50, StopStatus.inactive),
  ];

  /// Stop detail for a card on Stops to look at: the trip stop with that name
  /// and status, or a sample stop of that status renamed to [name].
  static ({RouteStop stop, RouteSummary summary, TripState state}) lookAtStop(
    String name,
    StopStatus status,
  ) {
    bool match(RouteStop s) => s.name == name && s.status == status;
    for (final s in approvedStops.where(match)) {
      return (stop: s, summary: approvedSummary, state: TripState.approved);
    }
    for (final s in todayStops.where(match)) {
      return (stop: s, summary: todaySummary, state: TripState.onRoute);
    }
    final sample = status == StopStatus.missed
        ? approvedStops.firstWhere((s) => s.status == status)
        : todayStops.firstWhere((s) => s.status == status);
    return (
      stop: sample.copyWith(name: name),
      summary: status == StopStatus.missed ? approvedSummary : todaySummary,
      state: status == StopStatus.missed
          ? TripState.approved
          : TripState.onRoute,
    );
  }
}
