import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'profile_assets.dart';
import 'package:eerl_app/features/local_data/model/eerl_models.dart';

Future<void> showAssignedCentersDialog(
  BuildContext context, {
  required List<CenterModel> centers,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: false,
  barrierLabel: context.l10n.profileAssignedCentersTitle,
  barrierColor: Colors.black.withValues(alpha: .6),
  transitionDuration: const Duration(milliseconds: 180),
  pageBuilder: (context, _, _) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    child: _AssignedCentersDialog(centers: centers),
  ),
  transitionBuilder: (_, animation, _, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: Tween<double>(begin: .96, end: 1).animate(animation),
      child: child,
    ),
  ),
);

class _AssignedCentersDialog extends StatelessWidget {
  const _AssignedCentersDialog({required this.centers});
  final List<CenterModel> centers;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: const Key('profile-assigned-centers-dialog'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 335),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    ProfileAssets.assignedCenters,
                    width: 119.258,
                    height: 81.924,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.profileAssignedCentersTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.boldH6_20.copyWith(
                      color: AppColors.neutral950,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var index = 0; index < centers.length; index++) ...[
                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 35),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '•  ${centers[index].name}',
                        style: AppTextStyles.mediumSH8_14.copyWith(
                          color: AppColors.neutral950,
                        ),
                      ),
                    ),
                    if (index != centers.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
              Positioned(
                right: 0,
                top: 0,
                child: InkWell(
                  key: const Key('profile-assigned-centers-close'),
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: SvgPicture.asset(
                    ProfileAssets.syncClose,
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
