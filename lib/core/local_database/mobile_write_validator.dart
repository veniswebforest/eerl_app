import 'package:sqflite/sqflite.dart';

/// Raised before a local mutation transaction commits when its API payload
/// does not satisfy the mobile validation contract.
class LocalWriteValidationException implements Exception {
  const LocalWriteValidationException(this.message, {this.field});

  final String message;
  final String? field;

  @override
  String toString() => message;
}

/// Last-line validation guard shared by every SQLite + outbox write.
///
/// Feature forms still validate early for field-level feedback. This guard is
/// deliberately placed inside the same SQLite transaction as the entity write
/// so a missed validation can never leave either a partial local row or an
/// invalid outbox entry behind.
abstract final class MobileWriteValidator {
  static Future<void> validate(
    Transaction transaction, {
    required String method,
    required String path,
    required Object? body,
  }) async {
    final payload = _payload(body, path: path, allowNull: _allowsNoBody(path));

    if (path == '/item-config') {
      _itemConfig(payload);
      return;
    }
    if (RegExp(r'^/vehicles/[^/]+$').hasMatch(path)) {
      _vehicle(payload, creating: method == 'PUT');
      return;
    }
    if (RegExp(
      r'^/(vehicles|mrf-people|ragpickers)/[^/]+/status$',
    ).hasMatch(path)) {
      _requiredBool(payload, 'isActive');
      return;
    }
    if (RegExp(r'^/mrf-people/[^/]+$').hasMatch(path)) {
      _person(payload, creating: method == 'PUT', mrf: true);
      return;
    }
    if (RegExp(r'^/ragpickers/[^/]+$').hasMatch(path)) {
      _person(payload, creating: method == 'PUT', mrf: false);
      return;
    }
    if (RegExp(r'^/collections/[^/]+/submit$').hasMatch(path)) {
      _collection(payload, submit: true);
      return;
    }
    if (RegExp(r'^/collections/[^/]+$').hasMatch(path) && method == 'PUT') {
      _collection(payload, submit: false);
      return;
    }
    if (RegExp(r'^/(collections|transfers)/[^/]+/reject$').hasMatch(path)) {
      _rejection(payload);
      return;
    }
    if (RegExp(r'^/expenses/[^/]+$').hasMatch(path)) {
      _expense(payload);
      return;
    }
    if (RegExp(r'^/expenses/[^/]+/decide$').hasMatch(path)) {
      _decision(payload, allowAmount: false);
      return;
    }
    if (RegExp(r'^/cash-requests/[^/]+$').hasMatch(path)) {
      _cashRequest(payload);
      return;
    }
    if (RegExp(r'^/cash-requests/[^/]+/decide$').hasMatch(path)) {
      _decision(payload, allowAmount: true);
      return;
    }
    if (RegExp(r'^/expense-categories/requests/[^/]+$').hasMatch(path)) {
      _categoryRequest(payload);
      return;
    }
    if (RegExp(r'^/expense-categories/requests/[^/]+/decide$').hasMatch(path)) {
      _decision(payload, allowAmount: false, remarksAllowed: false);
      return;
    }
    if (RegExp(r'^/transfers/[^/]+$').hasMatch(path)) {
      _transferRequest(payload);
      return;
    }
    if (RegExp(r'^/transfers/[^/]+/handover$').hasMatch(path)) {
      _transferHandover(payload);
      return;
    }
    if (RegExp(r'^/transfers/[^/]+/approve$').hasMatch(path)) {
      _transferApproval(payload);
      return;
    }
    if (RegExp(r'^/tasks/[^/]+$').hasMatch(path)) {
      _task(payload);
      return;
    }
    if (RegExp(r'^/tasks/[^/]+/complete$').hasMatch(path)) {
      _optionalText(payload, 'note', max: 255);
      _list(payload, 'photoUrls', min: 0, max: 5);
      return;
    }
    if (RegExp(r'^/requests/[^/]+$').hasMatch(path)) {
      _request(payload);
      return;
    }
    if (RegExp(r'^/requests/[^/]+/answer$').hasMatch(path)) {
      _requiredText(payload, 'notes', min: 3, max: 2000);
      _list(payload, 'photoUrls', min: 0);
    }
  }

