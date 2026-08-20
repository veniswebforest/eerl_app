import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widget/collection_drafts.dart';
import '../widget/collection_types.dart';
import '../widget/day_closure.dart';
import '../widget/home_app_bar.dart';
import '../widget/home_bottom_nav.dart';
import '../widget/online_status_banner.dart';
import '../widget/quick_actions.dart';
import '../widget/todays_summary.dart';
import '../widget/zone_selector.dart';

/// Home screen — composes all home widgets from the widget/ folder.
///
/// Each section is a separate, focused widget for maintainability.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBody: true,
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary400,
                      AppColors.primary200,
                      AppColors.cool50,
                    ],
                    stops: [0, .58, 1],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          20,
                        ),
                        child: const Column(
                          children: [
                            HomeAppBar(),
                            SizedBox(height: 24),
                            ZoneSelector(),
                            SizedBox(height: 12),
                            OnlineStatusBanner(),
                            SizedBox(height: 24),
                            TodaysSummary(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      140,
                    ),
                    child: const Column(
                      children: [
                        QuickActions(),
                        SizedBox(height: 24),
                        CollectionTypes(),
                        SizedBox(height: 24),
                        CollectionDrafts(),
                        SizedBox(height: 24),
                        DayClosure(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: const HomeBottomNav(),
        );
      },
    );
  }
}
