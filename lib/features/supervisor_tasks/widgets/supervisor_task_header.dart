import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'supervisor_task_assets.dart';

class SupervisorTaskHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const SupervisorTaskHeader({
    super.key,
    required this.title,
    this.backAsset = SupervisorTaskAssets.back,
  });

  final String title;
  final String backAsset;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 68,
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: AppColors.backgroundColor,
    leadingWidth: 68,
    leading: Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Center(
        child: Material(
          color: AppColors.primary500,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const Key('supervisor-task-back'),
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Center(
                child: SvgPicture.asset(backAsset, width: 20, height: 20),
              ),
            ),
          ),
        ),
      ),
    ),
    titleSpacing: 4,
    title: Text(
      title,
      style: AppTextStyles.semiboldH6_20.copyWith(color: AppColors.neutral950),
    ),
  );
}
