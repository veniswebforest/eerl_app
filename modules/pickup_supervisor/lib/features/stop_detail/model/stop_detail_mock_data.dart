import 'package:pickup_supervisor/features/stop_detail/model/stop_detail_models.dart';

/// Mock data for the stop detail screen (no backend yet).
abstract final class StopDetailMockData {
  static const _address =
      'U 9, 10, Siddhgiri Tower, B/H Navyug College Rd, Navyug Society, '
      'Sangana Society, Adajan, Surat, Gujarat 395009';

  static const _iec = StopContact(name: 'Nisha Mehta', phone: '98250 11223');

  static StopDetailInfo forStop(String name) => StopDetailInfo(
    person: switch (name) {
      'Om Sweets' => const StopContact(
        name: 'Pinal Joshi',
        phone: '98980 22110',
        role: 'Manager',
      ),
      _ => const StopContact(
        name: 'Kunal Shah',
        phone: '98791 33445',
        role: 'Manager',
      ),
    },
    iecExecutive: _iec,
    warehouse: 'Adajan Central Warehouse',
    fullAddress: _address,
  );
}