  static bool _allowsNoBody(String path) => RegExp(
    r'^/(collections/[^/]+(/approve)?|tasks/[^/]+/cancel|notifications(/[^/]+/read|/read-all))$',
  ).hasMatch(path);

  static Map<String, Object?> _payload(
    Object? body, {
    required String path,
    required bool allowNull,
  }) {
    if (body == null && allowNull) return const <String, Object?>{};
    if (body is Map<String, Object?>) return body;
    if (body is Map) return Map<String, Object?>.from(body);
    throw LocalWriteValidationException(
      'The data for this change is incomplete. Please review it and try again.',
      field: path,
    );
  }

  static void _itemConfig(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _enum(value, 'collectionChannel', const {'MRF', 'D2D', 'RAMP'});
    _enum(value, 'tab', const {'PLASTIC', 'NON_PLASTIC'}, optional: true);
    final items = _list(value, 'items', min: 1);
    final ids = <String>{};
    final orders = <int>{};
    for (var index = 0; index < items.length; index++) {
      final item = _map(items[index], 'items.$index');
      final id = _requiredText(item, 'itemId', prefix: 'items.$index');
      _requiredBool(item, 'isSelected', prefix: 'items.$index');
      final order = _wholeNumber(
        item,
        'sortOrder',
        min: 0,
        prefix: 'items.$index',
      );
      if (!ids.add(id)) {
        _fail(
          'Each material can be included only once.',
          'items.$index.itemId',
        );
      }
      if (!orders.add(order)) {
        _fail(
          'Each material must have a unique order.',
          'items.$index.sortOrder',
        );
      }
    }
  }

  static void _vehicle(Map<String, Object?> value, {required bool creating}) {
    if (creating) _requiredText(value, 'centerId');
    final plate = creating
        ? _requiredText(value, 'plateNumber')
        : _optionalText(value, 'plateNumber');
    if (plate != null &&
        !RegExp(
          r'^[A-Z]{2}[-\s]?[0-9]{1,2}[-\s]?[A-Z]{1,2}[-\s]?[0-9]{4}$',
          caseSensitive: false,
        ).hasMatch(plate)) {
      _fail(
        'Enter a valid vehicle number, for example GJ-05-BX-1234.',
        'plateNumber',
      );
    }
    _optionalText(value, 'driverName', max: 100);
    if (!creating && value.isEmpty) {
      _fail('Change at least one vehicle detail.', 'vehicle');
    }
  }

  static void _person(
    Map<String, Object?> value, {
    required bool creating,
    required bool mrf,
  }) {
    if (creating) _requiredText(value, 'centerId');
    if (creating || value.containsKey('name')) {
      _requiredText(value, 'name', min: 2, max: 255);
    }
    if (creating || value.containsKey('phone')) {
      final phone = _requiredText(value, 'phone').replaceAll(RegExp(r'\s'), '');
      final valid = mrf
          ? RegExp(r'^(?:\+91)?[6-9][0-9]{9}$').hasMatch(phone)
          : RegExp(r'^(?:\+91)?[6-9][0-9]{9}$').hasMatch(phone);
      if (!valid) {
        _fail('Enter a valid 10-digit Indian mobile number.', 'phone');
      }
    }
    _optionalText(value, 'idNumber', max: 100);
    _optionalText(value, 'photoUrl');
    if (mrf) {
      _enum(value, 'role', const {'SUPERVISOR', 'LABOUR'}, optional: !creating);
    }
  }

