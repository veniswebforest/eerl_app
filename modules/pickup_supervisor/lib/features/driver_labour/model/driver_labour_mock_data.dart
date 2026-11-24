import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';

/// Mock data until the directory is backed by SQLite.
abstract final class DriverLabourMockData {
  static const driverCount = 12;
  static const labourCount = 5;

  static const _phone = '+91 98765 43210';
  static const _idNumber = '8478 8456 63245';
  static const _date = '1 May 2026 • 08:15 AM';
  static const _warehouse = 'Adajan Central Warehouse';

  static DriverLabourPerson _driver(String name, {bool active = true}) =>
      DriverLabourPerson(
        name: name,
        code: 'SUR-DRV-0089',
        phone: _phone,
        idNumber: _idNumber,
        dateTime: _date,
        warehouse: _warehouse,
        kind: DriverLabourKind.driver,
        active: active,
      );

  static DriverLabourPerson _labour(String name, {String? phone}) =>
      DriverLabourPerson(
        name: name,
        code: 'SCH-LAB-0090',
        phone: phone,
        idNumber: _idNumber,
        dateTime: '2 May 2026 • 08:15 AM',
        kind: DriverLabourKind.labour,
      );

  static final List<DriverLabourPerson> activeDrivers = [
    _driver('Ramesh Bhai Patel'),
    _driver('Umesh Yadav'),
    _driver('Manohar Tiwari'),
    _driver('Ramchand Tripathi'),
  ];

  static final List<DriverLabourPerson> inactiveDrivers = [
    _driver('Ramesh Bhai Patel', active: false),
    _driver('Vikas Prajapati', active: false),
    _driver('Suresh Makwana', active: false),
    _driver('Munna Tripathi', active: false),
  ];

  static final List<DriverLabourPerson> activeLabour = [
    _labour('Neel Prakash'),
    _labour('Naman Dhir', phone: _phone),
    _labour('Virendra'),
    _labour('Rudra kumar', phone: _phone),
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
