import 'package:eerl_app/core/local_database/mobile_write_validator.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';

/// The stop a driver form records, read from SQLite.
class DriverStopTarget {
  const DriverStopTarget({
    required this.stopId,
    required this.tripId,
    required this.sourceName,
    required this.stopOrder,
    required this.totalStops,
    required this.materialMode,
    required this.items,
    required this.isLastOpen,
  });

  final String stopId;
  final String tripId;
  final String sourceName;
  final int stopOrder;
  final int totalStops;
  final String materialMode;

  /// A Sorted stop's items in form order: `id`, `name`, `unit_code`.
  final List<Map<String, Object?>> items;

  /// No other stop of the trip is still open.
  final bool isLastOpen;

  bool get isMixed => materialMode != 'SORTED';

  static Future<DriverStopTarget?> load(
    OutboundLiveSession session,
    String stopId,
  ) async {
    final row = await session.queries.driverStop(stopId);
    if (row == null) return null;
    final tripId = row['trip_id']! as String;
    final stops = await loadDriverTripStops(session, tripId);
    final open = stops.where((s) => s.isOpen && s.id != stopId);
    return DriverStopTarget(
      stopId: stopId,
      tripId: tripId,
      sourceName: row['source_name'] as String? ?? '',
      stopOrder: (row['stop_order'] as num?)?.toInt() ?? 0,
      totalStops: stops.length,
      materialMode: row['material_mode'] as String? ?? 'MIXED',
      items: await session.queries.sortedFormItems(stopId),
      isLastOpen: open.isEmpty,
    );
  }
}

/// One item line of a Sorted form, with its local photo paths.
class DriverEntryLineInput {
  const DriverEntryLineInput({
    required this.itemId,
    required this.itemName,
    required this.unit,
    required this.quantity,
    this.photoPaths = const [],
  });

  final String itemId;
  final String itemName;
  final String unit;
  final double quantity;
  final List<String> photoPaths;
}

/// Records a stop (outbound doc, Driver writes · Record a stop): stages the
/// photos in the photo queue, then queues `PUT /pickup-entries/{id}` with the
/// stop and trip changes in one transaction. Returns false when the phone's
/// checks refused it (the message is shown).
Future<bool> recordDriverStop(
  BuildContext context, {
  required DriverStopTarget target,
  required StopOutcome outcome,
  List<DriverEntryLineInput> lines = const [],
  double? totalKg,
  List<String> photoPaths = const [],
  String? zeroKgReason,
  String? sourceCancelReason,
  String? note,
}) async {
  final session = OutboundLiveSession.of(context);
  if (session == null) return false;
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    Future<String> stage(String path, String field) => session.stagePhoto(
      localPath: path,
      ownerTable: 'trip_stops',
      ownerId: target.stopId,
      field: field,
      purpose: 'PICKUP_PHOTO',
    );
    final photoIds = <String>[
      for (final path in photoPaths) await stage(path, 'material'),
    ];
    final entryLines = <EntryLine>[];
    for (final line in lines) {
      String? linePhoto;
      if (line.photoPaths.isNotEmpty) {
        linePhoto = await stage(line.photoPaths.first, 'item');
        // Every item photo also counts as a material and scale photo.
        photoIds.add(linePhoto);
        for (final extra in line.photoPaths.skip(1)) {
          photoIds.add(await stage(extra, 'material'));
        }
      }
      entryLines.add(
        EntryLine(
          itemId: line.itemId,
          itemName: line.itemName,
          quantity: line.quantity,
          unit: line.unit,
          photoId: linePhoto,
        ),
      );
    }
    final trimmed = note?.trim();
    await session.change(
      () => session.writes.recordStop(
        StopEntry(
          entryId: session.newId(),
          tripId: target.tripId,
          duePickupId: target.stopId,
          outcome: outcome,
          recordedAt: session.clock.now,
          lines: entryLines,
          totalKg: totalKg,
          photoIds: photoIds.toSet().toList(),
          zeroKgReason: zeroKgReason,
          sourceCancelReason: sourceCancelReason,
          note: trimmed == null || trimmed.isEmpty ? null : trimmed,
        ),
      ),
    );
    return true;
  } on LocalWriteValidationException catch (error) {
    messenger?.showSnackBar(SnackBar(content: Text(error.message)));
    return false;
  }
}