  static void _collection(Map<String, Object?> value, {required bool submit}) {
    _requiredText(value, 'centerId');
    final type = _enum(value, 'type', const {'MRF', 'D2D', 'RAMP'});
    _optionalText(value, 'givenByName', min: 1, max: 255);
    _optionalText(value, 'vehicleId');
    _optionalText(value, 'mrfLabourId');
    _optionalText(value, 'ragpickerId');
    _enum(value, 'paidBy', const {'CASH', 'UPI'}, optional: true);
    final handover = _list(
      value,
      'handoverPhotoUrls',
      min: 0,
      max: 10,
      optional: true,
    );
    final lines = _list(
      value,
      'lines',
      min: submit ? 1 : 0,
      max: submit ? 100 : 100,
      optional: !submit,
    );
    final itemIds = <String>{};
    for (var index = 0; index < lines.length; index++) {
      final line = _map(lines[index], 'lines.$index');
      final itemId = _requiredText(line, 'itemId', prefix: 'lines.$index');
      if (!itemIds.add(itemId)) {
        _fail('Each material can be added only once.', 'lines.$index.itemId');
      }
      _number(
        line,
        'collectedQty',
        min: submit ? 0.0000001 : 0,
        max: 999999.999,
        decimals: 3,
        optional: !submit,
        prefix: 'lines.$index',
      );
      _number(
        line,
        'verifiedQty',
        min: 0,
        max: 999999.999,
        decimals: 3,
        optional: !submit,
        prefix: 'lines.$index',
      );
      _number(
        line,
        'rate',
        min: 0,
        max: 99999999.99,
        decimals: 2,
        optional: true,
        nullable: true,
        prefix: 'lines.$index',
      );
      _number(
        line,
        'amount',
        min: 0,
        max: 99999999.99,
        decimals: 2,
        optional: true,
        nullable: true,
        prefix: 'lines.$index',
      );
      _list(line, 'photoUrls', min: submit ? 1 : 0, max: 10, optional: !submit);
    }
    _gps(value);
    if (!submit) return;
    _requiredText(value, 'slipNumber');
    _dateTime(value, 'collectedAt');
    if (type == 'D2D') {
      _requiredText(value, 'vehicleId');
      _requiredText(value, 'givenByName', min: 1, max: 255);
    } else if (type == 'MRF') {
      _requiredText(value, 'mrfLabourId');
      if (handover.isNotEmpty) {
        _fail(
          'MRF collections do not use a handover photo.',
          'handoverPhotoUrls',
        );
      }
    } else {
      _requiredText(value, 'ragpickerId');
      if (handover.isEmpty) {
        _fail('Add a handover photo for the ragpicker.', 'handoverPhotoUrls');
      }
    }
  }

  static void _expense(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _requiredText(value, 'categoryId');
    _number(value, 'amount', min: 0.0000001, max: 9999999, decimals: 2);
    _dateTime(value, 'spentAt');
    _optionalText(value, 'note', max: 255);
    _optionalText(value, 'collectionId');
    _list(value, 'photoUrls', min: 0, max: 5, optional: true);
  }

  static void _cashRequest(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _number(value, 'amount', min: 0.0000001, max: 9999999, decimals: 2);
    _optionalText(value, 'reason', max: 255);
  }

  static void _categoryRequest(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _requiredText(value, 'name', min: 2, max: 100);
    _optionalText(value, 'reason', max: 255);
  }

  static void _decision(
    Map<String, Object?> value, {
    required bool allowAmount,
    bool remarksAllowed = true,
  }) {
    final outcome = _enum(value, 'outcome', const {'APPROVED', 'REJECTED'});
    if (outcome == 'REJECTED') {
      _requiredText(value, 'reason', min: 3, max: 1000);
    } else {
      _optionalText(value, 'reason', min: 3, max: 1000);
    }
    if (remarksAllowed) _optionalText(value, 'remarks', max: 1000);
    if (allowAmount) {
      _number(value, 'amount', min: 0.0000001, max: 9999999, optional: true);
    }
  }

  static void _rejection(Map<String, Object?> value) {
    _requiredText(value, 'reason', min: 3, max: 1000);
    _optionalText(value, 'remarks', max: 1000);
  }

  static void _transferRequest(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    final items = _list(value, 'items', min: 1, max: 50);
    final ids = <String>{};
    for (var index = 0; index < items.length; index++) {
      final item = _map(items[index], 'items.$index');
      final id = _requiredText(item, 'itemId', prefix: 'items.$index');
      if (!ids.add(id)) {
        _fail('Each material can be added only once.', 'items.$index.itemId');
      }
      _number(
        item,
        'quantity',
        min: 0.0000001,
        max: 999999.999,
        decimals: 3,
        prefix: 'items.$index',
      );
    }
    _number(value, 'estimatedExpense', min: 0, max: 9999999, optional: true);
    _optionalText(value, 'note', max: 255);
  }

