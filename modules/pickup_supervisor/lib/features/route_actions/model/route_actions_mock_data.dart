import 'package:pickup_supervisor/features/route_actions/model/route_actions_models.dart';
import 'package:pickup_supervisor/features/route_detail/model/route_detail_models.dart';

/// Mock data for the planned-trip actions until they come from SQLite.
abstract final class RouteActionsMockData {
  static const tripDate = 'Fri 23 Oct';
  static const tripDay = 'Fri 23 Oct';

  /// Today's date on an on-route trip.
  static const todayDate = 'Thu 22 Oct';
  static const shiftWindow = '8 am – 2 pm';

  static const routeDriver = TeamPerson(
    name: 'Vikram Singh',
    phoneTail: '4321',
  );
  static const routeLabour = TeamPerson(name: 'Ravi Bisht', phoneTail: '5847');

  /// Free people first, then the busy ones.
  static const people = <TeamPerson>[
    TeamPerson(name: 'Suresh Kumar', phoneTail: '3310'),
    TeamPerson(name: 'Rakesh Sharma', phoneTail: '2458'),
    TeamPerson(
      name: 'Mahesh Patel',
      phoneTail: '7764',
      freeUntil: ('Vesu Evening', '3–7 pm'),
    ),
    TeamPerson(
      name: 'Amit Patel',
      phoneTail: '9510',
      busyWith: ('Pal Gam Morning', '12–5 pm'),
    ),
  ];

  static const moveTargets = <MoveTargetTrip>[
    MoveTargetTrip(
      name: 'Pal Gam Morning',
      plate: 'GJ-05-BX-5678',
      driver: 'Amit Patel',
      time: '12–5 pm',
    ),
    MoveTargetTrip(
      name: 'Vesu Evening',
      plate: 'GJ-05-EE-1001',
      driver: 'Mahesh Patel',
      time: '3–7 pm',
    ),
    MoveTargetTrip(
      name: 'Punagam FullDay',
      plate: 'GJ-05-EE-1002',
      driver: 'Shree Ram Transport',
      time: '8 am – 2 pm',
      contract: true,
    ),
  ];

  /// Stops ticked when Move stops opens.
  static const initiallyMoved = {
    'Om Sweets',
    'Navratri Ground',
    'Hotel Rajdhani',
  };

  static const askRoutes = <AskTarget>[
    AskTarget(
      name: 'Adajan Morning',
      detail: '',
      plate: 'GJ-05-BX-1234',
      time: '8 am – 2 pm',
    ),
    AskTarget(
      name: 'Pal Gam Morning',
      detail: '',
      plate: 'GJ-05-BX-5678',
      time: '12–5 pm',
    ),
    AskTarget(
      name: 'Punagam FullDay',
      detail: '',
      plate: 'GJ-05-EE-1002',
      contract: true,
      time: '8 am – 2 pm',
    ),
    AskTarget(
      name: 'Vesu Evening',
      detail: '',
      plate: 'GJ-05-EE-1001',
      time: '3–7 pm',
    ),
    AskTarget(
      name: 'Rander Evening',
      detail: '',
      plate: 'GJ-05-BX-9012',
      contract: true,
      time: '4–8 pm',
    ),
  ];

  static const askPoints = <AskTarget>[
    AskTarget(
      name: 'ABC Textile Mills',
      detail: 'U 9, 10, Siddhgiri Tower, Adajan',
    ),
    AskTarget(name: 'Shree Sai Dairy', detail: 'L.P Savani Road, Adajan'),
    AskTarget(name: 'Green Park Society', detail: 'Anand Mahal Road, Adajan'),
    AskTarget(name: 'Navratri Ground', detail: 'Pal Road, Adajan'),
    AskTarget(name: 'Hotel Rajdhani', detail: 'Station Road, Adajan'),
  ];

  /// "Today" for the Dates calendar and its default range (Sat 24 – Sun 25).
  static final askToday = DateTime(2026, 10, 22);
  static final askRange = (DateTime(2026, 10, 24), DateTime(2026, 10, 25));

  static const randerSummary = RouteSummary(
    name: 'Rander Evening',
    plate: 'GJ-05-BX-9012',
    shiftTime: '04:00 PM – 08:00 PM',
    shift: RouteShift.evening,
    assignedSources: 8,
    pausedSources: 0,
    warehouse: 'Adajan Central Warehouse',
    driverName: 'Jignesh',
    driverPhone: 'Khodiyar Transport',
    labourName: '',
    daily: 0,
    weekly: 6,
    biWeekly: 2,
    contractVehicle: true,
  );

  /// The swap saved on Adajan Morning before it started (Trips plan, Today).
  static const adajanTodayChange = TripTeamChange(
    driver: 'Suresh Kumar',
    replaces: 'Vikram Singh',
  );
}
