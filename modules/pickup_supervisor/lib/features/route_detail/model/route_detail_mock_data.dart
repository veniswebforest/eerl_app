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
    ),
    RouteStop(
      name: 'XYZ Textile Mills',
      type: StopType.sorted,
      frequency: StopFrequency.weekly,
      address: 'Industrial Area, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [4],
        time: '10–12 am',
      ),
      status: StopStatus.cancelledBySource,
      note: StopNote.closedForStocktaking,
    ),
    RouteStop(
      name: 'Om Sweets',
      type: StopType.mixed,
      frequency: StopFrequency.daily,
      address: 'Ghod Dod Road, Adajan',
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '10–12 am'),
      status: StopStatus.nextStop,
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
      schedule: StopSchedule(StopScheduleKind.everyDay, time: '11–1 pm'),
      status: StopStatus.pending,
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

  static const nextSevenDaysStops = <RouteStop>[
    RouteStop(
      name: 'ABC Textile Mills',
      type: StopType.sorted,
      address: 'U 9, 10, Siddhgiri Tower, B/H Navyug Society, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.days,
        days: [1, 4],
        time: '8–10 am',
      ),
      status: StopStatus.pending,
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.sorted,
      address: 'X 3, 10, Embrane Zone, navyug plus Society, Adajan',
      schedule: StopSchedule(StopScheduleKind.exceptSunday, time: '9–11 am'),
      status: StopStatus.pending,
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.sorted,
      address: 'U 9, 10, Siddhgiri Tower, B/H Navyug Society, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.secondWednesday,
        time: '10–11 am',
      ),
      status: StopStatus.pending,
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.mixed,
      address: 'X 3, 10, Embrane Zone, navyug plus Society, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.once,
        date: 'Sat 24 Oct',
        time: '11–12 pm',
      ),
      status: StopStatus.pending,
    ),
    RouteStop(
      name: 'Shree Sai Dairy',
      type: StopType.sorted,
      address: 'U 9, 10, Siddhgiri Tower, B/H Navyug Society, Adajan',
      schedule: StopSchedule(
        StopScheduleKind.once,
        date: 'Sat 24 Oct',
        time: '11–12 pm',
      ),
      status: StopStatus.pending,
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
}