  static void _transferHandover(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _dateTime(value, 'handedOverAt');
    _requiredText(value, 'vehicleNumber', min: 4, max: 20);
    _requiredText(value, 'driverName', min: 1, max: 255);
    _list(value, 'vehiclePhotoUrls', min: 1, max: 10);
    _number(
      value,
      'dispatchedWeight',
      min: 0.0000001,
      max: 999999.999,
      decimals: 3,
    );
    _wholeNumber(value, 'baleCount', min: 1, max: 9999, optional: true);
    _list(value, 'weighbridgePhotoUrls', min: 0, max: 10, optional: true);
    final items = _list(value, 'items', min: 1, max: 50, optional: true);
    for (var index = 0; index < items.length; index++) {
      final item = _map(items[index], 'items.$index');
      _requiredText(item, 'itemId', prefix: 'items.$index');
      _number(
        item,
        'quantity',
        min: 0.0000001,
        max: 999999.999,
        decimals: 3,
        prefix: 'items.$index',
      );
    }
    _optionalText(value, 'note', max: 255);
    _gps(value);
  }

  static void _transferApproval(Map<String, Object?> value) {
    _requiredText(value, 'destinationFacilityId');
    _dateTime(value, 'vehicleArrivalTime', optional: true);
    _optionalText(value, 'note', max: 255);
    final vehicle = _map(value['vehicle'], 'vehicle');
    final listed = _optionalText(vehicle, 'transferVehicleId');
    if (listed == null) {
      _requiredText(vehicle, 'vehicleNumber', min: 4, max: 20);
      _optionalText(vehicle, 'transporterName', max: 255);
      _number(vehicle, 'transferFee', min: 0, max: 9999999, decimals: 2);
    } else {
      _number(
        vehicle,
        'transferFee',
        min: 0,
        max: 9999999,
        decimals: 2,
        optional: true,
      );
    }
  }

  static void _task(Map<String, Object?> value) {
    _requiredText(value, 'assignedToId');
    _requiredText(value, 'centerId');
    _requiredText(value, 'title', min: 3, max: 255);
    _optionalText(value, 'description', max: 2000);
    _enum(value, 'priority', const {'HIGH', 'NORMAL', 'LOW'}, optional: true);
    _dateTime(value, 'dueDate', optional: true);
  }

  static void _request(Map<String, Object?> value) {
    _requiredText(value, 'centerId');
    _requiredText(value, 'body', min: 3, max: 2000);
    _enum(value, 'priority', const {'HIGH', 'NORMAL', 'LOW'}, optional: true);
    _dateTime(value, 'followUpAt');
    _list(value, 'photoUrls', min: 0, max: 5, optional: true);
  }

  static void _gps(Map<String, Object?> value) {
    if (!value.containsKey('gps') || value['gps'] == null) return;
    final gps = _map(value['gps'], 'gps');
    _number(gps, 'lat', min: -90, max: 90, prefix: 'gps');
    _number(gps, 'lng', min: -180, max: 180, prefix: 'gps');
  }

  static String _requiredText(
    Map<String, Object?> value,
    String field, {
    int min = 1,
    int? max,
    String? prefix,
  }) {
    final text = value[field]?.toString().trim() ?? '';
    final full = _field(prefix, field);
    if (text.length < min) {
      _fail(_lengthMessage(field, min: min, max: max), full);
    }
    if (max != null && text.length > max) {
      _fail(_lengthMessage(field, min: min, max: max), full);
    }
    return text;
  }

  static String? _optionalText(
    Map<String, Object?> value,
    String field, {
    int min = 1,
    int? max,
    String? prefix,
  }) {
    if (!value.containsKey(field) || value[field] == null) return null;
    final text = value[field].toString().trim();
    if (text.isEmpty) return null;
    final full = _field(prefix, field);
    if (text.length < min || (max != null && text.length > max)) {
      _fail(_lengthMessage(field, min: min, max: max), full);
    }
    return text;
  }

