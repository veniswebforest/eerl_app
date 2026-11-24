import 'package:flutter/material.dart';

enum DriverStopStatus { pending, skipped }

enum DriverPickupType { sorted, mixed }

@immutable
class DriverPickupStop {
  const DriverPickupStop({
    required this.name,
    required this.materialType,
    required this.location,
    required this.schedule,
    required this.status,
    required this.pickupType,
    this.useRegularScheduleStyle = false,
  });

  final String name;
  final String materialType;
  final String location;
  final String schedule;
  final DriverStopStatus status;
  final DriverPickupType pickupType;
  final bool useRegularScheduleStyle;
}
