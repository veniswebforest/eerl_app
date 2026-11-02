import 'package:eerl_app/features/d2d_vehicle_management/view/d2d_vehicle_management_screen.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _center = CenterModel(id: 'center-1', name: 'Bhatar Center');

Widget _appWithVehicles(List<VehicleModel> vehicles) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: D2dVehicleManagementScreen(
    loadCenters: () async => const [_center],
    loadActiveCenterId: () async => _center.id,
    loadVehicles: (_) async => vehicles,
  ),
);

void main() {
  testWidgets('renders the Figma vehicle management list state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(375, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const vehicles = [
      VehicleModel(
        id: 'vehicle-1',
        centerId: 'center-1',
        plateNumber: 'GJ-05-BX-1234',
        isActive: true,
        syncState: 'synced',
      ),
      VehicleModel(
        id: 'vehicle-2',
        centerId: 'center-1',
        plateNumber: 'GJ-05-AB-4567',
        isActive: true,
        syncState: 'synced',
      ),
      VehicleModel(
        id: 'vehicle-3',
        centerId: 'center-1',
        plateNumber: 'GJ-05-BX-7890',
        isActive: true,
        syncState: 'synced',
      ),
      VehicleModel(
        id: 'vehicle-4',
        centerId: 'center-1',
        plateNumber: 'GJ-05-ZZ-9999',
        isActive: false,
        syncState: 'synced',
      ),
    ];

    await tester.pumpWidget(_appWithVehicles(vehicles));
    await tester.pumpAndSettle();

    expect(find.text('D2D Vehicle Management'), findsOneWidget);
    expect(find.text('Assign Target Agent / Center'), findsOneWidget);
    expect(find.text('Active (3)'), findsOneWidget);
    expect(find.text('Deactivated (1)'), findsOneWidget);
    expect(find.text('Search Here...'), findsOneWidget);
    expect(find.text('GJ-05-BX-1234'), findsOneWidget);
    expect(find.text('GJ-05-AB-4567'), findsOneWidget);
    expect(find.text('GJ-05-BX-7890'), findsOneWidget);
    expect(find.byKey(const Key('d2d-add-vehicle-button')), findsOneWidget);
    expect(find.byKey(const Key('d2d-vehicle-empty-state')), findsNothing);

    expect(
      tester.getSize(find.byKey(const ValueKey('d2d-vehicle-GJ-05-BX-1234'))),
      const Size(335, 98),
    );
  });

  testWidgets('renders the exact Figma empty vehicle state', (tester) async {
    tester.view.physicalSize = const Size(375, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_appWithVehicles(const []));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('d2d-vehicle-empty-state')), findsOneWidget);
    expect(find.text('No Vehicle Added Yet'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const Key('d2d-vehicle-empty-illustration'))),
      const Size(285, 127),
    );
    expect(find.byKey(const Key('d2d-add-vehicle-button')), findsOneWidget);
  });
}
