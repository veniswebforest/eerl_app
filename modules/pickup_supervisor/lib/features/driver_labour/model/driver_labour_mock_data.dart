import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';

/// Mock data until the directory is backed by SQLite.
abstract final class DriverLabourMockData {
  static const driverCount = 12;
  static const labourCount = 5;

  static const _idNumber = '8478 8456 63245';
  static const _warehouse = 'Adajan Central Warehouse';

  static DriverLabourPerson _driver(
    String name,
    String phone, {
    bool active = true,
    String? inUseRoute,
  }) => DriverLabourPerson(
    name: name,
    code: 'SUR-DRV-0089',
    phone: '+91 $phone',
    idNumber: _idNumber,
    dateTime: '1 May 2026 • 08:15 AM',
    warehouse: _warehouse,
    kind: DriverLabourKind.driver,
    active: active,
    inUseRoute: inUseRoute,
  );

  static DriverLabourPerson _labour(
    String name, {
    String? phone,
    String? inUseRoute,
  }) => DriverLabourPerson(
    name: name,
    code: 'SCH-LAB-0090',
    phone: phone == null ? null : '+91 $phone',
    idNumber: _idNumber,
    dateTime: '2 May 2026 • 08:15 AM',
    warehouse: _warehouse,
    kind: DriverLabourKind.labour,
    inUseRoute: inUseRoute,
  );

  static final List<DriverLabourPerson> activeDrivers = [
    // Drives Adajan Morning: Deactivate is refused.
    _driver('Vikram Singh', '12345 43210', inUseRoute: 'Adajan Morning'),
    _driver('Suresh Kumar', '98250 43310'),
    _driver('Rakesh Sharma', '98250 12458'),
    _driver('Mahesh Patel', '98250 67764'),
  ];

  static final List<DriverLabourPerson> inactiveDrivers = [
    _driver('Rakesh Sharma', '98250 12458', active: false),
    _driver('Vikas Prajapati', '98250 70415', active: false),
    _driver('Suresh Makwana', '98250 61127', active: false),
    _driver('Munna Tripathi', '98250 58830', active: false),
  ];

  static final List<DriverLabourPerson> activeLabour = [
    _labour('Ravi Bisht', phone: '23456 58492', inUseRoute: 'Adajan Morning'),
    _labour('Ramesh Yadav', phone: '98250 32458'),
    _labour('Ram Singh', phone: '98250 22282'),
    // Labour has no app, so the phone number is optional.
    _labour('Virendra'),
  ];

  static const List<DriverLabourPerson> inactiveLabour = [];

  static List<DriverLabourPerson> peopleFor(
    DriverLabourKind kind, {
    required bool active,
  }) => switch ((kind, active)) {
    (DriverLabourKind.driver, true) => activeDrivers,
    (DriverLabourKind.driver, false) => inactiveDrivers,
    (DriverLabourKind.labour, true) => activeLabour,
    (DriverLabourKind.labour, false) => inactiveLabour,
  };
}
