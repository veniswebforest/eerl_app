import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF5),
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: const [
                  ZoneSelector(),
                  SizedBox(height: 12),
                  OnlineStatusBanner(),
                  SizedBox(height: 16),
                  TodaysSummary(),
                  SizedBox(height: 20),
                  QuickActions(),
                  SizedBox(height: 20),
                  CollectionTypes(),
                  SizedBox(height: 20),
                  CollectionDrafts(),
                  SizedBox(height: 20),
                  DayClosure(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(),
    );
  }
}


