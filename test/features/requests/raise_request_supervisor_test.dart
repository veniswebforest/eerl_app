import 'package:eerl_app/features/local_data/model/eerl_models.dart';
import 'package:eerl_app/features/requests/view/raise_request_screen.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:eerl_app/shared/widgets/supervisor_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildScreen({ProfileModel? profile}) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RaiseRequestScreen(
          profileLoader: () async =>
              profile ??
              const ProfileModel(
                userName: 'Agent Name',
                supervisorName: 'Kiran Rathod',
                supervisorPhone: '9876543210',
                supervisorPhotoUrl: 'https://example.com/kiran.jpg',
              ),
        ),
      );

  testWidgets(
    'displays supervisor photo and TO : {name} without adding (Supervisor)',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          profile: const ProfileModel(
            userName: 'Agent Name',
            supervisorName: 'Kiran Rathod',
            supervisorPhone: '9876543210',
            supervisorPhotoUrl: 'https://example.com/kiran.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('request-supervisor-card')), findsOneWidget);
      expect(find.text('TO : Kiran Rathod'), findsOneWidget);
      expect(find.textContaining('(Supervisor)'), findsNothing);
      expect(find.byType(SupervisorAvatar), findsOneWidget);

      final avatar = tester.widget<SupervisorAvatar>(
        find.byType(SupervisorAvatar),
      );
      expect(avatar.name, 'Kiran Rathod');
      expect(avatar.photoUrl, 'https://example.com/kiran.jpg');
    },
  );

  testWidgets(
    'displays initials circle when supervisor has no photo',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          profile: const ProfileModel(
            userName: 'Agent Name',
            supervisorName: 'Kiran Rathod',
            supervisorPhone: '9876543210',
            supervisorPhotoUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TO : Kiran Rathod'), findsOneWidget);
      expect(find.text('KR'), findsOneWidget);
    },
  );

  testWidgets(
    'displays "No supervisor set: ask your admin to set one." when supervisor_name is null',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          profile: const ProfileModel(
            userName: 'Agent Name',
            supervisorName: null,
            supervisorPhone: null,
            supervisorPhotoUrl: null,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('No supervisor set: ask your admin to set one.'),
        findsOneWidget,
      );
      expect(find.textContaining('TO :'), findsNothing);
    },
  );
}
