import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import '../widgets/collection_drafts.dart';
import '../widgets/collection_types.dart';
import '../widgets/day_closure.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_drawer.dart';
import '../widgets/online_status_banner.dart';
import '../widgets/quick_actions.dart';
import '../widgets/todays_summary.dart';
import '../widgets/zone_selector.dart';

/// Home screen — composes all home widgets from the widget/ folder.
///
/// Each section is a separate, focused widget for maintainability.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onWalletTap, this.onDrawerChanged});

  final VoidCallback? onWalletTap;
  final ValueChanged<bool>? onDrawerChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth < 360 ? 16.0 : 20.0;

        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBody: true,
          drawer: HomeDrawer(onWalletTap: onWalletTap),
          onDrawerChanged: onDrawerChanged,
          drawerScrimColor: Colors.black.withValues(alpha: 0.6),
          body: Stack(
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
                      AppColors.primary200,
                      AppColors.primary100,
                      AppColors.cool50,
                      AppColors.cool50,
                    ],
                    stops: [0, .25, .45, 1],
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
                        child: ListView(
                          children: [
                            HomeAppBar(),
                            SizedBox(height: 24),
                            ZoneSelector(),
                            SizedBox(height: 12),
                            OnlineStatusBanner(),
                            SizedBox(height: 24),
                            TodaysSummary(),
                            SizedBox(height: 24),

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
                ),
              ),
              // Center(
              //   child: ConstrainedBox(
              //     constraints: const BoxConstraints(maxWidth: 640),
              //     child: Padding(
              //       padding: EdgeInsets.fromLTRB(
              //         horizontalPadding,
              //         24,
              //         horizontalPadding,
              //         140,
              //       ),
              //       child: const Column(
              //         children: [
              //
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }
}
