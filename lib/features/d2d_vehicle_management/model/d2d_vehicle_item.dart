enum D2dVehicleStatus { active, deactivated }

class D2dVehicleItem {
  const D2dVehicleItem({required this.number, required this.status});

  final String number;
  final D2dVehicleStatus status;

  D2dVehicleItem copyWith({D2dVehicleStatus? status}) =>
      D2dVehicleItem(number: number, status: status ?? this.status);
}
