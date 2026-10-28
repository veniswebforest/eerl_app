import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/features/notifications/widgets/empty_notifications_view.dart';
import 'package:eerl_app/l10n/generated/app_localizations.dart';
import 'package:eerl_app/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('matches the Figma empty notification state', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(375, 812);
    tester.platformDispatcher.textScaleFactorTestValue = 1;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          appBar: const CustomAppBar(title: 'Notifications'),
          body: const EmptyNotificationsView(
            title: 'All Caught Up!',
            message:
                "You're all caught up! Check back later for updates, task "
                'status, and system alerts.',
          ),
        ),
      ),
    );

    final content = find.byKey(const Key('notification-empty-content'));
    final illustration = find.byKey(
      const Key('notification-empty-illustration'),
    );

    expect(find.text('All Caught Up!'), findsOneWidget);
    expect(find.textContaining("You're all caught up!"), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(3));
    expect(tester.getSize(content), const Size(335, 325.466));
    expect(tester.getSize(illustration), const Size(181.061, 217.466));
    expect(tester.getTopLeft(content).dy, closeTo(243.267, 0.01));

    final title = tester.widget<Text>(
      find.byKey(const Key('notification-empty-title')),
    );
    final message = tester.widget<Text>(
      find.byKey(const Key('notification-empty-message')),
    );
    expect(title.style?.fontSize, 24);
    expect(title.style?.fontWeight, FontWeight.w700);
    expect(title.style?.height, 28 / 24);
    expect(message.style?.fontSize, 14);
    expect(message.style?.fontWeight, FontWeight.w500);
    expect(message.style?.height, 18 / 14);
    expect(message.style?.color, AppColors.neutral700);
  });
}