  static String _enum(
    Map<String, Object?> value,
    String field,
    Set<String> allowed, {
    bool optional = false,
  }) {
    final raw = value[field]?.toString().trim().toUpperCase();
    if (optional && (raw == null || raw.isEmpty)) return '';
    if (raw == null || !allowed.contains(raw)) {
      _fail('Choose a valid ${_label(field)}.', field);
    }
    return raw;
  }

  static List<Object?> _list(
    Map<String, Object?> value,
    String field, {
    required int min,
    int? max,
    bool optional = false,
  }) {
    if (optional && (!value.containsKey(field) || value[field] == null)) {
      return const [];
    }
    final list = value[field];
    if (list is! List) _fail('${_label(field)} is required.', field);
    if (list.length < min) _fail('Add at least $min ${_label(field)}.', field);
    if (max != null && list.length > max) {
      _fail('You can add up to $max ${_label(field)}.', field);
    }
    return List<Object?>.from(list);
  }

  static double? _number(
    Map<String, Object?> value,
    String field, {
    required double min,
    required double max,
    int? decimals,
    bool optional = false,
    bool nullable = false,
    String? prefix,
  }) {
    final full = _field(prefix, field);
    if (!value.containsKey(field) || value[field] == null) {
      if (optional || nullable) return null;
      _fail('${_label(field)} is required.', full);
    }
    final number = value[field];
    if (number is! num || !number.isFinite) {
      _fail('Enter a valid ${_label(field)}.', full);
    }
    final result = number.toDouble();
    if (result < min || result > max) {
      _fail('${_label(field)} must be between $min and $max.', full);
    }
    if (decimals != null) {
      final factor = decimals == 2 ? 100.0 : 1000.0;
      if ((result * factor - (result * factor).round()).abs() > 0.000001) {
        _fail(
          '${_label(field)} can have at most $decimals decimal places.',
          full,
        );
      }
    }
    return result;
  }

  static int _wholeNumber(
    Map<String, Object?> value,
    String field, {
    required int min,
    int? max,
    bool optional = false,
    String? prefix,
  }) {
    if (optional && (!value.containsKey(field) || value[field] == null)) {
      return min;
    }
    final number = value[field];
    final full = _field(prefix, field);
    if (number is! num ||
        !number.isFinite ||
        number != number.roundToDouble()) {
      _fail('${_label(field)} must be a whole number.', full);
    }
    final result = number.toInt();
    if (result < min || (max != null && result > max)) {
      _fail('${_label(field)} is outside the allowed range.', full);
    }
    return result;
  }

  static void _requiredBool(
    Map<String, Object?> value,
    String field, {
    String? prefix,
  }) {
    if (value[field] is! bool) {
      _fail('${_label(field)} is required.', _field(prefix, field));
    }
  }

  static void _dateTime(
    Map<String, Object?> value,
    String field, {
    bool optional = false,
  }) {
    if (optional && (!value.containsKey(field) || value[field] == null)) return;
    final raw = value[field]?.toString();
    final parsed = raw == null ? null : DateTime.tryParse(raw);
    if (parsed == null || !parsed.isUtc) {
      _fail('${_label(field)} must be a valid UTC date and time.', field);
    }
  }

  static Map<String, Object?> _map(Object? value, String field) {
    if (value is Map<String, Object?>) return value;
    if (value is Map) return Map<String, Object?>.from(value);
    _fail('${_label(field)} is required.', field);
  }

  static String _field(String? prefix, String field) =>
      prefix == null || prefix.isEmpty ? field : '$prefix.$field';

  static String _label(String field) => field
      .replaceAllMapped(
        RegExp(r'([A-Z])'),
        (match) => ' ${match.group(1)!.toLowerCase()}',
      )
      .replaceAll('.', ' ');

  static String _lengthMessage(String field, {required int min, int? max}) {
    if (max == null) {
      return '${_label(field)} must be at least $min characters.';
    }
    if (min <= 1) return '${_label(field)} must be $max characters or fewer.';
    return '${_label(field)} must be between $min and $max characters.';
  }

  static Never _fail(String message, String field) {
    throw LocalWriteValidationException(message, field: field);
  }
}
